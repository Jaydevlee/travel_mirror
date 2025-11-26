<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="admin.Hyphen" %>
<%@ include file="../dbconn.jsp"%>
<html>
<head>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="../css/admin.css">
<script src='../js/jquery-3.7.1.min.js'></script>
<title>회원 정보수정</title>
</head>
<body>
<%@ include file="../menu.jsp"%>
<h2 class ="text-center">회원 정보수정</h2>
<div id="updateMemberForm">
<form action="processAdmin_memberUpdate.jsp" method="post" onsubmit="return updateValid()">
<%
	request.setCharacterEncoding("UTF-8");
	
	String id = request.getParameter("id");
	
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	String sql = "SELECT * FROM member WHERE id = ?";
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, id);
	rs = pstmt.executeQuery();
	rs.next();
%>
<div class="updateMemberForm1">
	<div class="subject1">
		<label class="label1">아이디 : </label>
	</div>
	<div class="subject2">
		<input type="text" name="id" class="form-control" value='<%=rs.getString("id")%>' readonly>
	</div>
</div>
<div class="updateMemberForm1">
	<div class="subject1">
		<label class="label1">비밀번호 : </label>
	</div>
	<div class="subject2">
		<input type="password" name="password" id="password" class="form-control" value='<%=rs.getString("password")%>'>
	</div>
</div>
<div class="updateMemberForm1">
	<div class="subject1">
		<label class="label1">비밀번호 확인 : </label>
	</div>
	<div class="subject2">
		<input type="password" name="password_confirm" id="password_confirm" class="form-control" value='<%=rs.getString("password")%>'>
	</div>
</div>
<div class="updateMemberForm1">
	<div class="subject1">
		<label class="label1">이름 : </label>
	</div>
	<div class="subject2">
		<input type="text" name="name" id="name" class="form-control" value='<%=rs.getString("name")%>' readonly>
	</div>
</div>
<div class="updateMemberForm1">
	<div class="subject1">
		<label class="label1">이메일 : </label>
	</div>
	<div class="subject2">
		<input type="text" name="email" id="email" class="form-control" value='<%=rs.getString("email")%>'>
	</div>
</div>
<div class="updateMemberForm1">
	<div class="subject1">
		<label class="label1">전화번호 : </label>
	</div>
	<div class="subject2">
		<input type="text" name="phone" id="phone" class="form-control" value='<%=rs.getString("phone")%>'>
	</div>
</div>
<div class="d-flex flex-row-reverse" style="width:500px; margin:auto">
	<input type="submit" class="btn btn-primary" value="수정" >
</div>
</form>
</div>
<script src="../js/admin.js"></script>
</body>
</html>