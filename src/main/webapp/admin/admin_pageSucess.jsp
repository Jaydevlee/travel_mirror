<%@ page contentType="text/html; charset=utf-8"%>
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
<body >
	<%@ include file="../menu.jsp"%>
	<h1 class="text-center mt-5 mb-5">회원 목록</h1>
	<div id = "list">
	<table class="table table-bordered rounded-4 text-center">
		<thead>
			<tr>
				<th scope="col">#</th>
				<th scope="col">아이디</th>
				<th scope="col">이 름</th>
				<th scope="col">이메일</th>
				<th scope="col">전화번호</th>
				<th scope="col">수정/삭제</th>
			</tr>
		</thead>
	<%	
		int count = 1;
		int cnt = Integer.parseInt(request.getParameter("cnt"));
		PreparedStatement pstmt = null;
	 	ResultSet rs = null;
	 	String sql = "SELECT * from (SELECT ROW_NUMBER() OVER (ORDER BY tr_mem_no) AS rn, tr_member.* FROM tr_member where tr_mem_level=? or tr_mem_level=?) WHERE rn BETWEEN ? and ?";
	 	pstmt = conn.prepareStatement(sql);
	 	pstmt.setInt(1, 2);
	 	pstmt.setInt(2, 3);
	 	if(request.getParameter("cnt") == null){
	 	pstmt.setInt(3, count);
	 	pstmt.setInt(4, count+10);
	 	}else {
	 		int count2 = Integer.parseInt(request.getParameter("cnt"));
	 		int count3 = count2+11;
	 		pstmt.setInt(3,count2-9);
	 		pstmt.setInt(4,count3);
	 	}
	 	rs = pstmt.executeQuery();
		for(int i = 0; i < 10; i++){
			if(rs.next()){
			if(rs.getInt("tr_mem_level") == 3){
	%>
 		<tbody>
 			<tr>
 				<th scope="col"><%=rs.getInt("rn")%></th>
 				<th scope="col"><%=rs.getString("tr_mem_id")%>(관리자계정)</th>
				<th scope="col"><%=rs.getString("tr_mem_name")%></th>
				<th scope="col"><%=rs.getString("tr_mem_email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("tr_mem_phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("tr_mem_id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("tr_mem_id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
 		<%
 			} else {		
 		%>
 		<tbody>
 			<tr>
 				<th scope="col"><%=rs.getInt("rn")%></th>
 				<th scope="col"><%=rs.getString("tr_mem_id")%></th>
				<th scope="col"><%=rs.getString("tr_mem_name")%></th>
				<th scope="col"><%=rs.getString("tr_mem_email")%></th>
				<th scope="col"><%=Hyphen.formatPhoneNumber(rs.getString("tr_mem_phone"))%></th>
				<th scope="col"><a href="./admin_memberUpdate.jsp?id=<%=rs.getString("tr_mem_id")%>" class="btn btn-success" role="button">수정</a><span> </span><button class="btn btn-danger" onclick="deleteConfirm('<%=rs.getString("tr_mem_id")%>')">삭제</button></th>
 			</tr>
 		</tbody>
 		
 	<%
 			}
			} else {
				break;
			}
		}
 	%>	
	</table>
	<%
	int memberNum = 0;
	sql = "SELECT ROW_NUMBER() OVER (ORDER BY tr_mem_no) AS rn, tr_member.* from tr_member where tr_mem_level=? or tr_mem_level=?";
	pstmt = conn.prepareStatement(sql);
	pstmt.setInt(1, 2);
 	pstmt.setInt(2, 3);
	rs = pstmt.executeQuery();
	while(rs.next()){
		memberNum = rs.getInt("rn");
	}
	
	int currentPage = 1;
	currentPage = (cnt == 0) ? 1 : (cnt / 10) + 1;   // 현재 페이지 번호
	int pageSize = 10;                           // 한 페이지 출력 수
	int blockSize = 5;                           // 페이지를 5개씩 묶기

	int startPage = ((currentPage - 1) / blockSize) * blockSize + 1; // 현재 블록 시작 페이지
	int endPage = startPage + blockSize - 1;                  // 현재 블록 끝 페이지

	if(endPage > (int)Math.ceil(memberNum / 10.0)) {
	    endPage = (int)Math.ceil(memberNum / 10.0);           // 마지막 페이지 넘으면 조정
	}

	request.setAttribute("currentPage", currentPage);
	request.setAttribute("startPage", startPage);
	request.setAttribute("endPage", endPage);
	request.setAttribute("totalPage", (int)Math.ceil(memberNum / 10.0));
	%>
<div>

<form method="get" action="processMember_search.jsp" class="d-flex mb-3 gap-1">
    <select name="searchType" class="form-select w-auto">
        <option value="tr_mem_id">아이디</option>
        <option value="tr_mem_name">이름</option>
        <option value="tr_mem_email">이메일</option>
        <option value="tr_mem_phone">전화번호</option>
    </select>
    <span> </span>
    <input type="text" name="keyword" class="form-control w-auto" placeholder="검색어 입력">
    <span> </span>
    <button type="submit" class="btn btn-primary">검색</button>
</form>

<nav aria-label="Page navigation example" class="d-flex flex-row-reverse">
<ul class="pagination">

    <!-- 이전 5개 -->
    <li class="page-item">
        <c:choose>
            <c:when test="${startPage <= 1}">
                <a class="page-link" href="#" aria-label="Previous">
                    <span aria-hidden="true">&laquo;</span>
                </a>
            </c:when>
            <c:otherwise>
                <a class="page-link" href="./admin_pageSucess.jsp?cnt=${(startPage-2)*10}" aria-label="Previous">
                    <span aria-hidden="true">&laquo;</span>
                </a>
            </c:otherwise>
        </c:choose>
    </li>

    <!-- 페이지 5개 출력 -->
    <c:forEach begin="${startPage}" end="${endPage}" var="i">
        <li class="page-item ${currentPage==i ? 'active' : ''}">
            <a class="page-link" href="./admin_pageSucess.jsp?cnt=${(i-1)*10}">${i}</a>
        </li>
    </c:forEach>

    <!-- 다음 5개 -->
    <li class="page-item">
        <c:choose>
            <c:when test="${endPage >= totalPage}">
                <a class="page-link" href="#" aria-label="Next">
                    <span aria-hidden="true">&raquo;</span>
                </a>
            </c:when>
            <c:otherwise>
                <a class="page-link" href="./admin_pageSucess.jsp?cnt=${(endPage)*10}" aria-label="Next">
                    <span aria-hidden="true">&raquo;</span>
                </a>
            </c:otherwise>
        </c:choose>
    </li>

</ul>
</nav>
</div>
</body>
</html>