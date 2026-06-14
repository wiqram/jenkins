# Vault secrets — Jenkins' role

This Jenkins instance **runs** the secret-sync automation; it is not itself an
app whose secrets live in Vault. The `vault-secrets-sync` pipeline
(`wiqram/vault` → `ci/Jenkinsfile`) reconciles each app's declarative secret
manifests into the shared **HashiCorp Vault** on every push.

## What lives where

- **Pipeline + reconciler:** `wiqram/vault` (`ci/Jenkinsfile`, `vault-sync.sh`,
  `scripts/`). The job is created/updated by `scripts/setup-jenkins-pipeline.sh`.
- **Credentials this job consumes (configured in Jenkins):**
  - `sops-age-key` — age private key for SOPS decryption
  - `vault-approle-id-<app>` / `vault-approle-secret-<app>` — per-app, write-scoped
    to `kv/<app>/*` (not the root token)
  - `kubeconfig-file` — for the post-sync `kubectl rollout restart`
- A GitHub **webhook** → `/github-webhook/` triggers the job; `changed-apps.sh`
  makes it sync only the apps whose `apps/<app>/` manifests changed.

## Adding or changing an app's secret

Do **not** edit Vault by hand from here. Follow the **canonical workflow**:
**https://github.com/wiqram/vault/blob/main/docs/adding-secrets.md**

The flow is: edit the app manifest → `sops`-encrypt secrets → push → this job
validates, syncs `kv/<app>/*`, and restarts the consumers.
