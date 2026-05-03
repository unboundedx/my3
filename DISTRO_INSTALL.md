# Linux Distribution Install Commands

This document lists full deployment commands for several Linux distributions.

All examples assume the `my3` repository is public:

```bash
git clone https://github.com/unboundedx/my3.git
```

If your repository is private, replace the clone URL with your SSH or token-based URL.

## Amazon Linux 2023

```bash
sudo dnf update -y
sudo dnf install -y git docker openssl
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
newgrp docker
git clone https://github.com/unboundedx/my3.git
cd my3
chmod +x scripts/install.sh
./scripts/install.sh
```

## Amazon Linux 2

```bash
sudo yum update -y
sudo yum install -y git openssl
sudo amazon-linux-extras install docker -y
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
newgrp docker
git clone https://github.com/unboundedx/my3.git
cd my3
chmod +x scripts/install.sh
./scripts/install.sh
```

## Ubuntu 24.04 / 22.04

```bash
sudo apt update
sudo apt install -y ca-certificates curl git openssl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
git clone https://github.com/unboundedx/my3.git
cd my3
chmod +x scripts/install.sh
./scripts/install.sh
```

## Debian 12 / 11

```bash
sudo apt update
sudo apt install -y ca-certificates curl git openssl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
git clone https://github.com/unboundedx/my3.git
cd my3
chmod +x scripts/install.sh
./scripts/install.sh
```

## CentOS Stream 9 / Rocky Linux 9 / AlmaLinux 9

```bash
sudo dnf -y update
sudo dnf -y install git openssl dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
git clone https://github.com/unboundedx/my3.git
cd my3
chmod +x scripts/install.sh
./scripts/install.sh
```

## RHEL 9 / 8

```bash
sudo dnf -y update
sudo dnf -y install git openssl dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
git clone https://github.com/unboundedx/my3.git
cd my3
chmod +x scripts/install.sh
./scripts/install.sh
```

## Fedora 42 / 43 / 44

```bash
sudo dnf -y update
sudo dnf -y install git openssl dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
git clone https://github.com/unboundedx/my3.git
cd my3
chmod +x scripts/install.sh
./scripts/install.sh
```

## Non-interactive install example

Use this on any supported distribution after the repository is cloned:

```bash
PASSWORD=12345678 SERVER_NAME=your-public-ip-or-domain ./scripts/install.sh
```
