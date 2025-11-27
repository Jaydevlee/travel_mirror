<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.DBConnection" %>
<%	
	request.setCharacterEncoding("UTF-8");

	String id = request.getParameter("id");
	String password = request.getParameter("password");
	String name = request.getParameter("name");
	String email = request.getParameter("email");
	String phone = request.getParameter("phone");
		
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	Connection conn = null;
	
	conn = DBConnection.getConnection();
	String sql = "SELECT * FROM tr_member WHERE tr_mem_id = ?";
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, id);
	rs = pstmt.executeQuery();
	
	if (rs.next()) {		
			sql = "UPDATE tr_member SET tr_mem_password=?, tr_mem_name=?, tr_mem_email=?, tr_mem_phone=? WHERE tr_mem_id=?";	
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, password);
			pstmt.setString(2, name);
			pstmt.setString(3, email);
			pstmt.setString(4, phone);
			pstmt.setString(5, id);
			pstmt.executeUpdate();
	}
	DBConnection.close(rs);
	DBConnection.close(pstmt);
	DBConnection.close(conn);

	response.sendRedirect("admin_pageSucess.jsp?cnt=10");
%>