# 개발 로그 생성

Claude Code 대화 내역을 기반으로 개발 로그 문서를 자동 생성합니다.

## 사용법

```
/devlog
```

## 출력 포맷 (반드시 이 형식으로 생성)

```markdown
# {프로젝트명} - 개발 로그

Claude Code와 함께 진행한 개발 작업 기록입니다.

---

## YYYY-MM-DD (Day N)

### 1. 작업 제목 (간결하게)

```
사용자가 입력한 원문 그대로
```

**Claude 작업:**
- 수행한 작업 설명
- `파일경로` - 파일 설명
- 생성/수정된 파일들 bullet point로 나열

---

### 2. 다음 작업 제목

```
사용자 요청
```

**Claude 작업:**
- 작업 내용

---

## 커밋 히스토리

| 날짜 | 커밋 | 설명 |
|------|------|------|
| MM/DD | `해시` | 커밋 메시지 |

---

## 기술 스택

- **Frontend**: 사용된 기술
- **Backend**: 사용된 기술
- **Deployment**: 배포 환경

---

## 주요 기능

1. **기능명**
   - 세부 설명
```

## 실행 방법

### 기존 DEVLOG.md가 있는 경우

1. 먼저 `DEVLOG.md` 파일을 읽어서 마지막으로 정리된 날짜와 작업 번호 확인
2. 세션 파일에서 **그 이후 날짜의 대화 내역만** 파싱
3. 기존 파일에 새로운 내용을 **이어서 추가** (덮어쓰기 X)
4. Day 번호와 작업 번호는 기존 파일의 마지막 번호에서 이어서 부여
5. 커밋 히스토리 테이블도 새로운 커밋만 추가

### 세션 파일 파싱

1. **세션 파일 위치**:
   - `~/.claude/projects/{프로젝트경로를-로치환}/` 폴더
   - 예: `/Users/dahye/DEV/my-project` → `-Users-dahye-DEV-my-project`

2. **세션 파일 파싱**:
   - `.jsonl` 파일들 읽기 (agent-*.jsonl 제외)
   - `type: 'user'` → 사용자 요청
   - `type: 'assistant'` → Claude 응답

3. **정리 규칙**:
   - IDE 메타데이터(`<ide_opened_file>` 등) 제외
   - 날짜별로 그룹핑 (Day 1, Day 2...)
   - 관련 작업끼리 하나의 섹션으로 묶기
   - 사용자 요청은 **코드블록**으로, Claude 작업은 **bullet point**로

4. **사용자 요청 정리 규칙** (중요):
   - 모든 의미있는 사용자 요청을 빠짐없이 포함
   - 짧은 질문이라도 맥락이 있으면 **맥락과 함께** 기록
   - 연속된 대화는 하나의 섹션으로 묶되, 핵심 요청들은 모두 포함
   - 에러/문제 해결 과정도 상세히 기록 (어떤 에러 → 어떻게 해결)
   - 예시 - 맥락 없이 질문만 (X): `근데 일부만 되고 다 안채워지는데 이유가 뭐야?`
   - 예시 - 맥락과 함께 (O): `[Airtable 필드 자동 업데이트 중] 근데 일부만 되고 다 안채워지는데 이유가 뭐야? 개선해`

5. **마지막에 추가**:
   - `git log --oneline`으로 커밋 히스토리 테이블 생성
   - 사용된 기술 스택 정리
   - 구현된 주요 기능 요약

## 예시 스크립트

```python
import json
import os
from datetime import datetime
from pathlib import Path

def get_project_session_dir():
    """현재 프로젝트의 세션 디렉토리 경로 반환"""
    cwd = os.getcwd()
    # /를 -로 치환하고 앞에 -붙이기
    project_key = cwd.replace('/', '-')
    return Path.home() / '.claude' / 'projects' / project_key

def parse_sessions(session_dir):
    """세션 파일들을 파싱하여 대화 내역 추출"""
    sessions = []

    for f in sorted(session_dir.glob('*.jsonl')):
        # agent 파일 제외
        if f.name.startswith('agent-'):
            continue
        if f.stat().st_size == 0:
            continue

        messages = []
        with open(f, 'r') as file:
            for line in file:
                try:
                    data = json.loads(line.strip())

                    if data.get('type') == 'user' and 'message' in data:
                        content = extract_content(data['message'])
                        if content:
                            messages.append({
                                'role': 'user',
                                'content': content,
                                'timestamp': data.get('timestamp', '')
                            })

                    elif data.get('type') == 'assistant' and 'message' in data:
                        content = extract_content(data['message'])
                        if content and len(content) > 50:
                            messages.append({
                                'role': 'assistant',
                                'content': content[:500],
                                'timestamp': data.get('timestamp', '')
                            })
                except:
                    continue

        if messages:
            sessions.append({
                'file': f.name,
                'messages': messages
            })

    return sessions

def extract_content(message):
    """메시지에서 텍스트 콘텐츠 추출"""
    if not isinstance(message, dict) or 'content' not in message:
        return None

    content = message['content']

    if isinstance(content, str):
        return content

    if isinstance(content, list):
        texts = []
        for item in content:
            if isinstance(item, dict) and item.get('type') == 'text':
                texts.append(item.get('text', ''))
        return '\n'.join(texts)

    return None

def generate_devlog(sessions, project_name):
    """세션 데이터로 DEVLOG.md 생성"""
    output = [f"# {project_name} - 개발 로그\n"]
    output.append(f"생성일: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n")

    for session in sessions:
        messages = session['messages']
        if not messages:
            continue

        # 세션 시작 시간
        first_ts = messages[0].get('timestamp', '')
        if first_ts:
            try:
                dt = datetime.fromisoformat(first_ts.replace('Z', '+00:00'))
                output.append(f"## 세션: {dt.strftime('%Y-%m-%d %H:%M')}\n\n")
            except:
                pass

        for msg in messages[:30]:  # 세션당 최대 30개
            if msg['role'] == 'user':
                clean = msg['content'].strip()[:200]
                # IDE 메타데이터 제거
                if clean.startswith('<ide_'):
                    continue
                if clean:
                    output.append(f"### 사용자 요청\n```\n{clean}\n```\n\n")
            else:
                clean = msg['content'].strip()[:300]
                if clean:
                    output.append(f"**Claude 작업:** {clean}...\n\n")

        output.append("---\n\n")

    return ''.join(output)

# 실행
if __name__ == '__main__':
    session_dir = get_project_session_dir()
    sessions = parse_sessions(session_dir)

    project_name = os.path.basename(os.getcwd())
    devlog = generate_devlog(sessions, project_name)

    with open('DEVLOG.md', 'w') as f:
        f.write(devlog)

    print(f"✓ DEVLOG.md 생성 완료 ({len(sessions)}개 세션)")
```

## 주의사항

- 세션 파일은 `.jsonl` (JSON Lines) 형식
- 대화 내역은 로컬에만 저장되며 세션별로 분리됨
- IDE 관련 메타데이터(`<ide_opened_file>` 등)는 필터링
- 매우 짧은 응답(50자 미만)은 제외