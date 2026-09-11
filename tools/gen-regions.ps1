# 지역별 최고경영자과정 페이지를 만든다.
#
# 원본 데이터는 apply.html 의 #class-table 표 하나뿐이다. 이 스크립트는 그 표를 읽어
# 지역 페이지를 다시 찍어낸다. 기수가 바뀌면 apply.html 표만 고치고 이 스크립트를 돌린다.
# 헤더·푸터도 index.html 에서 그대로 읽어오므로 메뉴를 바꿔도 따로 손댈 필요가 없다.
#
# 실행:  powershell -NoProfile -ExecutionPolicy Bypass -File tools\gen-regions.ps1
# 주의:  이 파일은 UTF-8 BOM 으로 저장해야 한다 (PowerShell 5.1 은 .ps1 을 ANSI 로 읽는다)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$enc  = [System.Text.UTF8Encoding]::new($false)

function Read-Text($p) { [System.IO.File]::ReadAllText($p, [System.Text.UTF8Encoding]::new($true)) }

$apply = Read-Text (Join-Path $root 'apply.html')
$index = Read-Text (Join-Path $root 'index.html')

# 캐시 버전은 index.html 에서 읽어 전 페이지와 맞춘다
$CACHE = [regex]::Match($index, 'style\.css\?v=([0-9]+)').Groups[1].Value

# 헤더·푸터는 홈에서 그대로 가져온다 (메뉴 변경이 자동 반영되도록)
$header = [regex]::Match($index, '<header class="site-header">.*?</header>', 'Singleline').Value
$footer = [regex]::Match($index, '<footer.*?</footer>', 'Singleline').Value
if (-not $header -or -not $footer) { throw 'index.html 에서 header/footer 를 찾지 못했습니다.' }

# 지역명 -> 파일 슬러그. 경기 광주(하남)와 전남 광주를 반드시 구분한다.
$slugs = @{
  '여수'='yeosu'; '포항'='pohang'; '화성 · 오산'='hwaseong-osan'; '대구'='daegu'
  '서울'='seoul'; '파주'='paju'; '용인'='yongin'; '고양'='goyang'
  '의정부 · 양주 · 포천'='uijeongbu'; '광주 · 하남'='gwangju-hanam'; '광명'='gwangmyeong'
  '수원'='suwon'; '시흥'='siheung'; '이천 · 여주 · 양평'='icheon'; '부산'='busan'
  '울산'='ulsan'; '대전'='daejeon'; '광주'='gwangju'; '진주'='jinju'
}
# 검색에 쓰이는 광역 표기 (제목·본문 보조어)
$wide = @{
  'hwaseong-osan'='경기 화성·오산'; 'uijeongbu'='경기 북부'; 'gwangju-hanam'='경기 광주·하남'
  'icheon'='경기 동부'; 'gwangju'='광주광역시'; 'yeosu'='전남 여수'; 'pohang'='경북 포항'
  'jinju'='경남 진주'; 'daejeon'='대전'; 'daegu'='대구'; 'busan'='부산'; 'ulsan'='울산'
}

