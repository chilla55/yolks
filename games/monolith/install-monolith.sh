#!/bin/bash

set -euo pipefail

ROOT_DIR="${ROOT_DIR:-/home/container}"
MONOLITH_REPO_URL="${MONOLITH_REPO_URL:-https://github.com/Monolith-Station/Monolith.git}"
MONOLITH_REF="${MONOLITH_REF:-main}"
MONOLITH_DIR="${MONOLITH_DIR:-${ROOT_DIR}/Monolith}"
MONOLITH_UPDATE_ENGINE="${MONOLITH_UPDATE_ENGINE:-1}"
MONOLITH_BUILD="${MONOLITH_BUILD:-1}"
MONOLITH_INSTALL_ONLY="${MONOLITH_INSTALL_ONLY:-0}"
MONOLITH_LAUNCH_CMD="${MONOLITH_LAUNCH_CMD:-}"

echo "[Monolith][INSTALL] Starting install/update flow"
echo "[Monolith][INSTALL] Repo: ${MONOLITH_REPO_URL}"
echo "[Monolith][INSTALL] Ref: ${MONOLITH_REF}"
echo "[Monolith][INSTALL] Dir: ${MONOLITH_DIR}"

mkdir -p "${ROOT_DIR}"
cd "${ROOT_DIR}"

if [[ ! -d "${MONOLITH_DIR}/.git" ]]; then
    echo "[Monolith][INSTALL] Cloning repository..."
    git clone --recurse-submodules "${MONOLITH_REPO_URL}" "${MONOLITH_DIR}"
else
    echo "[Monolith][INSTALL] Existing git repository found, updating..."
fi

cd "${MONOLITH_DIR}"

git remote set-url origin "${MONOLITH_REPO_URL}"
git fetch --all --tags --prune

if git show-ref --verify --quiet "refs/remotes/origin/${MONOLITH_REF}"; then
    git checkout -B "${MONOLITH_REF}" "origin/${MONOLITH_REF}"
else
    git checkout "${MONOLITH_REF}"
fi

git submodule sync --recursive
git submodule update --init --recursive

if [[ "${MONOLITH_UPDATE_ENGINE}" == "1" ]]; then
    if [[ -x "Scripts/sh/updateEngine.sh" ]]; then
        echo "[Monolith][INSTALL] Running updateEngine.sh..."
        bash Scripts/sh/updateEngine.sh
    else
        echo "[Monolith][INSTALL][WARN] Scripts/sh/updateEngine.sh not found or not executable, skipping."
    fi
fi

if [[ "${MONOLITH_BUILD}" == "1" ]]; then
    if [[ -x "Scripts/sh/buildAllDebug.sh" ]]; then
        echo "[Monolith][INSTALL] Running buildAllDebug.sh..."
        bash Scripts/sh/buildAllDebug.sh
    else
        echo "[Monolith][INSTALL][WARN] Scripts/sh/buildAllDebug.sh not found or not executable, skipping."
    fi
fi

if [[ "${MONOLITH_INSTALL_ONLY}" == "1" ]]; then
    echo "[Monolith][INSTALL] MONOLITH_INSTALL_ONLY=1 set, exiting without launch."
    exit 0
fi

if [[ -n "${MONOLITH_LAUNCH_CMD}" ]]; then
    echo "[Monolith][INSTALL] Launching command: ${MONOLITH_LAUNCH_CMD}"
    exec bash -lc "${MONOLITH_LAUNCH_CMD}"
fi

echo "[Monolith][INSTALL] Install/update finished. No launch command was provided."