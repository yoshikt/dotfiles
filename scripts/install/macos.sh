_install_homebrew() {
    if has_command brew; then
        return
    fi

    log 'Homebrew not found. Installing Homebrew...'
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        die 'Failed to install Homebrew.'
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        export PATH="/opt/homebrew/bin:${PATH}"
    elif [ -x /usr/local/bin/brew ]; then
        export PATH="/usr/local/bin:${PATH}"
    fi
}

_apply_brew_bundle() {
    local brewfile_path="${DOTFILES_DIR}/macos/Brewfile"

    if [ ! -f "${brewfile_path}" ]; then
        die "Missing Brewfile: ${brewfile_path}"
    fi

    log "Checking Brewfile: ${brewfile_path}"
    if brew bundle check --file "${brewfile_path}" >/dev/null 2>&1; then
        log 'Brewfile already satisfied.'
        return
    fi

    log 'Installing packages from Brewfile...'
    if ! brew bundle --file "${brewfile_path}"; then
        die 'brew bundle failed.'
    fi
}

_apply_iterm2_settings() {
    local source_path="${DOTFILES_DIR}/macos/iterm2/com.googlecode.iterm2.plist"
    local target_path="${HOME}/.config/iterm2/com.googlecode.iterm2.plist"
    local prefs_folder="${DOTFILES_DIR}/macos/iterm2"
    local log_dir="${HOME}/.local/state/terminallogs"
    local current_prefs_folder
    local current_load_custom

    if [ ! -f "${source_path}" ]; then
        die "Missing source file: ${source_path}"
    fi

    mkdir -p "${log_dir}"
    link_file "${source_path}" "${target_path}"

    current_prefs_folder="$(/usr/bin/defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true)"
    if [ "${current_prefs_folder}" != "${prefs_folder}" ]; then
        /usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${prefs_folder}"
        log "Set iTerm2 PrefsCustomFolder: ${prefs_folder}"
    fi

    current_load_custom="$(/usr/bin/defaults read com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null || true)"
    if [ "${current_load_custom}" != "1" ]; then
        /usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
        log 'Enabled iTerm2 LoadPrefsFromCustomFolder'
    fi

    log 'iTerm2 settings setup completed.'
}

_apply_karabiner_settings() {
    local source_path="${DOTFILES_DIR}/macos/karabiner/karabiner.json"
    local target_path="${HOME}/.config/karabiner/karabiner.json"

    if [ ! -f "${source_path}" ]; then
        die "Missing source file: ${source_path}"
    fi

    link_file "${source_path}" "${target_path}"
    log 'Karabiner settings setup completed.'
}

_warn_if_iterm2_missing() {
    if has_command brew; then
        if brew list --cask iterm2 >/dev/null 2>&1; then
            return
        fi

        warn 'iTerm2 (cask "iterm2") is not installed via Homebrew. Continuing settings phase.'
        return
    fi

    if [ ! -d "/Applications/iTerm.app" ]; then
        warn 'iTerm2 is not installed. Continuing settings phase.'
    fi
}

_warn_if_karabiner_missing() {
    if has_command brew; then
        if brew list --cask karabiner-elements >/dev/null 2>&1; then
            return
        fi

        warn 'Karabiner-Elements (cask "karabiner-elements") is not installed via Homebrew. Continuing settings phase.'
        return
    fi

    if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
        warn 'Karabiner-Elements is not installed. Continuing settings phase.'
    fi
}

setup_macos_packages() {
    _install_homebrew
    _apply_brew_bundle
}

setup_macos_settings() {
    _warn_if_iterm2_missing
    _warn_if_karabiner_missing
    _apply_iterm2_settings
    _apply_karabiner_settings
}

setup_macos() {
    local phase="${DOTFILES_MACOS_PHASE:-all}"

    case "${phase}" in
        all)
            setup_macos_packages
            setup_macos_settings
            ;;
        packages)
            setup_macos_packages
            ;;
        settings)
            setup_macos_settings
            ;;
        *)
            die "Invalid DOTFILES_MACOS_PHASE: ${phase}. Use one of: all, packages, settings"
            ;;
    esac
}
