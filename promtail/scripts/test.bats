source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Version matches" {
  result="$(promtail -version | head -1 | awk '{print $3}')"
  [ "$result" = "${pkg_version}" ]
}

@test "Help flag works" {
  run promtail --help
  [ $status -eq 2 ]
}

@test "Service is running" {
  [ "$(sudo bio svc status | grep "promtail\.default" | awk '{print $4}' | grep up)" ]
}

@test "Listening on port 9080" {
  result="$(sudo netstat -peanut | grep LISTEN | grep promtail | grep 9080 | awk '{print $4}' | tr -d ":")"
  [ "${result}" -eq 9080 ]
}

@test "Listening on port 9095" {
  result="$(sudo netstat -peanut | grep LISTEN | grep promtail | grep 9095 | awk '{print $4}' | tr -d ":")"
  [ "${result}" -eq 9095 ]
}