# shellcheck disable=2016,2086,2164

bats_require_minimum_version 1.5.0

bats_load_library bats-support
bats_load_library bats-assert

setup() {

  TEST_TMP=$BATS_TEST_TMPDIR/tmp
  mkdir "$TEST_TMP"

  # don't write to $HOME
  export HOME="$BATS_TEST_TMPDIR/home"

  # seed PWD with ./testenv and enter it
  local cwd="$BATS_TEST_TMPDIR/cwd"
  cp -a "$TEST_ENV" "$cwd"
  cd "$cwd"

}

_capture() {
  local condition=$1 type
  shift
  type=$(type -t $1)
  if [[ $type == "file" ]]; then
    local status
    [ $condition == assert ] && status=0 || status=1
    run -$status --separate-stderr "$@"
  else
    local stdout_file stderr_file
    stdout_file="$TEST_TMP/$BATS_TEST_NAME-stdout"
    stderr_file="$TEST_TMP/$BATS_TEST_NAME-stderr"
    (
    if [ -n "${TRACE:-}" ]; then
      _$condition "$@" > >(tee "$stdout_file") 2> >(tee "$stderr_file")
    else
      _$condition "$@" >"$stdout_file" 2>"$stderr_file"
    fi
    ) && status=0 || status=$?
    # shellcheck disable=2034
    output=$(<"$stdout_file")
    stderr=$(<"$stderr_file")
    if [ $status -ne 0 ]; then
      echo "$stderr" >&2
      return $status
    fi
  fi
}

eval _"$(declare -f assert)"
assert() { _capture assert "$@"; }

eval _"$(declare -f refute)"
refute() { _capture refute "$@"; }

_err_as_out() {
  local _output="${output:-}"
  # shellcheck disable=2034,2154
  output="$stderr"
  "$@" && status=0 || status=$?
  output="$_output"
  return $status
}

assert_error() { _err_as_out assert_output "$@"; }

refute_error() { _err_as_out refute_output "$@"; }

assert_var() {
  local var=$1 value="${2:-OK}"
  _assert eval "$(direnv export bash)"
  assert_equal "${!var}" "$value" "$var"
}

assert_find_count() {
  local find_args="$1" count=$2
  assert_equal "$(find $find_args | wc -l)" $count
}

_direnv_exec() {
  local condition=$1 stderr="$2"
  $condition direnv exec . true
  assert_error --partial "$stderr"
}

assert_direnv_exec() { _direnv_exec assert "$@"; }

refute_direnv_exec() { _direnv_exec refute "$@"; }

_setup_envrc() {
  local content="$1"
  cat <<EOF >.envrc
strict_env
source "$DIRENVRC"
$content
EOF
  direnv allow
}

assert_setup_envrc() {
  local envrc="$1" stderr="${2:-$RENEWED_CACHE}"
  _setup_envrc "$envrc"
  assert_direnv_exec "$stderr"
}

refute_setup_envrc() {
  local envrc="$1" stderr="$2"
  _setup_envrc "$envrc"
  refute_direnv_exec "$stderr"
}
