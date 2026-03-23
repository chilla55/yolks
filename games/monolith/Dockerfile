FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="GitHub Copilot" maintainer="noreply@github.com"
LABEL       org.opencontainers.image.source="https://github.com/Monolith-Station/Monolith"
LABEL       org.opencontainers.image.licenses="AGPL-3.0"

ENV         DEBIAN_FRONTEND=noninteractive
RUN         apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y --no-install-recommends \
                bash \
                curl \
                git \
                gettext-base \
                iproute2 \
                ca-certificates \
                tzdata \
                locales \
                tini \
                libnss-wrapper \
                libc6 \
                libgcc-s1 \
                libgssapi-krb5-2 \
                libicu72 \
                libssl3 \
                libstdc++6 \
                zlib1g \
            && rm -rf /var/lib/apt/lists/*

RUN         curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
            && chmod +x /tmp/dotnet-install.sh \
            && /tmp/dotnet-install.sh --version 9.0.101 --install-dir /usr/share/dotnet \
            && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
            && rm -f /tmp/dotnet-install.sh

RUN         update-locale lang=en_US.UTF-8 \
            && dpkg-reconfigure --frontend noninteractive locales

ENV         NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group
RUN         touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}
ADD         passwd.template /passwd.template

RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL  SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]