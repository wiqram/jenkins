FROM jenkins/inbound-agent:latest

# run updates as root
USER root

# Update & Upgrade OS
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install curl
RUN apt-get -y install wget
RUN curl --version
RUN apt-get -y install software-properties-common
### Docker and docker compose prerequisites
RUN apt-get -y install gnupg
RUN apt-get -y install ca-certificates
RUN apt-get -y install lsb-release
RUN apt-get -y update
#Download K8s
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#Download go
#RUN add-apt-repository ppa:longsleep/golang-backports
#RUN apt-get update
#RUN apt search golang-go
#RUN apt -y install golang-go
#RUN go version

#Download python and pip
#RUN apt-get -y install python3
#RUN python3 --version
#RUN apt -y install python3-pip

#RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
#Download NPM
#RUN apt -y install npm
#RUN npm -v

#install proto compilers
#RUN apt install -y protobuf-compiler
#RUN protoc --version
#RUN apt install -y golang-goprotobuf-dev
#RUN npm install -g grpc-tools
#RUN go get google.golang.org/grpc
#RUN go get -u github.com/golang/protobuf/proto
#RUN go get -u github.com/golang/protobuf/protoc-gen-go
#RUN go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway
#RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
#RUN python3 -m pip install grpcio
#RUN python3 -m pip install grpcio-tools
# Add Maven
#RUN apt-get -y install maven --no-install-recommends

# Add docker
#RUN curl -sSL https://get.docker.com/ | sh

# Create docker group
RUN addgroup docker
# Add docker compose
#RUN apt-get install -y docker-compose
#RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
#RUN add-apt-repository \
#     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#     $(lsb_release -cs) \
#     stable"
#RUN apt-get install -y docker docker-compose-plugin
### Download the docker gpg file to Ubuntu
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

### Add Docker and docker compose support to the Ubuntu's packages list
RUN echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN apt-get update

#RUN service docker start

#RUN systemctl start docker

### Install docker and docker compose on Ubuntu
RUN apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
RUN docker compose version
RUN docker -v
#RUN usermod -aG docker root
RUN usermod -aG docker jenkins
#RUN service docker start
#RUN curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#RUN chmod +x /usr/local/bin/docker-compose

# Add Telnet
RUN apt-get -y install telnet

# close root access
USER jenkins