#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOURCE_DIR="$ROOT_DIR/vendor/trojan-upstream"
SOURCE_REPO="${SOURCE_REPO:-https://github.com/unboundedx/trojan-upstream.git}"

mkdir -p "$ROOT_DIR/vendor"

if [ -d "$SOURCE_DIR/.git" ]; then
  git -C "$SOURCE_DIR" pull --ff-only
else
  rm -rf "$SOURCE_DIR"
  git clone "$SOURCE_REPO" "$SOURCE_DIR"
fi

printf '%s\n' "Trojan source ready at: $SOURCE_DIR"
printf '%s\n' "Source repo: $SOURCE_REPO"
