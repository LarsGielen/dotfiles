# Install script style guide

Conventions for everything under `install-scripts/`. The goal is that every
module reads the same way: a short, declarative list of what a machine needs,
with the mechanics hidden in `lib/common.sh`.

## File anatomy

A module is a standalone runnable script. Nothing more than this:

```bash
#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    kitty \
    ttf-jetbrains-mono-nerd

stow_config kitty ~/.config/kitty
```

Order inside a module, skipping whatever doesn't apply:

1. shebang + `source` of `lib/common.sh`
2. `require_cmd` for binaries that aren't installed by this script
3. script-level constants
4. `install_packages` / `install_aur`
5. config generation (files written outside `stow/`)
6. `stow_config`
7. system integration — services, groups, `mkinitcpio`
8. a closing `ok "<name> configured"` when the script did more than install packages

`#!/bin/bash` for modules and `setup-*.sh`; `#!/usr/bin/env bash` only for
`lib/common.sh` and standalone scripts that don't source it.

Never repeat `set -euo pipefail` in a module — sourcing `common.sh` sets it for
you. Two consequences worth remembering:

- An unchecked failing command aborts the module. That's intended;
  `install-all.sh` reports it and continues with the next module.
- `[ cond ] && cmd` as the **last** line of a script or function returns 1 when
  the condition is false, which aborts the caller. Use a real `if` when the
  line can end up last.

The path in the `source` line is relative to the script's own directory:
`../lib/common.sh` from `modules/`, `../../lib/common.sh` from `modules/base/`.

## Formatting

- Four spaces, no tabs.
- No column alignment. Don't pad assignments, trailing comments, or `case` arms
  to line up with the lines above them; one space is enough. The only tables are
  in `usage()` help text, where the alignment is what the user sees.
- No trailing whitespace, one trailing newline.
- Package lists: one or two packages stay on the call line, three or more get
  one per line with `\` continuations, indented four spaces.

```bash
install_packages ufw

install_packages \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    qt6-wayland
```

- Split a list into several `install_packages` calls when the groups mean
  different things (session vs. fonts vs. utilities); the grouping is the
  documentation.
- Quote every expansion: `"$path"`, `"${missing[@]}"`, `"$(dirname "$f")"`.
- `$VAR` normally; `${VAR}` when it needs bracing (`${MAPPER_NAME}.key`) or for
  the four inherited flags, which are always written `${DRY_RUN}`, `${YES}`,
  `${VERBOSE}`, `${PARSED_ARGS}`.
- `[ ]` for ordinary tests. `[[ ]]` only where it earns its keep — regex `=~`,
  glob matches, `&&`/`||` inside one test.
- Names: functions and locals `snake_case`, script-level constants
  `UPPER_SNAKE`, helpers private to `common.sh` prefixed with `_`.
- Declare locals before assigning from a command substitution, so `set -e` sees
  the real exit status:

```bash
local release tag
release=$(curl -fsSL "$api")
tag=$(grep -oP '"tag_name":\s*"\K[^"]+' <<< "$release")
```

- Section banners (`# --- parse arguments ----`) belong in the long scripts
  (`common.sh`, `install-all.sh`). A 20-line module doesn't need them.

## Use the library

Don't call `pacman`, `yay`, or `stow` directly. The helpers already handle
skip-if-installed, quiet output, `--verbose`, `--dry-run` and backups:

| Need | Use |
| --- | --- |
| repo packages | `install_packages <pkg>...` |
| AUR packages | `install_aur <pkg>...` |
| symlink a stow package | `stow_config <pkg> [conflicting-path...]` |
| any other command | `run_cmd <cmd>...` |
| noisy command whose output only matters on failure | `run_quiet <cmd>...` |
| long download/build worth a progress line | `run_progress <cmd>...` |
| check a package | `is_installed <pkg>` |
| check a binary | `require_cmd <cmd>` |

`run_progress` only keeps `sudo` out of its pty when `sudo` is the *leading*
word — anything that shells out to `sudo` internally (`yay`, `makepkg`) must use
`run_quiet`, or it will hang on an invisible password prompt.

Pass every path that `stow_config` might collide with, so a pre-existing real
config gets backed up instead of breaking the stow:

```bash
stow_config zsh ~/.zshrc ~/.zprofile
```

Adding a helper to `common.sh` means adding it to the `export -f` list at the
bottom of the file, and any new global to the `export` line above it.

## Dry-run is a contract

`--dry-run` must never touch the system. `run_cmd`/`run_quiet`/`run_progress`
handle that for you. Anything that writes, prompts, or shells out on its own
needs an explicit guard that prints what it *would* do:

