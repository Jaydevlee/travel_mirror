<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file = "../dbconn.jsp" %>	
<%
	session.invalidate();
	response.sendRedirect("../firstPage.jsp");
%>