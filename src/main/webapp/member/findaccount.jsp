<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>계정 찾기</title>
  <link rel="stylesheet" href="../css/accountStyle.css">
  <script src='../js/jquery-3.7.1.min.js'></script>
</head>
<body class="tr_findaccount">
<jsp:include page="/header.jsp" />
  <div class="tr_findContainer">
    <h2>혹시 아이디/비밀번호를 잊으셨나요?</h2>
    <!-- 아이디 찾기 -->
    <form action="process_findId.jsp" id="tr_formId">
      <div class="tr_findId">
        <p>아이디 찾기</p>
        <input type="text" name="email_findId" class="email_findId" placeholder="이메일을 입력하세요">
      </div>
      <button type="submit" id="tr_findIdBtn">아이디 찾기</button>
    </form>
    
    <!-- 비밀번호 찾기 -->
    <form action="process_findPw.jsp" id="tr_formPw">
      <div class="tr_findPw">
        <p>비밀번호 찾기</p>
        <input type="text" name="id_findPw" class="id_findPw" placeholder="아이디를 입력하세요">
        <input type="email" name="email_findPw" class="email_findPw" placeholder="이메일을 입력하세요">      
      </div>
      <button type="submit" id="tr_findPwBtn">비밀번호 찾기</button>
    </form>
  </div>
  <script src="../js/findaccount.js"></script>
</body>
</html>