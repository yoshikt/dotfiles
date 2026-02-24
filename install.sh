#!/usr/bin/env bash

set -euo pipefail

DOTFILES_REPO_URL="https://github.com/yoshikt/dotfiles.git"
DOTFILES_DIR="${HOME}/dotfiles"
DOTFILES_REPO_BRANCH="main"

log(){ printf '[dotfiles] %s\n' "$*"; }

has_command() { command -v "$1" >/dev/null 2>&1; }

# OS種別を判定する
detect_platform() {
    case "$(uname -s)" in
        Darwin)
            printf 'macos\n'
            ;;
        Linux)
            if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
                printf 'wsl\n'
            else
                printf 'linux\n'
            fi
            ;;
        *)
            printf 'unknown\n'
            ;;
    esac
}

# リポジトリがなければ clone、既存 repo は fast-forward で最新化
ensure_dotfiles_repo() {
    if [ -d "${DOTFILES_DIR}/.git" ]; then
        if [ -n "$(git -C "${DOTFILES_DIR}" status --porcelain)" ]; then
            log "Local changes detected in ${DOTFILES_DIR}. Please commit/stash, then rerun install.sh."
            exit 1
        fi

        log "Updating dotfiles in ${DOTFILES_DIR}"
        if ! git -C "${DOTFILES_DIR}" pull --ff-only origin "${DOTFILES_REPO_BRANCH}"; then
            log "Failed to fast-forward ${DOTFILES_DIR}. Resolve git state manually, then rerun install.sh."
            exit 1
        fi

        return
    fi

    if [ -e "${DOTFILES_DIR}" ]; then
        log "${DOTFILES_DIR} exists but is not a git repo. Please resolve manually."
        exit 1
    fi

    log "Cloning dotfiles into ${DOTFILES_DIR}"
    git clone --branch "${DOTFILES_REPO_BRANCH}" "${DOTFILES_REPO_URL}" "${DOTFILES_DIR}"
}

# ファイルを symlink へ切り替える
link_file() {
    local source_path="$1"
    local target_path="$2"
    local current_target

    mkdir -p "$(dirname "${target_path}")"

    if [ -L "${target_path}" ]; then
        current_target="$(readlink "${target_path}")"
        if [ "${current_target}" = "${source_path}" ]; then
            log "Already linked: ${target_path}"
            return
        fi
        log "Conflict: ${target_path} is linked to ${current_target}"
        log 'Resolve it manually, then rerun install.sh.'
        exit 1
    elif [ -e "${target_path}" ]; then
        log "Conflict: ${target_path} already exists"
        log 'Resolve it manually, then rerun install.sh.'
        exit 1
    fi

    ln -s "${source_path}" "${target_path}"
    log "Linked ${target_path} -> ${source_path}"
}

main() {
    local platform
    platform="$(detect_platform)"
    log "Detected platform: ${platform}"

    ensure_dotfiles_repo

    case "${platform}" in
        macos)
            if [ ! -f "${DOTFILES_DIR}/scripts/install/macos.sh" ]; then
                log "Missing script: ${DOTFILES_DIR}/scripts/install/macos.sh"
                exit 1
            fi
            # shellcheck source=/dev/null
            source "${DOTFILES_DIR}/scripts/install/macos.sh"
            setup_macos
            ;;
        wsl)
            log 'WSL setup is not implemented yet.'
            ;;
        linux)
            log 'Linux setup is not implemented yet.'
            ;;
        *)
            log 'Unsupported platform.'
            exit 1
            ;;
    esac
}

main "$@"
