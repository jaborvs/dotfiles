#!/usr/bin/env bash
# Midcentury Dark installer for Ubuntu 26.04 (x86_64).
#   1) deps:   apt packages, third-party apt repos, snaps, pinned user binaries
#   2) deploy: symlink home/ into $HOME with GNU stow, plus wallpaper, GTK theme, user services
# Run as your normal user; sudo is called where needed. Every step is idempotent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
SHARE="$HOME/.local/share"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "=== Midcentury Dark - Dotfiles Installer ==="
echo ""

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user (not root); it calls sudo itself."
    exit 1
fi
SUDO="sudo"
if ! command -v apt &>/dev/null; then
    echo "This script is designed for Ubuntu/Debian-based systems with apt."
    exit 1
fi
. /etc/os-release
CODENAME="${VERSION_CODENAME}"

# --- Mode selection ---
echo "Select an option:"
echo "  1) Install dependencies only"
echo "  2) Deploy dotfiles only"
echo "  3) Both (full installation)"
echo "  4) Exit"
echo ""
read -r -p "Choice [1-4]: " choice

case "$choice" in
    1) mode="deps" ;;
    2) mode="deploy" ;;
    3) mode="all" ;;
    4) echo "Exiting."; exit 0 ;;
    *) echo "Invalid choice."; exit 1 ;;
esac

# Download $1 to $3 and abort unless its SHA-256 is $2.
fetch() {
    local url="$1" sum="$2" dest="$3"
    curl -fsSL "$url" -o "$dest"
    if ! echo "${sum}  ${dest}" | sha256sum -c --quiet -; then
        echo "ERROR: checksum mismatch for $url" >&2
        exit 1
    fi
}

# True when $1 exists and its SHA-256 is $2 (lets reruns skip installed tools).
has_sha() {
    [ -f "$1" ] && echo "${2}  ${1}" | sha256sum -c --quiet - &>/dev/null
}

