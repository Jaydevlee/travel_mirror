<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.DBConnection" %> 

<%
    String root = request.getContextPath(); 

    String headerSessionId = (String) session.getAttribute("sessionId");
    String headerUserName = "Guest";

    if (headerSessionId != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection(); 
            String sql = "SELECT tr_mem_name FROM tr_member WHERE tr_mem_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, headerSessionId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                headerUserName = rs.getString("tr_mem_name");
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs);
            DBConnection.close(pstmt);
            DBConnection.close(conn);
        }
    }
    
    String pageTitle = (String)request.getAttribute("pageTitle");
    if(pageTitle == null) pageTitle = "Travel Plan";
%>

<link rel="stylesheet" href="<%=root%>/css/header_style.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<header id="header">
    <div class="title-area">
    <i class="fa-solid fa-arrow-left" id="back_btn" onclick="history.back()"></i>
    
    <i class="fa-solid fa-plane-departure" 
       style="color: #41E9C2; font-size: 20px; cursor: pointer;" 
       onclick="location.href='<%=root%>/member/myInfoPage.jsp'">
    </i>
    
    <h2><%=pageTitle%></h2>
</div>

    <div id="menu_bar">
        <i class="fa-solid fa-bars" style="color: #333;"></i>
    </div>
</header>

<aside id="side_menu">
    <div class="user-info-area">
        <% if (headerSessionId == null) { %>
            <span class="user-name">환영합니다!</span>
            <span style="font-size:0.9rem; color:#aaa;">여행을 계획해보세요.</span>
        <% } else { %>
            <span class="user-name"><%=headerUserName%> 님</span>
            <span style="font-size:0.9rem; color:#aaa;">즐거운 여행 되세요!</span>
        <% } %>
    </div>

    <ul id="link_menu">
        <li><a href="<%=root%>/personalPlan/travelList.jsp">✈️ 여행계획 세우기</a></li>
        <li><a href="<%=root%>/travelReview/reviewList.jsp">📖 여행리뷰 보기</a></li>
        <% if (headerSessionId != null) { %>
        	<li><a href="<%=root%>/travelReview/wishList.jsp">❤️ 나의 찜 목록</a></li>
            <li><a href="<%=root%>/member/myInfoPage.jsp">👤 마이페이지</a></li>
        <% } %>
    </ul>
    
    <ul id="btn_menu">
        <% if (headerSessionId == null) { %>
            <li><a href="<%=root%>/firstPage.jsp">로그인</a></li>
            <li><a href="<%=root%>/member/signup.jsp">회원가입</a></li>            
        <% } else { %>
            <li><a href="<%=root%>/member/updateMem.jsp">회원수정</a></li>
            <li><a href="<%=root%>/logout/processlogout.jsp">로그아웃</a></li>
        <% } %>
    </ul>
    
    <div style="text-align: right; margin-top: 20px;">
        <i class="fa-solid fa-xmark" id="close_menu_btn" style="font-size: 24px; cursor: pointer;"></i>
    </div>
</aside>

<div id="menu_overlay"></div>

<script>

    (function(){
        const menuBar = document.getElementById('menu_bar');
        const sideMenu = document.getElementById('side_menu');
        const overlay = document.getElementById('menu_overlay');
        const closeBtn = document.getElementById('close_menu_btn');

        function toggleMenu() {
            sideMenu.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        if(menuBar) menuBar.addEventListener('click', toggleMenu);
        if(overlay) overlay.addEventListener('click', toggleMenu);
        if(closeBtn) closeBtn.addEventListener('click', toggleMenu);
    })();
</script>