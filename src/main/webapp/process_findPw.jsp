<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
 
<sql:setDataSource  var="dataSource" url="jdbc:oracle:thin:@localhost:1521:xe"
 	driver="oracle.jdbc.driver.OracleDriver" user="travel" password="travel1234"/>

<sql:query var="rs" dataSource="${dataSource}">
	SELECT * FROM tr_member WHERE tr_mem_id=? AND tr_mem_email=?
	<sql:param value="${param.id_findPw}"/>
	<sql:param value="${param.email_findPw}"/> 	
</sql:query>

<c:choose>
	<c:when test="${rs.rowCount > 0}">
	<script>
		location.href="resetPassword.jsp?id=${rs.rows[0].tr_mem_id}";
	</script>
	</c:when>
	<c:otherwise>
		<script>
			alert("아이디 또는 비밀번호가 일치하지 않습니다.");
			history.back();
		</script>
	</c:otherwise>
</c:choose>