function Esc($s) { if ($null -eq $s) { return '' } ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;') }
function Strip($s) { ($s -replace '<[^>]+>','').Trim() }

# --- 표 파싱 -------------------------------------------------------------
$rows = @()
foreach ($m in [regex]::Matches($apply, '<tr\s+data-area="(?<area>[^"]*)"(?<attrs>[^>]*)>(?<body>.*?)</tr>', 'Singleline')) {
  $attrs = $m.Groups['attrs'].Value
  $tds = [regex]::Matches($m.Groups['body'].Value, '<td[^>]*>(?<v>.*?)</td>', 'Singleline')
  if ($tds.Count -lt 5) { continue }

  $first = $tds[0].Groups['v'].Value
  $region = Strip([regex]::Match($first, '<b>(?<b>.*?)</b>').Groups['b'].Value)
  $gi = Strip(($first -replace '<b>.*?</b>',''))

  $placeRaw = $tds[3].Groups['v'].Value
  $addr = Strip([regex]::Match($placeRaw, '<span>(?<s>.*?)</span>').Groups['s'].Value)
  $place = Strip(($placeRaw -replace '<span>.*?</span>',''))

  $rows += [pscustomobject]@{
    Region  = $region
    Gi      = $gi
    Area    = $m.Groups['area'].Value
    Start   = [regex]::Match($attrs, 'data-start="([^"]*)"').Groups[1].Value
    End     = [regex]::Match($attrs, 'data-end="([^"]*)"').Groups[1].Value
    Poster  = [regex]::Match($attrs, 'data-poster="([^"]*)"').Groups[1].Value
    PosterAlt = [regex]::Match($attrs, 'data-poster-alt="([^"]*)"').Groups[1].Value
    Open    = Strip($tds[1].Groups['v'].Value)
    When    = Strip($tds[2].Groups['v'].Value)
    Place   = $place
    Addr    = $addr
    Fee     = Strip($tds[4].Groups['v'].Value)
    Slug    = $slugs[$region]
  }
}
"표에서 읽은 기수: $($rows.Count)개"
$missing = $rows | Where-Object { -not $_.Slug }
if ($missing) { throw "슬러그가 없는 지역: " + (($missing | ForEach-Object { $_.Region }) -join ', ') }

# --- 페이지 생성 ---------------------------------------------------------
$made = 0
foreach ($r in $rows) {
  $slug = $r.Slug
  $wideName = if ($wide.ContainsKey($slug)) { $wide[$slug] } else { $r.Region }
  $title = "$($r.Region) 최고경영자과정"
  $giLabel = if ($r.Gi) { $r.Gi } else { '' }

  # 같은 권역의 다른 기수 3개를 인근 지역으로 건다
  $near = $rows | Where-Object { $_.Slug -ne $slug -and $_.Area -eq $r.Area } | Select-Object -First 3
  $nearHtml = ''
  if ($near) {
    $items = ($near | ForEach-Object {
      '<li><a href="' + $_.Slug + '-ceo.html">' + (Esc $_.Region) + ' ' + (Esc $_.Gi) + '</a></li>'
    }) -join "`n            "
    $nearHtml = @"
    <section class="section section--soft">
      <div class="container">
        <div class="section-head reveal">
          <span class="eyebrow">Nearby</span>
          <h2>인근 지역 개강 과정</h2>
          <p>일정이 맞지 않으시면 가까운 지역의 기수도 확인해 보세요.</p>
        </div>
        <div class="reveal">
          <ul class="near-list">
            $items
          </ul>
        </div>
      </div>
    </section>
"@
  }

  $posterHtml = ''
  if ($r.Poster) {
    $posterHtml = @"
    <section class="section">
      <div class="container">
        <div class="section-head reveal">
          <span class="eyebrow">Poster</span>
          <h2>$(Esc $r.Region) $(Esc $giLabel) 모집 안내</h2>
        </div>
        <figure class="region-poster reveal">
          <img src="$(Esc $r.Poster)" alt="$(Esc $r.PosterAlt)" loading="lazy" decoding="async" />
        </figure>
      </div>
    </section>
"@
  }

  $addrLine = if ($r.Addr) { '<div class="s">' + (Esc $r.Addr) + '</div>' } else { '<div class="s">상세 장소는 상담 시 안내</div>' }
  $desc = "$($r.Region) 데일카네기 최고경영자과정 $giLabel 모집. $($r.Open) 개강, $($r.When), $($r.Place). 수강료 $($r.Fee). 주 1회 12주 CEO·임원 리더십 훈련."

  $html = @"
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="icon" type="image/svg+xml" href="assets/images/favicon.svg" />
  <title>$(Esc $title) | 데일카네기 CEO 코스 $(Esc $giLabel) 모집 — 데일리카네기</title>
  <meta name="description" content="$(Esc $desc)" />
  <meta name="keywords" content="$(Esc $r.Region) 최고경영자과정, $(Esc $r.Region) CEO 과정, $(Esc $wideName) 데일카네기, $(Esc $r.Region) 리더십 교육, 데일카네기 $(Esc $r.Region)" />
  <meta property="og:type" content="website" />
  <meta property="og:site_name" content="데일리카네기" />
  <meta property="og:locale" content="ko_KR" />
  <meta property="og:url" content="https://dailycarnegie.com/$slug-ceo.html" />
  <meta property="og:title" content="$(Esc $title) $(Esc $giLabel) 모집" />
  <meta property="og:description" content="$(Esc $r.Open) 개강 · $(Esc $r.When) · $(Esc $r.Place)" />
  <meta property="og:image" content="https://dailycarnegie.com/assets/images/og-image.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <link rel="canonical" href="https://dailycarnegie.com/$slug-ceo.html" />
  <link rel="preconnect" href="https://cdn.jsdelivr.net" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.css" />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@500;600;700&display=swap" />
  <link rel="stylesheet" href="assets/css/style.css?v=$CACHE" />
</head>
<body>

$header

  <main>
    <section class="page-hero">
      <div class="container">
        <div class="breadcrumb"><a href="index.html">Home</a> &nbsp;/&nbsp; <a href="apply.html">일정·신청</a> &nbsp;/&nbsp; $(Esc $r.Region)</div>
        <h1>$(Esc $title)</h1>
        <p>데일카네기 CEO 코스 $(Esc $giLabel)가 $(Esc $r.Open) $(Esc $r.Place)에서 개강합니다. 주 1회 12주, 실제로 행동이 바뀌는 리더십 훈련입니다.</p>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="section-head reveal">
          <span class="eyebrow">$(Esc $giLabel) 모집 요강</span>
          <h2>$(Esc $r.Region) 개강 정보</h2>
        </div>
        <div class="info-grid reveal">
          <div class="info-box"><div class="k">Open</div><div class="v">$(Esc $r.Open)</div><div class="s">개강일</div></div>
          <div class="info-box"><div class="k">Schedule</div><div class="v">$(Esc $r.When)</div><div class="s">주 1회 · 12주 과정</div></div>
          <div class="info-box"><div class="k">Venue</div><div class="v">$(Esc $r.Place)</div>$addrLine</div>
          <div class="info-box"><div class="k">Tuition</div><div class="v">$(Esc $r.Fee)</div><div class="s">교재 · 석식 · 워크숍 포함</div></div>
        </div>
        <p class="sched-note reveal">정원 초과 시 사전 마감되며, 접수는 교육 시작일 일주일 전까지입니다. 전국 개강 일정은 <a href="apply.html">일정·신청</a> 페이지에서 한눈에 보실 수 있습니다.</p>
      </div>
    </section>

$posterHtml

    <section class="section section--soft">
      <div class="container">
        <div class="section-head reveal">
          <span class="eyebrow">Curriculum</span>
          <h2>12주 동안 무엇을 하나요</h2>
          <p>강의가 아니라 훈련입니다. 매주 한 가지 원칙을 배우고 그 주에 현업에서 직접 적용합니다.</p>
        </div>
        <div class="process">
          <div class="step reveal"><span class="n">1~3주</span><h3>비전과 자신감</h3><p>성공의 기초, 비전 설정, 용기와 자신감 개발</p></div>
          <div class="step reveal"><span class="n">4~6주</span><h3>설득과 전달</h3><p>열정 공약, 설득력 개발, 명확한 의사전달</p></div>
          <div class="step reveal"><span class="n">7~9주</span><h3>관계와 동기부여</h3><p>우호적 인간관계, 칭찬을 통한 동기부여, 협력 창출</p></div>
          <div class="step reveal"><span class="n">10~12주</span><h3>리더십 완성</h3><p>건설적 의견 제시, 리더십 개발, 비전 재설정</p></div>
        </div>
        <div class="hero-actions reveal" style="margin-top:32px">
          <a href="program.html" class="btn btn--primary">주차별 커리큘럼 보기</a>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="section-head reveal">
          <span class="eyebrow">FAQ</span>
          <h2>$(Esc $r.Region) 과정 자주 묻는 질문</h2>
        </div>
        <div class="faq-group reveal">
          <div class="faq-item"><button class="faq-q" type="button">$(Esc $r.Region) 외 지역에서도 수강할 수 있나요?</button><div class="faq-a"><p>가능합니다. 거주지와 무관하게 일정이 맞는 지역으로 등록하실 수 있습니다. 실제로 인근 시·군에서 오시는 분들이 많습니다. 다만 12주 동안 매주 참석하셔야 하므로 이동 시간을 고려해 선택하시는 편이 좋습니다.</p></div></div>
          <div class="faq-item"><button class="faq-q" type="button">교육 장소가 어디인가요?</button><div class="faq-a"><p>$(Esc $r.Place)$(if ($r.Addr) { ' (' + (Esc $r.Addr) + ')' })에서 진행합니다. 주차 안내를 포함한 상세 내용은 등록 후 개별 안내드립니다.</p></div></div>
          <div class="faq-item"><button class="faq-q" type="button">한 번 빠지면 어떻게 되나요?</button><div class="faq-a"><p>부득이하게 결석하신 회차는 다른 지역 기수에서 보강하실 수 있습니다. 전국에서 동일한 커리큘럼으로 운영되기 때문입니다. 보강 일정은 담당자가 안내해 드립니다.</p></div></div>
          <div class="faq-item"><button class="faq-q" type="button">수료증은 어떤 것인가요?</button><div class="faq-a"><p>미국 데일카네기 본사가 발급하는 수료증으로, 전 세계에서 동일하게 인정됩니다. 수료 후에는 카네기클럽 동문 네트워크에 참여하실 수 있습니다.</p></div></div>
        </div>
      </div>
    </section>

$nearHtml

    <section class="section section--dark" id="apply-form">
      <div class="container">
        <div class="section-head reveal">
          <span class="eyebrow">Admission Inquiry</span>
          <h2>$(Esc $r.Region) $(Esc $giLabel) 입학 상담</h2>
          <p>연락처를 남겨주시면 담당자가 과정 안내서와 함께 영업일 기준 1일 이내 연락드립니다.</p>
        </div>
        <div class="reveal" style="max-width:720px;margin:0 auto">
          <form class="form-card" data-sheet="https://script.google.com/macros/s/AKfycbznAb0ZOODlNp-ckR5fvkqtVQijwuJ9Gl0G4KxDrfp-K7zM4fcfMMp5qDhAbwNkvYQG/exec" autocomplete="on">
            <input type="hidden" name="sheet" value="데일리카네기" />
            <input type="hidden" name="_form" value="데일리카네기-입학상담" />
            <input type="hidden" name="관심과정" value="$(Esc $r.Region) $(Esc $giLabel) ($(Esc $r.Open) 개강)" />
            <div class="form-grid2">
              <div class="form-row"><label for="f-name">성함<span class="req">*</span></label><input id="f-name" name="성함" type="text" required placeholder="홍길동" /></div>
              <div class="form-row"><label for="f-phone">연락처<span class="req">*</span></label><input id="f-phone" name="연락처" type="tel" required placeholder="010-0000-0000" /></div>
            </div>
            <div class="form-grid2">
              <div class="form-row"><label for="f-company">회사명<span class="req">*</span></label><input id="f-company" name="회사명" type="text" required placeholder="○○주식회사" /></div>
              <div class="form-row"><label for="f-title">직책</label><input id="f-title" name="직책" type="text" placeholder="대표이사 / 부사장 / 원장" /></div>
            </div>
            <div class="form-row"><label for="f-email">이메일</label><input id="f-email" name="이메일" type="email" placeholder="name@company.com" /></div>
            <div class="form-row"><label for="f-memo">문의 내용</label><textarea id="f-memo" name="문의내용" rows="4" placeholder="궁금하신 점이나 원하시는 상담 시간을 적어주세요."></textarea></div>
            <label class="form-agree"><input type="checkbox" name="개인정보동의" value="동의" required /><span>상담 안내를 위한 <a href="privacy.html" target="_blank" rel="noopener">개인정보 수집·이용</a>에 동의합니다. (수집 항목: 성함·연락처·회사명·직책·이메일 / 보유 기간: 상담 완료 후 1년)</span></label>
            <button type="submit" class="btn btn--primary btn--lg" style="width:100%">입학 상담 신청하기</button>
            <div class="form-result" role="status" aria-live="polite"></div>
          </form>
        </div>
      </div>
    </section>
  </main>

$footer

  <script src="assets/js/main.js?v=$CACHE"></script>
</body>
</html>
"@

  $path = Join-Path $root "$slug-ceo.html"
  [System.IO.File]::WriteAllText($path, $html, $enc)
  $made++
}
"생성한 지역 페이지: $made 개"
