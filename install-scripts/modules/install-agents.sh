#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# One call: stow links the whole package, so every target must be cleared first.
# --no-folding keeps stow from symlinking ~/.local itself on a fresh machine.
stow_config --no-folding agents ~/.config/agents ~/.config/claude-desktop-flags.conf ~/.local/share/icons/hicolor/scalable/apps/claude-code.svg ~/.claude/settings.json

run_cmd mkdir -p ~/.claude
run_cmd ln -sfn ~/.config/agents/CLAUDE.md ~/.claude/CLAUDE.md

if command -v claude >/dev/null 2>&1; then
    ok "claude code already installed"
else
    info "Installing claude code..."
    run_remote_installer https://claude.ai/install.sh bash
fi

install_packages bubblewrap socat

install_aur claude-desktop

# The only place Claude may read and write. It sits outside $HOME because the
# deny rules in system/claude/managed-settings.json cover everything under it, so
# keep the /projects entries in stow/agents/.claude/settings.json in sync with
# this path.
source "$DOTFILES_DIR/stow/shell/.config/shell/workspace.sh"
CLAUDE_PROJECTS_DIR=/projects
PROJECTS_LINK="$WORKSPACE_DIR/Projects"

# Everything that restricts Claude lives in root-owned managed settings, which
# outrank user and project settings and which Claude cannot edit. The stowed
# ~/.claude/settings.json only holds conveniences.
MANAGED_SETTINGS_DIR=/etc/claude-code
MANAGED_SETTINGS_SOURCE="$DOTFILES_DIR/system/claude/managed-settings.json"

info "Installing Claude Code managed settings..."
prime_sudo
run_cmd sudo mkdir -p "$MANAGED_SETTINGS_DIR"
write_root_file "$MANAGED_SETTINGS_DIR/managed-settings.json" "$(cat "$MANAGED_SETTINGS_SOURCE")"

info "Creating $CLAUDE_PROJECTS_DIR..."
run_cmd sudo install -d -o "$USER" -g "$(id -gn)" "$CLAUDE_PROJECTS_DIR"

# install-general creates Projects as a plain directory; replace it only when
# empty so no work is lost.
if [ -L "$PROJECTS_LINK" ] || [ ! -d "$PROJECTS_LINK" ] || [ -z "$(ls -A "$PROJECTS_LINK")" ]; then
    if [ -d "$PROJECTS_LINK" ] && [ ! -L "$PROJECTS_LINK" ]; then
        run_cmd rmdir "$PROJECTS_LINK"
    fi
    run_cmd mkdir -p "$WORKSPACE_DIR"
    run_cmd ln -sfn "$CLAUDE_PROJECTS_DIR" "$PROJECTS_LINK"
    ok "$PROJECTS_LINK linked to $CLAUDE_PROJECTS_DIR"
else
    warn "$PROJECTS_LINK is not empty; move its contents to $CLAUDE_PROJECTS_DIR and re-run"
fi

ok "agents configured"
