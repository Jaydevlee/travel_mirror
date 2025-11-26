<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.common.DBConnection, com.travelReview.dao.ReviewDAO, java.sql.*" %>
<%
    String memberId = (String) session.getAttribute("id");
    // if(memberId == null) memberId = "testUser"; // 테스트용

    String reviewNoStr = request.getParameter("reviewNo");
    if(memberId == null || reviewNoStr == null) {
        out.print("fail"); return;
    }

    Connection conn = DBConnection.getConnection();
    ReviewDAO dao = new ReviewDAO();
    String result = dao.toggleWishlist(conn, memberId, Integer.parseInt(reviewNoStr));
    DBConnection.close(conn);
    
    out.print(result); // "saved" 또는 "removed" 리턴
%>