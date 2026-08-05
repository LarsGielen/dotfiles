# Hyprland Dotfiles

Personal dotfiles for an **Arch Linux + Hyprland (Wayland)** desktop, with a
modular installer, GNU Stow for config symlinks, and a colour system that
themes every app from one palette file.

Hyprland · quickshell · kitty · zsh + starship · yazi · Zed

## Install

Needs a working Arch install with `git` and an internet connection. The repo
expects to live at `~/dotfiles`.

```bash
git clone https://github.com/larsgielen/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-scripts/install-all.sh            # interactive module picker
```

Other forms:

```bash
./install-scripts/install-all.sh --all              # everything
./install-scripts/install-all.sh base vscode docker # specific modules
./install-scripts/install-all.sh --all --dry-run    # print actions, change nothing
```

Flags: `--all`, `--dry-run`, `--yes/-y`, `--verbose/-v`, `--help/-h`.

`base` always runs first and sets up the desktop itself — drivers, audio, video,
Hyprland, quickshell, kitty, zsh, and the theme. Everything else is optional:
`docker`, `python`, `vscode`, `zed`, `gaming`, `qemu`, `flatpak`, `protonvpn`,
`rclone`, `blender`, `godot`, `unity`, `obs`, `gimp`, `slack`, `vivaldi`,
`zotero`, `plymouth`.

Every script is idempotent — re-run the installer any time to pick up changes.

## Theme

`theme/palettes.toml` holds every palette and is the single source of truth for
colours. Switching regenerates each app's colours and reloads it live:

```bash
./theme/switch.sh              # show the active palette and the alternatives
./theme/switch.sh catppuccin   # switch everything
```

Ships with `gruvbox` (default) and `catppuccin`. Add a palette by copying a
`[palettes.*]` block and filling in its `[ui]` and `[ansi]` colours.

## Layout

| Path | What |
| --- | --- |
| `install-scripts/` | the installer — entrypoint, shared library, per-app modules |
| `stow/` | configs, symlinked into `$HOME` by GNU Stow |
| `theme/` | palettes, templates and the generator |
| `utils/` | helper scripts, browser tweaks, wallpapers |

Edit configs in `stow/`, never in `~/.config` — the live files are symlinks back
into this repo.

Generated files (the per-app theme output, and the Hyprland machine profile) are
gitignored; the installer recreates them.

## Contributing

[STYLE.md](STYLE.md) is the style guide for all code here.
[CLAUDE.md](CLAUDE.md) describes the architecture. Before committing shell
changes:

```bash
cd install-scripts && make lint && make check
```
