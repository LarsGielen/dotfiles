# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for an **Arch Linux + Hyprland (Wayland)** desktop:

- `install-scripts/` — an idempotent, modular installer (bash + shellcheck).
- `stow/` — GNU Stow packages whose contents are symlinked into `$HOME` (e.g. `stow/kitty/.config/kitty/` -> `~/.config/kitty/`).
- `theme/` — the global colour system: `palettes.toml` plus the generator that feeds the whole system
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

# Theme (run from repo root)
./theme/switch.sh                   # show active palette + alternatives
./theme/switch.sh catppuccin        # switch every app, live
python3 theme/generate.py --dry-run # regenerate without writing

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
  (bootstrap → drivers/audio/video → shells/tools → system).
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
- `_G.colors` comes from the generated `hypr/colors.lua` (see below), so border
  colours follow the global palette.

## Theme system

`theme/palettes.toml` is the single source of truth for colours. `theme/generate.py`
fills the templates in `theme/templates/` with the active palette, and
`theme/switch.sh <palette>` activates one across the running session.

- **Adding a program:** drop a template in `theme/templates/` and add one line to the
  `[outputs]` table in `palettes.toml` mapping it to its destination. No Python changes.
- Placeholders are `{{accent}}` (`#fabd2f`), `{{accent:rgb}}` (`rgb(fabd2f)`, the only
  colour form Hyprland parses) and `{{accent:50}}` (`#fabd2f80`, alpha percent), plus
  `{{name}}`, `{{label}}` and `{{banner}}`. An unknown key or filter is a hard error
  naming the template, and nothing is written unless every template renders.
- Zed's syntax highlighting maps to the **ANSI** colours, not the semantic ones, so a
  new palette only needs the 16 values terminal themes already publish.
- **Never hand-edit a generated file** — they all carry a "do not edit" banner: Edit the template or `palettes.toml` and regenerate.
- Every palette carries a `[ui]` block (semantic: `base`/`mantle`/`surface`/…) and a
  full 16-colour `[ansi]` block. Both are mandatory; a missing key is a hard error in
  `generate.py` rather than a silently black widget.
- starship has no include mechanism, so the whole `starship.toml` is the template;
  it defines a `[palettes.dotfiles]` table and every segment styles itself by those
  names. Starship lowercases style tokens, so those names are snake_case, not the
  camelCase used elsewhere.
- Every output holds only the **active** palette, so all of them are gitignored — they
  change on every switch. A fresh clone gets them from `modules/base/install-theme.sh`,
  which runs before the hyprland/quickshell/kitty/starship aspects.
  `~/.local/state/dotfiles/theme` records the choice for `generate.py` to resolve.
- The generator skips files whose content is unchanged, so regenerating the palette
  already in use doesn't churn mtimes or bounce quickshell.
- Each app notices its own file changing: quickshell hot-reloads its config, Zed
  watches its themes dir, starship re-reads its config on every prompt. Hyprland
  and kitty need an explicit nudge, which `switch.sh` does (`hyprctl reload`,
  `pkill -SIGUSR1 kitty`).
- Zed's theme is always named `"Dotfiles Dark"`; only its contents change, so
  `settings.json` (JSONC, with comments) never needs patching.
