<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="admin.Hyphen" %>
<%@ page import="com.common.DBConnection" %>
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
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
conn = DBConnection.getConnection();
String sql = "SELECT * FROM tr_member";
if(searchType.equals("tr_mem_id")){
	sql = "SELECT * FROM tr_member Where tr_mem_id like ?";
	pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    rs = pstmt.executeQuery();
    while(rs.next()){
%>
	<tbody>
 			<tr>
 				<th scope="col"><%=rs.getString("tr_mem_id")%></th>
				<th scope="col"><%=rs.getString("tr_mem_name")%></th>
				<th scope="col"><%=rs.getString("tr_mem_email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("tr_mem_phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("tr_mem_id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("tr_mem_id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
<%
	}
}
%>
<%
if(searchType.equals("tr_mem_name")){
	sql = "SELECT * FROM tr_member Where tr_mem_name like ?";
	pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    rs = pstmt.executeQuery();
    while(rs.next()){
%>
	<tbody>
 			<tr>
 				<th scope="col"><%=rs.getString("tr_mem_id")%></th>
				<th scope="col"><%=rs.getString("tr_mem_name")%></th>
				<th scope="col"><%=rs.getString("tr_mem_email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("tr_mem_phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("tr_mem_id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("tr_mem_id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
<%
	}
}
%>
<%
if(searchType.equals("tr_mem_email")){
	sql = "SELECT * FROM tr_member Where tr_mem_email like ?";
	pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    rs = pstmt.executeQuery();
    while(rs.next()){
%>
	<tbody>
 			<tr>
 				<th scope="col"><%=rs.getString("tr_mem_id")%></th>
				<th scope="col"><%=rs.getString("tr_mem_name")%></th>
				<th scope="col"><%=rs.getString("tr_mem_email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("tr_mem_phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("tr_mem_id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("tr_mem_id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
<%
	}
}

%>
<%
if(searchType.equals("tr_mem_phone")){
	sql = "SELECT * FROM tr_member Where tr_mem_phone like ?";
	pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    rs = pstmt.executeQuery();
    while(rs.next()){
%>
	<tbody>
 			<tr>
 				<th scope="col"><%=rs.getString("tr_mem_id")%></th>
				<th scope="col"><%=rs.getString("tr_mem_name")%></th>
				<th scope="col"><%=rs.getString("tr_mem_email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("tr_mem_phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("tr_mem_id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("tr_mem_id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
<%
	}
}
DBConnection.close(rs);
DBConnection.close(pstmt);
DBConnection.close(conn);
%>
</table>
</body>
</html>