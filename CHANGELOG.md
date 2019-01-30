# `nginx-sidecar` changelog

## 0.3.0

- Allow `client_body_buffer_size` to be overridden.

## 0.2.2

- Add `--max-time` to the curl health check.

## 0.2.1

- Wait for the application to pass healthchecks before listening
  (and accepting) downstream healthchecks.

## 0.2.0

- Pass original request scheme to consuming application

## 0.1.0

- Pass original request hostname to consuming application

## 0.0.1

- Initial version
