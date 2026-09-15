#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

stow_config agents ~/.config/agents

run_cmd mkdir -p ~/.codex ~/.claude
run_cmd ln -sfn ~/.config/agents/AGENTS.md ~/.codex/AGENTS.md
run_cmd ln -sfn ~/.config/agents/AGENTS.md ~/.claude/CLAUDE.md

# Install claude code in terminal
run_cmd curl -fsSL https://claude.ai/install.sh | bash

# Install codex in terminal
run_cmd curl -fsSL https://chatgpt.com/codex/install.sh | sh

# Install chatgpt UI
run_cmd curl --proto '=https' --tlsv1.2 -fL -o install-arch.sh https://persistent.oaistatic.com/codex-app-prod/linux/install-arch.sh
run_cmd sudo bash install-arch.sh
