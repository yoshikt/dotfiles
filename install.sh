#!/usr/bin/env bash

set -euo pipefail

DOTFILES_REPO_URL="https://github.com/yoshikt/dotfiles.git"
DOTFILES_DIR="${HOME}/dotfiles"
DOTFILES_REPO_BRANCH="main"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    SUCCESS_COLOR=$'\033[0;32m'
    WARN_COLOR=$'\033[0;33m'
    ERROR_COLOR=$'\033[0;31m'
    COLOR_RESET=$'\033[0m'
else
    SUCCESS_COLOR=''
    WARN_COLOR=''
    ERROR_COLOR=''
    COLOR_RESET=''
fi

log(){ printf '[dotfiles] %s\n' "$*"; }
success(){ printf '%s%s%s\n' "${SUCCESS_COLOR}" "$*" "${COLOR_RESET}"; }
warn(){ printf '%s%s%s\n' "${WARN_COLOR}" "$*" "${COLOR_RESET}" >&2; }
error(){ printf '%s%s%s\n' "${ERROR_COLOR}" "$*" "${COLOR_RESET}" >&2; }
die(){ error "$*"; exit 1; }

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
            die "Local changes detected in ${DOTFILES_DIR}. Please commit/stash, then rerun install.sh."
        fi

        log "Updating dotfiles in ${DOTFILES_DIR}"
        if ! git -C "${DOTFILES_DIR}" pull --ff-only origin "${DOTFILES_REPO_BRANCH}"; then
            die "Failed to fast-forward ${DOTFILES_DIR}. Resolve git state manually, then rerun install.sh."
        fi

        return
    fi

    if [ -e "${DOTFILES_DIR}" ]; then
        die "${DOTFILES_DIR} exists but is not a git repo. Please resolve manually."
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
        error "Conflict: ${target_path} is linked to ${current_target}"
        die 'Resolve it manually, then rerun install.sh.'
    elif [ -e "${target_path}" ]; then
        error "Conflict: ${target_path} already exists"
        die 'Resolve it manually, then rerun install.sh.'
    fi

    ln -s "${source_path}" "${target_path}"
    success "Linked ${target_path} -> ${source_path}"
}

main() {
    local platform
    platform="$(detect_platform)"
    log "Detected platform: ${platform}"

    ensure_dotfiles_repo

    case "${platform}" in
        macos)
            if [ ! -f "${DOTFILES_DIR}/scripts/install/macos.sh" ]; then
                die "Missing script: ${DOTFILES_DIR}/scripts/install/macos.sh"
            fi
            # shellcheck source=/dev/null
            source "${DOTFILES_DIR}/scripts/install/macos.sh"
            setup_macos
            ;;
        wsl)
            warn 'WSL setup is not implemented yet.'
            ;;
        linux)
            warn 'Linux setup is not implemented yet.'
            ;;
        *)
            die 'Unsupported platform.'
            ;;
    esac
}

main "$@"
