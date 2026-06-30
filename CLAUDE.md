# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for an **Arch Linux + Hyprland (Wayland)** desktop. Two halves:

- `install-scripts/` — an idempotent, modular installer (bash + shellcheck).
- `stow/` — GNU Stow packages whose contents are symlinked into `$HOME` (e.g. `stow/kitty/.config/kitty/` -> `~/.config/kitty/`).
- `utils/` — helper scripts and wallpapers shared across configs.

`DOTFILES_DIR` defaults to `$HOME/dotfiles`; the repo expects to live there.

## Commands

```bash
# Install (run from repo root)
./install-scripts/install-all.sh            # interactive module picker
./install-scripts/install-all.sh --all      # every module
./install-scripts/install-all.sh base vscode docker   # specific modules
./install-scripts/install-all.sh --all --dry-run      # print actions, change nothing
# flags: --all, --dry-run, --yes/-y, --verbose/-v, --help/-h

# Lint shell scripts (run from install-scripts/)
cd install-scripts && make lint     # shellcheck -x on all *.sh
cd install-scripts && make check    # bash -n syntax check
```

There is no test suite; `make lint`/`make check` are the only verification steps.

## Installer architecture

- **Entrypoint:** `install-scripts/install-all.sh` parses args, resolves the module
  list, and runs `base` first (it bootstraps git/yay/stow/drivers that other modules
  depend on). Failures in one module are reported but don't stop the rest.
- **Modules:** each `modules/install-<name>.sh` is a standalone runnable script. The
  module name is the filename minus `install-` and `.sh`.
- **Base aspects:** `modules/install-base.sh` delegates to
  `modules/base/install-<aspect>.sh`, run in the fixed order defined in that file
  (bootstrap → drivers/audio/video → hyprland/quickshell/rofi → shells/tools → system).
- **Shared library:** every script sources `install-scripts/lib/common.sh`, which
  provides:
  - `install_packages <pkg>...` (pacman), `install_aur <pkg>...` (yay) — both skip
    already-installed packages and run quietly unless `--verbose`.
  - `stow_config <pkg> [conflicting-path...]` — clears conflicting paths (real files
    are moved to a timestamped `.bak`, old symlinks removed) then stows from
    `$DOTFILES_DIR/stow`.
  - `run_cmd` / `run_quiet` — honor `--dry-run`; `run_quiet` hides output unless it fails.
  - `info/ok/warn/die`, `require_cmd`, `prime_sudo`, `is_installed`.
- **Conventions when adding a module:** create `modules/install-<name>.sh`, source
  `../lib/common.sh`, call `install_packages`/`install_aur`, then `stow_config` if it
  ships a `stow/` package. It is auto-discovered by `install-all.sh`. Keep
  `external-sources` happy with `.shellcheckrc` (it disables SC1090/SC1091 for the
  dynamic `source` path); lint with `make lint` before committing.

## Stow layout

Each top-level dir under `stow/` is a Stow package mirroring its target path under
`$HOME`. Edit files in `stow/` (not in `~/.config`) — the live config is a symlink
back into this repo.

## Hyprland config (Lua, not hyprlang)

Hyprland is configured in **Lua**, loaded via `stow/hyprland/.config/hypr/hyprland.lua`,
which `require("machine")` after some global setup:
- `machine.lua` is **gitignored** and generated at install time
  (`modules/base/install-hyprland.sh` prompts for a profile), pointing at one of
  `config/{default,pc,work}/_hyprland-<profile>.lua`. Each profile layers
  machine-specific overrides on top of `config/default/`.
- IPC dispatch from Lua uses dispatch objects (`hl.dsp.*`), not raw command strings.
