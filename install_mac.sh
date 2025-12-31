#!/bin/bash

# ai-post-write installer for Mac/Linux

REPO_URL="https://raw.githubusercontent.com/daht-mad/ai-post-write/main"

mkdir -p .claude/commands

curl -fsSL "$REPO_URL/.claude/commands/write-post.md" -o .claude/commands/write-post.md

echo "ai-post-write 설치 완료!"
echo "사용법: /write-post"