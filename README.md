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

For a step-by-step command guide, see `USAGE.md`.

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
- `docker-compose.build.yml`: optional override to build `trojan` locally from your mirrored source repo
- `scripts/install.sh`: installs Docker, installs `docker-compose`, clones or updates the repo, generates config, and starts the stack
- `scripts/bootstrap-trojan-source.sh`: clones or updates your mirrored `trojan` source repo into `vendor/trojan-upstream`
- `scripts/init.sh`: generates `/certs/server.crt`, `/certs/server.key`, `config/config.json`, `www/index.html`, and persists settings in `.trojan.env`
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

If you want an interactive installer that prompts for the password and public IP or domain, run:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

It will prompt like this:

```text
Enter Trojan password [5512097]:
Enter public IP or domain [current-hostname]:
```

The installer will:

- install `git`, `docker`, and `openssl`
- start and enable Docker on boot
- install `docker-compose` if missing
- clone or update this repo from GitHub
- generate the self-signed certificate and `trojan` config
- start the stack
- optionally enable the auto-update timer

## Use your own mirrored Trojan source

The default deployment still uses `trojangfw/trojan:latest` so existing servers keep working.

If you want to stop depending on the original source repository and Docker image, use your own mirrored source repo:

```bash
chmod +x scripts/bootstrap-trojan-source.sh
./scripts/bootstrap-trojan-source.sh
docker-compose -f docker-compose.yml -f docker-compose.build.yml up -d --build
```

This clones `https://github.com/unboundedx/trojan-upstream.git` into `vendor/trojan-upstream` and builds the `trojan` image locally on your server.

You can also override the source repo:

```bash
SOURCE_REPO=https://github.com/unboundedx/trojan-upstream.git ./scripts/bootstrap-trojan-source.sh
```

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

## Change password later

Edit `.trojan.env` or rerun `init.sh` with a new password:

```bash
PASSWORD=new-password SERVER_NAME=your-domain.example ./scripts/init.sh
docker-compose up -d
```

After the first run, the chosen values are stored in `.trojan.env`, so future `./scripts/update.sh` runs keep using the same password and server name.

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
- `.trojan.env` is ignored by Git because it stores the local password and server identity.
- Self-signed certificates require the client side to trust the generated certificate manually.
- If you want other machines to `git clone` and run directly, keep the init script in the repo and let each target machine generate its own cert locally.
- Containers use `restart: unless-stopped`, so with Docker enabled on boot they will return automatically after server reboot.
