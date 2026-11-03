FROM ghcr.io/nforceroh/alpine-base:3.24

ARG \
  BUILD_DATE=now \
  VERSION=unknown

LABEL \
  org.label-schema.maintainer="Sylvain Martin (sylvain@nforcer.com)" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.version="${VERSION}" \
  org.label-schema.vcs-url="https://github.com/nforceroh/dcc" \
  org.label-schema.schema-version="1.0"

ENV \
  SERVICE=dcc \
  UID=dcc \
  PUID=100 \
  PGID=101 \
  DCCIFD_ARGS="-b -d -I dcc -SHELO -Smail_host -SSender -SList-ID -p *,10045,10.0.0.0/8"

### Install Dependencies
RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash ca-certificates dcc dcc-dccifd dcc-extras \
    && rm -rf /var/cache/apk/* /usr/src/*

### Add Files
ADD --chmod=755 /content/etc/s6-overlay /etc/s6-overlay
ADD --chown=dcc:dcc content/var/dcc /var/dcc

EXPOSE 10045

ENTRYPOINT [ "/init" ]