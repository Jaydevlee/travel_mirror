<%@ page contentType="text/html; charset=utf-8"  language="java"%>
<%@ page import="com.common.*" %>
<%@ page import="com.member.dao.*"%>
<%@ page import="com.member.dto.*"%>
<%@ page import="java.sql.*" %>

 
<%
	request.setCharacterEncoding("UTF-8");
	String id=request.getParameter("id_findPw");
	String email=request.getParameter("email_findPw");

	TravelSelectMemDAO dao = new TravelSelectMemDAO();
	//conn변수에 DBConnection의 DB연결 메소드 저장
	Connection conn=DBConnection.getConnection();

try{
	TravelMemberDTO dto = dao.findMemPw(conn, email, id);
	if(dto != null){
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
	DBConnection.close(conn);
	}
%>