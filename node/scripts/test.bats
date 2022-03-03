source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Node version matches" {
  output="$(node --version)"
  [ "$output" = "v${pkg_version}" ]
}

@test "Node help flag works" {
  run node --help
  [ $status -eq 0 ]
}