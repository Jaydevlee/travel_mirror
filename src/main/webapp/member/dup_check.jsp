<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>

<%
	request.setCharacterEncoding("UTF-8");
  String id=request.getParameter("tr_id");
  
	//conn변수에 DBConnection의 DB연결 메소드 저장
	Connection conn=DBConnection.getConnection();
 
  TravelSelectMemDAO dao = new TravelSelectMemDAO();
  TravelMemberDTO dto = dao.dupCheck(conn, id);
  
  boolean isDuplicate = false;
try{
	
  if(dto!=null){
   isDuplicate=true;
	}
  } catch(Exception e){
e.printStackTrace();
	} finally {
	 DBConnection.close(conn);
	}
	
	if(isDuplicate){
	 out.print("duplicate");
	} else{
	 out.print("ok");
	}
%>