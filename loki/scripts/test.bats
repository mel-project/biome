source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Help flag works" {
  run loki -help
  [ $status -eq 2 ]
}

@test "HTTP port is running" {
  result="$(netstat -lnp | grep LISTEN | grep loki | grep 3100 | awk '{print $4}' | awk -F':' '{print $2}')"
  [ "$result" = "3100" ]
}

@test "gRPC port is running" {
  result="$(netstat -lnp | grep LISTEN | grep loki | grep 9095 | awk '{print $4}' | awk -F':' '{print $2}')"
  [ "$result" = "9095" ]
}