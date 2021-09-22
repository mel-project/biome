source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Version matches" {
  result="$(themelio-node --version | head -1 | awk '{print $2}')"
  [ "$result" = "${pkg_version}" ]
}

@test "Help flag works" {
  run themelio-node --help
  [ $status -eq 0 ]
}

@test "Service is running" {
  result="$(nmap 127.0.0.1 -p 11814 | tail -3 | head -1 | awk '{print $2}')"
  [ "$result" = "open" ]
}

@test "Metrics webserver is running" {
  result="$(nmap 127.0.0.1 -p 8080 | tail -3 | head -1 | awk '{print $2}')"
  [ "$result" = "open" ]
}

@test "Metrics webserver returns 200" {
  result="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/metrics)"
  [ "$result" = "200" ]
}







TEST_PKG_VERSION="$(echo "${TEST_PKG_IDENT}" | cut -d/ -f3)"

@test "Version matches" {
  result="$(hab pkg exec ${TEST_PKG_IDENT} grafana-server -v 2>&1 | head -n 1 | awk '{print $2}')"
  [ "$result" = "${TEST_PKG_VERSION}" ]
}

@test "Service is running" {
  [ "$(hab svc status | grep "grafana\.default" | awk '{print $4}' | grep up)" ]
}

@test "Listening on port 80" {
  result="$(netstat -peanut | grep LISTEN | grep grafana| awk '{print $4}' | tr -d ':')"
  [ "${result}" -eq 80 ]
}