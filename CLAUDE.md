# 데일리카네기 (Daily Carnegie) 웹사이트

> 이 프로젝트를 처음 보는 사람(및 Claude)이 빠르게 이해하도록 정리한 안내서입니다.

## 한줄 요약
**데일리카네기** = "매일 만나는 카네기 교육"이라는 뜻의 바인그룹 서비스 브랜드. 데일카네기코리아(바인그룹)의 **최고경영자(CEO) 과정** 안내·입학 상담 사이트. **순수 정적 사이트**(HTML/CSS/JS)이며 프레임워크·서버·DB가 없습니다. GitHub Pages로 배포됩니다.

## 기본 정보
- **저장소**: github.com/x26589334-cpu/daily-carnegie
- **배포 URL**: https://dailycarnegie.com/ (커스텀 도메인 연결 시 `CNAME` 파일 추가 + 모든 페이지의 canonical/og:url + `sitemap.xml` + `robots.txt`의 URL 교체 필요)
- **호스팅/배포**: GitHub Pages. `main` 브랜치에 **push하면 1~2분 뒤 자동 배포**됩니다. (빌드 과정 없음)
- **기술**: 정적 HTML/CSS/JS. 폰트는 Pretendard(jsdelivr CDN) + Noto Serif KR(Google Fonts, 헤드라인용). 지도는 Google Maps iframe(API 키 없음).
- **디자인 톤**: 딥 네이비(#0B1F3A) × 골드(#B8933F) × 아이보리. 세리프 헤드라인. "중후하고 고급스러운" CEO 교육 톤.

## 파일 구조
- `index.html` — 홈 (히어로에 **모집 중인 기수 카드** 포함)
- `program.html` — 과정 소개 (12주 커리큘럼·특징·기대효과·특전)
- `about.html` — 데일카네기 소개 (철학·수치·연혁·프로그램·고객사)
- `alumni.html` — 카네기클럽 동문 네트워크 + 후기
- `faq.html` — FAQ (아코디언, FAQPage JSON-LD)
- `apply.html` — 개강 일정표·수강료 + **입학 상담 신청 폼** (지도·오시는 길 없음)
- `privacy.html` — 개인정보처리방침 (noindex)
- `assets/css/style.css` — 전체 스타일. 색상·폰트는 상단 `:root` 디자인 토큰에서 관리
- `assets/js/main.js` — 공통 JS (모바일 카테고리 바, FAQ 아코디언, 스크롤 reveal, `[data-count]` 카운트업, `form[data-sheet]` 전송, 전화 플로팅 버튼, 현재 메뉴 active)
- `assets/images/favicon.svg` — 파비콘 (네이비 원 + 골드 C). 로고 이미지 없음 — 헤더/푸터 로고는 CSS 모노그램(`.logo .mark`)
- `google-apps-script.gs` — 상담폼 백엔드(구글 Apps Script) **참고용 사본** (연결 방법 주석 포함)
- `sitemap.xml`, `robots.txt`, `.nojekyll`

## 공통 마크업
헤더·푸터는 모든 페이지에 **복사되어** 있습니다(인클루드 없음). 메뉴를 바꾸면 7개 HTML 모두 수정해야 합니다.
메뉴: 과정 소개 / 데일카네기 / 동문·후기 / FAQ / 일정·신청 + 우측 전화번호·"입학 상담 신청" 버튼.

## 외부 연동
- **상담 신청 폼**(`apply.html`): `<form data-sheet="…/exec">` — 과외(perfectedu)·픽포스와 **같은 공용 Apps Script 웹앱** → 구글 "웹 문의" 시트. hidden `sheet=데일리카네기`, `_form=데일리카네기-입학상담`(구분 컬럼), `main.js`가 `_page`/`_time` 추가. 필드명은 시트 헤더가 되므로 **한글**: 성함, 연락처, 회사명, 직책, 이메일, 관심과정, 문의내용, 개인정보동의. 전용 탭으로 분리하려면 `google-apps-script.gs` 새 웹앱 배포 후 URL 교체.
- **전화**: 다른 사이트와 같은 마케팅 상담 번호 **010-6832-1994** (헤더·푸터·플로팅 버튼·CTA·FAQ). 데일카네기코리아의 사무실 전화/이메일/주소/지도는 **사이트에 넣지 않음** (사무실 방문 없이 온라인 상담·등록). 교육 장소는 "서울 (상담 시 안내)"로만 표기.
- **GA4 / 네이버 서치어드바이저**: 아직 미삽입. 삽입 시 각 페이지 `<head>`에 추가.

## 콘텐츠 출처 (2026-08 기준)
- 과정 정보(12주 커리큘럼, 특징, 특전, 시간, 수강료 4,000,000원, 서울 103기 2026.9.8~11.24 화 17:00~21:00, 기수 일정)는 carnegie.co.kr 공개 정보. 공식 전화·이메일·주소는 사이트에 표기하지 않음.
- 수치(1912년 설립, 85개국, 1,000만 명 수료, 4만 명 카네기클럽, 3,000개 기업, 만족도 90%)는 carnegie.co.kr 소개 페이지 기준.
- **후기 6건과 "소수 정원", "저녁 식사 포함", 신청 절차, 104기 일정, 보강 규정은 예시/추정**입니다. 실제 정보로 교체 필요.

## 자주 하는 작업 가이드
- **새 기수 반영**: `index.html` 히어로 `.class-card`, `apply.html` 일정표·select 옵션, `program.html`·`faq.html`의 기수 언급, `index.html` CTA 문구.
- **캐시 갱신**: CSS/JS 수정 시 각 HTML의 `style.css?v=…`, `main.js?v=…` 버전 문자열을 올릴 것.
- **새 페이지 추가**: HTML 만들고 → 헤더/푸터 메뉴 7개 파일 반영 → `sitemap.xml`에 URL 추가.

## ⚠️ 주의사항
- **공개 저장소**입니다. 신청자 데이터(xlsx/csv), 시트 ID 외 비밀값(봇 토큰 등)은 절대 커밋 금지 (`.gitignore` 등록됨).
- **브랜드 표기 규칙**: 서비스명(로고·title·og:site_name·푸터·저작권)은 **"데일리카네기"**(Daily Carnegie, "매일 만나는 카네기 교육"). 교육 과정·역사·수료증 등 내용을 가리킬 때는 **"데일카네기"**(공식 표기) 그대로. 둘을 섞지 말 것.
