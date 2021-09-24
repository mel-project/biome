source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Help flag works" {
  run loki --help
  [ $status -eq 2 ]
}

@test "Service is running" {
  [ "$(bio svc status | grep "loki\.default" | awk '{print $4}' | grep up)" ]
}

@test "Listening on port 3100" {
  result="$(netstat -peanut | grep LISTEN | grep loki | grep 3100 | awk '{print $4}' | awk '{split($0, a, ":"); print a[2]}')"
  [ "${result}" -eq 3100 ]
}

@test "Listening on port 9095" {
  result="$(netstat -peanut | grep LISTEN | grep loki | grep 9095 | awk '{print $4}' | awk '{split($0, a, ":"); print a[2]}')"
  [ "${result}" -eq 9095 ]
}