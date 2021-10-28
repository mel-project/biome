source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Rust version matches" {
  result="$(rustc --version | awk '{print $2}')"
  [ "$result" = "${pkg_version}" ]
}

@test "Help flag works" {
  run rustc --help
  [ $status -eq 0 ]
}

@test "Cargo version matches" {
  result="$(cargo --version | awk '{print $2}')"
  [ "$result" = "${pkg_version}" ]
}

@test "Help flag works" {
  run cargo --help
  [ $status -eq 0 ]
}