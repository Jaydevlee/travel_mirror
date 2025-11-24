<%@ page contentType="text/html; charset=utf-8"  language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.sql.*" %>
<%@ include file="dbconn.jsp" %>
 
<%
	request.setCharacterEncoding("UTF-8");
	String id=request.getParameter("id_findPw");
	String email=request.getParameter("email_findPw");
	PreparedStatement pstmt=null;
	ResultSet rs=null;

try{
	String sql="SELECT tr_mem_password FROM tr_member WHERE tr_mem_email=? AND tr_mem_id=?";
	pstmt=conn.prepareStatement(sql);
	pstmt.setString(1, email);
	pstmt.setString(2, id);
	rs=pstmt.executeQuery();
	if(rs.next()){
%>
	<script type="text/javascript">
		location.href="resetPassword.jsp?id=<%=id %>";
	</script>
<%
} else {
%>
	<script type="text/javascript">
		alert("해당아이디와 일치하는 비밀번호가 없습니다.");	
		history.back();
	</script>

<%
}
} catch(SQLException ex) {
	out.println("오류가 발생했습니다.<br>");
out.println("SQLException: " + ex.getMessage());
	} finally {
	if(rs!=null)
	rs.close();
	if(pstmt!=null)
	pstmt.close();
	if(conn!=null)
	conn.close();
	}
%>