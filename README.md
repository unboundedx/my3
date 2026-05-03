# Trojan Docker Server

This repository provides a Docker-based `trojan` server with:

- Password preset to `5512097`
- Self-signed TLS certificate generated automatically
- Certificate validity set to 10 years
- Auto-generated `trojan` config and HTTPS fallback page
- One-command installer for new servers
- GitHub Actions validation on push / pull request
- Auto-update script for servers that pull from GitHub
- Docker restart policy so containers return after server reboot

## Quick start

```bash
chmod +x scripts/init.sh
chmod +x scripts/install.sh
chmod +x scripts/update.sh
./scripts/init.sh
docker-compose up -d
```

## Files

- `docker-compose.yml`: starts `trojan` and an `nginx` fallback page
- `scripts/install.sh`: installs Docker, installs `docker-compose`, clones or updates the repo, generates config, and starts the stack
- `scripts/init.sh`: generates `/certs/server.crt`, `/certs/server.key`, `config/config.json`, and `www/index.html`
- `scripts/update.sh`: pulls the latest Git commit and refreshes containers, with both `docker compose` and `docker-compose` support
- `deploy/trojan-auto-update.service` and `deploy/trojan-auto-update.timer`: optional systemd auto-pull example
- `.github/workflows/compose-validate.yml`: runs `docker compose config` in GitHub Actions

## One-command install on a new server

If the server can access your GitHub repo directly, run:

```bash
curl -fsSL https://raw.githubusercontent.com/unboundedx/my3/main/scripts/install.sh -o install.sh
chmod +x install.sh
PASSWORD=5512097 SERVER_NAME=your-domain.example ./install.sh
```

The installer will:

- install `git`, `docker`, and `openssl`
- start and enable Docker on boot
- install `docker-compose` if missing
- clone or update this repo from GitHub
- generate the self-signed certificate and `trojan` config
- start the stack
- optionally enable the auto-update timer

## Optional environment variables

You can override these when generating files:

```bash
PASSWORD=5512097 SERVER_NAME=your-domain.example CERT_DAYS=3650 ./scripts/init.sh
```

For the full installer:

```bash
REPO_URL=https://github.com/unboundedx/my3.git \
INSTALL_DIR=$HOME/my3 \
PASSWORD=5512097 \
SERVER_NAME=your-domain.example \
CERT_DAYS=3650 \
ENABLE_AUTO_UPDATE=1 \
./install.sh
```

## Upload to GitHub

1. Initialize the repository:

   ```bash
   git init
   git add .
   git commit -m "Add Trojan Docker server"
   ```

2. Add your GitHub remote and push:

   ```bash
   git remote add origin <your-github-repo-url>
   git branch -M main
   git push -u origin main
   ```

## Auto-pull from GitHub on the server

After cloning this repo to your server, you can refresh it with:

```bash
./scripts/update.sh
```

The script performs:

```bash
git pull --ff-only
./scripts/init.sh
docker-compose pull
docker-compose up -d
```

You can run it with cron, systemd timers, or a GitHub webhook receiver if you want unattended updates.

## Optional systemd timer

If your server uses systemd, copy the unit files and update `WorkingDirectory` to your clone path:

```bash
sudo cp deploy/trojan-auto-update.service /etc/systemd/system/
sudo cp deploy/trojan-auto-update.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now trojan-auto-update.timer
```

## Notes

- `certs/` and `config/` are ignored by Git because they are generated locally.
- Self-signed certificates require the client side to trust the generated certificate manually.
- If you want other machines to `git clone` and run directly, keep the init script in the repo and let each target machine generate its own cert locally.
- Containers use `restart: unless-stopped`, so with Docker enabled on boot they will return automatically after server reboot.
