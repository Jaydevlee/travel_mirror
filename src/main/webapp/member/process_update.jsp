<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>

<!-- 세션id값과 정보 수정부분 값 가져오기 -->
<% 
	request.setCharacterEncoding("UTF-8");
	//입력폼의 값 가져오기
	String id=(String) session.getAttribute("sessionId");
	String pw=request.getParameter("tr_newPw");
	String email=request.getParameter("tr_newEmail");
	String phone=request.getParameter("tr_newPhone");
	
	TravelMemberDTO dto = new TravelMemberDTO();
	dto.setMemId(id);
	dto.setMemPw(pw);
	dto.setMemEmail(email);
	dto.setMemPhone(phone);
	
	//conn변수에 DBConnection의 DB연결 메소드 저장
		Connection conn=DBConnection.getConnection();
	
	TravelUpdateMemDAO dao = new TravelUpdateMemDAO();
	
	
try{
	int result = dao.updateMem(conn, dto);
	if(result > 0){
%>
	<script type="text/javascript">
		alert("회원정보가 수정되었습니다.");
		location.href="myInfoPage.jsp";
	</script>
<%
	} else {
%>
	<script type="text/javascript">
		alert("회원정보 수정에 실패했습니다. 다시 시도해주세요.");
		history.back();
	</script>
<%
	}

} catch (Exception ex) {
	ex.printStackTrace();
} finally {
	DBConnection.close(conn);
}
%>