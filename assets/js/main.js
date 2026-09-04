/* =========================================================
   데일카네기 최고경영자 과정 — shared interactions
   ========================================================= */
(function () {
  "use strict";

  /* ---- Mobile nav toggle ---- */
  var toggle = document.querySelector(".nav-toggle");
  var body = document.body;
  if (toggle) {
    toggle.addEventListener("click", function () {
      body.classList.toggle("nav-open");
      var open = body.classList.contains("nav-open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
    document.querySelectorAll(".main-nav a").forEach(function (a) {
      a.addEventListener("click", function () { body.classList.remove("nav-open"); });
    });
  }

  /* ---- 현재 페이지 메뉴 active 표시 ---- */
  var here = location.pathname.split("/").pop() || "index.html";
  document.querySelectorAll(".main-nav a").forEach(function (a) {
    var href = a.getAttribute("href");
    if (href === here) a.classList.add("active");
  });

  /* ---- FAQ accordion ---- */
  document.querySelectorAll(".faq-item").forEach(function (item) {
    var q = item.querySelector(".faq-q");
    var a = item.querySelector(".faq-a");
    if (!q || !a) return;
    q.addEventListener("click", function () {
      var isOpen = item.classList.contains("open");
      var group = item.closest(".faq");
      if (group) {
        group.querySelectorAll(".faq-item.open").forEach(function (other) {
          if (other !== item) {
            other.classList.remove("open");
            var oa = other.querySelector(".faq-a");
            if (oa) oa.style.maxHeight = null;
          }
        });
      }
      if (isOpen) {
        item.classList.remove("open");
        a.style.maxHeight = null;
      } else {
        item.classList.add("open");
        a.style.maxHeight = a.scrollHeight + "px";
      }
    });
  });

  /* ---- Scroll reveal ---- */
  var reveals = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window && reveals.length) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) {
          e.target.classList.add("in");
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.12 });
    reveals.forEach(function (el) { io.observe(el); });
  } else {
    reveals.forEach(function (el) { el.classList.add("in"); });
  }

  /* ---- 숫자 카운트업 ([data-count] 요소, 화면에 보일 때 실행) ---- */
  var counters = document.querySelectorAll("[data-count]");
  if (counters.length) {
    var reduce = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var fmt = function (n) { return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ","); };
    var runCounter = function (el) {
      var target = parseInt(el.getAttribute("data-count"), 10) || 0;
      var suffix = el.getAttribute("data-suffix") || "";
      if (reduce) { el.textContent = fmt(target) + suffix; return; }
      var dur = 1400, t0 = null;
      function step(ts) {
        if (t0 === null) t0 = ts;
        var p = Math.min((ts - t0) / dur, 1);
        var eased = 1 - Math.pow(1 - p, 3);
        el.textContent = fmt(Math.round(target * eased)) + suffix;
        if (p < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
    };
    if ("IntersectionObserver" in window) {
      var cio = new IntersectionObserver(function (entries) {
        entries.forEach(function (e) { if (e.isIntersecting) { runCounter(e.target); cio.unobserve(e.target); } });
      }, { threshold: 0.4 });
      counters.forEach(function (el) { cio.observe(el); });
    } else {
      counters.forEach(runCounter);
    }
  }

  /* ---- Google Sheet 연동 폼 (Apps Script 웹앱으로 전송) ---- */
  document.querySelectorAll("form[data-sheet]").forEach(function (form) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      var endpoint = form.getAttribute("data-sheet");
      var msg = form.querySelector(".form-result");
      var btn = form.querySelector('button[type="submit"]');

      function show(text, color) {
        if (!msg) return;
        msg.textContent = text;
        msg.style.color = color || "var(--color-primary)";
        msg.style.display = "block";
      }

      var agree = form.querySelector('input[name="개인정보동의"]');
      if (agree && !agree.checked) {
        show("개인정보 수집·이용에 동의해 주세요.", "#b42318");
        return;
      }

      // 아직 시트 URL이 연결되지 않은 경우(데모)
      if (!endpoint) {
        show("✅ (데모) 구글 시트 연동 전입니다. 연동 후 실제로 저장됩니다.");
        form.reset();
        return;
      }

      // 공용 Apps Script("웹 문의" 시트)가 쓰는 메타 필드: sheet/_form은 hidden input, _page/_time은 여기서 추가
      var data = new URLSearchParams(new FormData(form));
      data.set("_page", location.pathname);
      data.set("_time", new Date().toLocaleString("ko-KR"));
      var orig = btn ? btn.textContent : "";
      if (btn) { btn.disabled = true; btn.textContent = "전송 중..."; }

      // Apps Script 웹앱은 CORS 응답을 주지 않으므로 no-cors로 전송
      fetch(endpoint, { method: "POST", mode: "no-cors", body: data })
        .then(function () {
          show("✅ 상담 신청이 접수되었습니다. 담당자가 영업일 기준 1일 이내 연락드리겠습니다.");
          form.reset();
        })
        .catch(function () {
          show("⚠️ 전송에 실패했습니다. 잠시 후 다시 시도하거나 010-6832-1994로 연락 주세요.", "#b42318");
        })
        .then(function () {
          if (btn) { btn.disabled = false; btn.textContent = orig; }
        });
    });
  });

  /* ---- Footer year ---- */
  document.querySelectorAll("[data-year]").forEach(function (el) { el.textContent = new Date().getFullYear(); });
})();

/* ---- 모바일 가로 카테고리 바 (햄버거 대체, 전 페이지 공통) ---- */
(function () {
  if (document.querySelector(".mobile-cat-bar")) return;
  var header = document.querySelector(".site-header");
  var links = document.querySelectorAll(".main-nav ul li a");
  if (!header || !links.length) return;
  var bar = document.createElement("nav");
  bar.className = "mobile-cat-bar";
  bar.setAttribute("aria-label", "카테고리");
  var ul = document.createElement("ul");
  links.forEach(function (a) {
    var li = document.createElement("li");
    var na = document.createElement("a");
    na.href = a.getAttribute("href");
    na.textContent = a.textContent.trim();
    if (a.classList.contains("active")) na.classList.add("active");
    li.appendChild(na);
    ul.appendChild(li);
  });
  bar.appendChild(ul);
  header.insertAdjacentElement("afterend", bar);
  var act = bar.querySelector("a.active");
  if (act && act.scrollIntoView) { try { act.scrollIntoView({ inline: "center", block: "nearest" }); } catch (e) {} }
})();

/* ---- 전화 상담 플로팅 버튼 (전 페이지 공통) ---- */
(function () {
  if (document.querySelector(".call-float")) return;
  var a = document.createElement("a");
  a.className = "call-float";
  a.href = "tel:01068321994";
  a.setAttribute("aria-label", "전화 상담 010-6832-1994");
  a.innerHTML = '<span class="call-float-ic" aria-hidden="true">☎</span><span class="call-float-tx">입학 상담</span>';
  document.body.appendChild(a);
})();

/* ---- 개강 일정표: 상태 뱃지 자동 계산 + 지역 필터 (apply.html) ----
   표의 각 행에 있는 data-start / data-end 만 보고 오늘 날짜 기준으로 상태를 정합니다.
   기수를 갱신할 때는 표의 날짜만 고치면 되고 상태는 손대지 않습니다. */
