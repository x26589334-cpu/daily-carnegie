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

      var agree = form.querySelector('input[name="agree"]');
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

      var data = new URLSearchParams(new FormData(form));
      var orig = btn ? btn.textContent : "";
      if (btn) { btn.disabled = true; btn.textContent = "전송 중..."; }

      // Apps Script 웹앱은 CORS 응답을 주지 않으므로 no-cors로 전송
      fetch(endpoint, { method: "POST", mode: "no-cors", body: data })
        .then(function () {
          show("✅ 상담 신청이 접수되었습니다. 담당자가 영업일 기준 1일 이내 연락드리겠습니다.");
          form.reset();
        })
        .catch(function () {
          show("⚠️ 전송에 실패했습니다. 잠시 후 다시 시도하거나 02-556-0113으로 연락 주세요.", "#b42318");
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
  a.href = "tel:025560113";
  a.setAttribute("aria-label", "전화 상담 02-556-0113");
  a.innerHTML = '<span class="call-float-ic" aria-hidden="true">☎</span><span class="call-float-tx">입학 상담</span>';
  document.body.appendChild(a);
})();
