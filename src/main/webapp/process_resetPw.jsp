<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
 
 <%
 	String newPw=request.getParameter("tr_newPw");
  String id=request.getParameter("id");
 %>
<sql:setDataSource  var="dataSource" url="jdbc:oracle:thin:@localhost:1521:xe"
 	driver="oracle.jdbc.driver.OracleDriver" user="travel" password="travel1234"/>

<sql:update var="rs" dataSource="${dataSource}">
	UPDATE tr_member SET tr_mem_password=? WHERE tr_mem_id=?
	<sql:param value="<%=newPw %>"/>
	<sql:param value="<%=id %>"/> 	
</sql:update>

<c:choose>
	<c:when test ="${rs > 0}">
		<script type="text/javascript">
		 alert("비밀번호가 변경되었습니다.");
		 location.href="firstPage.jsp";
		</script>
	</c:when>
	<c:otherwise>
		<script>
		 alert("비밀번호 변경에 실패했습니다. 다시 시도해주세요.");
		 history.back();
		</script>
	</c:otherwise>
</c:choose>