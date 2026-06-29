#!/bin/bash
# =============================================================================
# 06b-tmux.sh — Deploy tmux.conf (Tokyo Night theme)
# =============================================================================

USER="user"
HOME_DIR="/home/user"
REPO_DIR="/home/user/dev/git/gcp-dev-cloud-workstation"
if [ ! -d "$REPO_DIR" ]; then
    REPO_DIR="/home/user/Apps/gcp-dev-cloud-workstation"
fi
TMUX_SRC="$REPO_DIR/workstation-image/configs/tmux/tmux.conf"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [06b-tmux] $1"; }

if [ -f "$TMUX_SRC" ]; then
    cp "$TMUX_SRC" "$HOME_DIR/.tmux.conf"
    chown $USER:$USER "$HOME_DIR/.tmux.conf"
    log "Deployed tmux.conf (Tokyo Night)"
else
    log "WARNING: tmux.conf source not found at $TMUX_SRC"
fi
