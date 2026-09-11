# 카네기 레터 — 발행 계획

하루 한 편. 위에서부터 순서대로 쓴다. 발행한 줄은 맨 앞에 `[x]` 를 붙인다.

## 쓰는 방법
1. 본문 HTML 조각을 아무 데나 `draft.html` 로 쓴다 (`<p>`, `<h2>`, `<blockquote>`, `<ul>` 만 쓴다)
2. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new-post.ps1 -Slug {슬러그} -Title "{제목}" -Date {YYYY-MM-DD} -Desc "{한 문장}" -BodyFile draft.html -Principle "{원칙}"`
3. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-blog.ps1`  ← 목록·RSS·사이트맵 갱신
4. 커밋·푸시

## 글의 형식 (지킬 것)
- **상황 → 원칙 → 현장 적용 → 한 줄 요약** 순서. 원칙 소개로 시작하지 않는다.
- 제목에 리더가 **실제로 검색할 상황**을 넣는다. "원칙 1: 비난하지 마라"(X) / "실적이 부진한 팀장에게 어떻게 말할 것인가"(O)
- 1,000~1,500자. 짧으면 검색에 안 걸리고, 길면 안 읽는다.
- 한 편에 원칙 하나. 여러 개 욱여넣지 않는다.
- **발행한 글은 고치지 않는다.** 제목을 바꾸면 검색 순위가 초기화된다 (퍼펙트에듀에서 노출 44→12 로 떨어진 사례가 있다).

---

## 1부 · 인간관계론 — 사람을 다루는 법 (12편)
- [x] `blame-nothing` | 실적이 부진한 팀장에게 어떻게 말할 것인가 | 원칙 1 비난하지 않는다
- [x] `honest-appreciation` | "수고했어"가 통하지 않는 이유 | 원칙 2 솔직한 인정
- [x] `want-it-themselves` | 시키지 않아도 움직이게 하려면 | 원칙 3 상대의 욕구를 자극한다
- [ ] `genuine-interest` | 회식 말고, 관심 | 원칙 4 진심 어린 관심
- [ ] `smile-first` | 대표의 표정이 조직의 온도를 정한다 | 원칙 5 미소
- [x] `remember-names` | 직원 이름을 기억하는 것이 왜 성과가 되는가 | 원칙 6 이름
- [x] `let-them-talk` | 회의에서 아무도 의견을 내지 않을 때 | 원칙 7 상대가 말하게 한다
- [ ] `their-interest` | 상대가 관심 있는 것으로 말문을 연다 | 원칙 8 상대의 관심사
- [ ] `make-them-important` | 인정에 인색한 리더가 잃는 것 | 원칙 9 중요한 사람이라는 느낌
- [ ] `avoid-argument` | 논쟁에서 이기고 사람을 잃는다 | 원칙 10 논쟁을 피한다
- [ ] `never-say-wrong` | "그건 틀렸습니다"라고 말하기 전에 | 원칙 11 잘못을 지적하지 않는다
- [x] `admit-fault-first` | 잘못을 지적해야 할 때, 먼저 인정하고 시작하라 | 원칙 12 자기 잘못을 먼저 인정

## 2부 · 인간관계론 — 설득 (10편)
- [ ] `friendly-start` | 협상은 첫 30초에 결정된다 | 우호적으로 시작한다
- [ ] `yes-yes` | 반대하는 상대에게서 "예"를 끌어내는 순서 | 예 반응을 얻는다
- [ ] `let-them-own` | 내 아이디어를 상대의 아이디어로 만드는 법 | 스스로 생각해냈다고 느끼게 한다
- [ ] `see-their-side` | 왜 저 사람은 저렇게 생각할까 | 상대의 관점에서 본다
- [ ] `sympathize` | 불만을 제기한 고객을 단골로 바꾸는 한 문장 | 공감한다
- [ ] `noble-motives` | 사람은 자기가 괜찮은 사람이고 싶어 한다 | 고상한 동기에 호소한다
- [ ] `dramatize` | 숫자만으로는 조직이 움직이지 않는다 | 극적으로 표현한다
- [ ] `throw-challenge` | 유능한 직원이 지루해할 때 | 경쟁심을 자극한다
- [ ] `praise-then-ask` | 지적 전에 칭찬, 그다음이 중요하다 | 칭찬으로 시작한다
- [ ] `indirect-attention` | "그런데"라고 말하는 순간 칭찬은 사라진다 | 간접적으로 알린다

## 3부 · 인간관계론 — 리더십 (8편)
- [ ] `ask-dont-order` | 명령 대신 질문으로 지시하는 법 | 질문으로 지시한다
- [ ] `save-face` | 사람 앞에서 체면을 세워준다 | 체면을 살려준다
- [ ] `praise-improvement` | 작은 진전을 놓치지 않는 리더 | 작은 발전도 칭찬한다
- [ ] `give-reputation` | 기대를 말해주면 그렇게 되어간다 | 좋은 평판을 갖게 한다
- [ ] `easy-to-fix` | "이건 쉽게 고칠 수 있습니다" | 격려한다
- [ ] `make-them-happy` | 시키는 일을 기꺼이 하게 만드는 구조 | 기꺼이 협력하게 한다
- [ ] `succession-talk` | 2세 경영 승계, 대화가 막히는 지점 | 리더십 종합
- [ ] `first-90-days` | 새로 부임한 리더의 첫 90일 | 리더십 종합

