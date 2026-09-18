SHELL := /bin/bash

# Every tracked script, NUL-separated so no path is ever word-split.
LS_FILES = git ls-files -z
SHFMT ?= shfmt
LUAC ?= luac

.PHONY: lint check

# Static analysis and formatting. qmllint is deliberately absent: without
# quickshell's type information it reports nothing but false positives.
lint:
	$(LS_FILES) '*.sh' | xargs -0 shellcheck -x
	$(LS_FILES) '*.sh' | xargs -0 $(SHFMT) -d -i 4 -ci
	$(LS_FILES) '*.lua' | xargs -0 -n1 $(LUAC) -p --
	python3 -m py_compile theme/generate.py

# Syntax checks, plus a dry run of the theme generator, which validates every
# palette and renders every template without writing anything.
check:
	@$(LS_FILES) '*.sh' | xargs -0 -n1 bash -n
	@python3 theme/generate.py --dry-run >/dev/null
	@echo "check ok"
