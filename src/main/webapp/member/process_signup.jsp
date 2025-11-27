<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*"%>
<%@ page import="com.member.dto.*"%>
<%@ page import="com.member.dao.*"%>
<%@ page import="com.common.*"%>
<%
	request.setCharacterEncoding("UTF-8");

	TravelMemberDTO dto = new TravelMemberDTO();
	
	dto.setMemId(request.getParameter("tr_id"));
	dto.setMemPw(request.getParameter("tr_pw"));
	dto.setMemName(request.getParameter("tr_name"));
	dto.setMemEmail(request.getParameter("tr_email"));
	dto.setMemPhone(request.getParameter("tr_phone"));
	dto.setMemLevel(2);
	
	//conn변수에 DBConnection의 DB연결 메소드 저장
	Connection conn=DBConnection.getConnection();
	
	TravelSignUpDAO dao = new TravelSignUpDAO(); 
	
	
try{
	 
	 int result = dao.insertMember(conn, dto);
	 if(result > 0){		 
 
	 session.setAttribute("sessionMemNO", dto.getMemNo());
	 session.setAttribute("sessionId", dto.getMemId());
	 session.setAttribute("sessionName", dto.getMemName());
%>
	 <script type="text/javascript">
		 	alert("회원가입 되었습니다! Travel과 함께 즐거운 여행되세요!");
		 	location.href="myInfoPage.jsp";
	 </script>
<%	
	} else {
%>
	<script type="text/javascript">
	 	alert("회원가입 실패!");
	 	history.back();
	</script>
 <%
	}
} catch(Exception e) {
	e.printStackTrace();
	%>
	<script type="text/javascript">
		alert("오류발생!");
		history.back();
	</script>
 <%
} finally {
	DBConnection.close(conn);
}
%>