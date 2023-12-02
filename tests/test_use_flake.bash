load lib
load use_common

USE="use flake"

@test "basic usage" {
  _test_use_common
  assert_find_count ".direnv/flake-inputs -type l" 4
  assert_var IS_SET
}

@test "bad usage" {
  local message="the first argument must be a flake expression"
  local did_you_mean="did you mean '$USE . --impure'"
  refute_setup_envrc "$USE --impure" "$message. $did_you_mean"
  refute_setup_envrc "$USE --impure ." "$message"
  # refute_error --partial "$did_you_mean"
}

@test "manual reload" {
  assert_setup_envrc "nix_direnv_manual_reload; $USE" "cache does not exist"
  .direnv/bin/nix-direnv-reload
  assert_direnv_exec "$USING_CACHED"
  touch .envrc
  assert_direnv_exec "cache is out of date"
  .direnv/bin/nix-direnv-reload
  assert_direnv_exec "$USING_CACHED"
}
