source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Rust version matches" {
  output="$(rustc --version | awk '{print $2}')"
  [ "$output" = "${rustc_version}" ]
}

@test "Help flag works" {
  run rustc --help
  [ $status -eq 0 ]
}

@test "Cargo version matches" {
  output="$(cargo --version | awk '{print $2}')"
  [ "$output" = "${cargo_version}" ]
}