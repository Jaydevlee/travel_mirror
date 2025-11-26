<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../member/dbconn.jsp"%>
<%@ page import="java.sql.*" %>
<%
	String sessionId = (String) session.getAttribute("sessionId");

	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	String sql = "SELECT * FROM tr_member WHERE tr_mem_id = ?";
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, sessionId);
	rs = pstmt.executeQuery();
	rs.next();
%>
<link rel="stylesheet" href="../../travel/css/header_style.css">
<header id="header">
    <h2>title</h2>
    <div id="menu_bar">
        <img src="../../travel/img/icon/menu_bar.png" style="width: 100%;">
    </div>
</header>
<!-- 경로는 절대경로로 -->
<aside id="side_menu">
    <ul id="link_menu">
    	<c:choose>
    		<c:when test="${empty sessionId}">
		        <li><a href="../personalPlan/travelList.jsp">여행계획 세우기</a></li>
		        <li><a href="../travelReview/reviewList.jsp">여행리뷰 보기</a></li>
		    </c:when>
		    <c:otherwise>
		    	<li><%=rs.getString("tr_mem_name")%>님</li>
		        <li><a href="../personalPlan/travelList.jsp">여행계획 세우기</a></li>
		        <li><a href="../travelReview/reviewList.jsp">여행리뷰 보기</a></li>
		    </c:otherwise>
		</c:choose>
    </ul>
    <ul id="btn_menu">
    	<c:choose>
    		<c:when test="${empty sessionId}">
		    	<li><a href="firstPage.jsp">로그인</a></li>
		    	<li><a href="member/signup.jsp">회원가입</a></li>    		
    		</c:when>
    		<c:otherwise>
    			<li><a href="member/updateMem.jsp">회원수정</a></li>
		    	<li><a href="../logout/processlogout.jsp">로그아웃</a></li>
    		</c:otherwise>
    	</c:choose>
    </ul>
</aside>

<div id="menu_overlay"></div>
<script src="../../travel/js/header.js"></script>
