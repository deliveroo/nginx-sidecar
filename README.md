# nginx-sidecar

A simple nginx reverse proxy side-car, which can be placed in front an application's web container to queue requests and to provide statistics to New Relic about request queuing.

## Requirements

 - The application must be linked (either by Docker `--link` or ECS `links` section) as `app`.
 - The `NGINX_PORT` environment variable should be set to the port nginx should bind to.
 - The `APP_PORT` environment variable should be set to the port that the application is bound to inside the `app` container.

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
        # TODO: Staging vs. production??
        image: 517902663915.dkr.ecr.eu-west-1.amazonaws.com/nginx-sidecar:740797ae4525cceb81625dd70b0035516aaf80ba

        cpu: 128
        memory: 256
        essential: true

        # Link your `app` to this container, so that the nginx sidecar can forward requests.
        # If your app container is named something else (e.g. `appcontainer`), you can use
        # `appcontainer:app` to specify it.
        links:
        - app

        portMappings:
        - containerPort: 3000

        # Specify which port nginx should listen on (should match the `portMappings` above), and
        # which port the `app` is listening on.
        environment:
        - name: NGINX_PORT
          value: '3000'
        - name: APP_PORT
          value: '3001'

  # ...
```

## Future

This relies on the legacy `--link` flag of Docker/ECS and requires the `bridged` networking mode.

We'll want to switch to another way of doing this once we have different networking modes available - this is an ongoing area of research for Production Engineering.
