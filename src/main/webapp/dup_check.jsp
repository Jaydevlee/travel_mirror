<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="dbconn.jsp" %>
<%
  String id=request.getParameter("tr_id");

  ResultSet rs=null;
  PreparedStatement pstmt=null;

  boolean isDuplicate = false;
try{
  String sql="SELECT tr_mem_id FROM tr_member WHERE tr_mem_id=?";
  pstmt=conn.prepareStatement(sql);
  pstmt.setString(1, id);
  rs=pstmt.executeQuery();

  if(rs.next()){
   isDuplicate=true;
	}
  } catch(Exception e){
e.printStackTrace();
} finally{
 if(rs!=null)
  rs.close();
 if(pstmt!=null)
  pstmt.close();
 if(conn!=null)
  conn.close();
}

if(isDuplicate){
 out.print("duplicate");
} else{
 out.print("ok");
}
%>