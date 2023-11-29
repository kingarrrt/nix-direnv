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

# {{{ checks

SYSTEM := $(shell printf %s-%s $$(uname -m) $$(uname -s | tr "[:upper:]" "[:lower:]"))

# cache nix flake checks
CHECKS_MK = .checks.mk
$(CHECKS_MK): flake.nix Makefile
	printf "CHECKS = %s" "$$(nix flake show --json 2>/dev/null \
		| jq --raw-output ".checks.\"$(SYSTEM)\" | keys | .[]" \
		| tr \\n " ")" > $@

include $(CHECKS_MK)

ifdef CHECKS

TEST_TARGET = test

define test

.PHONY: test-$1
test-$1:
	nix develop .#$1 --command make $$(TEST_TARGET) $(if $(ARGV),ARGV="$(ARGV)")

.PHONY: test-cov-$1
test-cov-$1: TEST_TARGET = test-cov
test-cov-$1: test-$1

define HELP +=

  test-$1
  test-cov-$1
endef

endef

TEST_PREFIX = package-test-runner-

TESTS = $(patsubst $(TEST_PREFIX)%,%,$(filter $(TEST_PREFIX)%,$(CHECKS)))

UNIQUE_TESTS = $(filter nix%,$(TESTS))

$(foreach _test,$(TESTS),$(eval $(call test,$(_test))))

.PHONY: tests
tests: $(addprefix test-,$(UNIQUE_TESTS))

# generate github check matrix, see .github/workflows/test.yml
ifdef GITHUB_OUTPUT

.PHONY: github-test-matrix
github-test-matrix:
# filter out stable and unstable aliases
	printf "tests=%s" '["$(shell sed 's/ /","/g' <<< "$(UNIQUE_TESTS)")"]' >> $(GITHUB_OUTPUT)

endif

endif # ifdef CHECKS

# }}}
