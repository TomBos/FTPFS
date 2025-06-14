#!/bin/bash

set -e

REPO_URL="https://github.com/TomBos/FTPFS"
INSTALL_DIR="$HOME/.local/share/FTPFS"
BIN_DIR="$HOME/.local/bin"
WRAPPER="$BIN_DIR/FTPFS"
CONFIG_DIR="$HOME/.config/FTPFS"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
TMP_DIR=$(mktemp -d)

echo "[*] Downloading FTPFS from $REPO_URL..."
git clone --depth=1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1

echo "[*] Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -rf "$TMP_DIR/src/"* "$INSTALL_DIR"

echo "[*] Creating wrapper at $WRAPPER..."
mkdir -p "$BIN_DIR"

cat > "$WRAPPER" <<'EOF'
#!/usr/bin/env bash

if [[ "$1" == "-u" ]]; then
    bash <(curl -sL "https://raw.githubusercontent.com/TomBos/FTPFS/master/install.sh")
else
    python3 "__INSTALL_DIR__/FTPFS.py" "$@"
fi
EOF

sed -i "s|__INSTALL_DIR__|$INSTALL_DIR|g" "$WRAPPER"


echo "[*] Setting up config..."
mkdir -p "$CONFIG_DIR"
cp -n "$TMP_DIR/src/config.example.yaml" "$CONFIG_FILE"

chmod +x "$WRAPPER"
rm -rf "$TMP_DIR"

echo "[i] Edit your config at: $CONFIG_FILE"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "[!] ~/.local/bin not in PATH"
    echo "    Add this to your ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
else
    echo "[✓] Installed! Run with: FTPFS"
fi

