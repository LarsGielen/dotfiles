#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# Compressed swap in RAM. zram-generator is a systemd generator: it reads this
# file at boot, so there is no service to enable.

install_packages zram-generator

ZRAM_CONF="/etc/systemd/zram-generator.conf"
ZRAM_BODY="[zram0]
compression-algorithm = zstd"

# write_root_file runs sudo tee inside a pipe, so credentials must already
# be cached.
prime_sudo

write_root_file "$ZRAM_CONF" "$ZRAM_BODY"

ok "zram swap configured (takes effect at next boot)"
