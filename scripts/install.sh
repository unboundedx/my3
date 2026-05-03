#!/usr/bin/env sh

set -eu

REPO_URL="${REPO_URL:-https://github.com/unboundedx/my3.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/my3}"
DEFAULT_PASSWORD="5512097"
DEFAULT_SERVER_NAME="$(hostname 2>/dev/null || echo trojan-server)"
PASSWORD="${PASSWORD:-}"
SERVER_NAME="${SERVER_NAME:-}"
CERT_DAYS="${CERT_DAYS:-3650}"
ENABLE_AUTO_UPDATE="${ENABLE_AUTO_UPDATE:-1}"

prompt_value() {
  VAR_NAME="$1"
  PROMPT_TEXT="$2"
  DEFAULT_VALUE="$3"
  CURRENT_VALUE="$4"

  if [ -n "$CURRENT_VALUE" ]; then
    printf '%s' "$CURRENT_VALUE"
    return 0
  fi

  if [ ! -t 0 ]; then
    printf '%s' "$DEFAULT_VALUE"
    return 0
  fi

  printf '%s' "$PROMPT_TEXT"
  if [ -n "$DEFAULT_VALUE" ]; then
    printf ' [%s]' "$DEFAULT_VALUE"
  fi
  printf ': '
  read -r INPUT_VALUE

  if [ -n "$INPUT_VALUE" ]; then
    printf '%s' "$INPUT_VALUE"
  else
    printf '%s' "$DEFAULT_VALUE"
  fi
}

PASSWORD=$(prompt_value "PASSWORD" "Enter Trojan password" "$DEFAULT_PASSWORD" "$PASSWORD")
SERVER_NAME=$(prompt_value "SERVER_NAME" "Enter public IP or domain" "$DEFAULT_SERVER_NAME" "$SERVER_NAME")

if command -v dnf >/dev/null 2>&1; then
  sudo dnf update -y
  sudo dnf install -y git docker openssl
elif command -v yum >/dev/null 2>&1; then
  sudo yum update -y
  sudo yum install -y git docker openssl
else
  printf '%s\n' "Unsupported package manager. Install git, docker, and openssl manually."
  exit 1
fi

sudo systemctl enable --now docker
sudo usermod -aG docker "${USER:-ec2-user}" || true

if ! command -v docker-compose >/dev/null 2>&1; then
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64) COMPOSE_BIN="docker-compose-linux-x86_64" ;;
    aarch64) COMPOSE_BIN="docker-compose-linux-aarch64" ;;
    *)
      printf '%s\n' "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  sudo mkdir -p /usr/local/bin
  sudo curl -fsSL "https://github.com/docker/compose/releases/latest/download/$COMPOSE_BIN" -o /tmp/docker-compose
  sudo install -m 0755 /tmp/docker-compose /usr/local/bin/docker-compose
  rm -f /tmp/docker-compose
fi

if [ -d "$INSTALL_DIR/.git" ]; then
  git -C "$INSTALL_DIR" pull --ff-only
else
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"
chmod +x scripts/init.sh scripts/update.sh
PASSWORD="$PASSWORD" SERVER_NAME="$SERVER_NAME" CERT_DAYS="$CERT_DAYS" ./scripts/init.sh
docker-compose up -d

if [ "$ENABLE_AUTO_UPDATE" = "1" ]; then
  sudo cp deploy/trojan-auto-update.service /etc/systemd/system/
  sudo cp deploy/trojan-auto-update.timer /etc/systemd/system/
  sudo sed -i "s#/opt/trajondocker#$INSTALL_DIR#g" /etc/systemd/system/trojan-auto-update.service
  sudo systemctl daemon-reload
  sudo systemctl enable --now trojan-auto-update.timer
fi

printf '%s\n' "Install directory: $INSTALL_DIR"
printf '%s\n' "Server name: $SERVER_NAME"
printf '%s\n' "Password: $PASSWORD"
printf '%s\n' "Started with: docker-compose up -d"
