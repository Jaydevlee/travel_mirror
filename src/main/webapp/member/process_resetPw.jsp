<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.*" %>
<%@ page import="com.member.dao.*"%>
<%@ page import="com.member.dto.*"%>

<%
	request.setCharacterEncoding("UTF-8");
  String newPw=request.getParameter("tr_newPw");
  String id=request.getParameter("id");
 
  TravelMemberDTO dto = new TravelMemberDTO();
  dto.setMemPw(newPw);
  dto.setMemId(id);
  
  Connection conn=DBConnection.getConnection();
  TravelUpdateMemDAO dao = new TravelUpdateMemDAO();
   
try{
	int result = dao.resetPw(conn, dto);
	if(result > 0){
		%>
		<script type="text/javascript">
			alert("비밀번호가 변경되었습니다.");
			location.href="../firstPage.jsp";
		</script>
	<%
		} else {
	%>
		<script type="text/javascript">
		 alert("비밀번호 변경에 실패했습니다. 다시 시도해주세요.");
		 history.back();
		</script>
	<%
		}
		} catch (Exception ex){
			ex.printStackTrace();
			%>
			<script>
			    alert("오류가 발생했습니다. 다시 시도해주세요.");
			    history.back();
			</script>
			<%
		} finally {
		 DBConnection.close(conn);
		}
	%>