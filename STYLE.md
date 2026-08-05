# Style guide

Conventions for every file in this repo — shell, Lua, QML, Python and config.
The goal is that anything you open reads as a short, declarative statement of
what the machine should look like, with the mechanics hidden in shared helpers.

## Principles

- **Declarative over procedural.** A file lists what is wanted; a shared library,
  a singleton or a generator does the work.
- **Idempotent.** Everything survives being re-run. Check state, act, and say
  which branch you took.
- **One source of truth.** Colours, sizes and durations come from the theme
  system, not from literals scattered across configs.
- **Never hand-edit a generated file.** They carry a "do not edit" banner; edit
  the template or the source data and regenerate.
- **Delete, don't comment out.** Git remembers the old version.

## Formatting

Applies everywhere unless a language section says otherwise.

- Indent with **hard tabs**, one tab per level, displayed four columns wide.
  Exception: formats that forbid tabs (YAML) use four spaces.
- No trailing whitespace, one trailing newline.
- Wrap comments and prose at ~80 columns; code lines may run longer when
  breaking them hurts readability.
- Align a column only when a block is a table of like entries — keybind lists,
  palette declarations, dispatch tables. Never pad ordinary assignments or
  trailing comments to line up with their neighbours. Alignment is *spaces
  after* the indent tabs, so the block still lines up at any tab width.
- Blank lines group related statements; two blank lines are never needed.
- Section banners are for long files only. A 20-line config doesn't need them.

## Comments

Comments are for the reason, never the mechanism. Installing a package or
setting a colour does not get a comment. Write one when the next reader would
otherwise change the code and break something:

- a non-obvious ordering constraint
- something deliberately **not** done, and why
- a workaround whose trigger isn't visible in the code
- a host-specific constant
- a name that says nothing about why it's here:
  `libnotify   # notify-send, used by the VPN widget`

Keep them above the block they explain, in full sentences. A one-line file
header is fine when the file's purpose isn't obvious from its name.

## Shell

A script is standalone and runnable. Order inside it, skipping what doesn't
apply:

1. shebang + `source` of the shared library
2. `require_cmd` for binaries this script doesn't install
3. script-level constants
4. package installation
5. config generation
6. `stow_config`
7. system integration — services, groups, initramfs
8. a closing `ok "<name> configured"` when the script did more than install
   packages

Use `#!/bin/bash` for scripts that source the shared library, `#!/usr/bin/env
bash` for the library itself and for standalone scripts that don't.

The library sets `set -euo pipefail`; never repeat it. Two consequences:

- An unchecked failing command aborts the script. That's intended — the
  installer entrypoint reports it and continues.
- `[ cond ] && cmd` as the **last** line of a script or function returns 1 when
  the condition is false, which aborts the caller. Use a real `if` when the line
  can end up last.

### Use the library

Don't call `pacman`, `yay` or `stow` directly. The helpers already handle
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

Pass every path `stow_config` might collide with, so a pre-existing real config
is backed up instead of breaking the stow:

```bash
stow_config zsh ~/.zshrc ~/.zprofile
```

Adding a helper to the library means adding it to the `export -f` list at the
bottom, and any new global to the `export` line above it.

### Syntax

- Quote every expansion: `"$path"`, `"${missing[@]}"`, `"$(dirname "$f")"`.
- `$VAR` normally; `${VAR}` when it needs bracing (`${MAPPER_NAME}.key`) or for
  the four inherited flags, always written `${DRY_RUN}`, `${YES}`, `${VERBOSE}`,
  `${PARSED_ARGS}`.
- `[ ]` for ordinary tests. `[[ ]]` only where it earns its keep — regex `=~`,
  glob matches, `&&`/`||` inside one test.
- Functions and locals `snake_case`, script-level constants `UPPER_SNAKE`,
  library-private helpers prefixed with `_`.
- Declare locals before assigning from a command substitution, so `set -e` sees
  the real exit status:

```bash
local release tag
release=$(curl -fsSL "$api")
tag=$(grep -oP '"tag_name":\s*"\K[^"]+' <<< "$release")
```

- Package lists: one or two packages stay on the call line, three or more get
  one per line with `\` continuations, indented one tab. Split into several
  calls when the groups mean different things — the grouping is documentation.

```bash
install_packages ufw

install_packages \
	xdg-desktop-portal \
	xdg-desktop-portal-hyprland \
	qt6-wayland
