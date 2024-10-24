# nginx sidecar

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/deliveroo/nginx-sidecar/tree/master.svg?style=shield&circle-token=01448f7fc138e431d175c0958cbb5f9f90c8872e)](https://dl.circleci.com/status-badge/redirect/gh/deliveroo/nginx-sidecar/tree/master)

A simple nginx `Reverse Proxy` sidecar, which can be placed in front an application's web container to queue requests and to provide statistics to New Relic about request queuing.

:warning: This relies on the legacy `--link` flag of Docker/ECS and requires the `bridged` networking mode which is the default networking mode in our tasks.

### Contents
- [Set up](#set-up)
    - [Example](#example)
    - [Requirements](#requirements)
    - [Optional customisations](#optional-customisations)
- [Stats Monitoring](#stats-monitoring)
- [Local Debugging](#local-debugging)
- [Contributing](#contributing)

## Set up

`nginx` can be placed in front of your application using the `sidecars` section of a Hopper service definition in your Hopper config.

Read the [requirements](#requirements) and [optional customisations](#optional-customisations) sections for information on how to customise your `nginx` set up.

Full details of the schema can be found at <https://hopper.deliveroo.net/config-docs>, note that customisation is done through Environment Variables and this information isn't included in the schema (yet).

### Example

The following is an example of how to set up `nginx` with default settings, passing in the required fields.

```yaml
# ...

services:
  - type: Hopper::Services::ECS::Service
    name: web
    sidecars:
      nginx:
        # By default the Nginx container will be named after the service, in this case "web"
        # and by defining an Nginx port we will assume your app container uses the same port.
        # Note: both the container name and the app port are configurable if needed
        nginx_port: 8008
    taskDefinitions:
        containerDefinitions:
          # Your application container, defined as normal, but named 'app'
          # Note: you can change the container name you use here, see the
          # optional customisation sections of this README for more information
          - name: app
            cpu: 1024
            memory: 1024
            command: "exec puma -p 3001 -C config/puma.rb"
  # ...
```


## Requirements

There is only one required field when defining an `nginx` sidecar in Hopper:

- `nginx_port` must be set to the port nginx should bind to.

### App port

`app_port` can be set to define what port your application container is listening on and this is the port `nginx` will forward requests to.

By default if you don't define an `app_port` then it will be set to the value of `nginx_port`.

### Nginx Container Name

`container_name` can be set to change the name of the `nginx` container.

By default the container name will be set to the name of the service which is usually what you want.

## Optional Customisations

`nginx` can be customised using environment variables, these are passed to the `environment` field of the `nginx` config:
```yaml
services:
  - type: Hopper::Services::ECS::Service
    name: web
    sidecars:
      nginx:
        nginx_port: 8008
        environment:
          - name: APP_HOST
            value: 'app-worker'
          # ...
    taskDefinition:
      # ...
```

Here is a list of available customisation environment variables:

- `APP_HOST` (default: app) the name of your application container. You can use this if you want to give your application container a more meaningful name.
- `CLIENT_BODY_BUFFER_SIZE` (default: 8k) sets the client_body_buffer_size.
- `NGINX_CLIENT_MAX_BODY_SIZE` (default: 5MB) sets the maximum request body size.
- `NGINX_KEEPALIVE_TIMEOUT` (default: 20s) sets keepalive_timeout.
- `NGINX_LOGS_INCLUDE_STATUS_CODE_REGEX` (default: not set, log all) configures the included access logs.  Use a regex like `^[45]` to include only 4xx and 5xx status codes.
- `NGINX_STATUS_ALLOW_FROM` (default: all) IP, CIDR, `all` for the nginx config's `allow` statement (<http://nginx.org/en/docs/http/ngx_http_access_module.html>), see [Stats Monitoring](#stats-monitoring) for details.
- `NGINX_STATUS_PORT` (default: 81) sets the port to run the status module on. See [Stats Monitoring](#stats-monitoring) for details.
- `PROXY_TIMEOUT` (default: 60s) sets proxy_connect_timeout, proxy_send_timeout, proxy_read_timeout
- `PROXY_TIMEOUT` (default: 60s) sets proxy_connect_timeout, proxy_send_timeout, proxy_read_timeout values.


## Stats Monitoring

We've enabled `http_stub_status_module` access to help with monitoring integration. By default it is listening on port _81_ with `allow all` as restriction. You can customize this with:
- `NGINX_STATUS_PORT`
- `NGINX_STATUS_ALLOW_FROM`

## Local debugging

To check the connection between your app and the nginx reverse proxy sidecar you can use docker compose. First you have to download the image from our `platform` account.

- Get AWS credentials for our `platform` account, readonly is fine.
- Run `./scripts/download_image <version>`, by default `staging` will be downloaded.

Then run `docker compose up`:

```yaml
version: "3.9"
services:
  app:
    container_name: "foo-app"
    build:
      context: .
    # No Port exposed in the main app

sidecar:
    container_name: "foo-sidecar"
    image: "930404128139.dkr.ecr.eu-west-1.amazonaws.com/nginx-sidecar:<VERSION>"
    ports:
      - "8001:8001"
    links:
      - app
    depends_on:
      - app
    environment:
      - NGINX_PORT=8001
      - APP_PORT=8000
      - APP_HOST=app
```

## Contributing

This repository has a `staging` branch that builds and pushes the image with a `staging` to allow changes to be tested before merging and bumping `VERSION`.

The CI for the master branch reads the `VERSION` file and creates a new image tag `nginx:VERSION` if it doesn't already exist. A `latest` version tag is also added for ease of use.
Any push to the staging branch will upload the image with the tag `staging`.

The `VERSION` should be incremented each time changes are made.
