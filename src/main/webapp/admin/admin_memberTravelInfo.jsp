<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="admin.Hyphen" %>
<%@ page import="com.common.DBConnection" %> 
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
<link rel="stylesheet" href="../css/bootstrap.min.css" />
<link rel="stylesheet" href="../css/admin.css">
<script src='js/jquery-3.7.1.min.js'></script>
<title>관리자 페이지</title>
</head>
<body >
<%@ include file="../menu.jsp"%>
<h1 class="text-center mt-5 mb-5">회원 목록</h1>
<div id = "list">
<table class="table table-bordered rounded-4 text-center">
	<thead>
		<tr>
			<th scope="col">#</th>
			<th scope="col">여행제목</th>
			<th scope="col">여행국가</th>
			<th scope="col">시작일</th>
			<th scope="col">종료일</th>
			<th scope="col">총예산</th>
			<th scope="col">삭제</th>
		</tr>
	</thead>
<%	
	int count = 1;
	String id = request.getParameter("id");
	Connection conn = null;
	PreparedStatement pstmt = null;
 	ResultSet rs = null;
 	conn = DBConnection.getConnection();
 	String sql =  "SELECT ROW_NUMBER() OVER (ORDER BY TRAVEL_NO) AS rn, travel_info.* " + "FROM travel_info WHERE tr_mem_id=?";
 	pstmt = conn.prepareStatement(sql);
 	pstmt.setString(1, id);
 	rs = pstmt.executeQuery();
	while(rs.next()){
%>
		<tbody>
			<tr>
			<th scope="col"><%=rs.getInt("rn")%></th>
			<th scope="col"><%=rs.getString("TITLE")%></th>
			<th scope="col"><%=rs.getString("country")%></th>
			<th scope="col"><%=rs.getDate("START_DATE")%></th>
			<th scope="col"><%=rs.getDate("END_DATE")%></th>
			<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("TOTAL_BUDGET"))%></th>
			<th><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("TRAVEL_NO")%>')">삭제</button></th>
			</tr>
		</tbody>
		<%
			}
		DBConnection.close(rs);
	    DBConnection.close(pstmt);
	    DBConnection.close(conn);
		%>
</table>
</body>
</html>