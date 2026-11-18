#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

stow_config agents ~/.config/agents
stow_config --no-folding agents ~/.local/share/icons/hicolor/scalable/apps/claude-code.svg

run_cmd mkdir -p ~/.claude
run_cmd ln -sfn ~/.config/agents/AGENTS.md ~/.claude/CLAUDE.md

if command -v claude >/dev/null 2>&1; then
    ok "claude code already installed"
else
    info "Installing claude code..."
    run_remote_installer https://claude.ai/install.sh bash
fi

install_aur claude-desktop

ok "agents configured"
