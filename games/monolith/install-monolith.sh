#!/bin/ash

set -eu

SERVER_DIR="${SERVER_DIR:-/mnt/server}"
MONOLITH_REPO_URL="${MONOLITH_REPO_URL:-https://github.com/Monolith-Station/Monolith.git}"
MONOLITH_REF="${MONOLITH_REF:-main}"
MONOLITH_DIR="${MONOLITH_DIR:-${SERVER_DIR}/monolith}"
MONOLITH_UPDATE_SUBMODULES="${MONOLITH_UPDATE_SUBMODULES:-1}"
MONOLITH_RUN_BUILD="${MONOLITH_RUN_BUILD:-0}"

echo "[Monolith][INSTALL] Starting install/update flow"
echo "[Monolith][INSTALL] Repo: ${MONOLITH_REPO_URL}"
echo "[Monolith][INSTALL] Ref: ${MONOLITH_REF}"
echo "[Monolith][INSTALL] Dir: ${MONOLITH_DIR}"

mkdir -p "${SERVER_DIR}"
mkdir -p "${MONOLITH_DIR}"

if ! command -v git >/dev/null 2>&1; then
    echo "[Monolith][INSTALL] git not found, attempting installation..."
    if command -v apk >/dev/null 2>&1; then
        apk add --no-cache git bash curl ca-certificates
    elif command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y git bash curl ca-certificates
    else
        echo "[Monolith][INSTALL][ERROR] No supported package manager found to install git."
        exit 1
    fi
fi

if [ ! -d "${MONOLITH_DIR}/.git" ]; then
    if [ -n "$(ls -A "${MONOLITH_DIR}" 2>/dev/null)" ]; then
        echo "[Monolith][INSTALL][ERROR] ${MONOLITH_DIR} is not empty and is not a git repository."
        echo "[Monolith][INSTALL][ERROR] Clean the directory or set MONOLITH_DIR to an empty path."
        exit 1
    fi

    echo "[Monolith][INSTALL] Cloning repository..."
    git clone --recurse-submodules "${MONOLITH_REPO_URL}" "${MONOLITH_DIR}"
fi

cd "${MONOLITH_DIR}"

echo "[Monolith][INSTALL] Updating repository..."
git remote set-url origin "${MONOLITH_REPO_URL}"
git fetch --all --tags --prune

if git show-ref --verify --quiet "refs/remotes/origin/${MONOLITH_REF}"; then
    git checkout -B "${MONOLITH_REF}" "origin/${MONOLITH_REF}"
else
    git checkout "${MONOLITH_REF}"
fi

if [ "${MONOLITH_UPDATE_SUBMODULES}" = "1" ]; then
    echo "[Monolith][INSTALL] Updating submodules..."
    git submodule sync --recursive
    git submodule update --init --recursive
fi

if [ "${MONOLITH_RUN_BUILD}" = "1" ]; then
    if command -v dotnet >/dev/null 2>&1 && [ -x "Scripts/sh/updateEngine.sh" ] && [ -x "Scripts/sh/buildAllDebug.sh" ]; then
        echo "[Monolith][INSTALL] Running updateEngine.sh..."
        bash Scripts/sh/updateEngine.sh
        echo "[Monolith][INSTALL] Running buildAllDebug.sh..."
        bash Scripts/sh/buildAllDebug.sh
    else
        echo "[Monolith][INSTALL][WARN] Build requested but dotnet/scripts missing; skipping build phase."
    fi
fi

echo "-----------------------------------------"
echo "Installation completed..."
echo "-----------------------------------------"