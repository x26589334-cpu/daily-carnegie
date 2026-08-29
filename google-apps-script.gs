/* =========================================================================
   데일리카네기 입학 상담 신청 → "웹 문의" 시트의 "데일리카네기" 탭 저장용 Apps Script
   -------------------------------------------------------------------------
   ★ 현재 상태: apply.html 의 폼은 과외(perfectedu)·픽포스와 같은 공용 웹앱 URL로 보냅니다.
     공용 스크립트가 sheet 파라미터로 탭을 고르지 않으면 "과외" 탭에 쌓이고,
     "구분" 컬럼이 "데일리카네기-입학상담" 으로 표시되어 구분됩니다.

   ▶ 데일리카네기 전용 탭으로 나누고 싶을 때 (기존 과외/픽포스 스크립트는 안 건드림)
   1) script.google.com 접속 → 왼쪽 위 [+ 새 프로젝트]
   2) 편집기의 기존 코드 전부 지우고, 아래 전체를 붙여넣기 → 저장(💾)
   3) [배포] → [새 배포] → 유형(톱니바퀴): 웹 앱
        - 설명: 데일리카네기
        - 실행 계정: 나
        - 액세스 권한: 모든 사용자
      → [배포] → 권한 승인 팝업 뜨면 [고급]→[안전하지 않음(이동)]→[허용]
   4) 나오는 "웹 앱 URL"(.../exec) 을 apply.html 의 <form data-sheet="..."> 에 교체 → push
   ========================================================================= */

var SHEET_ID   = "1UUS6le8gJTsuvaSDi31ZzuQjA214YD32xJFVgYx9cno"; // 웹 문의 시트 (과외·픽포스와 같은 파일)
var SHEET_NAME = "데일리카네기"; // 저장할 탭 (없으면 자동 생성)

// 폼이 보내는 필드: 성함, 연락처, 회사명, 직책, 이메일, 관심과정, 문의내용, 개인정보동의
// (+ 메타: sheet, _form, _page, _time — 헤더에는 안 들어감)
function doPost(e) {
  try {
    var ss = SpreadsheetApp.openById(SHEET_ID);
    var sh = ss.getSheetByName(SHEET_NAME) || ss.insertSheet(SHEET_NAME);
    var p  = (e && e.parameter) ? e.parameter : {};
    var when = p._time || new Date().toLocaleString("ko-KR");
    var kind = p._form || "";

    var headers;
    if (sh.getLastRow() === 0) {
      headers = ["접수시각", "구분"];
      for (var k in p) { if (k.charAt(0) === "_" || k === "sheet") continue; headers.push(k); }
      sh.appendRow(headers);
    } else {
      headers = sh.getRange(1, 1, 1, sh.getLastColumn()).getValues()[0];
      for (var k2 in p) {
        if (k2.charAt(0) === "_" || k2 === "sheet") continue;
        if (headers.indexOf(k2) === -1) { headers.push(k2); sh.getRange(1, headers.length).setValue(k2); }
      }
    }

    var row = [];
    for (var i = 0; i < headers.length; i++) {
      var h = headers[i];
      row.push(h === "접수시각" ? when : h === "구분" ? kind : (p[h] != null ? p[h] : ""));
    }
    sh.appendRow(row);
    return ContentService.createTextOutput("ok");
  } catch (err) {
    return ContentService.createTextOutput("error: " + err);
  }
}
