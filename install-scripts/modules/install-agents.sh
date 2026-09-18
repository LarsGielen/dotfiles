#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

CHATGPT_INSTALLER="https://persistent.oaistatic.com/codex-app-prod/linux/install-arch.sh"

stow_config agents ~/.config/agents

run_cmd mkdir -p ~/.codex ~/.claude
run_cmd ln -sfn ~/.config/agents/AGENTS.md ~/.codex/AGENTS.md
run_cmd ln -sfn ~/.config/agents/AGENTS.md ~/.claude/CLAUDE.md

if command -v claude >/dev/null 2>&1; then
    ok "claude code already installed"
else
    info "Installing claude code..."
    run_remote_installer https://claude.ai/install.sh bash
fi

if command -v codex >/dev/null 2>&1; then
    ok "codex already installed"
else
    info "Installing codex..."
    run_remote_installer https://chatgpt.com/codex/install.sh sh
fi

# The ChatGPT app ships as chatgpt-bin from its own pacman repo, which this
# script registers. It keeps pacman's confirmation prompts, so it runs in the
# open rather than under run_quiet.
if is_installed chatgpt-bin; then
    ok "chatgpt-bin already installed"
elif [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] download $CHATGPT_INSTALLER and run it as root"
else
    info "Installing the ChatGPT app..."
    TEMP_DIR="$(mktemp -d)"
    curl --proto '=https' --tlsv1.2 -fsSL -o "$TEMP_DIR/install-arch.sh" "$CHATGPT_INSTALLER"
    sudo bash "$TEMP_DIR/install-arch.sh"
    rm -rf "$TEMP_DIR"
fi

ok "agents configured"
