<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.member.dao.*"%>
<%@ page import="com.member.dto.*"%>
<%@ include file="dbconn.jsp" %>
<%
	request.setCharacterEncoding("UTF-8");
  String newPw=request.getParameter("tr_newPw");
  String id=request.getParameter("id");
 
  TravelMemberDTO dto = new TravelMemberDTO();
  dto.setMemPw(newPw);
  dto.setMemId(id);
  TravelUpdateMemDAO dao = new TravelUpdateMemDAO();
  
try{
	int result = dao.resetPw(conn, dto);
	if(result > 0){
		%>
		<script type="text/javascript">
			alert("비밀번호가 변경되었습니다.");
			location.href="firstPage.jsp";
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
		} catch (SQLException ex){
			out.println("오류가 발생했습니다<br>");
			out.println("SQLException: "+ ex.getMessage());
		} finally {
		 if(conn!=null)
		  conn.close();
		}
	%>