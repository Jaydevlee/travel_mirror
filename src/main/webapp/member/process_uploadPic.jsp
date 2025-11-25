<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*"%>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>
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
	
	TravelMemberDTO dto = new TravelMemberDTO();
	dto.setMemId(id);
	dto.setMemFileName(fileName);
	TravelUpdateMemDAO dao = new TravelUpdateMemDAO();
	
	try{
		int result = dao.changePic(conn, dto);
		if(result > 0){
%>
	<script type="text/javascript">
	 alert("프로필 사진이 변경되었습니다.");
	</script>
	<%
	response.sendRedirect("myInfoPage.jsp");
	}
		} catch(SQLException ex){
		out.println("프로필사진 변경에 실패했습니다.<br>");
		out.println("SQLException : " + ex.getMessage());
	} finally {
		if(conn!=null)
			conn.close();
	}
%>