FROM        --platform=$TARGETOS/$TARGETARCH alpine:3.20

LABEL       author="GitHub Copilot" maintainer="noreply@github.com"
LABEL       org.opencontainers.image.source="https://github.com/Monolith-Station/Monolith"
LABEL       org.opencontainers.image.licenses="AGPL-3.0"

RUN         apk add --no-cache \
                bash \
                curl \
                git \
                gettext \
                iproute2 \
                ca-certificates \
                tzdata \
                tini \
                su-exec \
                nss_wrapper \
                icu-libs \
                krb5-libs \
                libgcc \
                libstdc++ \
                openssl \
                zlib

RUN         curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
            && chmod +x /tmp/dotnet-install.sh \
            && /tmp/dotnet-install.sh --version 9.0.101 --install-dir /usr/share/dotnet \
            && /tmp/dotnet-install.sh --version 10.0.100 --install-dir /usr/share/dotnet \
            && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
            && rm -f /tmp/dotnet-install.sh

ENV         NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group
RUN         touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}
ADD         passwd.template /passwd.template

RUN         addgroup -S container \
            && adduser -S -D -h /home/container -s /bin/bash -G container container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL  SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/sbin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]