# ai-post-write installer for Windows PowerShell

$RepoUrl = "https://raw.githubusercontent.com/daht-mad/ai-post-write/main"

New-Item -ItemType Directory -Force -Path ".claude\commands" | Out-Null

Invoke-WebRequest -Uri "$RepoUrl/.claude/commands/write-post.md" -OutFile ".claude\commands\write-post.md"

Write-Host "ai-post-write 설치 완료!" -ForegroundColor Green
Write-Host "사용법: /write-post"