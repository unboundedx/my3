#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

cd "$ROOT_DIR"

if [ ! -d .git ]; then
  printf '%s\n' "This directory is not a Git repository."
  printf '%s\n' "Run: git init && git remote add origin <repo-url>"
  exit 1
fi

git pull --ff-only
"$ROOT_DIR/scripts/init.sh"
docker compose pull
docker compose up -d
