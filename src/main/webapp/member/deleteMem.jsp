<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>

<!-- sessionId 가져오기 -->
<% 
	String id=(String) session.getAttribute("sessionId"); 
	TravelMemberDTO dto = new TravelMemberDTO();
	
	dto.setMemId(id);
	TravelDeleteMemDAO dao = new TravelDeleteMemDAO();
	
	//conn변수에 DBConnection의 DB연결 메소드 저장
	Connection conn=DBConnection.getConnection();
	
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
		DBConnection.close(conn);
	}
%>