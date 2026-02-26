_apply_default() {
    local domain="$1"
    local key="$2"
    local value_type="$3"
    local expected_value="$4"
    local current_value

    current_value="$(/usr/bin/defaults read "${domain}" "${key}" 2>/dev/null || true)"
    if [ "${current_value}" = "${expected_value}" ]; then
        return
    fi

    /usr/bin/defaults write "${domain}" "${key}" "-${value_type}" "${expected_value}"
    success "Set ${domain} ${key}: ${expected_value}"
}

apply_macos_defaults() {
    # キーボードのリピート開始時間を短くする
    _apply_default NSGlobalDomain InitialKeyRepeat int 15

    # キーボードのキーリピート速度を上げる
    _apply_default NSGlobalDomain KeyRepeat float 1.5

    # トラックパッドの軌跡速度を上げる
    _apply_default NSGlobalDomain com.apple.trackpad.scaling float 2.5
}