# =============================================================================
# 1. Dependencies
# =============================================================================
if [ "$mode" = "deps" ] || [ "$mode" = "all" ]; then
    echo ">>> Updating package lists..."
    $SUDO apt update

    PACKAGES=(
        # Desktop
        sway swaybg swayidle waybar mako-notifier kanshi foot rofi
        grim slurp wl-clipboard wtype brightnessctl wf-recorder
        xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
        fonts-jetbrains-mono papirus-icon-theme yaru-theme-gtk yaru-theme-icon
        libnotify-bin jq stow
        # Audio and devices
        pipewire pipewire-bin pipewire-pulse wireplumber libspa-0.2-bluetooth libpulse0
        pavucontrol v4l-utils bluez blueman upower lm-sensors network-manager
        # totp (age + YubiKey, QR import)
        age zbar-tools
        # Shell and tools
        zsh zoxide fzf vim btop ncdu sqlite3 shellcheck
        git curl wget unzip flatpak
        # Builds (swaylock-effects, waybar-module-pomodoro, Python venvs)
        build-essential python3-venv rustc cargo
    )

    echo ">>> Installing apt packages..."
    $SUDO apt install -y "${PACKAGES[@]}"

    # --- Third-party apt repos: Chrome, Tailscale, NodeSource, HashiCorp ---
    echo ">>> Configuring third-party apt repositories..."
    KEYRINGS=/usr/share/keyrings
    ARCH="$(dpkg --print-architecture)"
    NODE_MAJOR=24

    # Google Chrome: its .deb registers the apt repo and signing key itself.
    if ! dpkg -s google-chrome-stable &>/dev/null; then
        curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$TMP/chrome.deb"
        $SUDO apt install -y "$TMP/chrome.deb"
    fi

    curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${CODENAME}.noarmor.gpg" \
        | $SUDO tee "$KEYRINGS/tailscale-archive-keyring.gpg" >/dev/null
    curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${CODENAME}.tailscale-keyring.list" \
        | $SUDO tee /etc/apt/sources.list.d/tailscale.list >/dev/null

    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor | $SUDO tee "$KEYRINGS/nodesource.gpg" >/dev/null
    printf 'Types: deb\nURIs: https://deb.nodesource.com/node_%s.x\nSuites: nodistro\nComponents: main\nArchitectures: %s\nSigned-By: %s/nodesource.gpg\n' \
        "$NODE_MAJOR" "$ARCH" "$KEYRINGS" | $SUDO tee /etc/apt/sources.list.d/nodesource.sources >/dev/null
    for pkg in nodejs nsolid; do
        printf 'Package: %s\nPin: origin deb.nodesource.com\nPin-Priority: 600\n' "$pkg" \
            | $SUDO tee "/etc/apt/preferences.d/$pkg" >/dev/null
    done

    curl -fsSL https://apt.releases.hashicorp.com/gpg \
        | gpg --dearmor | $SUDO tee "$KEYRINGS/hashicorp-archive-keyring.gpg" >/dev/null
    echo "deb [signed-by=$KEYRINGS/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${CODENAME} main" \
        | $SUDO tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

    $SUDO apt update
    $SUDO apt install -y tailscale nodejs terraform-ls

    # --- Snaps ---
    echo ">>> Installing snaps..."
    for spec in "kubectl --classic" "obsidian --classic" "code --classic" "spotify" "mattermost-desktop"; do
        name="${spec%% *}"
        if snap list "$name" &>/dev/null; then
            echo ">>> snap $name already installed, skipping."
        else
            # shellcheck disable=SC2086  # spec carries the optional --classic flag
            $SUDO snap install $spec
        fi
    done

    # --- Build and install swaylock-effects ---
    # swaylock-effects (jirutka fork) is required for sway 1.8+ (ext-session-lock protocol).
    # It is not available as a prebuilt package on Ubuntu.
    if /usr/local/bin/swaylock --version 2>/dev/null | grep -q "swaylock"; then
        echo ">>> swaylock-effects already installed, skipping build."
    else
        echo ">>> Building swaylock-effects from source..."
        $SUDO apt install -y \
            meson ninja-build pkg-config \
            libwayland-dev wayland-protocols \
            libxkbcommon-dev libcairo-dev \
            libgdk-pixbuf-2.0-dev libpam0g-dev

        git clone -q https://github.com/jirutka/swaylock-effects.git "$TMP/swaylock-effects"
        cd "$TMP/swaylock-effects"

        echo ">>> Patching swaylock-effects (clock offset + date color)..."
        python3 "${SCRIPT_DIR}/swaylock-patch-render.py"

        meson build --prefix=/usr/local -Dsysconfdir=/etc
        ninja -C build

        # Preserve existing /etc/pam.d/swaylock if present
        PAM_FILE=/etc/pam.d/swaylock
        if [ -f "$PAM_FILE" ]; then
            cp "$PAM_FILE" "$TMP/pam-swaylock"
            $SUDO ninja -C build install
            $SUDO cp "$TMP/pam-swaylock" "$PAM_FILE"
            echo ">>> Restored $PAM_FILE"
        else
            $SUDO ninja -C build install
            echo -e "#%PAM-1.0\nauth required pam_unix.so" | $SUDO tee "$PAM_FILE" > /dev/null
        fi

        cd "${SCRIPT_DIR}"
        echo ">>> swaylock-effects installed."
    fi

    # --- Set zsh as default shell ---
    ME="$(id -un)"
    ZSH_PATH="$(command -v zsh)"
    if [ "$(getent passwd "$ME" | cut -d: -f7)" != "$ZSH_PATH" ]; then
        echo ">>> Setting zsh as default shell for $ME..."
        if grep -q "^$ME:" /etc/passwd; then
            $SUDO usermod -s "$ZSH_PATH" "$ME"
        else
            # Directory users (e.g. user@domain from authd/SSSD) are not in /etc/passwd,
            # so usermod/chsh cannot change their shell: add a local entry instead.
            echo "$ME:x:$(id -u):$(id -g):$ME:$HOME:$ZSH_PATH" | $SUDO tee -a /etc/passwd >/dev/null
        fi
    fi

    # --- JetBrainsMono Nerd Font (optional, skip on network failure) ---
    NERD_FONT_VERSION="3.3.0"
    NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/JetBrainsMono.zip"
    FONT_DIR="$SHARE/fonts"

    if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        echo ">>> JetBrainsMono Nerd Font already installed, skipping."
    else
        echo ">>> Downloading JetBrainsMono Nerd Font v${NERD_FONT_VERSION}..."
        mkdir -p "${FONT_DIR}"
        if curl -fsSL "${NERD_FONT_URL}" -o "$TMP/JetBrainsMono.zip"; then
            unzip -q "$TMP/JetBrainsMono.zip" -d "$TMP/JetBrainsMonoNerdFont/"
            cp "$TMP"/JetBrainsMonoNerdFont/*.ttf "${FONT_DIR}/"
            fc-cache -f
            echo ">>> JetBrainsMono Nerd Font installed."
        else
            echo "WARNING: Could not download JetBrainsMono Nerd Font (no internet?). Skipping."
        fi
    fi

    # --- Oh My Zsh & plugins (optional, skip on failure) ---
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo ">>> Installing Oh My Zsh..."
        # KEEP_ZSHRC: the repo's .zshrc is deployed by stow, don't let the installer write one.
        KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || \
            echo "WARNING: Oh My Zsh installation failed, skipping."
    else
        echo ">>> Oh My Zsh already installed, skipping."
    fi

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    install_omz_plugin() {
        local name="$1"
        local url="$2"
        local target="${ZSH_CUSTOM}/plugins/${name}"
        if [ ! -d "${target}" ]; then
            echo ">>> Installing Oh My Zsh plugin: ${name}"
            git clone --depth=1 "${url}" "${target}" || \
                echo "WARNING: Failed to install plugin ${name}, skipping."
        else
            echo ">>> Oh My Zsh plugin already installed: ${name}"
        fi
    }

    install_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

    # --- subnixr/minimal theme ---
    THEME_DIR="${ZSH_CUSTOM}/themes/minimal"
    if [ ! -d "$THEME_DIR" ]; then
        echo ">>> Installing subnixr/minimal theme..."
        git clone --depth=1 https://github.com/subnixr/minimal.git "$THEME_DIR" || \
            echo "WARNING: Failed to install subnixr/minimal theme, skipping."
    else
        echo ">>> subnixr/minimal theme already installed, skipping."
    fi
    if [ -f "${THEME_DIR}/minimal.zsh" ] && [ ! -f "${ZSH_CUSTOM}/themes/minimal.zsh-theme" ]; then
        ln -sf "${THEME_DIR}/minimal.zsh" "${ZSH_CUSTOM}/themes/minimal.zsh-theme"
    fi

    # --- Flathub remote (optional, skip on failure) ---
    echo ">>> Setting up Flathub..."
    $SUDO flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || \
        echo "WARNING: Could not add Flathub, skipping Flatpak setup."

    # --- Pinned user binaries in ~/.local (checksums verified against upstream releases) ---
    echo ">>> Installing user binaries into ~/.local..."
    mkdir -p "$BIN" "$SHARE"
    GH=https://github.com

    NVIM_VERSION=0.12.5
    if [ ! -x "$SHARE/nvim-$NVIM_VERSION/bin/nvim" ]; then
        fetch "$GH/neovim/neovim/releases/download/v$NVIM_VERSION/nvim-linux-x86_64.tar.gz" \
            bce0f56eda1f1b1db6eee8f4133d7a38813ea07933837dd1777411ca384c6875 "$TMP/nvim.tar.gz"
        tar -xzf "$TMP/nvim.tar.gz" -C "$TMP"
        mv "$TMP/nvim-linux-x86_64" "$SHARE/nvim-$NVIM_VERSION"
    fi
    ln -sfn "$SHARE/nvim-$NVIM_VERSION/bin/nvim" "$BIN/nvim"

    if ! has_sha "$BIN/age-plugin-fido2-hmac" 89821f7c88af9d097173ce08efc1754e7020b5920cd125f1aacd52f4848aa9fe; then
        fetch "$GH/olastor/age-plugin-fido2-hmac/releases/download/v0.5.0/age-plugin-fido2-hmac-v0.5.0-linux-amd64.tar.gz" \
            f837ee7eea5a94c33366b7a78cd143a2a64a1cbae8532b58f16335ca05cccc92 "$TMP/age-fido2.tar.gz"
        tar -xzf "$TMP/age-fido2.tar.gz" -C "$TMP"
        install -m755 "$TMP/age-plugin-fido2-hmac/age-plugin-fido2-hmac" "$BIN/"
    fi

    if ! has_sha "$BIN/stylua" 81d7a816a52f89a4e5b39709c4597b47e184916a2c86037bfecfb6c5b21a6fc7; then
        fetch "$GH/JohnnyMorganz/StyLua/releases/download/v2.5.2/stylua-linux-x86_64.zip" \
            bcb0d855e91f102f28a370e850f8566b3b44b79e6274d806ea5246837c0fd5ab "$TMP/stylua.zip"
        unzip -q -o "$TMP/stylua.zip" -d "$TMP/stylua"
        install -m755 "$TMP/stylua/stylua" "$BIN/"
    fi

    if ! has_sha "$BIN/shfmt" 76e77641faa025814b77f153b29796b8e6fa2fca03e0c76a691608b86c7ea7bf; then
        fetch "$GH/mvdan/sh/releases/download/v3.14.1/shfmt_v3.14.1_linux_amd64" \
            76e77641faa025814b77f153b29796b8e6fa2fca03e0c76a691608b86c7ea7bf "$TMP/shfmt"
        install -m755 "$TMP/shfmt" "$BIN/shfmt"
    fi

    if ! has_sha "$BIN/tree-sitter" 5a228811cdb3a01b7e4dd493c5fc5e05b0040a49ffede94e866c4c58ff2605db; then
        fetch "$GH/tree-sitter/tree-sitter/releases/download/v0.27.0/tree-sitter-cli-linux-x64.zip" \
            e4a3826bcd0fe099ee3a5617767374939cbc23c4a35b5b53f5fc04142525a2c1 "$TMP/tree-sitter.zip"
        unzip -q -o "$TMP/tree-sitter.zip" -d "$TMP/tree-sitter"
        install -m755 "$TMP/tree-sitter/tree-sitter" "$BIN/"
    fi

    LUALS_DIR="$SHARE/lua-language-server"
    if ! has_sha "$LUALS_DIR/bin/lua-language-server" 39d9c9f8937d619c482f1fb2b7a4cce46a85b7a35cbe67cef7e2555aff3dc4f1; then
        fetch "$GH/LuaLS/lua-language-server/releases/download/3.19.1/lua-language-server-3.19.1-linux-x64.tar.gz" \
            e9235d2d72ef55bc41cf8c99cda2ed64777682024b4bb81f5dea425060c5cbb8 "$TMP/luals.tar.gz"
        rm -rf "$LUALS_DIR"
        mkdir -p "$LUALS_DIR"
        tar -xzf "$TMP/luals.tar.gz" -C "$LUALS_DIR"
    fi
    printf '#!/bin/bash\nexec "$HOME/.local/share/lua-language-server/bin/lua-language-server" "$@"\n' > "$BIN/lua-language-server"
    chmod 755 "$BIN/lua-language-server"

    # waybar-module-pomodoro has no releases: build the pinned upstream commit.
    POMODORO_COMMIT=3867b25ab691c4a697ee2ffca76d7cc9408675cc
    if [ ! -x "$BIN/waybar-module-pomodoro" ]; then
        git clone -q https://github.com/Andeskjerf/waybar-module-pomodoro "$TMP/pomodoro"
        git -C "$TMP/pomodoro" checkout -q "$POMODORO_COMMIT"
        cargo build --release --locked --manifest-path "$TMP/pomodoro/Cargo.toml"
        install -m755 "$TMP/pomodoro/target/release/waybar-module-pomodoro" "$BIN/"
    fi

    # uv via its version-pinned installer (keeps `uv self update` working).
    if [ ! -x "$BIN/uv" ]; then
        curl -LsSf https://astral.sh/uv/0.12.19/install.sh | sh
    fi
    "$BIN/uv" tool install basedpyright==1.40.1
    "$BIN/uv" tool install git-review==2.5.0
    "$BIN/uv" tool install trafilatura==2.2.0

    # omp (self-updating binary) and its plugins.
    if [ ! -x "$BIN/omp" ]; then
        curl -fsSL https://omp.sh/install | sh -s -- --binary
    fi
    "$BIN/omp" plugin install pi-superpowers-plus superpowers || \
        echo "WARNING: omp plugin install failed; retry with: omp plugin install pi-superpowers-plus superpowers"

    # context-mode MCP server (omp's mcp.json points at ~/.local/bin/context-mode).
    if [ ! -x "$BIN/context-mode" ]; then
        npm install -g --prefix "$HOME/.local" context-mode
    fi

    # Notification sounds used by mako (CC BY-SA 4.0).
    SOUNDS_DIR="$SHARE/sounds/modern-minimal-ui"
    if [ ! -d "$SOUNDS_DIR" ]; then
        git clone -q https://github.com/cadecomposer/modern-minimal-ui-sounds.git "$SOUNDS_DIR"
        git -C "$SOUNDS_DIR" checkout -q 2a391669f0d79cd0e2de502c0963b446c3728708
    fi

    echo ">>> Dependencies installed."
    echo ""
fi

# =============================================================================
# 2. Deploy dotfiles
# =============================================================================
if [ "$mode" = "deploy" ] || [ "$mode" = "all" ]; then
    echo ">>> Deploying dotfiles..."
    if ! command -v stow &>/dev/null; then
        echo "ERROR: GNU stow is not installed. Run option 1 first (or: sudo apt install stow)."
        exit 1
    fi

    # stow refuses to replace real files: move anything in the way to a dated backup.
    BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    moved=0
    while IFS= read -r -d '' rel; do
        dest="$HOME/$rel"
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            if [ "$(readlink -f "$dest")" = "$(readlink -f "$SCRIPT_DIR/home/$rel")" ]; then
                continue
            fi
            mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
            mv "$dest" "$BACKUP_DIR/$rel"
            moved=$((moved + 1))
        fi
    done < <(cd "$SCRIPT_DIR/home" && find . -type f -printf '%P\0')
    if [ "$moved" -gt 0 ]; then
        echo "    Moved $moved existing file(s) to $BACKUP_DIR"
    fi

    # --no-folding: link files one by one, never whole directories, so apps
    # cannot write their state (sessions, caches, databases) into the repo.
    stow --no-folding --restow -d "$SCRIPT_DIR" -t "$HOME" home
    echo "    Linked home/ into ~"

    # --- Wallpaper ---
    WALLPAPER_SRC="${SCRIPT_DIR}/images/frame_106.png"
    WALLPAPER_DEST="$HOME/Pictures/wallpapers/frame_106.png"
    if [ -f "$WALLPAPER_SRC" ]; then
        mkdir -p "$HOME/Pictures/wallpapers"
        cp "$WALLPAPER_SRC" "$WALLPAPER_DEST"
        echo "    Deployed wallpaper to ~/Pictures/wallpapers/"
    fi

    # --- GTK theme (pavucontrol, Files, blueman, file dialogs) ---
    if command -v gsettings &>/dev/null && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-wartybrown-dark'
        gsettings set org.gnome.desktop.interface icon-theme 'Yaru-wartybrown-dark'
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface accent-color 'brown'
        echo "    Applied GTK theme settings"
    else
        echo "WARNING: no session bus; rerun option 2 from a graphical session to apply the GTK theme."
    fi

    # --- User services (Snowball mic filter chain) ---
    if systemctl --user daemon-reload 2>/dev/null; then
        systemctl --user enable --now filter-chain.service
        echo "    Enabled filter-chain.service"
    else
        echo "WARNING: no systemd user session; run 'systemctl --user enable --now filter-chain.service' after login."
    fi

    echo ">>> Dotfiles deployed."
    echo ""
fi

# =============================================================================
# 3. Summary
# =============================================================================
echo "=== Done ==="
echo ""
echo "Restore by hand (secrets, never in this repo):"
echo "  - ~/.ssh/id_ed25519 and id_ed25519.pub (chmod 600 the private key)"
echo "  - ~/.local/share/totp/*.age and ~/.config/totp/recipient"
echo ""
case "$mode" in
    deps)
        echo "Next: ./install.sh and pick option 2 to deploy the dotfiles."
        ;;
    deploy)
        echo "Edits to linked files now land in the repo; review them with git status."
        ;;
    all)
        echo "Post-install:"
        echo "  - Log out and back in (zsh, environment.d PATH, sway session)"
        echo "  - sudo tailscale up, then check: tailscale ip -4 dalinar"
        echo "  - Run 'sudo sensors-detect' to configure lm-sensors"
        ;;
esac
