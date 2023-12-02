# {{{ setup

MAKEFLAGS += \
	--no-builtin-rules \
	--no-builtin-variables \
	--no-print-directory \
	--warn-undefined-variables

SHELL = bash
export SHELLOPTS=errexit:pipefail

# target command line extra args
ARGV ?=

ifndef NIX_BUILD_CORES
	NIX_BUILD_CORES = $(shell nproc)
endif

# }}}

# {{{ test

export BATS_FILE_EXTENSION = bash

TEST_PATH ?= tests

TEST = $(strip bats $(ARGV) $(TEST_PATH))

.PHONY: test
test: override ARGV += -j $(NIX_BUILD_CORES)
test:
	$(TEST)

.PHONY: test-cov
test-cov: TEST := rm -rf coverage && bashcov --bash-path $$(command -v bash) -- $(TEST)
test-cov: test

# }}}
