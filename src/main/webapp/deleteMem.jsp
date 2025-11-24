<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="dbconn.jsp" %>

<!-- sessionId 가져오기 -->
<% 
	String id=(String) session.getAttribute("sessionId"); 
	PreparedStatement pstmt=null;
	int rs;
	
	try{
		String sql="DELETE FROM tr_member WHERE tr_mem_id=?";
		pstmt=conn.prepareStatement(sql);
		pstmt.setString(1, id);
		rs=pstmt.executeUpdate();
		
		if(rs>0){
%>
	<script type="text/javascript">
		 alert("탈퇴되었습니다.");
		 location.href="firstPage.jsp";
		</script>
<% 
	}
	} catch(SQLException ex){
		out.println("오류가 발생했습니다.<br>");
		out.println("SQLException : " + ex.getMessage());
	} finally {
		if(pstmt!=null)
			pstmt.close();
		if(conn!=null)
			conn.close();
	}
%>