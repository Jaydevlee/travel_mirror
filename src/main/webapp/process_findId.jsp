<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="dbconn.jsp" %>
<!-- DB연결 -->
<%
request.setCharacterEncoding("UTF-8");
String findId=request.getParameter("email_findId");
PreparedStatement pstmt=null;
ResultSet rs=null;
String id=null;

try{
	String sql="SELECT tr_mem_id FROM tr_member WHERE tr_mem_email=?";
	pstmt=conn.prepareStatement(sql);
	pstmt.setString(1, findId);
	rs=pstmt.executeQuery();
	
	if(rs.next()){
	id=rs.getString("tr_mem_id");
%>
<script type="text/javascript">
	alert("회원님의 아이디는 <%=id %> 입니다");
	location.href="findaccount.jsp";
</script>
<%
} else {
%>
<script type="text/javascript">
	alert("해당이메일로 가입된 아이디가 없습니다.");
	history.back();
</script>
<%
}
} catch(SQLException ex) {
	out.println("오류가 발생했습니다.<br>");
	out.println("SQLException: " + ex.getMessage());
} finally {
	if(rs!=null)
	rs.close();
	if(pstmt!=null)
	pstmt.close();
	if(conn!=null)
	conn.close();
}
%>
