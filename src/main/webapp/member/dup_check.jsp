<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>
<%@ include file="dbconn.jsp" %>
<%
	request.setCharacterEncoding("UTF-8");
  String id=request.getParameter("tr_id");
 
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
	 if(conn!=null)
	  conn.close();
	}
	
	if(isDuplicate){
	 out.print("duplicate");
	} else{
	 out.print("ok");
	}
%>