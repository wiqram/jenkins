# Registry addressing — why Jenkins uses the public URL, and when that stops being optional

**Short version:** always reference the registry as
`container-registry.traderyolo.com`. The internal address `172.16.238.2:5000` is faster and
is a **single-cluster optimisation only**. The moment Jenkins or the registry lives in a
different cluster from the other, the internal address stops working and the public URL is
the only thing left.

Written 2026-08-18 after measuring the difference and deciding *not* to take it.

## The two addresses

Both reach the **same blob store**. Measured 2026-08-18, same 8.6 MB layer, from the
minikube node:

| route | throughput |
|---|---|
| `http://172.16.238.2:5000` (internal) | **~900 MB/s** |
| `https://container-registry.traderyolo.com` (public) | **~15 MB/s** — 60x slower |

The public name resolves to this host's **public IP**, so traffic leaves via the 1GbE LAN
NIC, NATs at the router and comes back through nginx. That hairpin is the whole 60x.

## Why Jenkins keeps the slow one anyway

### 1. `172.16.238.2` only exists inside this one cluster, on this one host

It is the minikube node's address on the `5million` docker network. It is not routable
from another cluster, another host, or a cloud runner. Today Jenkins, the registry and
every workload that pulls are **co-located in one minikube cluster on one box**, so it
happens to work. That co-location is an assumption, not a guarantee.

**If Jenkins is ever deployed to a different cluster than the container registry — or the
registry is moved out from under Jenkins — every internal-IP reference breaks and must
revert to `container-registry.traderyolo.com`.** That is the fallback, and it is not a
workaround: the public URL is the only address that survives the split, which is exactly
why it is the default now.

Jenkins has two specific stakes in this that are easy to miss:

- **The agent image is pulled from this registry.** The pod template's `jnlp` container is
  `container-registry.traderyolo.com/jenkins-inbound-agent-vik:cloud`. If that reference
  ever pointed at the internal address and Jenkins moved clusters, **no agent could start
  at all** — which means no pipeline could run, including the one that would fix it. Keep
  it on the public name.
- **Pushes go through the HOST's docker socket, which is a same-*host* assumption, not just
  a same-*cluster* one.** Agent pods mount `/var/run/docker.sock` from the node via
  hostPath and run a `docker:` sidecar, so `docker push` in a Jenkinsfile executes against
  the host daemon. Moving Jenkins to another cluster breaks that binding independently of
  the registry address, and the replacement (kaniko, buildkit, a remote builder) has to be
  designed at the same time. Do not treat "swap the registry URL" as the whole migration.

There is already a fossil of this pattern in the platform: `start-scratch.sh` around line
268 carries a commented-out
`docker image inspect 172.16.238.2:5000/jenkins-inbound-agent-vik:cloud` next to the live
lines that build and push to `container-registry.traderyolo.com`. That is the old internal
form, left behind. Do not revive it.

### 2. The hairpin is load-bearing for security

In-cluster pulls arrive at nginx as `213.48.246.115`, and that is what passes the
**SEC-EDGE-ALLOWLIST** source allowlist. nginx returns **403** to a docker-bridge source
address (verified 2026-08-18 by probing NPM directly at `172.16.238.10`). So the slow path
is also the *authorised* path.

The allowlist must **not** be widened to `172.16.0.0/16` to work around this — that trusts
every container on the host, which is the SEC-LOKI-NODEPORT exposure it exists to prevent.
See the nginx repo's `docs/edge-exposure.md`.

### 3. It costs almost nothing on a real deploy

Layers are already cached on the node, so a redeploy only re-resolves the manifest. The
kubelet's own figure for a real `rollout restart` of a 288 MB image was **150 ms** — 0.7%
of a 24.8s rollout. The 60x only appears against a **cold** store: a fresh bootstrap or a
DR restore, where the node pulls all ~6.7 GB. Deploy time here is dominated by readiness
probes, not by image transfer.

## If you do decide to optimise it later

Two traps, both already paid for:

1. **The kubelet pulls via cri-dockerd → dockerd, not containerd.** Check with
   `kubectl get node minikube -o jsonpath='{.status.nodeInfo.containerRuntimeVersion}'`
   (returns `docker://…`) and `ctr namespace ls` on the node (only `moby`, no `k8s.io`). A
   containerd mirror in `/etc/containerd/certs.d/` therefore does **nothing** for pod
   pulls, however well it benchmarks with `ctr` — this was built, measured at
   30.9s → 6.0s on a cold 381 MiB pull, found inert, and reverted on 2026-08-18. Validate
   any pull-path change with `docker pull` on the node or a real rollout, never with `ctr`.
2. **Docker has no per-registry mirror for non-Hub registries.** `registry-mirrors` in
   `daemon.json` only applies to Docker Hub. A local shortcut needs `/etc/hosts` plus a
   plain-HTTP listener on `:443` plus an `insecure-registries` entry, or changed image
   references — and every one of those is a thing that must be found and undone on a
   cluster split.

Full write-up, including the measurements and the rejected alternatives:
STEP0 `docs/architecture.md` §"Image Registry" → "The internal address is a SINGLE-CLUSTER
optimisation", and STEP0 `CLAUDE.md` under "Conventions & facts to respect".
