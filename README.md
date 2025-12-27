# ai-post-write

Claude Code용 글쓰기 커맨드 모음

## 포함된 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/devlog` | 작업 내역을 개발 로그로 자동 정리 |
| `/ai-case` | AI 활용 사례 게시글 작성 (비개발자 대상) |

## 설치 방법

### Mac / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/daht-mad/ai-post-write/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/daht-mad/ai-post-write/main/install.ps1 | iex
```

## 수동 설치

프로젝트 루트에 `.claude/commands/` 폴더를 만들고 파일을 복사하세요:

```
your-project/
└── .claude/
    └── commands/
        ├── devlog.md
        └── ai-case.md
```

## 사용법

Claude Code에서:

```
/devlog     # 개발 로그 생성
/ai-case    # AI 활용 사례글 작성
```

## 라이선스

MIT