# nginx-sidecar

A simple nginx reverse proxy side-car, which can be placed in front an application's web container to queue requests and to provide statistics to New Relic about request queuing.

## Requirements

 - The application must be linked (either by Docker `--link` or ECS `links` section) as `app`.
 - The `NGINX_PORT` environment variable should be set to the port nginx should bind to.
 - The `APP_PORT` environment variable should be set to the port that the application is bound to inside the `app` container.

## Stats Monitoring

We've enabled `http_stub_status_module` access to help with monitoring integration. By default it is listening on port _81_ with `allow all` as restriction. You can customize this with:
- `NGINX_STATUS_PORT` (default `81`) a port to run the status module on
- `NGINX_STATUS_ALLOW_FROM` (default `all`) IP, CIDR, `all` or `none` for the nginx config's `allow` statement (http://nginx.org/en/docs/http/ngx_http_access_module.html)

## Example

In your `.hopper/config.yml`:

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

      # A separate `containerDefinition` should be added for the nginx side-car.
      # The side-car doesn't care what this is called, but it'll need to match the `process_name`
      # in your app's Terraform, as this is where Hopper expects to find the bound port.
      web:
        # Pin to a specific image of the nginx-sidecar.
        image: deliveroo/nginx-sidecar:0.0.1
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
