<%@page import="java.sql.*"%>
<%
	Connection conn=null;
	String url="jdbc:oracle:thin:@localhost:1521:xe";
	String user="travel";
	String password="travel1234";
	
	Class.forName("oracle.jdbc.driver.OracleDriver");
	conn=DriverManager.getConnection(url, user, password);
%>
