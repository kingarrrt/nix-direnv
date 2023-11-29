load lib
load use_common

USE="use nix"

@test "basic usage" {
  _test_use_common
}

@test attrs {
  assert_setup_envrc "$USE -A subshell"
  assert_var THIS_IS_A_SUBSHELL
}

_envrc_with_argstr() {
  assert_setup_envrc "$USE --argstr someArg OK"
}

@test args {
  _envrc_with_argstr
  assert_var SHOULD_BE_SET
}

@test "unset NIX_PATH" {
  _envrc_with_argstr
  # shellcheck disable=2064
  trap "NIX_PATH=$NIX_PATH" EXIT
  unset NIX_PATH
  assert_var SHOULD_BE_SET
}

# XXX: what's the point of this?
@test "no files" {
  assert_setup_envrc "$USE -p hello"
  assert direnv status
  refute_output 'Loaded watch: "."'
}
