<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- DB연결 -->
<sql:setDataSource  var="dataSource" url="jdbc:oracle:thin:@localhost:1521:xe"
 	driver="oracle.jdbc.driver.OracleDriver" user="travel" password="travel1234"/>
 	
<!-- DB에서 아이디값 가져오기 -->
<sql:query var="rs" dataSource="${dataSource}">
 	SELECT tr_mem_id FROM tr_member WHERE tr_mem_email=?
 	<sql:param value="${param.email_findId}"/>
</sql:query>


<c:choose>
<c:when test="${rs.rowCount >0 }">
	<c:set var="foundId" value="${rs.rows[0].tr_mem_id}" />
	<script type="text/javascript">
		alert("회원님의 아이디는 '${foundId}' 입니다.");
		location.href="findaccount.jsp";
	</script>
</c:when>
<c:otherwise>
	<script type="text/javascript">
		alert("해당이메일로 가입된 아이디가 없습니다.");
		history.back();
	</script>
</c:otherwise>
</c:choose>
