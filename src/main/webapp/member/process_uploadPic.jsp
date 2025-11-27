<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*"%>
<%@ page import="com.common.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

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
	
	//conn변수에 DBConnection의 DB연결 메소드 저장
		Connection conn=DBConnection.getConnection();
	TravelUpdateMemDAO dao = new TravelUpdateMemDAO();
	
	
	try{
		int result = dao.changePic(conn, dto);
			if(result > 0){
			response.sendRedirect("myInfoPage.jsp");
			}	
		} catch(Exception ex){
		ex.printStackTrace();
	} finally {
		DBConnection.close(conn);
	}
%>