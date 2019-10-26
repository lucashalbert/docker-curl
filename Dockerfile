FROM amd64/alpine

ENV CURL_VER=7.66.0-r0 \
    BUILD_DATE=20191026T000601 \
    PARAMS=""

LABEL build_version="Build-date: ${BUILD_DATE}"
LABEL maintainer="Lucas Halbert <lhalbert@lhalbert.xyz>"
MAINTAINER Lucas Halbert <lhalbert@lhalbert.xyz>


RUN apk add --no-cache --update ca-certificates curl


COPY docker-entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/curl"]
