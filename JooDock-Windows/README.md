# JooDock for Windows

Windows 화면 상단 중앙에 마우스를 올리면 자주 쓰는 파일에 빠르게 접근할 수 있는 앱입니다.

> macOS 버전: [JooDock-MacOS](../JooDock-MacOS/)

## 기능

- **Hover 트리거**: 화면 상단 중앙(300x50px)에 마우스를 0.3초 이상 올리면 팝업 표시
- **파일 검색**: Windows 전체 파일/폴더를 파일명으로 검색
- **최근 파일**: 최근 7일 이내 사용한 파일 5개 자동 표시
- **파일 관리**: 드래그앤드롭 또는 파일 탐색기에서 파일 추가
- **그룹핑**: 파일을 카테고리별로 분류 (Work, Personal 등)
- **다크모드**: Windows 다크모드 자동 지원

## 요구 사항

### 실행 환경
- Windows 10 (1903) 이상
- Windows 11 권장

### 개발 환경 (빌드 시)
- [Node.js](https://nodejs.org/) 18.0 이상
- [Rust](https://rustup.rs/) 최신 버전
- [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) (C++ 빌드 도구)

## 설치 방법

### 방법 1: Release 다운로드 (권장)

1. [Releases](https://github.com/roka8941/apps/releases) 페이지에서 최신 버전 다운로드
2. `JooDock_x64.msi` 설치 파일 실행
3. 설치 후 시작 메뉴에서 JooDock 실행

### 방법 2: 소스에서 빌드

```bash
# 1. 저장소 클론
git clone https://github.com/roka8941/apps.git
cd apps/JooDock-Windows

# 2. 의존성 설치
npm install

# 3. 개발 모드 실행
npm run tauri dev

# 4. 프로덕션 빌드
npm run tauri build
```

빌드된 설치 파일은 `src-tauri/target/release/bundle/` 폴더에 생성됩니다.

## 사용법

1. 앱 실행 후 시스템 트레이에 아이콘이 나타남
2. **화면 상단 중앙**에 마우스를 올리면 팝업 표시
3. **파일 검색**: 검색창에 파일명 입력 → Windows 전체에서 검색
4. **파일 추가**: 팝업에 파일 드래그앤드롭 또는 "Add File" 클릭
5. **파일 열기**: 클릭 (여러 파일 연속 열기 가능)
6. **파일 삭제**: 마우스 호버 시 나타나는 X 버튼 클릭
7. **팝업 닫기**: ESC 키, 외부 클릭, 또는 마우스가 팝업 영역 밖으로 2초 이상 벗어남

## 키보드 단축키

| 단축키 | 기능 |
|--------|------|
| `ESC` | 팝업 닫기 |
| 트레이 아이콘 클릭 | 팝업 토글 |

## 설정

설정 파일 위치: `%LOCALAPPDATA%\JooDock\`

| 파일 | 설명 |
|------|------|
| `files.json` | 저장된 파일 목록 |
| `groups.json` | 그룹 설정 |
| `settings.json` | 앱 설정 |

### 설정 값

| 키 | 기본값 | 설명 |
|----|--------|------|
| `hoverZoneWidth` | 300 | 트리거 영역 너비 (px) |
| `hoverZoneHeight` | 50 | 트리거 영역 높이 (px) |
| `hoverDelay` | 0.3 | 팝업 표시까지 대기 시간 (초) |

## 기술 스택

- **프레임워크**: [Tauri 2.0](https://tauri.app/) (Rust 백엔드)
- **프론트엔드**: React + TypeScript + Vite
- **스타일링**: Tailwind CSS
- **상태관리**: Zustand
- **아이콘**: Lucide React

## 라이선스

MIT License

유용하게 사용하셨다면 ⭐ 별을 눌러주세요!

---

Made with Tauri + React by Minsoo
