<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*"%>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ include file="dbconn.jsp" %>
<%
	request.setCharacterEncoding("UTF-8");

	String id=request.getParameter("tr_id");
	String pw=request.getParameter("tr_pw");
	String name=request.getParameter("tr_name");
	String email=request.getParameter("tr_email");
	String phone=request.getParameter("tr_phone");
	
	int level=2; //회원 레벨	

	PreparedStatement pstmt=null;
try{	
	 String sql="INSERT INTO TR_MEMBER(tr_mem_no, tr_mem_id, tr_mem_password, tr_mem_name, tr_mem_email, tr_mem_phone, tr_mem_level) VALUES(tr_member_seq.NEXTVAL, ?, ?, ?, ?, ?, ?)";
	 pstmt=conn.prepareStatement(sql);
	 pstmt.setString(1, id);
	 pstmt.setString(2, pw);
	 pstmt.setString(3, name);
	 pstmt.setString(4, email);
	 pstmt.setString(5, phone);
	 pstmt.setInt(6, level);
	 pstmt.executeUpdate();
 
	session.setAttribute("sessionId", id);
	session.setAttribute("sessionName", name);
	
	response.sendRedirect("myInfoPage.jsp");
} catch(SQLException e) {
	out.println("회원가입 실패!<br>");
	out.println("SQLException " + e.getMessage());
} finally {
	if(pstmt!=null)
		pstmt.close();
	if(conn!=null)
		conn.close();
}
%>