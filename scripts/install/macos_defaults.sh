apply_macos_defaults() {
    # キーボードのリピート開始時間を短くする
    /usr/bin/defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # キーボードのキーリピート速度を上げる
    /usr/bin/defaults write NSGlobalDomain KeyRepeat -float 1.5

    # トラックパッドの軌跡速度を上げる
    /usr/bin/defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
}
