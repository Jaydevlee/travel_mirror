<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.common.DBConnection, com.travelReview.dao.ReviewDAO, java.sql.*" %>
<%
    String memberId = (String) session.getAttribute("sessionId");

    String reviewNoStr = request.getParameter("reviewNo");
    
    // 아이디가 없거나(비로그인), 글 번호가 안 넘어왔으면 실패 처리
    if(memberId == null || reviewNoStr == null) {
        out.print("fail"); 
        return;
    }

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        ReviewDAO dao = new ReviewDAO();
        
        // 저장/취소 토글 실행
        String result = dao.toggleWishlist(conn, memberId, Integer.parseInt(reviewNoStr));
        
        out.print(result); // "saved" 또는 "removed" 리턴
        
    } catch(Exception e) {
        e.printStackTrace();
        out.print("error");
    } finally {
        DBConnection.close(conn);
    }
%>