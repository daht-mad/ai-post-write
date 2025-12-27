# ai-post-write installer for Windows PowerShell

$RepoUrl = "https://raw.githubusercontent.com/daht-mad/ai-post-write/main"

New-Item -ItemType Directory -Force -Path ".claude\commands" | Out-Null

Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/devlog.md" -OutFile ".claude\commands\devlog.md"
Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/ai-case.md" -OutFile ".claude\commands\ai-case.md"

Write-Host "ai-post-write 설치 완료!" -ForegroundColor Green
Write-Host "사용법: /devlog, /ai-case"