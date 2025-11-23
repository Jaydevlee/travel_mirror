<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	String session_id=(String) session.getAttribute("sessionId");
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
        <li><a href="#">여행계획 세우기</a></li>
        <li><a href="#">여행리뷰 보기</a></li>
    </ul>
    <ul id="btn_menu">
    	<c:choose>
    		<c:when test="${empty session_id}">
		    	<li><a href="#">로그인</a></li>
		    	<li><a href="#">회원가입</a></li>    		
    		</c:when>
    		<c:otherwise>
    			<li><a href="#">회원수정</a></li>
		    	<li><a href="#">로그아웃</a></li>
    		</c:otherwise>
    	</c:choose>
    </ul>
</aside>

<div id="menu_overlay"></div>
<script src="../../travel/js/header.js"></script>
