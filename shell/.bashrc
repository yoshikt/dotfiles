# 共通設定 (bash/zsh 共有)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if [ -f "${DOTFILES_DIR}/shell/.shrc" ]; then
    . "${DOTFILES_DIR}/shell/.shrc"
fi

if [ -f "$HOME/.myrc" ]; then
    . "$HOME/.myrc"
fi
