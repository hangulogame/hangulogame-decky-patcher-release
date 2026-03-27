#!/bin/bash
# Hangulogame Patcher - Decky 플러그인 설치/업데이트 스크립트

REPO_URL="https://github.com/hangulogame/hangulogame-decky-patcher-release/releases/latest/download/hangulo-patcher.zip"
PLUGIN_NAME="Hangulogame Patcher"
PLUGIN_DIR="$HOME/homebrew/plugins/$PLUGIN_NAME"
LOG="/tmp/hangulo-install.log"

# 로그 초기화
echo "=== $PLUGIN_NAME 설치 시작 ===" > "$LOG"

# 에러 표시 함수
show_error() {
    zenity --error --title="$PLUGIN_NAME" --text="$1" --width=300 2>/dev/null
    exit 1
}

# Decky Loader 확인
if [ ! -d "$HOME/homebrew/plugins" ]; then
    show_error "Decky Loader가 설치되어 있지 않습니다.\n먼저 Decky Loader를 설치해주세요."
fi

# 비밀번호 입력
PASSWORD=$(zenity --password --title="$PLUGIN_NAME 설치" --text="설치를 위해 비밀번호를 입력해주세요." 2>/dev/null)
if [ -z "$PASSWORD" ]; then
    exit 0
fi

# sudo 검증
if ! echo "$PASSWORD" | sudo -S true 2>/dev/null; then
    show_error "비밀번호가 올바르지 않습니다."
fi

# 설치 진행 (zenity progress)
(
    echo "10"
    echo "# 기존 플러그인 정리 중..."
    if [ -d "$PLUGIN_DIR" ]; then
        echo "$PASSWORD" | sudo -S rm -rf "$PLUGIN_DIR" >> "$LOG" 2>&1
    fi

    echo "20"
    echo "# 디렉토리 생성 중..."
    echo "$PASSWORD" | sudo -S mkdir -p "$PLUGIN_DIR" >> "$LOG" 2>&1
    echo "$PASSWORD" | sudo -S chown -R "$(whoami):$(whoami)" "$PLUGIN_DIR" >> "$LOG" 2>&1

    echo "40"
    echo "# 다운로드 중..."
    rm -f /tmp/hangulo-patcher.zip
    rm -rf /tmp/hangulo-install
    curl -sL "$REPO_URL" -o /tmp/hangulo-patcher.zip >> "$LOG" 2>&1
    if [ ! -f /tmp/hangulo-patcher.zip ]; then
        echo "# 다운로드 실패"
        echo "100"
        exit 1
    fi

    echo "70"
    echo "# 설치 중..."
    unzip -o /tmp/hangulo-patcher.zip -d /tmp/hangulo-install/ >> "$LOG" 2>&1
    cp -r "/tmp/hangulo-install/$PLUGIN_NAME/"* "$PLUGIN_DIR/" >> "$LOG" 2>&1
    rm -rf /tmp/hangulo-patcher.zip /tmp/hangulo-install
    chmod -R u+rw "$PLUGIN_DIR"
    chmod +x "$PLUGIN_DIR/bin/"* 2>/dev/null

    echo "100"
    echo "# 완료!"
) | zenity --progress --title="$PLUGIN_NAME 설치" --text="설치 준비 중..." --percentage=0 --auto-close --width=400 2>/dev/null

# 결과 확인
if [ -d "$PLUGIN_DIR" ] && [ -f "$PLUGIN_DIR/plugin.json" ]; then
    zenity --info --title="$PLUGIN_NAME" --text="설치가 완료되었습니다!\n\n게임 모드로 전환하면\nQuick Access 메뉴에서 사용할 수 있습니다." --width=300 2>/dev/null
else
    zenity --error --title="$PLUGIN_NAME" --text="설치에 실패했습니다.\n로그: $LOG" --width=300 2>/dev/null
fi
