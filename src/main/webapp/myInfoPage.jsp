<%@ page language="java" contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ include file="dbconn.jsp" %>
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
<% 
		String sessionId=(String) session.getAttribute("sessionId");
		PreparedStatement pstmt=null;
		ResultSet rs=null;
		String name=null;
		String id=null;
		String email=null;
		String phone=null;
		String pic=null;
try{
  
  String sql="SELECT * FROM tr_member WHERE tr_mem_id=?";
  pstmt=conn.prepareStatement(sql);
  pstmt.setString(1, sessionId);
  rs=pstmt.executeQuery();

 while(rs.next()){
   name=rs.getString("tr_mem_name");
   id=rs.getString("tr_mem_id");
   email=rs.getString("tr_mem_email");
   phone=rs.getString("tr_mem_phone");
   pic=rs.getString("tr_mem_pic");
}
%>

	<div class="leftSection">
  <h2>나의 계정</h2>
    <div class="tr_profileSection">
      <img src="<%= (pic != null ? "img/profile/" + pic : "../../travel/img/defaultprofile.jpg") %>" alt="프로필 사진" class="tr_profilePic" id="tr_profilePreview">
      <button type="button" id="changePicBtn">사진 변경</button>
      <form id="uploadProfileForm" action="process_uploadPic.jsp" method="post" enctype="multipart/form-data">
      	<input type="file" id="profilePicFile" name="profilePicFile" accept="image/*" style="display:none;">
      	 <input type="hidden" name="userId" value="<%=sessionId%>">
      </form>
    </div>
    <div class="tr_infoSection">
      <div class="tr_mem_id">
        <p><strong><%= name%>님 반가워요!</strong></p>
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
				<li>아이디: <%=id %></li>
				<li>이메일: <%=email %></li>
				<li>전화번호: <%=phone %></li>
			</ul>
		</div>
<div class="myTravel">
 		<div class="title">
 				<h3>내 여행</h3>
 			</div>
			<ul class="travelPlan">
				<li>여행: 리뷰번호와 연결해서 가져오기	</li>
			</ul>
		</div>
	</div>
<%
} catch(SQLException ex){
 out.println("회원 정보를 불러오는데 문제가 발생했습니다.");
 out.println("SQLException: " + ex.getMessage());
} finally {
 if(rs!=null)
  rs.close();
 if(pstmt!=null)
  pstmt.close();
 if(conn!=null)
  conn.close();
}	
%>
	</div>
  	<script src="js/myInfoPage.js"></script>
</body>
</html>