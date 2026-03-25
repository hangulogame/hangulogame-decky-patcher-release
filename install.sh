#!/bin/bash
# Hangulogame Patcher - Decky 플러그인 설치/업데이트 스크립트
set -e

REPO_URL="https://github.com/hangulogame/hangulogame-decky-patcher-release/releases/latest/download/hangulo-patcher.zip"
PLUGIN_NAME="Hangulogame Patcher"
PLUGIN_DIR="$HOME/homebrew/plugins/$PLUGIN_NAME"

echo "=== $PLUGIN_NAME 설치 ==="

# Decky Loader 확인
if [ ! -d "$HOME/homebrew/plugins" ]; then
    echo "Error: Decky Loader가 설치되어 있지 않습니다."
    echo "먼저 Decky Loader를 설치해주세요."
    exit 1
fi

# 비밀번호 입력 (zenity가 있으면 GUI, 없으면 터미널)
if command -v zenity &> /dev/null; then
    PASSWORD=$(zenity --password --title="$PLUGIN_NAME 설치" --text="설치를 위해 비밀번호를 입력해주세요." 2>/dev/null)
    if [ -z "$PASSWORD" ]; then
        echo "취소됨."
        exit 1
    fi
else
    read -s -p "비밀번호: " PASSWORD
    echo ""
fi

# sudo 검증
if ! echo "$PASSWORD" | sudo -S true 2>/dev/null; then
    echo "Error: 비밀번호가 올바르지 않습니다."
    exit 1
fi

# 기존 플러그인 삭제
if [ -d "$PLUGIN_DIR" ]; then
    echo "기존 플러그인 삭제 중..."
    echo "$PASSWORD" | sudo -S rm -rf "$PLUGIN_DIR"
fi

# 디렉토리 생성 + 소유권 설정
echo "디렉토리 생성 중..."
echo "$PASSWORD" | sudo -S mkdir -p "$PLUGIN_DIR"
echo "$PASSWORD" | sudo -S chown -R "$(whoami):$(whoami)" "$PLUGIN_DIR"

# 다운로드 + 설치
echo "다운로드 중..."
curl -sL "$REPO_URL" -o /tmp/hangulo-patcher.zip
unzip -o /tmp/hangulo-patcher.zip -d /tmp/hangulo-install/ > /dev/null
cp -r "/tmp/hangulo-install/$PLUGIN_NAME/"* "$PLUGIN_DIR/"
rm -rf /tmp/hangulo-patcher.zip /tmp/hangulo-install

# 쓰기 권한 설정
chmod -R u+rw "$PLUGIN_DIR"

# plugin_loader 재시작
echo "플러그인 로더 재시작 중..."
echo "$PASSWORD" | sudo -S systemctl restart plugin_loader.service

echo "=== 설치 완료! ==="

if command -v zenity &> /dev/null; then
    zenity --info --title="$PLUGIN_NAME" --text="설치가 완료되었습니다!\nSteam의 Quick Access 메뉴에서 확인하세요." --width=300 2>/dev/null
fi
