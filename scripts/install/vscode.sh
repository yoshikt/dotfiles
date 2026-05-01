DOTFILES_RESOLVED_VSCODE_ROLE=''

_validate_vscode_role() {
    case "$1" in
        private|work)
            return 0
            ;;
        *)
            die "Invalid VS Code role: $1. Use one of: private, work"
            ;;
    esac
}

_resolve_vscode_role() {
    local role_file="${DOTFILES_DIR}/vscode/local/role"
    local role=''

    if [[ -n "${DOTFILES_VSCODE_ROLE:-}" ]]; then
        role="${DOTFILES_VSCODE_ROLE}"
        _validate_vscode_role "${role}"
        DOTFILES_RESOLVED_VSCODE_ROLE="${role}"
        return
    fi

    if [[ -f "${role_file}" ]]; then
        role="$(awk 'NF && $1 !~ /^#/ { print $1; exit }' "${role_file}")"
        if [[ -n "${role}" ]]; then
            _validate_vscode_role "${role}"
            DOTFILES_RESOLVED_VSCODE_ROLE="${role}"
            return
        fi
    fi

    die "Set DOTFILES_VSCODE_ROLE=private|work or create ${role_file}."
}

_vscode_user_dir() {
    printf '%s\n' "${DOTFILES_VSCODE_USER_DIR:-${HOME}/Library/Application Support/Code/User}"
}

_link_vscode_user_file() {
    local source_path="$1"
    local target_path="$2"
    local current_target

    mkdir -p "$(dirname "${target_path}")"

    if [[ -L "${target_path}" ]]; then
        current_target="$(readlink "${target_path}")"
        if [[ "${current_target}" == "${source_path}" ]]; then
            log "Already linked: ${target_path}"
            return
        fi

        case "${current_target}" in
            "${DOTFILES_DIR}/vscode/"*)
                ln -sfn "${source_path}" "${target_path}"
                success "Relinked ${target_path} -> ${source_path}"
                return
                ;;
            *)
                error "Conflict: ${target_path} is linked to ${current_target} (expected: ${source_path})"
                die "Remove or relink ${target_path}, then rerun install.sh. e.g. rm \"${target_path}\""
                ;;
        esac
    elif [[ -e "${target_path}" ]]; then
        error "Conflict: ${target_path} already exists"
        die "Remove or move ${target_path}, then rerun install.sh. e.g. mv \"${target_path}\" \"${target_path}.bak\""
    fi

    ln -s "${source_path}" "${target_path}"
    success "Linked ${target_path} -> ${source_path}"
}

_apply_vscode_user_settings() {
    local user_dir="$1"
    local source_path="${DOTFILES_DIR}/vscode/settings/common.json"
    local target_path="${user_dir}/settings.json"

    if [[ ! -f "${source_path}" ]]; then
        die "Missing VS Code settings file: ${source_path}"
    fi

    _link_vscode_user_file "${source_path}" "${target_path}"
}

_apply_vscode_keybindings() {
    local user_dir="$1"
    local source_path="${DOTFILES_DIR}/vscode/keybindings/common.json"
    local target_path="${user_dir}/keybindings.json"

    if [[ ! -f "${source_path}" ]]; then
        die "Missing VS Code keybindings file: ${source_path}"
    fi

    _link_vscode_user_file "${source_path}" "${target_path}"
}

_collect_vscode_snippet_layer() {
    local layer_dir="$1"
    local selected_dir="$2"
    local snippet_path

    if [[ ! -d "${layer_dir}" ]]; then
        return
    fi

    while IFS= read -r snippet_path; do
        ln -sfn "${snippet_path}" "${selected_dir}/$(basename "${snippet_path}")"
    done < <(find "${layer_dir}" -maxdepth 1 -type f -name '*.json' -print)
}

_apply_vscode_snippets() {
    local role="$1"
    local user_dir="$2"
    local target_dir="${user_dir}/snippets"
    local selected_dir
    local selected_path
    local source_path

    selected_dir="$(mktemp -d)"

    _collect_vscode_snippet_layer "${DOTFILES_DIR}/vscode/snippets/common" "${selected_dir}"
    _collect_vscode_snippet_layer "${DOTFILES_DIR}/vscode/snippets/roles/${role}" "${selected_dir}"
    _collect_vscode_snippet_layer "${DOTFILES_DIR}/vscode/local/snippets" "${selected_dir}"

    if ! find "${selected_dir}" -maxdepth 1 -type l -print | grep -q .; then
        rm -rf "${selected_dir}"
        log 'No VS Code snippets to link.'
        return
    fi

    while IFS= read -r selected_path; do
        source_path="$(readlink "${selected_path}")"
        _link_vscode_user_file "${source_path}" "${target_dir}/$(basename "${selected_path}")"
    done < <(find "${selected_dir}" -maxdepth 1 -type l -print)

    rm -rf "${selected_dir}"
}

_collect_vscode_extensions() {
    local role="$1"
    local output_path="$2"
    local manifest_path

    : >"${output_path}"

    for manifest_path in \
        "${DOTFILES_DIR}/vscode/extensions/common.txt" \
        "${DOTFILES_DIR}/vscode/extensions/${role}.txt" \
        "${DOTFILES_DIR}/vscode/local/extensions.txt"
    do
        if [[ -f "${manifest_path}" ]]; then
            awk '{ sub(/\r$/, ""); sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); if ($0 != "") print }' "${manifest_path}" >>"${output_path}"
        fi
    done

    sort -u -o "${output_path}" "${output_path}"
}

_apply_vscode_extensions() {
    local role="$1"
    local code_command="${DOTFILES_VSCODE_CODE_CMD:-code}"
    local desired_path
    local installed_path
    local extension_id

    desired_path="$(mktemp)"
    installed_path="$(mktemp)"

    _collect_vscode_extensions "${role}" "${desired_path}"

    if [[ ! -s "${desired_path}" ]]; then
        rm -f "${desired_path}" "${installed_path}"
        log 'No VS Code extensions to install.'
        return
    fi

    if ! has_command "${code_command}"; then
        rm -f "${desired_path}" "${installed_path}"
        warn "VS Code CLI '${code_command}' was not found. Skipping extension install."
        return
    fi

    if ! "${code_command}" --list-extensions >"${installed_path}"; then
        rm -f "${desired_path}" "${installed_path}"
        die "Failed to list VS Code extensions with '${code_command}'."
    fi

    while IFS= read -r extension_id; do
        if grep -Fxq "${extension_id}" "${installed_path}"; then
            log "VS Code extension already installed: ${extension_id}"
            continue
        fi

        log "Installing VS Code extension: ${extension_id}"
        if ! "${code_command}" --install-extension "${extension_id}"; then
            rm -f "${desired_path}" "${installed_path}"
            die "Failed to install VS Code extension: ${extension_id}"
        fi
    done <"${desired_path}"

    rm -f "${desired_path}" "${installed_path}"
}

setup_vscode() {
    local role
    local user_dir

    _resolve_vscode_role
    role="${DOTFILES_RESOLVED_VSCODE_ROLE}"
    user_dir="$(_vscode_user_dir)"

    log "Applying VS Code configuration for role: ${role}"
    _apply_vscode_user_settings "${user_dir}"
    _apply_vscode_keybindings "${user_dir}"
    _apply_vscode_snippets "${role}" "${user_dir}"
    _apply_vscode_extensions "${role}"
    log 'VS Code setup completed.'
}