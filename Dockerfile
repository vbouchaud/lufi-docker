
FROM alpine/git AS git

ARG VERSION=0.07.0

RUN wget "https://framagit.org/fiat-tux/hat-softwares/lufi/-/archive/${VERSION}/lufi-${VERSION}.tar.gz" && \
	tar -xzf "lufi-${VERSION}.tar.gz" && \
	mv "lufi-${VERSION}" /lufi

FROM debian:bullseye-slim

RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
	libpq-dev \
	build-essential \
	libssl-dev \
	gosu \
	libio-socket-ssl-perl \
	curl \
	liblwp-protocol-https-perl \
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN cpan Carton

COPY --from=git /lufi /usr/lufi

WORKDIR /usr/lufi

RUN carton install --deployment --without=test --without=postgresql --without=mysql --without=ldap --without=htpasswd --without=swift-storage

ENV CONTACT_HTML="<a href= 'example.com'>here</a>"
ENV REPORT_EMAIL="abc@example.com"
ENV SITE_NAME="lufi"
ENV URL_LENGTH=4
ENV MAX_FILE_SIZE=104857600
ENV MAX_DELAY=0
ENV ALLOW_PWD=1
ENV THEME="default"
ENV PROVIS_STEP=5
ENV PROVISIONING=100
ENV TOKEN_LENGTH=32
ENV LIMIT_FILE_DESTROY_DAYS=0
ENV URL_PREFIX="/"
ENV FORCE_BURN_AFTER_READING=0
ENV X_FRAME="DENY"
ENV X_CONTENT_TYPE="nosniff"
ENV X_XSS_PROTECTION="1; mode=block"
ENV KEEP_IP_DURING=365
ENV WORKER=30
ENV CLIENTS=1
ENV DISABLE_MAIL_SENDING=1

COPY lufi.conf .
COPY docker-entrypoint.sh .

RUN chmod u+x docker-entrypoint.sh

RUN mkdir -p /usr/lufi/files && \
    groupadd -g 1000 -o lufi && \
    useradd -g 1000 -g lufi lufi && \
    chown -R lufi:lufi /usr/lufi && \
    chmod -R 700 /usr/lufi && \
    chmod -R 600 /usr/lufi/files && \
    chmod u+x $(find /usr/lufi/files -type d)

USER lufi
ENTRYPOINT ["/usr/lufi/docker-entrypoint.sh"]
CMD ["carton", "exec", "hypnotoad", "/usr/lufi/script/lufi"]
