# pinned based image instead of :latest tag.  Simple and cheap way to establish outdated base image.
FROM nginx:1.23.3-alpine-slim

RUN apk --no-cache add curl

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /usr/bin/start.sh
RUN chmod a+x /usr/bin/start.sh

CMD /usr/bin/start.sh
