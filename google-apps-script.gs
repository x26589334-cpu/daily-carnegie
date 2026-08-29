/**
 * 데일카네기 최고경영자 과정 — 입학 상담 신청 폼 → 구글 시트 저장
 *
 * ★ 이 버전은 "신청정보" 스프레드시트의 [데일카네기] 탭에 저장합니다.
 *   (와와·국제학교 신청과 같은 스프레드시트에 함께 모으는 방식)
 *
 * [연결 방법 — 5분]
 * 1) "신청정보" 스프레드시트를 브라우저에서 연다.
 * 2) 주소창 URL에서 스프레드시트 ID를 복사한다.
 *    예) https://docs.google.com/spreadsheets/d/[이 부분이 ID]/edit
 * 3) 아래 SHEET_ID = "..." 의 따옴표 안에 그 ID를 붙여넣는다.
 * 4) script.google.com → 새 프로젝트 → 이 파일 내용을 붙여넣고 저장.
 * 5) [배포] → [새 배포] → 유형: 웹 앱 / 실행: 나 / 액세스: 모든 사용자 → [배포]
 * 6) 발급된 웹 앱 URL을 apply.html 의 <form data-sheet=""> 따옴표 안에 넣고 push.
 * 7) 권한 승인이 뜨면 "신청정보" 시트를 소유한 그 구글 계정으로 허용.
 */

// ▼▼▼ "신청정보" 스프레드시트 ID를 붙여넣으세요 ▼▼▼
var SHEET_ID = "";
// ▲▲▲                                            ▲▲▲

var TAB_NAME = "데일카네기"; // 저장할 탭 이름

// 시트 첫 줄(헤더)을 자동으로 만들어 줌
var HEADERS = ["접수일시", "성함", "연락처", "회사명", "직책", "이메일", "관심 과정", "문의 내용", "개인정보동의"];

function doPost(e) {
  try {
    var ss = SpreadsheetApp.openById(SHEET_ID);
    var sheet = ss.getSheetByName(TAB_NAME) || ss.insertSheet(TAB_NAME);

    if (sheet.getLastRow() === 0) {
      sheet.appendRow(HEADERS);
    }

    var p = (e && e.parameter) ? e.parameter : {};
    sheet.appendRow([
      new Date(),
      p.name || "",
      p.phone || "",
      p.company || "",
      p.title || "",
      p.email || "",
      p.course || "",
      p.memo || "",
      p.agree || ""
    ]);

    return ContentService
      .createTextOutput(JSON.stringify({ result: "success" }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService
      .createTextOutput(JSON.stringify({ result: "error", message: String(err) }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// 브라우저에서 URL 직접 열었을 때 동작 확인용
function doGet() {
  return ContentService.createTextOutput("데일카네기 입학 상담 폼 수신 서버가 정상 작동 중입니다. (신청정보 → 데일카네기 탭)");
}
