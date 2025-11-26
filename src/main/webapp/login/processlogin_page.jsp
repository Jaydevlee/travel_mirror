<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ include file = "../dbconn.jsp" %>
<%	
	request.setCharacterEncoding("UTF-8");
	String id = request.getParameter("tr_id");
	String psw = request.getParameter("tr_psw");
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sql = "SELECT * FROM MEMBER where id = ?";
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, id);
	rs = pstmt.executeQuery();
	
	if(rs.next()){
		if(psw.equals(rs.getString("password"))){
			if(rs.getInt("num") == 3){
				session.setAttribute("sessionId", id);
				response.sendRedirect("login_sucessAdmin.jsp");
			} else if(rs.getInt("num") == 2) {
				session.setAttribute("sessionId", id);
				response.sendRedirect("login_sucess.jsp");
			} 
		} else {
			response.sendRedirect("login_failPassword.jsp");
		}
	} else {
		response.sendRedirect("login_failId.jsp");
	}
%>