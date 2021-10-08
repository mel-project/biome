source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Version matches" {
  result="$(grafana-server -v | head -n 1 | awk '{print $2}')"
  [ "$result" = "${pkg_version}" ]
}

@test "Help flag works" {
  run grafana-server --help
  [ $status -eq 0 ]
}

@test "Curl returns 302" {
  result="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000)"
  [ "$result" = "302" ]
}

@test "Service is running" {
  [ "$(bio svc status | grep "grafana\.default" | awk '{print $4}' | grep up)" ]
}

@test "Listening on port 3000" {
  result="$(netstat -peanut | grep LISTEN | grep grafana| awk '{print $4}' | tr -d ':')"
  [ "${result}" -eq 3000 ]
}