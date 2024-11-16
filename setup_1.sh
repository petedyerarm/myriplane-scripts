#!/bin/bash

echo "PATH=\"$PATH:/home/ubuntu/go/bin\"" >> /home/ubuntu/.profile
echo "source <(kubectl completion bash)" >> /home/ubuntu/.profile

sudo apt-get update
sudo apt-get install -y software-properties-common

sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl bash-completion git
sudo apt-get install -y dnsutils gnupg lsb-release net-tools software-properties-common ssh
sudo apt-get install -y golang-go
sudo apt-get install -y gpg
sudo apt-get install -y apache2-utils

echo "Set up kubernetes repo"
if [[ ! -f /etc/apt/keyrings/kubernetes-apt-keyring-1.29.gpg ]]; then
    curl -fsSL -o Release.key https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key
    sudo gpg --dearmor --no-tty --batch -o /etc/apt/keyrings/kubernetes-apt-keyring-1.29.gpg Release.key
fi
if [[ ! -f /etc/apt/sources.list.d/kubernetes-1.29.list ]]; then
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring-1.29.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes-1.29.list
fi

sudo apt-get update
sudo apt-get install -y  kubectl

echo "Setup Docker"

sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker "$USER"

echo "Setup Protobuf"
sudo apt-get update && sudo apt-get install -y protobuf-compiler make
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.21.0
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.21.0

echo "Setup kompose"
curl -L https://github.com/kubernetes/kompose/releases/download/v1.26.1/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv kompose /usr/local/bin/

echo "Setup /etc/hosts"
echo "127.0.0.1 loginmyriplane loginmyriplane.local dex" | sudo tee -a /etc/hosts
echo "127.0.0.1 etcd0" | sudo tee -a /etc/hosts
echo "127.0.0.1 etcd1" | sudo tee -a /etc/hosts
echo "127.0.0.1 etcd2" | sudo tee -a /etc/hosts

echo "mkcert and myriplane"
git clone https://github.com/FiloSottile/mkcert
git clone http://github.com/IzumaNetworks/myriplane


cd mkcert/ || exit
go build
./mkcert -install
cd ../myriplane || exit
../mkcert/mkcert loginmyriplane loginmyriplane.local

