<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>
<%@ include file="dbconn.jsp" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원정보 수정</title>
    <link rel="stylesheet" href="../css/accountStyle.css">
    <script src='../js/jquery-3.7.1.min.js'></script>
</head>
<body class="tr_updateMem">
	<jsp:include page="/header.jsp" />
	<div class="tr_updateMainContainer">
  <div class="tr_updateContainer">
  <%
	request.setCharacterEncoding("UTF-8");
	String mem_id=(String) session.getAttribute("sessionId");
	

	TravelSelectMemDAO dao = new TravelSelectMemDAO();
	TravelMemberDTO dto= dao.selectMem(conn, mem_id);
 if(dto == null){
%>
	<script>
    alert("회원 정보를 찾을 수 없습니다.");
    location.href="../firstPage.jsp";
	</script>
 <% 
 	return; 
 	} 
	 request.setAttribute("mem", dto);%>
    <h1>회원정보 수정</h1>
    <!-- 회원 탈퇴 부분(js에서 confirm 추가로 링크 삭제) -->
    <a href="#" id="deleteMemBtn">회원 탈퇴</a>
    <form action="process_update.jsp" method="post" id="updateForm">
      <div class="tr_pwUpdate">
        <input type="password" id="tr_newPw" name="tr_newPw" class="tr_newPw" placeholder="비밀번호 입력(비밀 번호를 변경할 경우 새 비밀번호 입력)">
        <p id="resultNewPw"></p> <!-- 새 pw 유효성검사 -->
      </div>
      <div class="tr_pwUpdateVer">
        <input type="password" id="tr_newPwVer" name="tr_newPwVer" class="tr_newPwVer" placeholder="비밀번호 확인(비밀번호를 유지하려면 새 비밀번호 입력)">
        <p id="resultNewPwVer"></p> <!-- 새 pw 일치여부 확인 -->
      </div>
      <div class="tr_emailUpdate">
        <input type="email" id="tr_newEmail" name="tr_newEmail" class="tr_newEmail" value="${mem.memEmail}" placeholder="새 이메일 입력">
        <p id="resultNewEmail"></p> <!-- 새 email 유효성검사 -->
      </div>
      <div class="tr_phoneUpdate">
        <input type="text" id="tr_newPhone" name="tr_newPhone" class="tr_newPhone" value="${mem.memPhone}" placeholder="휴대폰 번호('-'제외 숫자만 입력)">
        <p id="resultNewPhone"></p> <!-- phone 유효성검사 -->
      </div>
      <button type="submit" id="updateBtn"> 회원 정보 수정</button>
    </form>
 
  </div>
  </div>
  <script src="../js/updateMem.js"></script>
</body>
</html>