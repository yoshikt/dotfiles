## Homebrew の環境変数
if [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
	eval "$(/usr/local/bin/brew shellenv)"
fi

## ユーザー管理コマンド用に ~/.local/bin の PATH 設定を読み込む
if [ -f "$HOME/.local/bin/env" ]; then
	. "$HOME/.local/bin/env"
fi

## Macでzshをデフォルトで使えという警告を非表示にする
## https://support.apple.com/ja-jp/HT208050
export BASH_SILENCE_DEPRECATION_WARNING=1

if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi
