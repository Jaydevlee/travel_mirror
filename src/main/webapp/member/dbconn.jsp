<%@page import="java.sql.*"%>
<%
	Connection conn=null;
	String url="jdbc:oracle:thin:@192.168.0.141:1521:xe";
	String user="scott";
	String password="tiger";
	
	Class.forName("oracle.jdbc.driver.OracleDriver");
	conn=DriverManager.getConnection(url, user, password);
%>
