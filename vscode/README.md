# VS Code

このディレクトリでは、VS Code User 設定のうち次を dotfiles 管理する。

VS Code 本体は `macos/Brewfile` の `visual-studio-code` cask で導入する。

- `settings/common.json`
- `keybindings/common.json`
- User snippets
- 拡張機能の install manifest

## Role

セットアップ時は machine role を `private` または `work` として解決する。

settings は role で分けず `settings/common.json` を使う。role は snippets と extensions の layer 選択に使う。

優先順は次の通り。

1. `DOTFILES_VSCODE_ROLE`
2. `vscode/local/role`

`DOTFILES_VSCODE_ROLE` を指定して実行した場合は、その値を `vscode/local/role` に保存する。
保存済み role と別の `DOTFILES_VSCODE_ROLE` を渡した場合も、意図しない混在を防ぐためセットアップは停止する。
どちらもない場合、セットアップは停止する。

初回セットアップ例:

```sh
curl -fsSL https://raw.githubusercontent.com/yoshikt/dotfiles/main/install.sh | DOTFILES_VSCODE_ROLE=work bash
```

```sh
curl -fsSL https://raw.githubusercontent.com/yoshikt/dotfiles/main/install.sh | DOTFILES_VSCODE_ROLE=private bash
```

clone 済み repo で保存済み role と同じ role を明示したい場合は、次のどちらかで再実行する。

```sh
DOTFILES_VSCODE_ROLE=private bash ~/dotfiles/install.sh
```

```sh
DOTFILES_VSCODE_ROLE=work bash ~/dotfiles/install.sh
```

role を意図的に切り替えたい場合は、保存済み role file を削除してから希望する role で再実行する。

```sh
rm ~/dotfiles/vscode/local/role
DOTFILES_VSCODE_ROLE=private bash ~/dotfiles/install.sh
```

```sh
rm ~/dotfiles/vscode/local/role
DOTFILES_VSCODE_ROLE=work bash ~/dotfiles/install.sh
```

手動で Git 管理しない local file を置く場合は次でもよい。

```sh
mkdir -p ~/dotfiles/vscode/local
printf 'private\n' > ~/dotfiles/vscode/local/role
```

role が保存済みなら、2 回目以降は次だけでよい。

```sh
bash ~/dotfiles/install.sh
```

## User Files

VS Code User directory は macOS では `~/Library/Application Support/Code/User/`。

セットアップでは次を symlink する。

- `settings/common.json` -> `settings.json`
- `keybindings/common.json` -> `keybindings.json`

反映先に dotfiles 管理外の既存ファイルがある場合は、自動上書きしない。セットアップは停止し、手動で退避または削除してから再実行する。

## Snippets

snippets はファイル単位で扱う。

優先順は次の通りで、同名ファイルは後の layer が勝つ。

1. `snippets/common/`
2. `snippets/roles/{role}/`
3. `local/snippets/`

選ばれた snippet file は VS Code User `snippets/` へ symlink する。

## Extensions

拡張機能は `.vscode/extensions.json` ではなく、install manifest として管理する。`.vscode/extensions.json` は workspace recommendation 用であり、User 環境の再現には使わない。

manifest は role ごとに分ける。

- `extensions/common.txt`: 全端末で入れる拡張
- `extensions/private.txt`: private 端末だけで入れる拡張
- `extensions/work.txt`: work 端末だけで入れる拡張
- `local/extensions.txt`: Git 管理しないローカル追加分

セットアップ時は不足している拡張だけを install する。余分な拡張は標準では uninstall しない。

## Local-Only Workspace Files

この dotfiles repo を VS Code で開くときだけ使う個人用ファイルは、repo 直下の `.vscode/` に置く。

例:

- `.vscode/character.instructions.md`
- `.vscode/config/AGENTS.md`

これらは Git には載せず、`.git/info/exclude` または global excludes でローカル除外する。

## Phase 2 Candidates

次のファイルは dotfiles 化可能だが、role 固有、端末固有、private、secret を含む可能性があるため初回スコープからは外す。

- `chatLanguageModels.json`
- `mcp.json`
- `prompts/`
- `pyproject.toml`
- VS Code Profiles

必要性と中身を確認してから、別フェーズで扱う。

## 管理しないもの

次は runtime state、cache、workspace metadata、または拡張本体なので管理しない。

- `History/`
- `globalStorage/`
- `workspaceStorage/`
- `~/.vscode/extensions/`