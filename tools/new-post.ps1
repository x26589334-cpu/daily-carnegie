# 카네기 레터 글 한 편을 만든다.
#
# 본문만 HTML 조각으로 써서 넘기면 헤더·푸터·메타태그를 붙여 blog\{슬러그}.html 로 저장한다.
# 헤더·푸터는 index.html 에서 읽으므로 메뉴가 바뀌어도 따로 손댈 필요가 없다.
#
# 실행 예:
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\new-post.ps1 `
#     -Slug blame-nothing -Title "실적이 부진한 팀장에게 어떻게 말할 것인가" `
#     -Date 2026-09-12 -Desc "비난은 방어를 부릅니다..." -BodyFile draft.html -Principle "인간관계론 원칙 1"
#
# 주의: 이 파일은 UTF-8 BOM 으로 저장해야 한다 (PowerShell 5.1 은 .ps1 을 ANSI 로 읽는다)

param(
  [Parameter(Mandatory=$true)][string]$Slug,
  [Parameter(Mandatory=$true)][string]$Title,
  [Parameter(Mandatory=$true)][string]$Date,      # YYYY-MM-DD
  [Parameter(Mandatory=$true)][string]$Desc,
  [Parameter(Mandatory=$true)][string]$BodyFile,  # 본문 HTML 조각
  [string]$Principle = ''                          # 예: 인간관계론 원칙 1
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$enc  = [System.Text.UTF8Encoding]::new($false)
function Read-Text($p) { [System.IO.File]::ReadAllText($p, [System.Text.UTF8Encoding]::new($true)) }
function Esc($s) { ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;') }

$index  = Read-Text (Join-Path $root 'index.html')
$header = [regex]::Match($index, '<header class="site-header">.*?</header>', 'Singleline').Value
$footer = [regex]::Match($index, '<footer.*?</footer>', 'Singleline').Value
$CACHE  = [regex]::Match($index, 'style\.css\?v=([0-9]+)').Groups[1].Value
if (-not $header -or -not $footer) { throw 'index.html 에서 header/footer 를 찾지 못했습니다.' }

$body = Read-Text (Resolve-Path $BodyFile)
$dateKr = ([datetime]::ParseExact($Date, 'yyyy-MM-dd', $null)).ToString('yyyy년 M월 d일')
$badge = if ($Principle) { '<span class="post-principle">' + (Esc $Principle) + '</span>' } else { '' }

New-Item -ItemType Directory -Force -Path (Join-Path $root 'blog') | Out-Null

$html = @"
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="icon" type="image/svg+xml" href="../assets/images/favicon.svg" />
  <title>$(Esc $Title) — 카네기 레터 | 데일리카네기</title>
  <meta name="description" content="$(Esc $Desc)" />
  <meta name="post-date" content="$Date" />
  <meta name="post-principle" content="$(Esc $Principle)" />
  <meta property="og:type" content="article" />
  <meta property="og:site_name" content="데일리카네기" />
  <meta property="og:locale" content="ko_KR" />
  <meta property="og:url" content="https://dailycarnegie.com/blog/$Slug.html" />
  <meta property="og:title" content="$(Esc $Title)" />
  <meta property="og:description" content="$(Esc $Desc)" />
  <meta property="og:image" content="https://dailycarnegie.com/assets/images/og-image.png" />
  <meta property="article:published_time" content="$Date" />
  <meta name="twitter:card" content="summary_large_image" />
  <link rel="canonical" href="https://dailycarnegie.com/blog/$Slug.html" />
  <link rel="alternate" type="application/rss+xml" title="카네기 레터" href="../rss.xml" />
  <link rel="preconnect" href="https://cdn.jsdelivr.net" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.css" />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@500;600;700&display=swap" />
  <link rel="stylesheet" href="../assets/css/style.css?v=$CACHE" />
  <script type="application/ld+json">
  {"@context":"https://schema.org","@type":"BlogPosting","headline":"$(Esc $Title)","datePublished":"$Date","description":"$(Esc $Desc)","author":{"@type":"Organization","name":"데일리카네기"},"publisher":{"@type":"Organization","name":"데일리카네기"},"mainEntityOfPage":"https://dailycarnegie.com/blog/$Slug.html"}
  </script>
</head>
<body>

$($header -replace 'href="', 'href="../' -replace 'href="\.\./(tel:|#|https?:)', 'href="$1' -replace 'href="\.\./\.\./', 'href="../')

  <main>
    <article class="post">
      <div class="container container--narrow">
        <div class="breadcrumb"><a href="../index.html">Home</a> &nbsp;/&nbsp; <a href="../blog.html">카네기 레터</a></div>
        <h1>$(Esc $Title)</h1>
        <p class="post-meta"><time datetime="$Date">$dateKr</time>$badge</p>
      </div>
      <div class="container container--narrow post-body">
$body
      </div>
      <div class="container container--narrow">
        <aside class="post-cta">
          <div>
            <b>매주 한 가지 원칙, 12주 후 달라진 리더</b>
            <p>글로 읽는 것과 훈련으로 몸에 붙이는 것은 다릅니다. 데일카네기 최고경영자 과정은 전국에서 주 1회 12주로 진행됩니다.</p>
          </div>
          <a href="../apply.html" class="btn btn--gold">개강 일정 보기</a>
        </aside>
      </div>
    </article>
  </main>

$($footer -replace 'href="', 'href="../' -replace 'href="\.\./(tel:|#|https?:)', 'href="$1')

  <script src="../assets/js/main.js?v=$CACHE"></script>
</body>
</html>
"@

$out = Join-Path $root "blog\$Slug.html"
[System.IO.File]::WriteAllText($out, $html, $enc)
"작성: blog\$Slug.html  ($Date · $Title)"
