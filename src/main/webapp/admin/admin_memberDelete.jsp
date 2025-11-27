<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.common.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    conn = DBConnection.getConnection();

    String sql = "SELECT * FROM tr_member WHERE tr_mem_id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, id);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        sql = "DELETE FROM tr_member WHERE tr_mem_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        int result = pstmt.executeUpdate();

        if(result > 0){
            response.sendRedirect("admin_pageSucess.jsp?cnt=10");
        } else {
            out.println("회원 삭제 실패");
        }

    } else {
        out.println("일치하는 회원이 없습니다");
    }

    DBConnection.close(rs);
    DBConnection.close(pstmt);
    DBConnection.close(conn);
%>
