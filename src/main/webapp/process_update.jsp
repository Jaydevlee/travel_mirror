<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="dbconn.jsp" %>
<!-- 세션id값과 정보 수정부분 값 가져오기 -->
<% 
	String id=(String) session.getAttribute("sessionId");
	String newPw=request.getParameter("tr_newPw");
	String newEmail=request.getParameter("tr_newEmail");
	String newPhone=request.getParameter("tr_newPhone");
	PreparedStatement pstmt=null;
	int rs;
	
try{
	String sql="UPDATE tr_member SET tr_mem_password=?, tr_mem_email=?, tr_mem_phone=? WHERE tr_mem_id=?";
	pstmt=conn.prepareStatement(sql);
	pstmt.setString(1, newPw);
	pstmt.setString(2, newEmail);
	pstmt.setString(3, newPhone);
	pstmt.setString(4, id);
	rs=pstmt.executeUpdate();
	
	if(rs > 0){
%>
<script type="text/javascript">
	alert("회원정보가 수정되었습니다.");
	location.href="myInfoPage.jsp";
</script>
<%
	} else {
%>
<script type="text/javascript">
	alert("회원정보가 수정에 실패했습니다. 다시 시도해주세요.");
	history.back();
</script>
<%
	}
} catch (SQLException ex) {
	out.println("오류가 발생했습니다.<br>");
	out.println("SQLException: " + ex.getMessage());
} finally {
	if(pstmt!=null)
		pstmt.close();
	if(conn!=null)
		conn.close();
}
%>