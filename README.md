# dotfiles

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/yoshikt/dotfiles/main/install.sh | bash
```

## Current scope

- macOS: Homebrew の導入確認、`macos/Brewfile` によるパッケージ導入、iTerm2 / Karabiner / VS Code 設定リンク、VS Code 拡張機能の不足分 install、Homebrew bash へのログインシェル変更、Custom Prefs defaults の設定
- Linux / WSL: dotfiles の clone のみ（セットアップ処理は今後追加）

## macOS setup phases

- default: `bash ~/dotfiles/install.sh` (`DOTFILES_MACOS_PHASE=all`)
- packages only: `DOTFILES_MACOS_PHASE=packages bash ~/dotfiles/install.sh`
- settings only: `DOTFILES_MACOS_PHASE=settings bash ~/dotfiles/install.sh`

## VS Code role

VS Code setup requires `DOTFILES_VSCODE_ROLE=private|work` or a local role file at `~/dotfiles/vscode/local/role`.
