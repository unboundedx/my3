#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ENV_FILE="$ROOT_DIR/.trojan.env"
CERT_DIR="$ROOT_DIR/certs"
CONFIG_DIR="$ROOT_DIR/config"
WWW_DIR="$ROOT_DIR/www"

if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
fi

PASSWORD="${PASSWORD:-5512097}"
CERT_DAYS="${CERT_DAYS:-3650}"
SERVER_NAME="${SERVER_NAME:-$(hostname 2>/dev/null || echo trojan-server)}"

mkdir -p "$CERT_DIR" "$CONFIG_DIR" "$WWW_DIR"

cat > "$ENV_FILE" <<EOF
PASSWORD='$PASSWORD'
SERVER_NAME='$SERVER_NAME'
CERT_DAYS='$CERT_DAYS'
EOF

if [ ! -f "$CERT_DIR/server.key" ] || [ ! -f "$CERT_DIR/server.crt" ]; then
  openssl req \
    -x509 \
    -nodes \
    -newkey rsa:2048 \
    -keyout "$CERT_DIR/server.key" \
    -out "$CERT_DIR/server.crt" \
    -days "$CERT_DAYS" \
    -subj "/C=CN/ST=Auto/L=Auto/O=Trojan/CN=$SERVER_NAME"
fi

cat > "$CONFIG_DIR/config.json" <<EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 443,
  "remote_addr": "fallback",
  "remote_port": 80,
  "password": [
    "$PASSWORD"
  ],
  "log_level": 1,
  "ssl": {
    "cert": "/certs/server.crt",
    "key": "/certs/server.key",
    "alpn": [
      "http/1.1"
    ],
    "fallback_addr": "fallback",
    "fallback_port": 80,
    "prefer_server_cipher": true,
    "reuse_session": true,
    "session_ticket": true
  },
  "tcp": {
    "prefer_ipv4": true,
    "no_delay": true,
    "keep_alive": true,
    "reuse_port": false,
    "fast_open": false,
    "fast_open_qlen": 20
  }
}
EOF

cat > "$WWW_DIR/index.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trojan Server Ready</title>
    <style>
      :root {
        color-scheme: light;
        --bg: #f2efe8;
        --card: #fffdf8;
        --ink: #1d1a16;
        --accent: #9a3412;
      }
      * { box-sizing: border-box; }
      body {
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        background:
          radial-gradient(circle at top, rgba(154, 52, 18, 0.10), transparent 35%),
          linear-gradient(135deg, #f7f3eb 0%, var(--bg) 100%);
        font-family: "Georgia", "Times New Roman", serif;
        color: var(--ink);
      }
      main {
        width: min(92vw, 760px);
        padding: 40px;
        border: 1px solid rgba(29, 26, 22, 0.10);
        border-radius: 24px;
        background: var(--card);
        box-shadow: 0 20px 60px rgba(29, 26, 22, 0.08);
      }
      h1 { margin: 0 0 12px; font-size: clamp(2rem, 5vw, 3.5rem); }
      p { margin: 0; font-size: 1.05rem; line-height: 1.6; }
      code {
        padding: 0.15rem 0.4rem;
        border-radius: 6px;
        background: rgba(154, 52, 18, 0.08);
        color: var(--accent);
      }
    </style>
  </head>
  <body>
    <main>
      <h1>Trojan server is online.</h1>
      <p>
        This HTTPS fallback page is served by nginx inside Docker. Client password is
        <code>$PASSWORD</code>. Replace it before public deployment if needed.
      </p>
    </main>
  </body>
</html>
EOF

printf '%s\n' "Generated certs and config under: $ROOT_DIR"
printf '%s\n' "Password: $PASSWORD"
printf '%s\n' "Server name in cert: $SERVER_NAME"
