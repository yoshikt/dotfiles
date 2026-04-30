# dotfiles

## Installation

初回実行時は VS Code role を指定する。

```sh
curl -fsSL https://raw.githubusercontent.com/yoshikt/dotfiles/main/install.sh | DOTFILES_VSCODE_ROLE=work bash
```

private 端末では `work` を `private` に置き換える。

既に clone 済みの場合は、local role file を作ってから再実行できる。

```sh
mkdir -p ~/dotfiles/vscode/local
printf 'work\n' > ~/dotfiles/vscode/local/role
bash ~/dotfiles/install.sh
```

`vscode/local/role` を作っておけば、以後は毎回 `DOTFILES_VSCODE_ROLE` を指定しなくてよい。

VS Code User 設定の既存ファイルは自動上書きしない。初回移行時は [vscode/README.md](vscode/README.md) を参照する。

## Current scope

- macOS: Homebrew の導入確認、`macos/Brewfile` によるパッケージ導入、iTerm2 / Karabiner / VS Code の導入と設定リンク、VS Code 拡張機能の不足分 install、Homebrew bash へのログインシェル変更、Custom Prefs defaults の設定
- Linux / WSL: dotfiles の clone のみ（セットアップ処理は今後追加）

## macOS setup phases

- default: `bash ~/dotfiles/install.sh` (`DOTFILES_MACOS_PHASE=all`)
- packages only: `DOTFILES_MACOS_PHASE=packages bash ~/dotfiles/install.sh`
- settings only: `DOTFILES_MACOS_PHASE=settings bash ~/dotfiles/install.sh`

