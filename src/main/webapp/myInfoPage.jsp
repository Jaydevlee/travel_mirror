<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원정보 수정</title>
  <script src='js/jquery-3.7.1.min.js'></script>
  <link rel="stylesheet" href="css/myInfoPage.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&icon_names=person" />
</head>
<body class="tr_myInfoPage">
  <div class="tr_myInfoContainer">
  
  <!-- DB에서 회원 정보 가져오기 -->
  <% String id=(String) session.getAttribute("sessionId"); %>  
  <sql:setDataSource  var="dataSource" url="jdbc:oracle:thin:@localhost:1521:xe"
 	driver="oracle.jdbc.driver.OracleDriver" user="travel" password="travel1234"/>
 	<sql:query var="rs" dataSource="${dataSource}">
 	SELECT * FROM tr_member WHERE tr_mem_id=?
 	<sql:param value="<%=id %>"/>
 	</sql:query>
 	
 		<!-- 왼쪽 프로필 영역 -->
 		<c:if test="${rs.rowCount>0}">
 		<div class="leftSection">
    <h2>나의 계정</h2>
    
		    <div class="tr_profileSection">
		      <img src="./img/defaultprofile.jpg" alt="프로필 사진" class="tr_profilePic">
		      <button type="button" id="changePicBtn">사진 변경</button>
		    </div>
		    <div class="tr_infoSection">
		      <div class="tr_mem_id">
		        <p><strong>${rs.rows[0].tr_mem_name}님 반가워요!</strong></p>
		    </div>
	  	</div>
  	</div>
  	</c:if>
  	<!-- 오른쪽 내 정보 및 여행 계획 목록-->
  	<div class="rightSection">
  	<c:if test="${rs.rowCount>0}">
  		<div class="myProfile">
  			<div class="title">
  				<a href="updateMem.jsp"><h3>내 프로필&raquo;</h3></a>
  			</div>
  			<ul class="profileBox">
  				<li>아이디: ${rs.rows[0].tr_mem_id}</li>
  				<li>이메일: ${rs.rows[0].tr_mem_email}</li>
  				<li>전화번호: ${rs.rows[0].tr_mem_phone}</li>
  			</ul>
  		</div>
  		</c:if>
  		<div class="myTravel">
		 		<div class="title">
		 				<h3>내 여행</h3>
		 			</div>
  			<ul class="travelPlan">
  				<li>여행: 리뷰번호와 연결해서 가져오기	</li>
  			</ul>
  		</div>
  	</div>
  	</div>
  	
  	<script src="js/myInfoPage.js"></script>
</body>
</html>