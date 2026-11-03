#!/usr/bin/env bash
# Setup for this sway config on Ubuntu 24.04.
#
#   git clone https://github.com/antoniolch/sway-config ~/.config/sway
#   ~/.config/sway/install.sh
#
# Safe to re-run: every step skips what is already done.
set -euo pipefail

SWAY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAMESHOT_VERSION="14.0.0"
FLAMESHOT_ZIP="flameshot-v14.0+git0.da6121bd-artifact-ubuntu-24.04-amd64.zip"
FLAMESHOT_URL="https://github.com/flameshot-org/flameshot/releases/download/v${FLAMESHOT_VERSION}/${FLAMESHOT_ZIP}"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*"; }

if [[ $EUID -eq 0 ]]; then
    echo "Run as your normal user, not root (sudo is used where needed)." >&2
    exit 1
fi

if [[ "$SWAY_DIR" != "$HOME/.config/sway" ]]; then
    warn "Repo is at $SWAY_DIR, but sway reads ~/.config/sway — clone it there."
fi

. /etc/os-release
if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
    warn "Tested on Ubuntu 24.04, this is ${PRETTY_NAME:-unknown}. Continuing anyway."
fi

# --------------------------------------------------------------------------
step "Installing packages"
PACKAGES=(
    # compositor, bar, launcher, terminal, lock/idle
    sway swaybg swayidle swaylock waybar wofi foot
    # monitor profiles
    kanshi
    # screenshots and clipboard
    grim slurp wl-clipboard cliphist jq
    # Fn keys: brightness, media
    brightnessctl playerctl
    # notifications, night light
    mako-notifier libnotify-bin wlsunset
    # screen sharing / file pickers, password prompts, keyring
    xdg-desktop-portal-wlr policykit-1-gnome gnome-keyring
    # tray applets and the tools Waybar opens on click
    network-manager-gnome blueman pavucontrol gnome-system-monitor nautilus
    # fonts used by Waybar
    fonts-font-awesome fonts-noto-core
    # needed by this script
    curl unzip
)
sudo apt-get update
sudo apt-get install -y "${PACKAGES[@]}"

# --------------------------------------------------------------------------
step "Flameshot ${FLAMESHOT_VERSION} (Ubuntu ships 12.x, which breaks with fractional scaling)"
current="$(dpkg-query -W -f='${Version}' flameshot 2>/dev/null || true)"
if [[ "$current" == ${FLAMESHOT_VERSION}* ]]; then
    echo "Already installed ($current)."
elif [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
    warn "Not amd64 — install Flameshot >= 13 manually from GitHub releases."
else
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL -o "$tmp/$FLAMESHOT_ZIP" "$FLAMESHOT_URL"
    curl -fsSL -o "$tmp/$FLAMESHOT_ZIP.sha256sum" "$FLAMESHOT_URL.sha256sum"
    (cd "$tmp" && sha256sum -c "$FLAMESHOT_ZIP.sha256sum")
    unzip -q -o "$tmp/$FLAMESHOT_ZIP" -d "$tmp"
    (cd "$tmp" && sha256sum -c ./*.deb.sha256sum)
    sudo apt-get install -y "$tmp"/flameshot-*.deb
fi

# --------------------------------------------------------------------------
step "Brightness permissions (video group)"
if id -nG "$USER" | grep -qw video; then
    echo "$USER is already in the video group."
else
    sudo usermod -aG video "$USER"
    NEED_RELOGIN=1
fi

# --------------------------------------------------------------------------
step "Linking Waybar config"
target="$HOME/.config/waybar"
if [[ -L "$target" && "$(readlink -f "$target")" == "$SWAY_DIR/waybar" ]]; then
    echo "Already linked."
else
    if [[ -e "$target" || -L "$target" ]]; then
        backup="$target.bak-$(date +%Y%m%d-%H%M%S)"
        mv "$target" "$backup"
        echo "Existing $target moved to $backup"
    fi
    ln -s "$SWAY_DIR/waybar" "$target"
    echo "$target -> $SWAY_DIR/waybar"
fi

# --------------------------------------------------------------------------
step "Checking the sway config"
sway -C -c "$SWAY_DIR/config" && echo "Config OK."

# --------------------------------------------------------------------------
step "Done"
cat <<EOF
- Monitors: add a profile for this machine to kanshi.conf. List your outputs with:
    swaymsg -t get_outputs | jq -r '.[] | "\(.make) \(.model) \(.serial)"'
- Night light uses Rome's coordinates (wlsunset -l/-L in config).
EOF
if [[ "${NEED_RELOGIN:-0}" == 1 ]]; then
    warn "Log out and back in (or reboot) so the video group applies — brightness keys need it."
fi
echo "Then pick 'Sway' on the login screen."