```

### Dry-run is a contract

`--dry-run` must never touch the system. `run_cmd`/`run_quiet`/`run_progress`
handle that for you. Anything that writes, prompts or shells out on its own
needs an explicit guard that prints what it *would* do:

```bash
if [ "${DRY_RUN}" = true ]; then
	info "[DRY-RUN] select colour palette -> $STATE_FILE"
elif [ ! -f "$STATE_FILE" ]; then
	...
fi
```

That covers heredocs into `cat`/`tee`, `read`/`select` prompts, and anything
piped. Read-only probes (`grep`, `pgrep`, `command -v`) run unguarded. Use
`info "[DRY-RUN] ..."` in your own code; the bare `[DRY-RUN] ` prefix without a
marker is `run_cmd`'s own format.

### Idempotency

```bash
if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
	ok "zsh is already the default shell"
else
	info "Setting zsh as the default shell..."
	run_cmd chsh -s "$ZSH_PATH"
fi
```

Guard the specific edit, not the whole file: grep for the exact line before a
`sed -i`, test for the unit file before writing it. Prefer commands that are
idempotent by construction — `mkdir -p`, `ln -sf`, `install -d`,
`systemctl enable --now`.

### Output

Four levels, and nothing else — no bare `echo` for status, no hand-rolled colour:

- `info "Enabling bluetooth service..."` — about to do something. Present
  participle, trailing `...`.
- `ok "bluetooth enabled"` — done, or already the case. Lowercase, past tense.
- `warn "..."` — recoverable; goes to stderr.
- `die "..."` — unrecoverable; exits 1.

Close a manual step with `ok`; a script that only installs packages needs no
closing line. End with a `warn` for anything the user must still do by hand.

### Writing files outside stow

Stowing is the default. Write a file directly only when something else rewrites
it in place and would follow the symlink back into the repo, or when it lives
outside `$HOME` (systemd units, `/etc`). Quote the heredoc delimiter unless you
actually want expansion:

```bash
cat >"$USER_DIRS" <<'EOF'
XDG_DOWNLOAD_DIR="$HOME/Downloads"
EOF
```

Name the generating script in the file's header so the next reader knows where
to edit.

### sudo

Only for what genuinely needs root — `/etc`, system services, `usermod`.
User-level systemd goes through `systemctl --user` with no sudo. Call
`prime_sudo` before a block that would otherwise prompt from inside a captured
or backgrounded command; the entrypoint and the package helpers already prime,
so a plain script rarely needs it.

### Before committing

`make lint` (shellcheck -x) and `make check` (bash -n) must both be clean.
Suppress a check inline with a `# shellcheck disable=SCxxxx` and a reason on the
same line, never by widening the shellcheck config. Then run the script with
`--dry-run`, and a second time for real to confirm it's idempotent.

## Lua (Hyprland)

- Config is data: one `hl.config{}` table per topic, mirroring upstream option
  names exactly (`gaps_in`, `resize_on_border`) so the wiki stays searchable.
- Bind and dispatch through the dispatch objects (`hl.dsp.*`), never raw command
  strings.
- `local` declarations at the top of the file; locals `camelCase`, tuning
  constants `UPPER_SNAKE`.
- Colours come from the global palette table, never as hex literals.
- Machine profiles layer on top of the defaults. A profile file contains only
  what differs — never a copy of the default.
- Generate repetition with a loop rather than pasting ten near-identical lines.

## QML (quickshell)

- One component per file; the filename is the component name, `PascalCase`.
- Inside a component: `id` first (`id: root` for the top level), then properties,
  then signal handlers, then child items.
- Every colour, spacing, font and animation duration comes from the `Theme`
  singleton. No hex literals and no magic pixel numbers in components — add a
  property to `Theme` instead.
- `readonly property` for anything not assigned after construction.
- Expose configuration with `property alias` rather than reaching into a child
  from outside.
- Keep long-lived state and external process handling in a service singleton;
  components stay presentational.

## Python

- Standard library only — no third-party dependencies.
- Type-annotated signatures, `pathlib` over string paths, module-level
  `UPPER_SNAKE` constants for paths and key lists.
- Validate input up front and fail with a message naming the offending file and
  key. A missing key is an error, never a silent default.
- Do all the work in memory and write only once everything succeeded, so a
  failure never leaves half-written output.
- Skip writing a file whose content is unchanged; mtime churn makes watchers
  reload for nothing.

## Config files (toml, json, conf)

- Group related keys with a blank line and a `#` comment naming the group.
- Keep upstream key order where a program documents one; otherwise order by
  topic, not alphabetically.
- JSON with comments (JSONC) is fine where the program accepts it — say *why* a
  non-default setting is set.
