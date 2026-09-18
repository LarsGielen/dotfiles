#!/bin/bash
# Parse after defining usage, and accept module names as arguments.
# shellcheck disable=SC2034 # both read by lib/common.sh
COMMON_AUTO_PARSE=false ACCEPT_POSITIONAL=true
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

MODULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/modules" && pwd)"

# 'base' bootstraps the system (git, yay/AUR, hardware, …); run it before any
# app module, which may depend on what base installs.
BOOTSTRAP=(base)

module_path() { echo "$MODULES_DIR/install-$1.sh"; }

list_modules() {
    local f name
    for f in "$MODULES_DIR"/install-*.sh; do
        name="$(basename "$f")"
        name="${name#install-}"
        echo "${name%.sh}"
    done
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [options] [module...]

Install dotfiles modules. With no module given, choose interactively.

Options:
  --all          Install every available module
  --dry-run      Print actions without executing them
  --yes, -y      Skip the confirmation prompt
  --verbose, -v  Show full package-manager output
  --help, -h     Show this help and list modules

Available modules:
$(list_modules | sed 's/^/  /')
EOF
}

choose_interactively() {
    local i reply n
    info "Available modules:"
    for i in "${!ALL_MODULES[@]}"; do
        printf '  %2d) %s\n' "$((i + 1))" "${ALL_MODULES[$i]}"
    done
    echo
    read -rp "Enter numbers (space-separated), 'all', or blank to cancel: " reply
    if [ -z "$reply" ]; then
        warn "Nothing selected."
        exit 0
    fi
    if [ "$reply" = all ]; then
        CHOSEN=("${ALL_MODULES[@]}")
        return
    fi
    for n in $reply; do
        [[ "$n" =~ ^[0-9]+$ ]] || die "Invalid selection: $n"
        { [ "$n" -ge 1 ] && [ "$n" -le ${#ALL_MODULES[@]} ]; } || die "Out of range: $n"
        CHOSEN+=("${ALL_MODULES[$((n - 1))]}")
    done
}

parse_args "$@"

# --- decide which modules to run -------------------------------------------
mapfile -t ALL_MODULES < <(list_modules)
CHOSEN=()
if [ "$WANT_ALL" = true ]; then
    CHOSEN=("${ALL_MODULES[@]}")
elif [ ${#POSITIONAL_ARGS[@]} -gt 0 ]; then
    CHOSEN=("${POSITIONAL_ARGS[@]}")
else
    choose_interactively
fi

for m in "${CHOSEN[@]}"; do
    [ -f "$(module_path "$m")" ] || die "Unknown module: $m"
done

# Order: chosen bootstrap modules first, then the rest (de-duplicated).
RUN_LIST=()
add_unique() {
    local x
    for x in ${RUN_LIST[@]+"${RUN_LIST[@]}"}; do
        [ "$x" = "$1" ] && return 0
    done
    RUN_LIST+=("$1")
}
for b in "${BOOTSTRAP[@]}"; do
    for m in "${CHOSEN[@]}"; do
        [ "$m" = "$b" ] && add_unique "$b"
    done
done
for m in "${CHOSEN[@]}"; do
    add_unique "$m"
done

confirm "About to install ${#RUN_LIST[@]} module(s): ${RUN_LIST[*]}"
prime_sudo
run_modules continue module module_path "${RUN_LIST[@]}"
