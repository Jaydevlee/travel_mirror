<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ include file="dbconn.jsp" %>
<%
	request.setCharacterEncoding("UTF-8");
	String save = application.getRealPath("./img/profile");
	int maxSize= 10*1024*1024;
	
	MultipartRequest multi=new MultipartRequest(request, save, maxSize, "UTF-8", new DefaultFileRenamePolicy());
	
	Enumeration file=multi.getFileNames();
	String name=(String) file.nextElement();
	String fileName=multi.getFilesystemName(name);
	
	String id = multi.getParameter("userId");
	
	PreparedStatement pstmt=null;
	ResultSet rs=null;
	
	try{
			String sql="UPDATE tr_member SET tr_mem_pic=? WHERE tr_mem_id=?";
			pstmt=conn.prepareStatement(sql);
			pstmt.setString(1, fileName);
			pstmt.setString(2, id);
			pstmt.executeUpdate();		
%>
	<script type="text/javascript">
	 alert("프로필 사진이 변경되었습니다.");
	</script>
	<%
	response.sendRedirect("myInfoPage.jsp");
	} catch(SQLException ex){
		out.println("프로필사진 변경에 실패했습니다.<br>");
		out.println("SQLException : " + ex.getMessage());
	} finally {
		if(pstmt!=null)
			pstmt.close();
		if(conn!=null)
			conn.close();
	}
%>