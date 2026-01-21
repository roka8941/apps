# JooDock

macOS 화면 상단 중앙에 마우스를 올리면 자주 쓰는 파일에 빠르게 접근할 수 있는 앱입니다.

## 기능

- **Hover 트리거**: 화면 상단 중앙(300x50px)에 마우스를 0.3초 이상 올리면 팝업 표시
- **Spotlight 검색**: 맥북 전체 파일/폴더를 파일명으로 검색
- **최근 파일**: 최근 7일 이내 사용한 파일 5개 자동 표시
- **파일 관리**: 드래그앤드롭 또는 Finder에서 파일 추가
- **그룹핑**: 파일을 카테고리별로 분류 (Work, Personal 등)
- **다크모드**: macOS 다크모드 자동 지원

## 설치 방법

### 방법 1: 소스에서 빌드 (Xcode 필요)

```bash
git clone https://github.com/roka8941/apps.git
cd apps
open JooDock.xcodeproj
```

Xcode에서 `Cmd + B`로 빌드 후:

```bash
cp -R ~/Library/Developer/Xcode/DerivedData/JooDock-*/Build/Products/Debug/JooDock.app /Applications/
xattr -cr /Applications/JooDock.app
```

### 방법 2: Release 다운로드

1. [Releases](https://github.com/roka8941/apps/releases) 페이지에서 최신 버전 다운로드
2. `JooDock.app`을 `/Applications` 폴더로 이동
3. 첫 실행 시 보안 경고가 나오면:
   - **시스템 설정 → 개인정보 보호 및 보안** → "확인 없이 열기" 클릭
   - 또는 터미널에서: `xattr -cr /Applications/JooDock.app`

## 사용법

1. 앱 실행 후 메뉴바에 아이콘이 나타남
2. **화면 상단 중앙**에 마우스를 올리면 팝업 표시
3. **파일 검색**: 검색창에 파일명 입력 → 맥북 전체에서 검색
4. **파일 추가**: 팝업에 파일 드래그앤드롭 또는 그룹 메뉴에서 "Add Files" 클릭
5. **파일 열기**: 클릭 (여러 파일 연속 열기 가능)
6. **파일 삭제**: 마우스 호버 시 나타나는 X 버튼 클릭
7. **팝업 닫기**: ESC 키, 외부 클릭, 또는 마우스가 팝업 영역 밖으로 2초 이상 벗어남

## 키보드 단축키

| 단축키 | 기능 |
|--------|------|
| `ESC` | 팝업 닫기 |
| 메뉴바 아이콘 클릭 | 팝업 토글 |

## 설정 (UserDefaults)

| 키 | 기본값 | 설명 |
|----|--------|------|
| `hoverZoneWidth` | 300 | 트리거 영역 너비 (px) |
| `hoverZoneHeight` | 50 | 트리거 영역 높이 (px) |
| `hoverDelay` | 0.3 | 팝업 표시까지 대기 시간 (초) |

## 요구 사항

- macOS 13.0 이상
- Xcode 15.0 이상 (빌드 시)

## 프로세스 종료

터미널에서:
```bash
pkill -f JooDock
```

## 라이선스

Private - Tyche Technologies 내부용

---

Made with SwiftUI by Minsoo