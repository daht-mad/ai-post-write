#!/bin/bash

# ai-post-write installer for Mac/Linux

REPO_URL="https://raw.githubusercontent.com/daht-mad/ai-post-write/main"

mkdir -p .claude/commands

curl -fsSL "$REPO_URL/.claude/commands/devlog.md" -o .claude/commands/devlog.md
curl -fsSL "$REPO_URL/.claude/commands/ai-case.md" -o .claude/commands/ai-case.md

echo "ai-post-write 설치 완료!"
echo "사용법: /devlog, /ai-case"