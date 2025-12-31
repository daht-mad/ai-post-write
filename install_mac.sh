#!/bin/bash

# write-post installer for Mac/Linux

REPO_URL="https://raw.githubusercontent.com/daht-mad/write-post/main"

echo "설치 위치를 선택하세요:"
echo "1) 전역 설치 (모든 프로젝트에서 사용)"
echo "2) 프로젝트 설치 (현재 폴더에서만 사용)"
read -p "선택 (1/2): " choice </dev/tty

if [ "$choice" = "1" ]; then
    TARGET_DIR="$HOME/.claude/commands"
    SCOPE="전역"
else
    TARGET_DIR=".claude/commands"
    SCOPE="프로젝트"
fi

mkdir -p "$TARGET_DIR"
curl -fsSL "$REPO_URL/.claude/commands/write-post.md" -o "$TARGET_DIR/write-post.md"

echo ""
echo "write-post $SCOPE 설치 완료!"
echo "사용법: /write-post"
