#!/bin/bash

set -ex

# nginx.conf doesn't support environment variables,
# so we substitute at run time
/bin/sed -e "s/<NGINX_PORT>/${NGINX_PORT}/g" -e "s/<APP_PORT>/${APP_PORT}/g" /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# run in foreground as pid 1
exec /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
