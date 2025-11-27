<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>

<!-- DB연결 -->
<%
	request.setCharacterEncoding("UTF-8");
	String email_findId=request.getParameter("email_findId");
	
	TravelSelectMemDAO dao = new TravelSelectMemDAO();
	
	//conn변수에 DBConnection의 DB연결 메소드 저장
		Connection conn=DBConnection.getConnection();

try{
	TravelMemberDTO dto = dao.findMemId(conn, email_findId);
	if(dto != null){
%>
		<script type="text/javascript">
			alert("회원님의 아이디는 <%=dto.getMemId() %> 입니다");
			location.href="findaccount.jsp";
		</script>
<%
	} else {
%>
		<script type="text/javascript">
			alert("해당 이메일로 가입된 아이디가 없습니다.");
			history.back();
		</script>
<%
	}
	} catch(SQLException ex) {
		out.println("오류가 발생했습니다.<br>");
		out.println("SQLException: " + ex.getMessage());
	} finally {
		DBConnection.close(conn);
	}
%>
