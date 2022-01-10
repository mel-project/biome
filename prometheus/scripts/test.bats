source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Version matches" {
  output="$(prometheus --version | head -n 1 | awk '{print $3}')"
  [ "$output" = "${pkg_version}" ]
}

@test "Help flag works" {
  run prometheus --help
  [ $status -eq 0 ]
}

@test "Curl returns 302" {
  output="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9090)"
  [ "$output" = "302" ]
}

@test "Curl shows the proper link" {
  output="$(curl --silent http://127.0.0.1:9090 | htmlq --attribute href a | grep "/graph")"
  [ "$output" = "/graph" ]
}

@test "Graph link can be reached" {
  output="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9090/graph)"
  [ "$output" = "200" ]
}

@test "Service is running" {
  [ "$(sudo bio svc status | grep "prometheus\.default" | awk '{print $4}' | grep up)" ]
}

@test "Listening on port 9090" {
  output="$(sudo netstat -peanut | grep LISTEN | grep prometheus | awk '{print $4}' | tr -d ':')"
  [ "${output}" -eq 9090 ]
}