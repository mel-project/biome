source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Version matches" {
  output="$(grafana-server -v | head -n 1 | awk '{print $2}')"
  [ "$output" = "${pkg_version}" ]
}

@test "Help flag works" {
  run grafana-server --help
  [ $status -eq 1 ]
}

@test "Curl returns 302" {
  output="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000)"
  [ "$output" = "302" ]
}

@test "Curl shows the proper link" {
  output="$(curl --silent http://127.0.0.1:3000 | htmlq --attribute href a | grep "/login")"
  [ "$output" = "/login" ]
}

@test "Login link can be reached" {
  output="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/login)"
  [ "$output" = "200" ]
}

@test "Service is running" {
  [ "$(bio svc status | grep "grafana\.default" | awk '{print $4}' | grep up)" ]
}

@test "Listening on port 3000" {
  output="$(netstat -peanut | grep LISTEN | grep grafana| awk '{print $4}' | tr -d ':')"
  [ "${output}" -eq 3000 ]
}