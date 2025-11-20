<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 세션id값과 정보 수정부분 값 가져오기 -->
<% String id=(String) session.getAttribute("sessionId");
	String newPw=request.getParameter("tr_newPw");
	String newEmail=request.getParameter("tr_newEmail");
	String newPhone=request.getParameter("tr_newPhone");
%>


<sql:setDataSource  var="dataSource" url="jdbc:oracle:thin:@localhost:1521:xe"
 driver="oracle.jdbc.driver.OracleDriver" user="travel" password="travel1234"/>
 <!-- 회원 정보 수정 저장 -->
 <sql:update var="rs" dataSource="${dataSource}">
 	UPDATE tr_member SET tr_mem_password=?, tr_mem_email=?, tr_mem_phone=? WHERE tr_mem_id=?
 	<sql:param value="<%=newPw %>" />
 	<sql:param value="<%=newEmail %>" />
 	<sql:param value="<%=newPhone %>" />
 	<sql:param value="<%=id %>" />
 </sql:update>

 <c:choose>
	<c:when test ="${rs > 0}">
		<script type="text/javascript">
		 alert("회원정보가 수정되었습니다.");
		 location.href="myInfoPage.jsp";
		</script>
	</c:when>
	<c:otherwise>
		<script>
		 alert("회원정보가 수정에 실패했습니다. 다시 시도해주세요.");
		 history.back();
		</script>
	</c:otherwise>
</c:choose>
 