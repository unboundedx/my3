# Usage Guide

This document provides the exact commands to deploy and maintain this Trojan Docker server.

## 1. Deploy on a new Amazon Linux 2023 server

### Option A: interactive install

Use this when you want the script to ask for the Trojan password and your public IP or domain.

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

The installer will prompt:

```text
Enter Trojan password [5512097]:
Enter public IP or domain [current-hostname]:
```

### Option B: non-interactive install

Use this when you already know the password and server address.

```bash
sudo dnf update -y
sudo dnf install -y git docker openssl
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
newgrp docker
git clone https://github.com/unboundedx/my3.git
cd my3
chmod +x scripts/install.sh
PASSWORD=5512097 SERVER_NAME=your-public-ip-or-domain ./scripts/install.sh
```

Example:

```bash
PASSWORD=5512097 SERVER_NAME=52.69.3.188 ./scripts/install.sh
```

## 2. Check service status

```bash
cd ~/my3
docker-compose ps
docker-compose logs -f trojan
docker-compose logs -f fallback
```

## 3. Update from GitHub

```bash
cd ~/my3
./scripts/update.sh
```

This does:

```bash
git pull --ff-only
./scripts/init.sh
docker-compose pull
docker-compose up -d
```

## 4. Change the Trojan password later

```bash
cd ~/my3
PASSWORD=new-password SERVER_NAME=your-public-ip-or-domain ./scripts/init.sh
docker-compose up -d
```

The selected values are saved in `.trojan.env`, so future updates keep using the same password and server name.

## 5. Use your own mirrored Trojan source repo

The default deployment uses `trojangfw/trojan:latest`.

If you want to build from your own mirrored source repository instead:

```bash
cd ~/my3
chmod +x scripts/bootstrap-trojan-source.sh
./scripts/bootstrap-trojan-source.sh
docker-compose -f docker-compose.yml -f docker-compose.build.yml up -d --build
```

This clones:

```text
https://github.com/unboundedx/trojan-upstream.git
```

into:

```text
vendor/trojan-upstream
```

and builds the image locally.

## 6. Verify auto-start after reboot

Docker is enabled on boot and the containers use `restart: unless-stopped`.

Check that with:

```bash
systemctl is-enabled docker
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' trojan-server
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' trojan-fallback
systemctl status trojan-auto-update.timer --no-pager
```

## 7. Client parameters

For a standard Trojan client, use:

- Server: your public IP or domain
- Port: `443`
- Password: your configured password
- TLS: enabled
- SNI: usually leave empty when using self-signed IP-based certs, or set it to the same domain used in `SERVER_NAME`
- Certificate verification: disable it, or import `certs/server.crt`

## 8. Self-signed certificate note

This project uses a self-signed certificate by default. Many clients will require one of these:

- disable certificate verification
- import and trust `~/my3/certs/server.crt`
