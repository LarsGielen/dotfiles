SHELL := /bin/bash
SCRIPTS := $(wildcard *.sh modules/*.sh modules/base/*.sh lib/*.sh)

.PHONY: lint check

# Static analysis with shellcheck.
lint:
	shellcheck -x $(SCRIPTS)

# Quick bash syntax check.
check:
	@for f in $(SCRIPTS); do bash -n "$$f" && echo "ok: $$f"; done
