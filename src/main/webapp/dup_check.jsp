<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% String id = request.getParameter("tr_id"); %>
<sql:setDataSource  var="dataSource" url="jdbc:oracle:thin:@localhost:1521:xe"
 driver="oracle.jdbc.driver.OracleDriver" user="travel" password="travel1234"/>
 <sql:query var="rs" dataSource="${dataSource}">
 SELECT tr_mem_id FROM tr_member WHERE tr_mem_id=?
 <sql:param value="<%=id %>"/>
 </sql:query>
 
 <c:choose>
 	<c:when test="${rs.rowCount>0}">
 		duplicate
 	</c:when>
 	<c:otherwise>
 		ok
 	</c:otherwise>
 </c:choose>
 