## 4부 · 자기관리론 — 걱정과 스트레스 (12편)
- [ ] `live-today` | 오늘 하루에 집중하는 경영자 | 오늘에 충실하라
- [ ] `worst-case` | 최악을 받아들이면 결정이 빨라진다 | 최악을 받아들이고 개선하라
- [ ] `cost-of-worry` | 이 걱정에 얼마를 지불할 것인가 | 걱정의 값을 매겨라
- [ ] `get-facts` | 감정이 아니라 사실을 모은다 | 사실을 파악하라
- [ ] `decide-and-act` | 결정을 미루는 것이 가장 비싼 선택 | 결정하고 실행하라
- [ ] `busy-cure` | 바쁜 사람은 걱정할 틈이 없다 | 바쁘게 움직여라
- [ ] `ignore-trifles` | 사소한 일에 흔들리지 않기 | 사소한 일을 무시하라
- [ ] `law-of-averages` | 확률로 따져보면 대개 일어나지 않는다 | 평균의 법칙
- [ ] `accept-inevitable` | 바꿀 수 없는 것과 협력하기 | 불가피한 것을 받아들여라
- [ ] `stop-loss` | 손절 기준을 미리 정해둔다 | 손절매 주문을 걸어라
- [ ] `dont-saw-sawdust` | 지나간 실패를 되씹지 않기 | 톱밥을 다시 켜지 마라
- [ ] `fatigue-first` | 피로가 판단을 망친다 | 지치기 전에 쉬어라

## 5부 · 스피치론 — 말하기 (10편)
- [ ] `two-minute-speech` | 2분 발표가 리더를 바꾸는 이유 | 짧게 말하기
- [ ] `stage-fear` | 무대 공포는 없앨 수 없고 쓸 수 있다 | 긴장 다루기
- [ ] `earn-the-right` | 아는 것만 말한다 | 말할 자격을 갖춘다
- [ ] `open-strong` | 첫 문장에서 결정된다 | 도입부
- [ ] `one-message` | 한 번에 하나만 말한다 | 핵심 메시지
- [ ] `story-over-data` | 사례 하나가 통계 열 개를 이긴다 | 예시의 힘
- [ ] `close-with-action` | 발표는 요청으로 끝난다 | 마무리
- [ ] `impromptu` | 갑자기 한마디 하라고 할 때 | 즉석 연설
- [ ] `presentation-to-board` | 이사회 보고, 5분 안에 승인받기 | 설득 구조
- [ ] `bad-news` | 나쁜 소식을 전하는 순서 | 위기 커뮤니케이션

## 6부 · CEO가 실제로 검색하는 고민 (23편)
- [ ] `staff-only-told` | 직원이 시키는 것만 합니다
- [ ] `no-opinions` | 회의가 침묵으로 끝납니다
- [ ] `high-turnover` | 사람이 자꾸 나갑니다
- [ ] `founder-syndrome` | 제가 없으면 안 돌아갑니다
- [ ] `family-business` | 가족이 함께 일할 때 생기는 문제
- [ ] `old-new-conflict` | 오래된 직원과 새 직원이 부딪칩니다
- [ ] `delegation` | 맡기면 불안하고 안 맡기면 지칩니다
- [ ] `performance-review` | 평가 면담이 늘 어색합니다
- [ ] `salary-talk` | 연봉 협상에서 감정이 상합니다
- [ ] `firing-well` | 내보내야 할 때
- [ ] `remote-trust` | 재택근무, 믿음의 문제인가 구조의 문제인가
- [ ] `ceo-loneliness` | 대표는 왜 외로운가
- [ ] `burnout` | 번아웃이 온 대표에게
- [ ] `partner-conflict` | 동업자와 의견이 갈릴 때
- [ ] `customer-complaint` | 진상 고객을 다루는 법
- [ ] `vendor-negotiation` | 거래처와의 단가 협상
- [ ] `bank-loan-talk` | 은행·투자자 앞에서 말하기
- [ ] `second-gen` | 2세에게 회사를 넘길 준비
- [ ] `small-company-culture` | 20명 회사의 조직문화
- [ ] `first-executive` | 첫 임원을 뽑을 때
- [ ] `meeting-too-long` | 회의가 길어지는 진짜 이유
- [ ] `kpi-resistance` | 성과지표를 도입했더니 반발이 왔습니다
- [ ] `ai-and-people` | AI가 사람을 대체한다는 불안 앞에서

---

## 참고
- 출처 표기: 인간관계론·자기관리론·스피치론은 데일 카네기 저작. 원문을 길게 인용하지 말고 **원칙을 요약하고 우리 해석을 쓴다.**
- 각 글 하단 CTA 는 `new-post.ps1` 이 자동으로 붙인다. 본문에 따로 넣지 않는다.
- 본문에서 지역 페이지로 자연스럽게 링크할 수 있으면 건다 (예: `<a href="../suwon-ceo.html">수원 과정</a>`).
