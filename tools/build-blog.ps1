# 카네기 레터 목록(blog.html) · RSS(rss.xml) · 사이트맵(sitemap.xml) 을 다시 만든다.
#
# blog\*.html 을 훑어 <title> · <meta name="description"> · <meta name="post-date"> 를 읽는다.
# 글을 새로 올린 뒤 반드시 이 스크립트를 돌리고 같이 커밋한다.
#
# 실행:  powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-blog.ps1
# 주의:  이 파일은 UTF-8 BOM 으로 저장해야 한다 (PowerShell 5.1 은 .ps1 을 ANSI 로 읽는다)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$enc  = [System.Text.UTF8Encoding]::new($false)
$SITE = 'https://dailycarnegie.com'

function Read-Text($p) { [System.IO.File]::ReadAllText($p, [System.Text.UTF8Encoding]::new($true)) }
function Esc($s) { if ($null -eq $s) { return '' } ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;') }

$index  = Read-Text (Join-Path $root 'index.html')
$header = [regex]::Match($index, '<header class="site-header">.*?</header>', 'Singleline').Value
$footer = [regex]::Match($index, '<footer.*?</footer>', 'Singleline').Value
$CACHE  = [regex]::Match($index, 'style\.css\?v=([0-9]+)').Groups[1].Value

# --- 글 수집 -------------------------------------------------------------
$posts = @()
$dir = Join-Path $root 'blog'
if (Test-Path $dir) {
  foreach ($f in Get-ChildItem "$dir\*.html") {
    $h = Read-Text $f.FullName
    $t = [regex]::Match($h, '<title>(.*?)</title>', 'Singleline').Groups[1].Value
    $t = ($t -replace '\s*—\s*카네기 레터.*$','').Trim()
    $posts += [pscustomobject]@{
      Slug      = $f.BaseName
      Title     = $t
      Desc      = [regex]::Match($h, '<meta name="description" content="(.*?)"').Groups[1].Value
      Date      = [regex]::Match($h, '<meta name="post-date" content="(.*?)"').Groups[1].Value
      Principle = [regex]::Match($h, '<meta name="post-principle" content="(.*?)"').Groups[1].Value
    }
  }
}
$posts = $posts | Where-Object { $_.Date } | Sort-Object Date -Descending
"글 $($posts.Count) 편"

# --- 기존 글의 헤더·푸터·캐시버전 동기화 -----------------------------------
# 글 파일은 new-post.ps1 이 한 번 찍고 끝이라, 메뉴를 바꾸면 옛 글만 낡게 된다.
# 여기서 매번 다시 맞춰준다 (본문은 건드리지 않는다).
$hdrSub = ($header -replace 'href="', 'href="../') -replace 'href="\.\./(tel:|#|https?:)', 'href="$1'
$ftrSub = ($footer -replace 'href="', 'href="../') -replace 'href="\.\./(tel:|#|https?:)', 'href="$1'
$synced = 0
foreach ($f in Get-ChildItem "$dir\*.html") {
  $h = Read-Text $f.FullName
  $o = $h
  $h = [regex]::Replace($h, '<header class="site-header">.*?</header>', { $hdrSub }, 'Singleline')
  $h = [regex]::Replace($h, '<footer.*?</footer>', { $ftrSub }, 'Singleline')
  $h = [regex]::Replace($h, '(style\.css|main\.js)\?v=[0-9]+', "`$1?v=$CACHE")
  if ($h -ne $o) { [System.IO.File]::WriteAllText($f.FullName, $h, $enc); $synced++ }
}
"글 헤더·푸터·캐시 동기화: $synced 편"
# --- 목록 페이지 ---------------------------------------------------------
$cards = if ($posts.Count -eq 0) {
  '<p class="sched-note">첫 글을 준비하고 있습니다.</p>'
} else {
  ($posts | ForEach-Object {
    $d = ([datetime]::ParseExact($_.Date,'yyyy-MM-dd',$null)).ToString('yyyy. M. d')
    $p = if ($_.Principle) { '<span class="post-principle">' + (Esc $_.Principle) + '</span>' } else { '' }
    @"
          <article class="post-card reveal">
            <a href="blog/$($_.Slug).html">
              <p class="post-meta"><time datetime="$($_.Date)">$d</time>$p</p>
              <h3>$(Esc $_.Title)</h3>
              <p class="post-excerpt">$(Esc $_.Desc)</p>
              <span class="post-more">읽어보기 →</span>
            </a>
          </article>
"@
  }) -join "`n"
}

$blog = @"
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="icon" type="image/svg+xml" href="assets/images/favicon.svg" />
  <title>카네기 레터 | 매일 만나는 카네기 교육 — 데일리카네기</title>
  <meta name="description" content="데일카네기의 인간관계론·자기관리론·스피치론 원칙을 경영 현장에 적용하는 법. 리더가 매일 마주하는 상황을 한 편에 하나씩 다룹니다." />
  <meta property="og:type" content="website" />
  <meta property="og:site_name" content="데일리카네기" />
  <meta property="og:locale" content="ko_KR" />
  <meta property="og:url" content="$SITE/blog.html" />
  <meta property="og:title" content="카네기 레터 — 매일 만나는 카네기 교육" />
  <meta property="og:description" content="카네기의 원칙을 경영 현장에 적용하는 법. 한 편에 하나씩." />
  <meta property="og:image" content="$SITE/assets/images/og-image.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <link rel="canonical" href="$SITE/blog.html" />
  <link rel="alternate" type="application/rss+xml" title="카네기 레터" href="rss.xml" />
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
        <div class="breadcrumb"><a href="index.html">Home</a> &nbsp;/&nbsp; 카네기 레터</div>
        <h1>카네기 레터</h1>
        <p>데일카네기가 100년 전에 정리한 원칙은 지금도 회의실에서 그대로 작동합니다. 리더가 매일 마주하는 상황을 한 편에 하나씩 다룹니다.</p>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="post-grid">
$cards
        </div>
      </div>
    </section>
  </main>

$footer

  <script src="assets/js/main.js?v=$CACHE"></script>
</body>
</html>
"@
[System.IO.File]::WriteAllText((Join-Path $root 'blog.html'), $blog, $enc)
"blog.html 갱신"

# --- RSS -----------------------------------------------------------------
$items = ($posts | Select-Object -First 100 | ForEach-Object {
  $pub = ([datetime]::ParseExact($_.Date,'yyyy-MM-dd',$null)).ToString('ddd, dd MMM yyyy 09:00:00 +0900', [System.Globalization.CultureInfo]::InvariantCulture)
  @"
    <item>
      <title>$(Esc $_.Title)</title>
      <link>$SITE/blog/$($_.Slug).html</link>
      <guid isPermaLink="true">$SITE/blog/$($_.Slug).html</guid>
      <pubDate>$pub</pubDate>
      <description>$(Esc $_.Desc)</description>
    </item>
"@
}) -join "`n"

$rss = @"
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>카네기 레터 — 데일리카네기</title>
    <link>$SITE/blog.html</link>
    <description>데일카네기의 원칙을 경영 현장에 적용하는 법. 한 편에 하나씩.</description>
    <language>ko</language>
    <lastBuildDate>$([datetime]::Now.ToString('ddd, dd MMM yyyy HH:mm:ss +0900', [System.Globalization.CultureInfo]::InvariantCulture))</lastBuildDate>
$items
  </channel>
</rss>
"@
[System.IO.File]::WriteAllText((Join-Path $root 'rss.xml'), $rss, $enc)
"rss.xml 갱신"

# --- 사이트맵 -------------------------------------------------------------
# privacy.html 은 noindex 라 제외한다.
$today = [datetime]::Now.ToString('yyyy-MM-dd')
$urls = @()
$urls += [pscustomobject]@{ Loc="$SITE/";              Pri='1.0'; Date=$today }
foreach ($p in @('program','about','alumni','faq','apply','blog')) {
  $urls += [pscustomobject]@{ Loc="$SITE/$p.html";     Pri='0.9'; Date=$today }
}
foreach ($f in Get-ChildItem (Join-Path $root '*-ceo.html')) {
  $urls += [pscustomobject]@{ Loc="$SITE/$($f.Name)";  Pri='0.8'; Date=$today }
}
foreach ($p in $posts) {
  $urls += [pscustomobject]@{ Loc="$SITE/blog/$($p.Slug).html"; Pri='0.7'; Date=$p.Date }
}
$body = ($urls | ForEach-Object {
  "  <url><loc>$($_.Loc)</loc><lastmod>$($_.Date)</lastmod><priority>$($_.Pri)</priority></url>"
}) -join "`n"
$sm = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
$body
</urlset>
"@
[System.IO.File]::WriteAllText((Join-Path $root 'sitemap.xml'), $sm, $enc)
"sitemap.xml 갱신 — URL $($urls.Count)개"
