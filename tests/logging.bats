#!/usr/bin/env bats

teardown() {
  docker compose -f docker-compose.ci.yml rm --stop --force --volumes 2> /dev/null
}

setup() {
  docker compose -f docker-compose.ci.yml build nginx-test 2> /dev/null
}

@test "with no include status code reg ex set it logs every request" {
  export NGINX_LOGS_INCLUDE_STATUS_CODE_REGEX=""
  docker compose -f docker-compose.ci.yml up --detach nginx-test 2> /dev/null
  docker compose -f docker-compose.ci.yml run wait-test wfi nginx-test:8001 --timeout=60

  for response_status in 200 300 400 500; do
    curl --head --silent --header "x-set-response-status-code: ${response_status}" http://localhost:8001/anything

    run docker compose -f docker-compose.ci.yml logs nginx-test 2> /dev/null

    echo "expected ${lines[-1]} to contain ${response_status}"

    [[ "${lines[-1]}" =~ status=${response_status} ]]
  done
}

@test "with include status code reg ex set to include 200 it logs only 200 requests" {
  export NGINX_LOGS_INCLUDE_STATUS_CODE_REGEX="^[2]"
  docker compose -f docker-compose.ci.yml up --detach nginx-test 2> /dev/null
  docker compose -f docker-compose.ci.yml run wait-test wfi nginx-test:8001 --timeout=60

  curl --head --silent --header "x-set-response-status-code: 200" http://localhost:8001/anything

  run docker compose -f docker-compose.ci.yml logs nginx-test 2> /dev/null

  echo "expected ${lines[-1]} to contain status=200"

  [[ "${lines[-1]}" =~ status=200 ]]

  log_count=${#lines[@]}

  for response_status in 300 400 500; do
    curl --head --silent --header "x-set-response-status-code: ${response_status}" http://localhost:8001/anything

    run docker compose -f docker-compose.ci.yml logs nginx-test 2> /dev/null

    echo "expected ${lines[-1]} to not contain status=${response_status}"
    echo "expected ${log_count} log lines but got ${#lines[@]}"

    [[ "${lines[-1]}" =~ status=200 ]]
    [[ ! "${lines[-1]}" =~ status=${response_status} ]]
    [ ${#lines[@]} -eq ${log_count} ]
  done
}

@test "with include status code reg ex set to include 200 and 400 it logs only 200 and 400 requests" {
  export NGINX_LOGS_INCLUDE_STATUS_CODE_REGEX="^[24]"
  docker compose -f docker-compose.ci.yml up --detach nginx-test 2> /dev/null
  docker compose -f docker-compose.ci.yml run wait-test wfi nginx-test:8001 --timeout=60

  for response_status in 200 400; do
    curl --head --silent --header "x-set-response-status-code: ${response_status}" http://localhost:8001/anything

    run docker compose -f docker-compose.ci.yml logs nginx-test 2> /dev/null

    echo "expected ${lines[-1]} to contain ${response_status}"

    [[ "${lines[-1]}" =~ status=${response_status} ]]
  done

  log_count=${#lines[@]}

  for response_status in 300 500; do
    curl --head --silent --header "x-set-response-status-code: ${response_status}" http://localhost:8001/anything

    run docker compose -f docker-compose.ci.yml logs nginx-test 2> /dev/null

    echo "expected ${lines[-1]} to not contain status=${response_status}"
    echo "expected ${log_count} log lines but got ${#lines[@]}"

    [[ "${lines[-1]}" =~ status=400 ]]
    [[ ! "${lines[-1]}" =~ status=${response_status} ]]
    [ ${#lines[@]} -eq ${log_count} ]
  done
}

@test "path does not include query params by default" {
  docker compose -f docker-compose.ci.yml up --detach nginx-test 2> /dev/null
  docker compose -f docker-compose.ci.yml run wait-test wfi nginx-test:8001 --timeout=60

  curl --head --silent http://localhost:8001/foo/bar?something-secret=boo

  run docker compose -f docker-compose.ci.yml logs nginx-test 2> /dev/null
  echo "expected ${lines[-1]} to contain the path /foo/bar but not the query param something-secret=boo"

  [[ ! "${lines[-1]}" =~ "something-secret=boo" ]]
  [[ "${lines[-1]}" =~ "/foo/bar" ]]
}

@test "with include query params set path does include query params by default" {
  export NGINX_LOGS_INCLUDE_QUERY_PARAMS="true"
  docker compose -f docker-compose.ci.yml up --detach nginx-test 2> /dev/null
  docker compose -f docker-compose.ci.yml run wait-test wfi nginx-test:8001 --timeout=60

  curl --head --silent http://localhost:8001/foo/bar?something-secret=boo

  run docker compose -f docker-compose.ci.yml logs nginx-test 2> /dev/null

  echo "expected ${lines[-1]} to contain the path /foo/bar including the query param something-secret=boo"

  [[ "${lines[-1]}" =~ "something-secret=boo" ]]
  [[ "${lines[-1]}" =~ "/foo/bar" ]]
}

