# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

Read [STYLE.md](STYLE.md) before writing code — it covers shell, Lua, QML,
Python and config, and applies to the whole repo.

## What this is

Personal dotfiles for an **Arch Linux + Hyprland (Wayland)** desktop:

- `install-scripts/` — an idempotent, modular installer (bash + shellcheck).
- `stow/` — GNU Stow packages symlinked into `$HOME`
  (`stow/kitty/.config/kitty/` -> `~/.config/kitty/`).
- `theme/` — the global colour system: `palettes.toml` plus the generator.
- `utils/` — helper scripts, browser tweaks and wallpapers.

`DOTFILES_DIR` defaults to `$HOME/dotfiles`; the repo expects to live there.

## Commands

```bash
# Install (from repo root)
./install-scripts/install-all.sh                      # interactive module picker
./install-scripts/install-all.sh --all                # every module
./install-scripts/install-all.sh base vscode docker   # specific modules
./install-scripts/install-all.sh --all --dry-run      # print actions, change nothing
# flags: --all, --dry-run, --yes/-y, --verbose/-v, --help/-h

# Theme (from repo root)
./theme/switch.sh                   # show active palette + alternatives
./theme/switch.sh catppuccin        # switch every app, live
python3 theme/generate.py --dry-run # regenerate without writing

# Lint (from install-scripts/)
make lint     # shellcheck -x on all *.sh, including theme/
make check    # bash -n syntax check
```

There is no test suite; `make lint`/`make check` are the only verification steps.

## Installer architecture

- **Entrypoint:** `install-all.sh` parses args, resolves the module list, and
  runs `base` first (it bootstraps git/yay/stow/drivers the others depend on).
  A failing module is reported but doesn't stop the rest.
- **Modules:** each `modules/install-<name>.sh` is standalone and runnable; the
  module name is the filename minus `install-` and `.sh`. Auto-discovered — no
  registration.
- **Base aspects:** `modules/install-base.sh` delegates to
  `modules/base/install-<aspect>.sh` in the fixed `BASE_MODULES` order
  (bootstrap → drivers/audio/video → shells/tools → system). That list is the
  install order and its grouping comments are part of the contract.
- **Shared library:** every script sources `lib/common.sh`, which sets
  `set -euo pipefail` and provides `install_packages`, `install_aur`,
  `stow_config`, `run_cmd`, `run_quiet`, `run_progress`, `is_installed`,
  `require_cmd`, `prime_sudo` and `info/ok/warn/die`. See [STYLE.md](STYLE.md)
  for what each one guarantees.
- `.shellcheckrc` disables SC1090/SC1091 for the dynamic `source` path; don't
  widen it further.

## Stow layout

Each top-level dir under `stow/` is a Stow package mirroring its target path
under `$HOME`. Edit files in `stow/`, never in `~/.config` — the live config is
a symlink back into this repo.

## Hyprland config (Lua, not hyprlang)

Hyprland is configured in **Lua** via `stow/hyprland/.config/hypr/hyprland.lua`,
which sets `_G.colors` and then `require("machine")`.

- `machine.lua` is **gitignored** and generated at install time
  (`modules/base/install-hyprland.sh` prompts for a profile). It points at one of
  `config/{default,pc,work}/_hyprland-<profile>.lua`; each profile layers
  machine-specific overrides on top of `config/default/`.
- `_G.colors` comes from the generated `hypr/colors.lua`, so border colours
  follow the global palette.

## Theme system

`theme/palettes.toml` is the single source of truth for colours.
`theme/generate.py` fills the templates in `theme/templates/` with the active
palette; `theme/switch.sh <palette>` activates one across the running session.

- **Adding a program:** drop a template in `theme/templates/` and add one line
  to the `[outputs]` table in `palettes.toml` mapping it to its destination. No
  Python changes.
- Placeholders: `{{accent}}` (`#fabd2f`), `{{accent:rgb}}` (`rgb(fabd2f)`, the
  only colour form Hyprland parses), `{{accent:50}}` (`#fabd2f80`, alpha
  percent), `{{accent:mix45}}` (45% toward base), plus `{{name}}`, `{{label}}`
  and `{{banner}}`. An unknown key or filter is a hard error naming the
  template, and nothing is written unless every template renders.
- Every palette carries a `[ui]` block (semantic: `base`/`mantle`/`surface`/…)
  and a full 16-colour `[ansi]` block. Both are mandatory; a missing key is a
  hard error rather than a silently black widget.
- Zed's syntax highlighting maps to the **ANSI** colours, so a new palette only
  needs the 16 values terminal themes already publish. Its theme is always named
  `"Dotfiles Dark"` — only the contents change, so `settings.json` never needs
  patching.
- starship has no include mechanism, so the whole `starship.toml` is the
  template. Starship lowercases style tokens, so its palette names are
  snake_case, not the camelCase used elsewhere.
- Every output holds only the **active** palette, so all of them are gitignored.
  A fresh clone gets them from `modules/base/install-theme.sh`, which runs before
  the hyprland/quickshell/kitty/starship aspects.
  `~/.local/state/dotfiles/theme` records the choice.
- The generator skips unchanged files, so re-running doesn't churn mtimes or
  bounce quickshell.
- quickshell, Zed and starship each notice their own file changing. Hyprland and
  kitty need an explicit nudge, which `switch.sh` does (`hyprctl reload`,
  `pkill -SIGUSR1 kitty`).
