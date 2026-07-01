#!/bin/bash
# =============================================================================
# deploy-configs.sh — Deploy configurations, boot scripts, and initialize Nix
# =============================================================================
# This script copies the boot scripts, configurations, and custom fonts from
# your local clone to the running workstation, and initializes Nix on the
# persistent HOME disk if not already present.
#
# Run this script after your workstation is started for the first time.
#
# Usage:
#   bash scripts/deploy-configs.sh -p PROJECT_ID [-r REGION] [-c CLUSTER] [-w WORKSTATION]
# =============================================================================

set -euo pipefail

REGION="us-central1"
CLUSTER="main-cluster"
WORKSTATION="gcp-dev-cloud-workstation"
CONFIG="gcp-dev-cloud-workstation-config"
PROJECT_ID=""

usage() {
  echo "Usage:"
  echo "  bash scripts/deploy-configs.sh -p PROJECT_ID [-r REGION] [-c CLUSTER] [-w WORKSTATION]"
  echo ""
  echo "Options:"
  echo "  -p, --project PROJECT_ID     GCP project ID (required)"
  echo "  -r, --region REGION          GCP region (default: us-central1)"
  echo "  -c, --cluster CLUSTER        Workstation cluster name (default: main-cluster)"
  echo "  -w, --workstation NAME       Workstation name (default: gcp-dev-cloud-workstation)"
  echo "  -f, --config CONFIG          Workstation config name (default: gcp-dev-cloud-workstation-config)"
  exit 1
}

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--project)     PROJECT_ID="$2"; shift 2 ;;
    -r|--region)      REGION="$2"; shift 2 ;;
    -c|--cluster)     CLUSTER="$2"; shift 2 ;;
    -w|--workstation) WORKSTATION="$2"; shift 2 ;;
    -f|--config)      CONFIG="$2"; shift 2 ;;
    -h|--help)        usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [ -z "$PROJECT_ID" ]; then
  echo "ERROR: --project is required."
  usage
fi

log() { echo "[$(date '+%H:%M:%S')] $1"; }

# Pre-flight check: is workstation running?
log "Checking workstation status..."
STATE=$(gcloud workstations describe "$WORKSTATION" \
  --cluster="$CLUSTER" \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --format="value(state)" 2>/dev/null || echo "NOT_FOUND")

if [ "$STATE" = "NOT_FOUND" ]; then
  echo "ERROR: Workstation '$WORKSTATION' not found in cluster '$CLUSTER' ($REGION)."
  exit 1
elif [ "$STATE" != "STATE_RUNNING" ]; then
  echo "ERROR: Workstation '$WORKSTATION' is not running (current state: $STATE)."
  echo "Please start it first: gcloud workstations start $WORKSTATION --cluster=$CLUSTER --region=$REGION --project=$PROJECT_ID"
  exit 1
fi
log "Workstation is RUNNING."

# SSH helper
ws_ssh() {
  gcloud workstations ssh "$WORKSTATION" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --cluster="$CLUSTER" \
    --config="$CONFIG" \
    --command="$1"
}

ws_pipe() {
  gcloud workstations ssh "$WORKSTATION" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --cluster="$CLUSTER" \
    --config="$CONFIG" \
    --ssh-flag="-T" \
    --command="$1"
}

# 1. Deploy boot scripts and fonts
log "Deploying boot scripts..."
tar -czf - -C workstation-image/boot . | ws_pipe "mkdir -p ~/boot && tar -xzf - -C ~/boot"

log "Deploying custom fonts..."
if [ -d dev-fonts/Operator-Mono ]; then
  tar -czf - -C dev-fonts/Operator-Mono . | ws_pipe "mkdir -p ~/boot/fonts && tar -xzf - -C ~/boot/fonts"
else
  log "WARNING: dev-fonts/Operator-Mono directory not found. Skipping Operator Mono font deploy."
fi

# 2. Deploy configurations
log "Deploying workstation configurations..."
ws_ssh "mkdir -p ~/.config/sway ~/.config/waybar ~/.config/wofi ~/.config/nvim ~/.config/home-manager ~/.local/bin ~/.config/snippets ~/.zsh"

