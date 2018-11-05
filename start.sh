#!/bin/bash

set -ex

# nginx.conf doesn't support environment variables,
# so we substitute at run time
/bin/sed -e "s/<NGINX_PORT>/${NGINX_PORT}/g" -e "s/<APP_PORT>/${APP_PORT}/g" /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Wait for the application to start before accepting ALB requests.
while sleep 2; do
  curl --max-time 5 http://app:${APP_PORT}${HEALTHCHECK_PATH:-/health} && break
done

# run in foreground as pid 1
exec /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
