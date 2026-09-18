# shellcheck shell=bash disable=SC2034 # sourced by load_profile
# Main desktop: RTX 5070 Ti, XP-Pen tablet, wired ethernet.
MACHINE_ASPECTS=(nvidia tunables xppentablet networkd)

# The wired interface systemd-networkd-wait-online waits for at boot.
ETH_INTERFACE="eno1"
