#!/bin/bash

set -euo pipefail

echo "[Monolith] Container startup initiated..."

# Give wings a moment to mount volumes and inject environment.
sleep 1

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container/monolith || exit 1

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

if [[ "${MONOLITH_BUILD_ON_LAUNCH:-1}" == "1" ]]; then
    if [[ -f "Scripts/sh/updateEngine.sh" && -f "Scripts/sh/buildAllDebug.sh" ]]; then
        export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
        export DOTNET_CLI_TELEMETRY_OPTOUT=1
        export DOTNET_NOLOGO=1
        export NUGET_XMLDOC_MODE=skip
        export MSBUILDNODECOUNT=1

        echo "[Monolith] Running updateEngine.sh before launch..."
        sh Scripts/sh/updateEngine.sh
        echo "[Monolith] Running buildAllDebug.sh before launch..."
        sh Scripts/sh/buildAllDebug.sh
    else
        echo "[Monolith][WARN] MONOLITH_BUILD_ON_LAUNCH=1 but build scripts are missing."
        echo "[Monolith][WARN] Expected: Scripts/sh/updateEngine.sh and Scripts/sh/buildAllDebug.sh"
    fi
fi

MODIFIED_STARTUP=$(eval echo "${STARTUP}")
echo "[Monolith] Executing startup command: ${MODIFIED_STARTUP}"

if [[ "$(id -u)" -eq 0 ]]; then
    exec su-exec container:container bash -lc "${MODIFIED_STARTUP}"
fi

exec bash -lc "${MODIFIED_STARTUP}"