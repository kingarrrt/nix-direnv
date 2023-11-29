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
