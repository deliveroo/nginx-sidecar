# pinned based image instead of :latest tag.  
# Why?  Simple and cheap way to establish staleness of container.
FROM nginx:1.23.2

# RUN apt update && apt install -y curl

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /usr/bin/start.sh
RUN chmod a+x /usr/bin/start.sh

CMD /usr/bin/start.sh
