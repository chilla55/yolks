#!/bin/ash

set -eu

ROOT_DIR="${ROOT_DIR:-/mnt/server}"
MONOLITH_REPO_URL="${MONOLITH_REPO_URL:-https://github.com/Monolith-Station/Monolith.git}"
MONOLITH_REF="${MONOLITH_REF:-main}"
MONOLITH_DIR="${MONOLITH_DIR:-${ROOT_DIR}/monolith}"
MONOLITH_UPDATE_SUBMODULES="${MONOLITH_UPDATE_SUBMODULES:-1}"
MONOLITH_RUN_BUILD="${MONOLITH_RUN_BUILD:-0}"

echo "[Monolith][INSTALL] Starting install/update flow"
echo "[Monolith][INSTALL] Repo: ${MONOLITH_REPO_URL}"
echo "[Monolith][INSTALL] Ref: ${MONOLITH_REF}"
echo "[Monolith][INSTALL] Dir: ${MONOLITH_DIR}"

mkdir -p "${ROOT_DIR}"
mkdir -p "${MONOLITH_DIR}"

if ! command -v git >/dev/null 2>&1; then
    echo "[Monolith][INSTALL][ERROR] git is not available in the runtime container."
    exit 1
fi

if ! command -v dotnet >/dev/null 2>&1; then
    echo "[Monolith][INSTALL][ERROR] dotnet is not available in the runtime container."
    exit 1
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

if ! git config --global --get-all safe.directory 2>/dev/null | grep -Fx "${MONOLITH_DIR}" >/dev/null 2>&1; then
    echo "[Monolith][INSTALL] Marking repository as a git safe.directory..."
    git config --global --add safe.directory "${MONOLITH_DIR}" || true
fi

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
    if [ -f "Scripts/sh/updateEngine.sh" ] && [ -f "Scripts/sh/buildAllDebug.sh" ]; then
        echo "[Monolith][INSTALL] Running updateEngine.sh..."
        sh Scripts/sh/updateEngine.sh
        echo "[Monolith][INSTALL] Running buildAllDebug.sh..."
        sh Scripts/sh/buildAllDebug.sh
    else
        echo "[Monolith][INSTALL][WARN] Build requested but required scripts are missing."
        echo "[Monolith][INSTALL][WARN] Required scripts: Scripts/sh/updateEngine.sh, Scripts/sh/buildAllDebug.sh"
        echo "[Monolith][INSTALL][WARN] Skipping build phase."
    fi
else
    echo "[Monolith][INSTALL] Build disabled during install (MONOLITH_RUN_BUILD=0)."
    echo "[Monolith][INSTALL] Build will run during launch if MONOLITH_BUILD_ON_LAUNCH=1."
fi

echo "-----------------------------------------"
echo "Installation completed..."
echo "-----------------------------------------"