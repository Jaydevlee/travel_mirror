<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="com.personalPlan.dao.TravelDAO" %>
<%@ page import="com.personalPlan.dto.TravelInfoDTO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="admin.Hyphen" %>
<%@ include file="dbconn.jsp" %>

<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원정보 수정</title>
  <script src='../js/jquery-3.7.1.min.js'></script>
  <link rel="stylesheet" href="../css/myInfoPage.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&icon_names=person" />
</head>
<body class="tr_myInfoPage">
	<jsp:include page="/header.jsp" />
	<main>
  <div class="tr_myInfoContainer">

  <!-- DB에서 회원 정보 가져오기 -->
<% 
		request.setCharacterEncoding("utf-8");
		String sessionId=(String) session.getAttribute("sessionId");
		TravelSelectMemDAO memDao = new TravelSelectMemDAO();
		TravelMemberDTO dto = memDao.selectMem(conn, sessionId);
		request.setAttribute("mem", dto);
		
		TravelDAO dao = new TravelDAO();
		List<TravelInfoDTO> myTravelList = dao.selectTravelList(conn);
   if(dto.getMemId() == null){
%>
	<script type="text/javascript">
    alert("회원 정보를 찾을 수 없습니다.");
    location.href="../firstPage.jsp";
	</script>
 <% return; } 
 %>
	<div class="leftSection">
	<div class="leftProfileSection">
  <h2>나의 계정</h2>
    <div class="tr_profileSection">
		 <c:choose>
		<c:when test="${empty mem.memFileName}">
		   <img src="../../travel/img/defaultprofile.jpg" 
		        alt="프로필 사진" class="tr_profilePic" id="tr_profilePreview">
		</c:when>
		<c:otherwise>
		   <img src="../../travel/img/profile/${mem.memFileName}" 
		        alt="프로필 사진" class="tr_profilePic" id="tr_profilePreview">
		</c:otherwise>
		</c:choose>
      <button type="button" id="changePicBtn">사진 변경</button>
      <form id="uploadProfileForm" action="process_uploadPic.jsp" method="post" enctype="multipart/form-data">
      	<input type="file" id="profilePicFile" name="profilePicFile" accept="image/*" style="display:none;">
      	 <input type="hidden" name="userId" value="<%=sessionId%>">
      </form>
    </div>
    <div class="tr_infoSection">
      <div class="tr_mem_id">
        <p><strong>"${mem.memName}"님 반가워요!</strong></p>
    </div>
 	</div>
 	</div>
	</div>

	<!-- 오른쪽 내 정보 및 여행 계획 목록-->
	<div class="rightSection">
		<div class="myProfile">
			<div class="title">
				<a href="updateMem.jsp"><h3>내 프로필&raquo;</h3></a>
			</div>
			<ul class="profileBox">
				<li>아이디: ${mem.memId}</li>
				<li>이메일: ${mem.memEmail}</li>
				<li>전화번호: <%=Hyphen.formatPhoneNumber(dto.getMemPhone())%></li>
			</ul>
		</div>
<div class="myTravel">
 		<div class="title">
 				<a href="../../travel/personalPlan/travelList.jsp"><h3>내 여행</h3></a>
 			</div>
			<ul class="travelPlan">
			<% if(myTravelList.size() == 0) { %>
			    <li>등록된 여행이 없습니다.</li>
			<% } else {
			   for(TravelInfoDTO t : myTravelList) { %>
			       <li>
			       	<a href="../../travel/personalPlan/makeAPlan.jsp?travelNo=<%= t.getTravelNo() %>"><%= t.getTitle() %> - <%= t.getCountry() %></a>
			       </li>
			<% } 
			   } %>
			</ul>
		</div>
	</div>
	</div>
	</main>
  	<script src="../js/myInfoPage.js"></script>
</body>
</html>