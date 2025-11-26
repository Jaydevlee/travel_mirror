<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="admin.Hyphen" %>
<%@ include file = "../dbconn.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
<link rel="stylesheet" href="../css/bootstrap.min.css" />
<link rel="stylesheet" href="../css/admin.css">
<script src='js/jquery-3.7.1.min.js'></script>
<script src="js/admin.js"></script>
<title>관리자 페이지</title>
</head>
<body>
	<h1 class="text-center mt-5 mb-5">회원 목록</h1>
	<div id = "list">
	<table class="table table-bordered rounded-4 text-center">
		<thead>
			<tr>
				<th scope="col">아이디</th>
				<th scope="col">이 름</th>
				<th scope="col">이메일</th>
				<th scope="col">전화번호</th>
				<th scope="col">수정/삭제</th>
			</tr>
		</thead>
<%
String searchType = request.getParameter("searchType");
String keyword = request.getParameter("keyword");
PreparedStatement pstmt = null;
ResultSet rs = null;
String sql = "SELECT * FROM MEMBER";
if(searchType.equals("id")){
	sql = "SELECT * FROM MEMBER Where id like ?";
	pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    rs = pstmt.executeQuery();
    while(rs.next()){
%>
	<tbody>
 			<tr>
 				<th scope="col"><%=rs.getString("id")%></th>
				<th scope="col"><%=rs.getString("name")%></th>
				<th scope="col"><%=rs.getString("email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
<%
	}
}
%>
<%
if(searchType.equals("name")){
	sql = "SELECT * FROM MEMBER Where name like ?";
	pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    rs = pstmt.executeQuery();
    while(rs.next()){
%>
	<tbody>
 			<tr>
 				<th scope="col"><%=rs.getString("id")%></th>
				<th scope="col"><%=rs.getString("name")%></th>
				<th scope="col"><%=rs.getString("email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
<%
	}
}
%>
<%
if(searchType.equals("email")){
	sql = "SELECT * FROM MEMBER Where email like ?";
	pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    rs = pstmt.executeQuery();
    while(rs.next()){
%>
	<tbody>
 			<tr>
 				<th scope="col"><%=rs.getString("id")%></th>
				<th scope="col"><%=rs.getString("name")%></th>
				<th scope="col"><%=rs.getString("email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
<%
	}
}

%>
<%
if(searchType.equals("phone")){
	sql = "SELECT * FROM MEMBER Where phone like ?";
	pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    rs = pstmt.executeQuery();
    while(rs.next()){
%>
	<tbody>
 			<tr>
 				<th scope="col"><%=rs.getString("id")%></th>
				<th scope="col"><%=rs.getString("name")%></th>
				<th scope="col"><%=rs.getString("email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
<%
	}
}
%>
</table>
</body>
</html>