```bash
if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] select colour palette -> $STATE_FILE"
elif [ ! -f "$STATE_FILE" ]; then
    ...
fi
```

That covers heredocs into `cat`/`tee`, `read`/`select` prompts, and anything
piped. Read-only probes (`grep`, `pgrep`, `command -v`) run unguarded.

Use `info "[DRY-RUN] ..."` inside a module; the bare `[DRY-RUN] ` prefix without
a marker is `run_cmd`'s own format.

## Idempotency

Every script must survive being re-run. Check state, then act, and say which
branch you took:

```bash
if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    ok "zsh is already the default shell"
else
    info "Setting zsh as the default shell..."
    run_cmd chsh -s "$ZSH_PATH"
fi
```

Guard the specific edit, not the whole file: `grep -q '\bplymouth\b'` before
`sed -i` on `mkinitcpio.conf`, `[ -f "$SERVICE_FILE" ]` before writing a unit.
Prefer commands that are idempotent by construction — `mkdir -p`, `ln -sf`,
`install -d`, `systemctl enable --now`, `pyenv install --skip-existing`.

## Output

Four levels, and nothing else — no bare `echo` for status, no `printf` colour by
hand:

- `info "Enabling bluetooth service..."` — about to do something. Present
  participle, trailing `...`.
- `ok "bluetooth enabled"` — done, or already the case. Lowercase, past tense.
- `warn "..."` — recoverable; goes to stderr.
- `die "..."` — unrecoverable; exits 1.

Close a manual step with `ok`. A module that only calls `install_packages` needs
no closing line — the helper already reported each package. End with a `warn`
for anything the user still has to do by hand:

```bash
warn "Run 'rclone config' to create your remote before the first sync"
```

## Comments

Comments are for the reason, never the mechanism. `install_packages steam` does
not get a comment. Write one when the next reader would otherwise change the
code and break something:

- a non-obvious ordering constraint — *theme must run before hyprland because it
  writes into its stow package*
- something deliberately **not** done — *hyprpolkitagent isn't installed; the
  quickshell shell provides the polkit agent*
- a workaround whose trigger isn't visible in the code — *`$SHELL` is inherited
  and can be stale, so read passwd*
- a host-specific constant — `ETH_INTERFACE="eno1"`
- a package name that says nothing about why it's here:
  `libnotify   # notify-send, used by the quickshell VPN widget`

Keep them above the block they explain, in full sentences, wrapped at ~80
columns. A one-line file header is fine when the module's purpose isn't obvious
from its name (`install-general.sh`, `install-cli-tools.sh`).

Don't leave commented-out commands behind; delete them.

## Writing files outside stow

`stow_config` is the default. Write a file directly only when something else
rewrites it in place and would follow the symlink back into the repo
(`user-dirs.dirs`), or when it lives outside `$HOME` (systemd units, `/etc`).
When you do, quote the heredoc delimiter unless you actually want expansion, and
escape what must survive into the file:

```bash
cat >"$USER_DIRS" <<'EOF'
XDG_DOWNLOAD_DIR="$HOME/Downloads"
EOF
```

Name the source in generated files so the next reader knows where to edit:
`# Managed by dotfiles (install-scripts/modules/base/install-general.sh).`

## sudo

Only for what genuinely needs root — `/etc`, system services, `usermod`.
User-level systemd goes through `systemctl --user` with no sudo.

Call `prime_sudo` before a block that would otherwise prompt from inside a
captured or backgrounded command. `install-all.sh` primes once up front, and
`_install_pkgs` primes before installing, so a plain module rarely needs it.

## Adding a module

1. Create `modules/install-<name>.sh`, `chmod +x`, source `../lib/common.sh`.
   `install-all.sh` discovers it automatically — no registration.
2. If it ships config, add `stow/<pkg>/` mirroring the path under `$HOME` and
   call `stow_config`.
3. A base *aspect* goes in `modules/base/install-<aspect>.sh` **and** into the
   `BASE_MODULES` list in `modules/install-base.sh`, at the right position — that
   list is the install order, and the grouping comments in it are part of the
   contract.

## Before committing

```bash
cd install-scripts && make lint    # shellcheck -x
cd install-scripts && make check   # bash -n
```

Both must be clean. Suppress a check inline with a `# shellcheck disable=SCxxxx`
and a reason on the same line, never by widening `.shellcheckrc`. Then run the
module with `--dry-run`, and a second time for real to confirm it's idempotent.
