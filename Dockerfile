# pinned based image instead of :latest tag.  Simple and cheap way to establish outdated base image.
FROM nginx:1.23.3-alpine-slim

RUN apk --no-cache add curl

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /usr/bin/start.sh
RUN chmod a+x /usr/bin/start.sh

RUN chown -R nginx:nginx /etc/nginx/nginx.conf.template && \
    chown -R nginx:nginx /usr/bin/start.sh && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

RUN touch /etc/nginx/nginx.conf && \
    chown -R nginx:nginx /etc/nginx/nginx.conf

RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

#############################################################################
# Set non-root user. nginx user and group already pre-created in base image #
#############################################################################

USER nginx

CMD /usr/bin/start.sh
