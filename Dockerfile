FROM nginx:stable

# # Install dependencies
# ARG DEPENDENCIES="curl"
# RUN apt-get update -y && \
#     apt-get install --no-install-recommends -y ${DEPENDENCIES} && \
#     apt-get clean && \
#     rm -rf /var/cache/apt/archives/* && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
#     truncate -s 0 /var/log/*log

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh && \
    mkdir -p /usr/local/etc/nginx

COPY *.conf.template /usr/local/etc/nginx/

ENTRYPOINT ["/entrypoint.sh"]
