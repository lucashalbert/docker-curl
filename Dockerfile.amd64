FROM amd64/alpine

ENV BUILD_DATE=20191019T015949 \
    PARAMS=""

LABEL build_version="Build-date: ${BUILD_DATE}"
LABEL maintainer="Lucas Halbert <lhalbert@lhalbert.xyz>"
MAINTAINER Lucas Halbert <lhalbert@lhalbert.xyz>


RUN apk add --no-cache --update ca-certificates curl


COPY docker-entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/curl"]