cat workstation-image/configs/sway/config | ws_pipe "cat > ~/.config/sway/config"
cat workstation-image/configs/foot/foot.ini | ws_pipe "cat > ~/boot/foot.ini"
cat workstation-image/configs/swaybar/sway-status | ws_pipe "cat > ~/.local/bin/sway-status && chmod +x ~/.local/bin/sway-status"
cat workstation-image/configs/waybar/config.jsonc | ws_pipe "cat > ~/.config/waybar/config.jsonc"
cat workstation-image/configs/waybar/style.css | ws_pipe "cat > ~/.config/waybar/style.css"
cat workstation-image/configs/nvim/init.lua | ws_pipe "cat > ~/.config/nvim/init.lua"
cat workstation-image/configs/wofi/config | ws_pipe "cat > ~/.config/wofi/config"
cat workstation-image/configs/wofi/style.css | ws_pipe "cat > ~/.config/wofi/style.css"
cat workstation-image/configs/snippets/snippets.conf | ws_pipe "cat > ~/.config/snippets/snippets.conf"
cat workstation-image/configs/tmux/tmux.conf | ws_pipe "cat > ~/.tmux.conf"

cat workstation-image/scripts/ws-modules.sh | ws_pipe "cat > ~/.local/bin/ws-modules.sh && chmod +x ~/.local/bin/ws-modules.sh"
cat workstation-image/scripts/hub-restart | ws_pipe "cat > ~/.local/bin/hub-restart && chmod +x ~/.local/bin/hub-restart"
cat workstation-image/scripts/hub-start | ws_pipe "cat > ~/.local/bin/hub-start && chmod +x ~/.local/bin/hub-start"
cat workstation-image/scripts/snippet-picker | ws_pipe "cat > ~/.local/bin/snippet-picker && chmod +x ~/.local/bin/snippet-picker"

# 3. Check if Nix is installed
log "Checking Nix installation status..."
NIX_CHECK=$(ws_ssh "test -d /home/user/nix/store && echo YES || echo NO")

if [ "$NIX_CHECK" = "YES" ]; then
  log "Nix is already installed on the persistent disk."
else
  log "Nix not found. Initializing persistent Nix installation..."

  # Build module config
  log "Setting up module configuration..."
  MODULES="core,desktop,tmux,ides,ai-tools,languages,tailscale"
  ws_ssh "cat > ~/.ws-modules << 'MODEOF'
