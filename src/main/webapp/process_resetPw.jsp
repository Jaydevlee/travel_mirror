<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="dbconn.jsp" %>
<%
  String newPw=request.getParameter("tr_newPw");
  String id=request.getParameter("id");
  PreparedStatement pstmt=null;
  int rs;
  
try{
 String sql="UPDATE tr_member SET tr_mem_password=? WHERE tr_mem_id=?";
 pstmt=conn.prepareStatement(sql);
 pstmt.setString(1, newPw);
 pstmt.setString(2, id);
 rs=pstmt.executeUpdate();

if(rs > 0){
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
	if(pstmt!=null)
	  pstmt.close();
	 if(conn!=null)
	  conn.close();
	}
%>