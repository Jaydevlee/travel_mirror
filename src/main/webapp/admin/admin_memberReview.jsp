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
<script type="text/javascript">
	function deleteReview(reviewNo) {
		if (confirm("해당 리뷰를 삭제합니다.") == true)
			location.href =  "./admin_memberReviewDelete.jsp?reviewNo=" + reviewNo;
		else
			return;
	}
</script>
<%@ include file="../menu.jsp"%>
<%
	String id = request.getParameter("id");
%>
<h1 class="text-center mt-5 mb-5"><%=id %> 여행 목록</h1>
<div id = "list">
<table class="table table-bordered rounded-4 text-center">
	<thead>
		<tr>
			<th scope="col">#</th>
			<th scope="col">여행지</th>
			<th scope="col">후기내용</th>
			<th scope="col">작성일</th>
			<th scope="col">삭제</th>
		</tr>
	</thead>
<%	
	int count = 1;
	Connection conn = null;
	PreparedStatement pstmt = null;
 	ResultSet rs = null;
 	conn = DBConnection.getConnection();
 	String sql =  "SELECT ROW_NUMBER() OVER (ORDER BY REVIEW_NO) AS rn, TRAVEL_REVIEW.* " + "FROM TRAVEL_REVIEW WHERE TR_MEM_ID=?";
 	pstmt = conn.prepareStatement(sql);
 	pstmt.setString(1, id);
 	rs = pstmt.executeQuery();
	while(rs.next()){
%>
		<tbody>
			<tr>
			<th scope="col"><%=rs.getInt("rn")%></th>
			<th scope="col"><%=rs.getString("destination")%></th>
			<th scope="col"><%=rs.getString("content")%></th>
			<th scope="col"><%=rs.getDate("reg_date")%></th>
			<th><button class="btn btn-danger" onclick="deleteReview(<%=rs.getInt("review_no")%>)">삭제</button></th>
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