profile=full
modules=$MODULES
MODEOF"

  # Build package list
  BASE_PKGS="neovim tmux tree ffmpeg git gh curl wget htop ripgrep fd jq unzip chromium google-chrome sway waybar foot wofi thunar grim slurp wl-clipboard clipman mako swaylock swayidle wayvnc nodejs_22 xdg-desktop-portal-wlr"
  ALL_PKGS="$BASE_PKGS vscode"

  # Format package list for Nix
  NIX_PKG_LIST=""
  count=0
  for pkg in $ALL_PKGS; do
    if [ $((count % 4)) -eq 0 ] && [ $count -gt 0 ]; then
      NIX_PKG_LIST="${NIX_PKG_LIST}\n    "
    fi
    NIX_PKG_LIST="${NIX_PKG_LIST}${pkg} "
    count=$((count + 1))
  done

  # Deploy home.nix
  log "Deploying home.nix..."
  cat << NIXEOF | ws_pipe "cat > ~/.config/home-manager/home.nix"
{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    $(echo -e "$NIX_PKG_LIST")
    cascadia-code fira-code jetbrains-mono
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -la";
      vim = "nvim";
      vi = "nvim";
      ta = "tmux attach";
      tl = "tmux list-sessions";
      tk = "tmux kill-session -t";
      tdt = "tmux detach";
      tn = "tmux new-session";
      ts = "tmux switch-client -t";
    };
    initContent = ''
      # Nix profile
      if [ -e \$HOME/.nix-profile/etc/profile.d/nix.sh ]; then . \$HOME/.nix-profile/etc/profile.d/nix.sh; fi
      if [ -e \$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then . \$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh; fi

      # Timezone
      export TZ="America/Chicago"

      # PATH additions
      export PATH="\$HOME/.npm-global/bin:\$HOME/.local/bin:/var/lib/nvidia/bin:\$PATH"
      export LD_LIBRARY_PATH=/var/lib/nvidia/lib64:\$LD_LIBRARY_PATH

      # Go
      export GOROOT="\$HOME/go"
      export GOPATH="\$HOME/gopath"
      export PATH="\$GOROOT/bin:\$GOPATH/bin:\$PATH"

      # Rust
      export PATH="\$HOME/.cargo/bin:\$PATH"

      # pyenv
      export PYENV_ROOT="\$HOME/.pyenv"
      export PATH="\$PYENV_ROOT/bin:\$PATH"
      if command -v pyenv &>/dev/null; then
          eval "\$(pyenv init -)"
      fi

      # rbenv
      export PATH="\$HOME/.rbenv/bin:\$PATH"
      if command -v rbenv &>/dev/null; then
          eval "\$(rbenv init -)"
      fi

      # Source environment
      if [ -f \$HOME/.env ]; then
          set -a
          . \$HOME/.env
          set +a
      fi

      # Starship prompt
      if command -v starship &>/dev/null; then
          eval "\$(starship init zsh)"
      fi

      # Custom aliases
      [ -f \$HOME/.zsh/zsh_aliases.sh ] && . \$HOME/.zsh/zsh_aliases.sh

      # User customizations
      [ -f \$HOME/.zshrc.local ] && . \$HOME/.zshrc.local
    '';
  };

  home.file.".config/nvim/init.lua".source = /home/user/.config/home-manager/nvim-init.lua;
  home.file.".config/sway/config".source = /home/user/.config/home-manager/sway-config;
  home.file.".config/waybar/config".source = /home/user/.config/home-manager/waybar-config.json;
  home.file.".config/waybar/style.css".source = /home/user/.config/home-manager/waybar-style.css;
  home.file.".config/xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    default=wlr;gtk
  '';
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "chromium";
  };

  programs.starship.enable = true;

  programs.home-manager.enable = true;
}
NIXEOF

  # Deploy configs needed by Nix
  log "Deploying Home Manager source configs..."
  cat workstation-image/configs/nvim/init.lua | ws_pipe "cat > ~/.config/home-manager/nvim-init.lua"
  cat workstation-image/configs/sway/config | ws_pipe "cat > ~/.config/home-manager/sway-config"
  cat workstation-image/configs/waybar/config.jsonc | ws_pipe "cat > ~/.config/home-manager/waybar-config.json"
  cat workstation-image/configs/waybar/style.css | ws_pipe "cat > ~/.config/home-manager/waybar-style.css"

  # Install Nix
  log "Installing Nix (this may take a minute)..."
  ws_ssh "curl -L -o /tmp/nix-install.sh https://nixos.org/nix/install && chmod +x /tmp/nix-install.sh && sh /tmp/nix-install.sh --no-daemon"

  # Source Nix for current environment
  NIX_SOURCE='if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; elif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh; fi; export PATH="$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/profile/bin:$PATH"'

  # Install Home Manager
  log "Installing Home Manager..."
  ws_ssh "${NIX_SOURCE} && nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && nix-channel --update && nix-shell '<home-manager>' -A install"

  # Run Home Manager switch (slow)
  log "Installing all Nix packages via Home Manager (this can take 5-10 minutes)..."
  ws_ssh "${NIX_SOURCE} && home-manager switch"

  # Persist Nix store to persistent disk
  log "Persisting Nix store to HOME disk for boot survival..."
  ws_ssh "sudo cp -a /nix /home/user/nix"
fi

echo "============================================="
echo " Deployment completed successfully!"
echo "============================================="
echo ""
echo " To complete the setup, restart your workstation to trigger boot scripts:"
echo "   gcloud workstations stop $WORKSTATION --cluster=$CLUSTER --region=$REGION --project=$PROJECT_ID"
echo "   gcloud workstations start $WORKSTATION --cluster=$CLUSTER --region=$REGION --project=$PROJECT_ID"
echo ""
echo " Once started, connect via the browser URL or run:"
echo "   gcloud workstations ssh $WORKSTATION --cluster=$CLUSTER --region=$REGION --project=$PROJECT_ID"
echo "============================================="
