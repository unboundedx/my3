#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
else
  printf '%s\n' "Docker Compose is not installed."
  exit 1
fi

cd "$ROOT_DIR"

if [ ! -d .git ]; then
  printf '%s\n' "This directory is not a Git repository."
  printf '%s\n' "Run: git init && git remote add origin <repo-url>"
  exit 1
fi

git pull --ff-only
"$ROOT_DIR/scripts/init.sh"
$COMPOSE_CMD pull
$COMPOSE_CMD up -d
