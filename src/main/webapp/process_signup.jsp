<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="java.sql.*"%>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%
	request.setCharacterEncoding("UTF-8");

	String id=request.getParameter("tr_id");
	String pw=request.getParameter("tr_pw");
	String name=request.getParameter("tr_name");
	String email=request.getParameter("tr_email");
	String phone=request.getParameter("tr_phone");
	
	int level=2; //회원 레벨
%>
<sql:setDataSource  var="dataSource" url="jdbc:oracle:thin:@localhost:1521:xe"
 driver="oracle.jdbc.driver.OracleDriver" user="travel" password="travel1234"/>
 <sql:update var="resultSet" dataSource="${dataSource}">
 INSERT INTO TR_MEMBER(tr_mem_no, tr_mem_id, tr_mem_password, tr_mem_name, tr_mem_email, tr_mem_phone, tr_mem_level) VALUES(tr_member_seq.NEXTVAL, ?, ?, ?, ?, ?, ?)
 <sql:param value="<%=id %>"/>
 <sql:param value="<%=pw %>"/>
 <sql:param value="<%=name %>"/>
 <sql:param value="<%=email %>"/>
 <sql:param value="<%=phone %>"/>
 <sql:param value="<%=level %>"/> 
 </sql:update>
 <!-- 회원 번호는 시퀀스로 자동 생성 -->
 <!-- level은 스크립트 변수로 선언해서 EL을 사용할 수 없다. -->
 <%
  session.setAttribute("sessionId", id);
 	session.setAttribute("sessionName", name);
 	
 	response.sendRedirect("myInfoPage.jsp");
 %>