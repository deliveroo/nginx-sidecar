# nginx sidecar

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/deliveroo/nginx-sidecar/tree/master.svg?style=shield&circle-token=01448f7fc138e431d175c0958cbb5f9f90c8872e)](https://dl.circleci.com/status-badge/redirect/gh/deliveroo/nginx-sidecar/tree/master)

A simple nginx `Reverse Proxy` sidecar, which can be placed in front an application's web container to queue requests and to provide statistics to New Relic about request queuing.

## Requirements

- The application must be linked (either by Docker `--link` or ECS `links` section) as `app`.
- The `NGINX_PORT` environment variable should be set to the port nginx should bind to.
- The `APP_PORT` environment variable should be set to the port that the application is bound to inside the `app` container.

## Stats Monitoring

We've enabled `http_stub_status_module` access to help with monitoring integration. By default it is listening on port _81_ with `allow all` as restriction. You can customize this with:

- `NGINX_STATUS_PORT` (default `81`) a port to run the status module on
- `NGINX_STATUS_ALLOW_FROM` (default `all`) IP, CIDR, `all` for the nginx config's `allow` statement (<http://nginx.org/en/docs/http/ngx_http_access_module.html>)

## Local debugging

To check the connection between your app and the nginx reverse proxy sidecar, `docker compose up`:

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
    image: "deliveroo/nginx-sidecar:0.3.9"
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

## Optional Requirements

- `PROXY_TIMEOUT` sets proxy_connect_timeout, proxy_send_timeout, proxy_read_timeout values. (default: 60s)
- `NGINX_LOGS_INCLUDE_STATUS_CODE_REGEX` configures the included access logs.  Use a regex like `^[45]` to include only 4xx and 5xx status codes. The default will log every status code.
- `KEEPALIVE_TIMEOUT` sets keepalive_timeout. (default: 20s)

## Example

[AWS documentation](https://aws.amazon.com/blogs/compute/nginx-reverse-proxy-sidecar-container-on-amazon-ecs/) shows how to deploy this type of sidecare into `AWS Elastic Container Service ( ECS )`:

```yaml
# ...

services:
  web:
    containerDefinitions:
      # Your application container, defined as normal, but without any `portMappings` section:
      app:
        cpu: 1024
        memory: 1024
        essential: true
        command: "exec puma -p 3001 -C config/puma.rb"

      # A separate `containerDefinition` should be added for the nginx sidecar.
      # The sidecar doesn't care what this is called, but it'll need to match the `process_name` in your app's Terraform, as this is where Hopper expects to find the bound port.
      web:
        # Pin to a specific image of the nginx-sidecar.
        image: deliveroo/nginx-sidecar:0.3.9
        cpu: 128
        memory: 256
        essential: true

        # Link your `app` to this container, so that the nginx sidecar can forward requests.
        # If your app container is named something else (e.g. `appcontainer`), you can use
        # `appcontainer:app` to specify it.
        links:
        - app

        # Port the container is listening on. Should match the definition of the service in Terraform.
        portMappings:
        - containerPort: 3000

        # Specify which port nginx should listen on (should match the `portMappings` above), and
        # which port the `app` is listening on.
        environment:
        - name: NGINX_PORT
          value: '3000'
        - name: APP_HOST
          value: 'app'
        - name: APP_PORT
          value: '3001'
        # If you want to customize monitoring status endpoint
        - name: NGINX_PORT
          value: '18081'
        - name: NGINX_STATUS_ALLOW_FROM
          value: '172.0.0.0/8'
        # If you want a custom timeout for the request
        - name: PROXY_TIMEOUT
          value: '10s'

        # If your datadog agent has Autodiscovery enabled, you can provide additional docker labels
        # in order to expose them
        dockerLabels:
          com.datadoghq.ad.check_names: '["nginx"]'
          com.datadoghq.ad.init_configs: '[{}]'
          com.datadoghq.ad.instances: '[{"nginx_status_url": "http://%%host%%:81/nginx_status/"}]'

  # ...
```

## Contributing

The CI for the master branch reads the `VERSION` file and creates a new tag `deliveroo/nginx-sidecar:VERSION` if it doesn't already exist. The `VERSION` should be incremented each time changes are made.

### Staging

This repository has a `staging` branch that pushes to a `deliveroo/nginx-sidecar:staging` tag in Docker Hub, to allow changes to be tested before merging and bumping `VERSION`.

## Future

This relies on the legacy `--link` flag of Docker/ECS and requires the `bridged` networking mode.
