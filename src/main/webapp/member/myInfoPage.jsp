<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.common.*" %>
<%@ page import="com.member.dao.*" %>
<%@ page import="com.member.dto.*" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.util.List" %>
<%@ page import="com.personalPlan.dao.TravelDAO" %>
<%@ page import="com.personalPlan.dto.TravelInfoDTO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="admin.Hyphen" %>

<%
	request.setCharacterEncoding("utf-8");
	
	Connection conn = null;
	//dto변수선언
	TravelMemberDTO dto = null;
	
	//myTraveList 변수 선언
	List<TravelInfoDTO> myTravelList = null;
	
	//페이지네이션 변수 선언
	int Page = 1;
	int pagesize = 5;
	int startpage = 0;
	int endpage = 0;
	int totalpage=0;
	
	// 1. 세션에서 아이디 가져오기
    String sessionId = (String) session.getAttribute("sessionId");
	
try {
    // DB 연결
    conn = DBConnection.getConnection();

    

    // 2. 로그인 안 했으면 튕겨내기
    if(sessionId == null){
%>
        <script type="text/javascript">
            alert("로그인이 필요합니다.");
            location.href="../firstPage.jsp"; 
        </script>
<%
        return;
    }

    // 3. 회원 정보 가져오기
    TravelSelectMemDAO memDao = new TravelSelectMemDAO();
    dto = memDao.selectMem(conn, sessionId);

    // 회원 정보가 없으면 처리
    if(dto.getMemId() == null){
%>
        <script type="text/javascript">
            alert("회원 정보를 찾을 수 없습니다.");
            location.href="../firstPage.jsp";
        </script>
<%
        return;
    }

    request.setAttribute("mem", dto);

    // 4. 내 여행 리스트 가져오기
    TravelDAO dao = new TravelDAO();
    myTravelList = dao.selectMyTravelList(conn, sessionId);

    // 페이지네이션
    if(request.getParameter("Page") != null){
        Page = Integer.parseInt(request.getParameter("Page"));
    }
 
    startpage = (Page-1)*pagesize;
    endpage = startpage + pagesize;
   	totalpage = (int)Math.ceil(myTravelList.size() / 5.0);

    // 페이지네이션 값 JSP에서 그대로 사용
    request.setAttribute("myTravelList", myTravelList);
    request.setAttribute("Page", Page);
    request.setAttribute("pagesize", pagesize);
    request.setAttribute("startpage", startpage);
    request.setAttribute("endpage", endpage);
    request.setAttribute("totalpage", totalpage);

} catch(Exception e) {
    e.printStackTrace();
%>
    <script>
        alert("데이터를 불러오는 중 오류가 발생했습니다.");
        location.href="../firstPage.jsp";
    </script>
<%
    return;

} finally {
    // DB 커넥션 닫기
    DBConnection.close(conn);
}
%>

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
					   <img src="/uploads/${mem.memFileName}" 
					        alt="프로필 사진" class="tr_profilePic" id="tr_profilePreview">
					</c:otherwise>
					</c:choose>
			      <button type="button" id="changePicBtn"></button>
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
	
		<div class="rightSection">
			<div class="myProfile">
				<div class="title">
					<a href="updateMem.jsp"><h3>내 프로필 &raquo;</h3></a>
				</div>
				<ul class="profileBox">
					<li>아이디: ${mem.memId}</li>
					<li>이메일: ${mem.memEmail}</li>
					<li>전화번호: <%=Hyphen.formatPhoneNumber(dto.getMemPhone())%></li>
				</ul>
			</div>
			
			<div class="myTravel">
		 		<div class="title">
		 			<a href="../../travel/personalPlan/travelList.jsp"><h3>내 여행 &raquo;</h3></a>
		 		</div>
				<ul class="travelPlan">
				<% if(myTravelList.size() == 0) { %>
				    <li>등록된 여행이 없습니다.</li>
				<% } else {
					for(int i = startpage; i < endpage && i < myTravelList.size(); i++){
						TravelInfoDTO t = myTravelList.get(i);
						if(myTravelList.get(i) == null){
							break;
						} else{
				%>
					<li>
				    	<a class="travelListTitle" href="../../travel/personalPlan/makeAPlan.jsp?travelNo=<%= t.getTravelNo() %>"><%= t.getTitle() %> - <%= t.getCountry() %></a>
				    </li>
				<%							
						}
					}
				}
				 %>
				</ul>
				<div class="pagenation">
					<%
					    if (Page > 1) {
					%>
					        <a href="?Page=<%= Page - 1 %>">이전</a>
					<%
					    }				
					    // 페이지 숫자들
					    for (int i = 1; i <= totalpage; i++) {
					%>
					        	<a href="?Page=<%= i %>" <%= (i == Page ? "style='font-weight:bold;'" : "") %>><%= i %></a>
					<%
					    }
					
					    // 다음 버튼
					    if (Page < totalpage) {
					%>
					        	<a href="?Page=<%= Page + 1 %>">다음</a>
					<%
					    }
					%>
				</div>
			</div>
		</div>	
	  </div>
	</main>
  	<script src="../js/myInfoPage.js"></script>
</body>
</html>