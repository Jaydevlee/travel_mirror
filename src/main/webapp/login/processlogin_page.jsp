<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.DBConnection" %>
<%	
	request.setCharacterEncoding("UTF-8");
	String id = request.getParameter("tr_id");
	String psw = request.getParameter("tr_psw");
	
	System.out.println(id);
	System.out.println(psw);
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	conn = DBConnection.getConnection();
	String sql = "SELECT * FROM tr_MEMBER where tr_mem_id = ?";
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, id);
	rs = pstmt.executeQuery();
	
	if(rs.next()){
		if(psw.equals(rs.getString("tr_mem_password"))){
			if(rs.getInt("tr_mem_level") == 3){
				session.setAttribute("sessionId", id);
				response.sendRedirect("login_sucessAdmin.jsp");
			} else if(rs.getInt("tr_mem_level") == 2) {
				session.setAttribute("sessionId", id);
				response.sendRedirect("login_sucess.jsp");
			} 
		} else {
			response.sendRedirect("login_failPassword.jsp");
		}
	} else {
		response.sendRedirect("login_failId.jsp");
	}
	
	DBConnection.close(rs);
    DBConnection.close(pstmt);
    DBConnection.close(conn);
%>