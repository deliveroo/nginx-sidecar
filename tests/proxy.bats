#!/usr/bin/env bats

teardown() {
  docker compose -f docker-compose.ci.yml rm --stop --force --volumes
}

setup() {
  docker compose -f docker-compose.ci.yml build nginx-test 2> /dev/null
}

@test "proxy request to echo server with 200 response" {
  docker compose -f docker-compose.ci.yml up --detach
  docker compose -f docker-compose.ci.yml run wait-test wfi nginx-test:8001 --timeout=60

  run curl --fail --header "x-set-response-status-code: 200" http://localhost:8001/anything

  [ "${status}" -eq 0 ]
}

@test "proxy request to echo server with response body" {
  docker compose -f docker-compose.ci.yml up --detach
  docker compose -f docker-compose.ci.yml run wait-test wfi nginx-test:8001 --timeout=60

  run curl --silent --fail --header "x-set-response-status-code: 200" --header "X-Set-Response-Content-Type: text/plain" --data "test body" http://localhost:8001/anything?response_body_only=true

  [ "${output}" == "test body" ]
}

