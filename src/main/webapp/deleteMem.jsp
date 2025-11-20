<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- sessionId 가져오기 -->
<% String id=(String) session.getAttribute("sessionId"); %>

<!-- DB 연결 -->
<sql:setDataSource  var="dataSource" url="jdbc:oracle:thin:@localhost:1521:xe"
 driver="oracle.jdbc.driver.OracleDriver" user="travel" password="travel1234"/>
 <!-- 회원 정보 삭제 -->
  <sql:update var="rs" dataSource="${dataSource}">
 	DELETE FROM tr_member WHERE tr_mem_id=?
 	<sql:param value="<%=id %>" />
 </sql:update>
 <c:if test="${rs > 0}">
 <script type="text/javascript">
		 alert("탈퇴되었습니다.");
		 location.href="firstPage.jsp";
		</script>
 </c:if>