(function () {
  var table = document.getElementById("class-table");
  if (!table) return;

  var DAY = 86400000;
  var today = new Date(); today.setHours(0, 0, 0, 0);
  var rows = Array.prototype.slice.call(table.querySelectorAll("tbody tr"));

  function toDate(s) {
    if (!s) return null;
    var p = s.split("-");
    var d = new Date(+p[0], +p[1] - 1, +p[2]);
    return isNaN(d.getTime()) ? null : d;
  }

  rows.forEach(function (tr) {
    var tag = tr.querySelector(".tag");
    if (!tag) return;
    var start = toDate(tr.getAttribute("data-start"));
    var end = toDate(tr.getAttribute("data-end"));
    var state, cls, text;

    if (!start) {
      state = "ask"; cls = "tag--ask"; text = "일정 문의";
    } else {
      var left = Math.round((start - today) / DAY);
      if (left > 7) { state = "open"; cls = "tag--open"; text = "모집 중"; }
      else if (left > 0) { state = "urgent"; cls = "tag--urgent"; text = "마감 임박 D-" + left; }
      else if (left === 0) { state = "urgent"; cls = "tag--urgent"; text = "오늘 개강"; }
      else if (end && end >= today) { state = "live"; cls = "tag--live"; text = "진행 중"; }
      else { state = "done"; cls = "tag--live"; text = "종료"; }
    }
    tag.className = "tag " + cls;
    tag.textContent = text;
    tr.setAttribute("data-state", state);
  });

  /* 모집 중 → 문의 → 진행 중 순으로 내려보냅니다 (같은 그룹 안에서는 원래 개강일 순 유지) */
  var weight = { urgent: 0, open: 0, ask: 1, live: 2, done: 3 };
  var tbody = table.querySelector("tbody");
  rows.map(function (tr, i) { return { tr: tr, i: i, w: weight[tr.getAttribute("data-state")] || 0 }; })
    .sort(function (a, b) { return a.w - b.w || a.i - b.i; })
    .forEach(function (o) { tbody.appendChild(o.tr); });

  /* 지역 필터 — 종료된 기수는 어떤 필터에서도 보이지 않습니다 */
  var buttons = document.querySelectorAll(".sf-btn");
  var empty = document.querySelector(".sched-empty");

  function applyFilter(area) {
    var shown = 0;
    rows.forEach(function (tr) {
      var visible = tr.getAttribute("data-state") !== "done" &&
                    (area === "all" || tr.getAttribute("data-area") === area);
      tr.style.display = visible ? "" : "none";
      if (visible) shown++;
    });
    if (empty) empty.hidden = shown > 0;
  }

  buttons.forEach(function (btn) {
    btn.addEventListener("click", function () {
      buttons.forEach(function (b) { b.classList.remove("is-on"); });
      btn.classList.add("is-on");
      applyFilter(btn.getAttribute("data-filter"));
    });
  });

  applyFilter("all");
})();

/* ---- 홈 히어로 기수 카드: apply.html 일정표에서 가장 임박한 기수를 읽어 채웁니다 ----
   데이터를 두 곳에 적지 않기 위한 장치입니다. fetch 가 실패하면 HTML 에 적힌
   기본 내용이 그대로 남으므로(점진적 향상) 검색엔진·JS 미사용 환경에도 안전합니다. */
(function () {
  var card = document.querySelector(".class-card[data-auto-next]");
  if (!card || !window.fetch || !window.DOMParser) return;

  function slot(n) { return card.querySelector('[data-slot="' + n + '"]'); }
  function fmt(d) { return d.getFullYear() + ". " + (d.getMonth() + 1) + ". " + d.getDate(); }

  fetch("apply.html", { credentials: "same-origin" })
    .then(function (r) { return r.ok ? r.text() : Promise.reject(new Error("no")); })
    .then(function (html) {
      var doc = new DOMParser().parseFromString(html, "text/html");
      var today = new Date(); today.setHours(0, 0, 0, 0);
      var best = null, bestDate = null;

      Array.prototype.forEach.call(
        doc.querySelectorAll("#class-table tbody tr[data-start]"),
        function (tr) {
          var p = tr.getAttribute("data-start").split("-");
          var d = new Date(+p[0], +p[1] - 1, +p[2]);
          if (d >= today && (bestDate === null || d < bestDate)) { bestDate = d; best = tr; }
        }
      );
      if (!best) return;

      var td = best.querySelectorAll("td");
      var endAttr = best.getAttribute("data-end");
      var end = endAttr ? new Date(+endAttr.split("-")[0], +endAttr.split("-")[1] - 1, +endAttr.split("-")[2]) : null;
      var left = Math.round((bestDate - today) / 86400000);

      var name = slot("name");
      if (name) name.innerHTML = "최고경영자 과정<br />" + td[0].textContent.trim();

      var period = slot("period");
      if (period) {
        period.innerHTML = fmt(bestDate) + (end ? " ~ " + (end.getMonth() + 1) + ". " + end.getDate() : "") +
          "<span>주 1회 · 12주 과정</span>";
      }

      var time = slot("time");
      if (time) time.textContent = td[2].textContent.trim();

      var place = slot("place");
      if (place) place.innerHTML = td[3].innerHTML;

      var badge = slot("badge");
      if (badge) badge.textContent = left > 7 ? "모집 중" : (left > 0 ? "마감 임박 D-" + left : "오늘 개강");
    })
    .catch(function () { /* 기본 표시 유지 */ });
})();
