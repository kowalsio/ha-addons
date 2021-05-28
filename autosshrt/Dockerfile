ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:9.2.1
FROM ${BUILD_FROM}

RUN apk add --no-cache openssh autossh

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
