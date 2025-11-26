<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>비밀번호 재설정</title>
  <script src="../js/jquery-3.7.1.min.js"></script>
  <link rel="stylesheet" href="../css/accountStyle.css">
</head>
<body class="tr_resetPw">
<jsp:include page="/header.jsp" />
<div class="tr_resetMainContainer">
  <div class="tr_resetContainer">
    <h2>비밀번호 재설정</h2>
    <form action="process_resetPw.jsp" id="tr_resetForm">
    <input type="hidden" name="id" value="<%= request.getParameter("id") %>">
      <div class="tr_resetPwInput">
        <input type="password" name="tr_newPw" id="tr_newPw" class="trInput" placeholder="새 비밀번호(영대소문자, 숫자 및 특수문자 포함 7~20자)">
        <p id="tr_resultNewPw"></p> <!-- 새 비밀번호 유효성검사 -->
      </div>
      <div class="tr_resetPwVerInput">
        <input type="password" id="tr_newPwVer" class="trInput" placeholder="새 비밀번호 확인">
        <p id="tr_resultNewPwVer"></p> <!-- 새 비밀번호 확인 유효성검사 -->
      </div>
      <button type="submit" id="tr_resetPwBtn">비밀번호 재설정</button>
    </form>
  </div>
  </div>
  <script src="../js/findaccount.js"></script>
</body>
</html>