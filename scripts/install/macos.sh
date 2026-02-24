_setup_homebrew() {
    if has_command brew; then
        return
    fi

    log 'Homebrew not found. Installing Homebrew...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x /opt/homebrew/bin/brew ]; then
        export PATH="/opt/homebrew/bin:${PATH}"
    elif [ -x /usr/local/bin/brew ]; then
        export PATH="/usr/local/bin:${PATH}"
    fi
}

_setup_iterm2() {
    local source_path="${DOTFILES_DIR}/macos/iterm2/com.googlecode.iterm2.plist"
    local target_path="${HOME}/.config/iterm2/com.googlecode.iterm2.plist"
    local prefs_folder="${DOTFILES_DIR}/macos/iterm2"
    local current_prefs_folder
    local current_load_custom

    if [ ! -f "${source_path}" ]; then
        log "Missing source file: ${source_path}"
        exit 1
    fi

    if ! brew list --cask iterm2 >/dev/null 2>&1; then
        log 'Installing iTerm2...'
        brew install --cask iterm2
    fi

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

    log 'iTerm2 setup completed.'
}

setup_macos() {
    _setup_homebrew
    _setup_iterm2
}
