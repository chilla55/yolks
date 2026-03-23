#!/bin/bash

set -euo pipefail

echo "[Monolith] Container startup initiated..."

# Give wings a moment to mount volumes and inject environment.
sleep 1

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

# Configure NSS wrapper so the process can run correctly with remapped UIDs/GIDs.
if [[ -f /passwd.template ]]; then
    USER_ID="${USER_ID:-$(id -u)}"
    GROUP_ID="${GROUP_ID:-$(id -g)}"
    export USER_ID GROUP_ID

    envsubst < /passwd.template > "${NSS_WRAPPER_PASSWD}"
    printf 'root:x:0:0:root:/root:/bin/bash\n%s:x:%s:\n' "${USER}" "${GROUP_ID}" > "${NSS_WRAPPER_GROUP}"

    if [[ -f /usr/lib/x86_64-linux-gnu/libnss_wrapper.so ]]; then
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so
    elif [[ -f /usr/lib/libnss_wrapper.so ]]; then
        export LD_PRELOAD=/usr/lib/libnss_wrapper.so
    fi
fi

if [[ -z "${STARTUP:-}" ]]; then
    echo "[Monolith][ERROR] STARTUP variable is empty. Set a startup command in your Pterodactyl egg."
    exit 1
fi

MODIFIED_STARTUP=$(eval echo "${STARTUP}")
echo "[Monolith] Executing startup command: ${MODIFIED_STARTUP}"

exec bash -lc "${MODIFIED_STARTUP}"