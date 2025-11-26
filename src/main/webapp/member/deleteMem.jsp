<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>
<%@ include file="dbconn.jsp" %>

<!-- sessionId 가져오기 -->
<% 
	String id=(String) session.getAttribute("sessionId"); 
	TravelMemberDTO dto = new TravelMemberDTO();
	
	dto.setMemId(id);
	TravelDeleteMemDAO dao = new TravelDeleteMemDAO();
	try{
		int result = dao.deleteMem(conn, dto);
		
		if(result > 0){
			session.invalidate();
%>
	<script type="text/javascript">
		 alert("탈퇴되었습니다.");
		 location.href="../firstPage.jsp";
		</script>
<%
		} else {
%>
	<script type="text/javascript">
		 alert("탈퇴실패.");
		 history.back();
		</script>
<% 
	}
	} catch(SQLException ex){
		out.println("오류가 발생했습니다.<br>");
		out.println("SQLException : " + ex.getMessage());
	} finally {
		if(conn!=null)
			conn.close();
	}
%>