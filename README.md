# JooDock

macOS 화면 상단 중앙에 마우스를 올리면 자주 쓰는 파일에 빠르게 접근할 수 있는 앱입니다.

## 기능

- **Hover 트리거**: 화면 상단 중앙에 마우스를 0.3초 이상 올리면 팝업 표시
- **파일 관리**: 드래그앤드롭 또는 Finder에서 파일 추가
- **그룹핑**: 파일을 카테고리별로 분류
- **검색**: 파일명 실시간 검색
- **미리보기**: QuickLook으로 파일 미리보기 (스페이스바 또는 눈 아이콘)
- **다크모드**: macOS 다크모드 자동 지원

## 설치 방법

### 방법 1: 소스에서 빌드 (Xcode 필요)

```bash
git clone https://github.com/roka8941/apps.git
cd apps
open JooDock.xcodeproj
```

Xcode에서 `⌘ + R`로 실행

### 방법 2: Release 다운로드

1. [Releases](https://github.com/roka8941/apps/releases) 페이지에서 최신 버전 다운로드
2. `JooDock.app`을 `/Applications` 폴더로 이동
3. 첫 실행 시 보안 경고가 나오면:
   - **시스템 설정 → 개인정보 보호 및 보안** → "확인 없이 열기" 클릭
   - 또는 터미널에서: `xattr -cr /Applications/JooDock.app`

## 사용법

1. 앱 실행 후 메뉴바에 아이콘이 나타남
2. **화면 상단 중앙**에 마우스를 올리면 팝업 표시
3. 파일 추가: 팝업에 파일 드래그앤드롭 또는 "Add File" 클릭
4. 파일 열기: 더블클릭
5. 미리보기: 파일에 마우스 올린 후 눈 아이콘 클릭

## 설정

메뉴바 아이콘 클릭 → Settings (또는 `⌘ + ,`)

- **Hover Zone Width**: 트리거 영역 너비
- **Hover Zone Height**: 트리거 영역 높이
- **Hover Delay**: 팝업 표시까지 대기 시간

## 요구 사항

- macOS 13.0 이상
- Xcode 15.0 이상 (빌드 시)

## 라이선스

Private - Tyche Technologies 내부용

---

Made with ❤️ by Minsoo