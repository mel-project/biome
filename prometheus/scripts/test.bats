source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Version matches" {
  result="$(prometheus --version | head -n 1 | awk '{print $3}')"
  [ "$result" = "${pkg_version}" ]
}

@test "Help flag works" {
  run prometheus --help
  [ $status -eq 0 ]
}

@test "Curl returns 302" {
  result="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9090)"
  [ "$result" = "302" ]
}

@test "Curl shows the proper link" {
  result="$(curl --silent http://127.0.0.1:9090 | htmlq --attribute href a | grep "/graph")"
  [ "$result" = "/graph" ]
}

@test "Graph link can be reached" {
  result="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9090/graph)"
  [ "$result" = "200" ]
}

@test "Service is running" {
  [ "$(sudo bio svc status | grep "prometheus\.default" | awk '{print $4}' | grep up)" ]
}

@test "Listening on port 9090" {
  result="$(sudo netstat -peanut | grep LISTEN | grep prometheus | awk '{print $4}' | tr -d ':')"
  [ "${result}" -eq 9090 ]
}