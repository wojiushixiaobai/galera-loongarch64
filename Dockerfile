FROM debian:buster-slim as builder
ARG TARGETARCH

ARG BUILD_DEPENDENCIES="           \
        ca-certificates            \
        devscripts                 \
        software-properties-common \
        wget"

RUN set -ex \
    && apt-get update \
    && apt-get install -y ${BUILD_DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash

ARG MARIADB_VERSION=10.6.15
ARG GALERA_VERSION=26.4.14

WORKDIR /opt/galera

RUN set -ex \
    && wget -q https://archive.mariadb.org/mariadb-${MARIADB_VERSION}/galera-${GALERA_VERSION}/src/galera-${GALERA_VERSION}.tar.gz \
    && tar -xf galera-${GALERA_VERSION}.tar.gz \
    && rm -f galera-${GALERA_VERSION}.tar.gz

RUN set -ex \
    && apt-get update \
    && cd galera-${GALERA_VERSION} \
    && mk-build-deps -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" -i debian/control

RUN set -ex \
    && cd galera-${GALERA_VERSION} \
    && dpkg-buildpackage -us -uc -I \
    && cd .. \
    && rm -rf galera-${GALERA_VERSION}

FROM debian:buster-slim

WORKDIR /opt/galera

COPY --from=builder /opt/galera /opt/galera/dist

