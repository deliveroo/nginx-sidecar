#!/bin/bash

set -e

# nginx.conf doesn't support environment variables, so we substitute at run time.
# Proxy setup was moved in external file.

## nginx.conf substitutions:
/bin/sed \
  -e "s/<NGINX_PORT>/${NGINX_PORT:-80}/g" \
  -e "s/<NGINX_CLIENT_BODY_BUFFER_SIZE>/${NGINX_CLIENT_BODY_BUFFER_SIZE:-8k}/g" \
  -e "s/<NGINX_CLIENT_MAX_BODY_SIZE>/${NGINX_CLIENT_MAX_BODY_SIZE:-5M}/g" \
  -e "s/<NGINX_STATUS_PORT>/${NGINX_STATUS_PORT:-81}/g" \
  -e "s:<NGINX_STATUS_ALLOW_FROM>:${NGINX_STATUS_ALLOW_FROM:-all}:g" \
  /usr/local/etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

## proxy.conf substitutions:
/bin/sed \
  -e "s/<NGINX_PROXY_BUFFER_SIZE>/${NGINX_PROXY_BUFFER_SIZE:-8k}/g" \
  -e "s:<NGINX_PROXY_TIMEOUT>:${NGINX_PROXY_TIMEOUT:-60s}:g" \
  -e "s/<APP_SCHEME>/${APP_SCHEME:-http}/g" \
  -e "s/<APP_HOST>/${APP_HOST:-app}/g" \
  -e "s/<APP_PORT>/${APP_PORT:-8080}/g" \
    /usr/local/etc/nginx/proxy.conf.template > /etc/nginx/proxy.conf

# Wait for the application to start before accepting ALB requests.
if [[ -z "${SKIP_HEALTHCHECK}" ]]; then
  curl --silent --fail --max-time 5 "http://${APP_HOST:-app}:${APP_PORT:-8080}${APP_HEALTHCHECK_PATH:-/health}" || ( echo "Couldn't contact app"; exit 1 )
fi

# run in foreground as pid 1
exec /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
