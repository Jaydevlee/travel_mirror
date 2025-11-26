<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String sessionId = (String) session.getAttribute("sessionId");
%>
<header class="pb-3 pt-3 mb-4 border-bottom ">
  <div class="container ">  
    <div class="d-flex flex-wrap align-items-center justify-content-center justify-content-lg-end">
      <ul class="nav nav-pills">
      <c:choose>
      		<c:when test="${empty sessionId}">
				<li class="nav-item"><a class="nav-link" href="<c:url value="firstPage.jsp"/>">로그인 </a></li>
			</c:when>
			<c:otherwise>
				<li style="padding-top: 7px; color: black; margin-right: 10px"><b><%=sessionId%>님</b></li>
				<li class="nav-item"><a class="btn btn-danger" href="<c:url value="/logout/processlogout.jsp"/>">로그아웃 </a></li>
			</c:otherwise>
      </c:choose>
      </ul> 
    </div>
</div>
</header>
