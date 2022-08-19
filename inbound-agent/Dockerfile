FROM jenkins/inbound-agent

# run updates as root
USER root

# Create docker group
#RUN addgroup docker

# Update & Upgrade OS
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install curl
RUN apt-get -y install wget
RUN curl --version
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Add Maven
RUN apt-get -y install maven --no-install-recommends

# Add docker
#RUN curl -sSL https://get.docker.com/ | sh
#RUN usermod -aG docker jenkins

# Add docker compose
#RUN curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#RUN chmod +x /usr/local/bin/docker-compose

# Add Telnet
RUN apt-get -y install telnet

# close root access
USER jenkins