# dotfiles

## Installation

初回実行時は VS Code role を指定する。端末に合わせて次のどちらかをそのまま実行する。

```sh
curl -fsSL https://raw.githubusercontent.com/yoshikt/dotfiles/main/install.sh | DOTFILES_VSCODE_ROLE=work bash
```

```sh
curl -fsSL https://raw.githubusercontent.com/yoshikt/dotfiles/main/install.sh | DOTFILES_VSCODE_ROLE=private bash
```

初回に `DOTFILES_VSCODE_ROLE` を渡すと、installer が `~/dotfiles/vscode/local/role` を自動作成する。
2 回目以降は次だけでよい。

```sh
bash ~/dotfiles/install.sh
```

`DOTFILES_VSCODE_ROLE` も `vscode/local/role` もない状態で実行した場合は停止する。
保存済み role と別の `DOTFILES_VSCODE_ROLE` を渡した場合も停止する。role を切り替えたいときは、`~/dotfiles/vscode/local/role` を削除してから希望する role で再実行する。

VS Code User 設定の既存ファイルは自動上書きしない。初回移行時は [vscode/README.md](vscode/README.md) を参照する。

## Current scope

- macOS: Homebrew の導入確認、`macos/Brewfile` によるパッケージ導入、iTerm2 / Karabiner / VS Code の導入と設定リンク、VS Code 拡張機能の不足分 install、Homebrew bash へのログインシェル変更、Custom Prefs defaults の設定
- Linux / WSL: dotfiles の clone のみ（セットアップ処理は今後追加）

## macOS setup phases

- default: `bash ~/dotfiles/install.sh` (`DOTFILES_MACOS_PHASE=all`)
- packages only: `DOTFILES_MACOS_PHASE=packages bash ~/dotfiles/install.sh`
- settings only: `DOTFILES_MACOS_PHASE=settings bash ~/dotfiles/install.sh`

