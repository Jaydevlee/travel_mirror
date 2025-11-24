<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="dbconn.jsp" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원정보 수정</title>
    <link rel="stylesheet" href="css/accountStyle.css">
    <script src='js/jquery-3.7.1.min.js'></script>
</head>
<body class="tr_updateMem">
  <div class="tr_updateContainer">
  <%
	request.setCharacterEncoding("UTF-8");
	String mem_id=(String) session.getAttribute("sessionId");
	PreparedStatement pstmt=null;
	ResultSet rs=null;
	String pw=null;
	String email=null;
	String phone=null;
	
	try{
	String sql="SELECT * FROM tr_member WHERE tr_mem_id=?";
	pstmt=conn.prepareStatement(sql);
	pstmt.setString(1, mem_id);
	rs=pstmt.executeQuery();
	
	if(rs.next()){
	pw=rs.getString("tr_mem_password");
	email=rs.getString("tr_mem_email");
	phone=rs.getString("tr_mem_phone");
	}
%>
  
    <h1>회원정보 수정</h1>
    <!-- 회원 탈퇴 부분 -->
    <a href='deleteMem.jsp'>회원 탈퇴</a>
    <form action="process_update.jsp" method="post" id="updateForm">
      <div class="tr_pwUpdate">
        <input type="password" id="tr_newPw" name="tr_newPw" class="tr_newPw" value="<%=pw %>" placeholder="새 비밀번호 입력">
        <p id="resultNewPw"></p> <!-- 새 pw 유효성검사 -->
      </div>
      <div class="tr_pwUpdateVer">
        <input type="password" id="tr_newPwVer" name="tr_newPwVer" class="tr_newPwVer" placeholder="새 비밀번호 입력">
        <p id="resultNewPwVer"></p> <!-- 새 pw 일치여부 확인 -->
      </div>
      <div class="tr_emailUpdate">
        <input type="email" id="tr_newEmail" name="tr_newEmail" class="tr_newEmail" value="<%=email %>" placeholder="새 이메일 입력">
        <p id="resultNewEmail"></p> <!-- 새 email 유효성검사 -->
      </div>
      <div class="tr_phoneUpdate">
        <input type="text" id="tr_newPhone" name="tr_newPhone" class="tr_newPhone" value="<%=phone %>" placeholder="휴대폰 번호('-'제외 숫자만 입력)">
        <p id="resultNewPhone"></p> <!-- phone 유효성검사 -->
      </div>
      <button type="submit" id="updateBtn"> 회원 정보 수정</button>
    </form>
    <%
		}catch (SQLException ex){
		out.println("오류가 발생했습니다<br>");
		out.println("SQLException: "+ex.getMessage());
		} finally{
		 if(rs!=null)
		  rs.close();
		 if(pstmt!=null)
		  pstmt.close();
		 if(conn!=null)
		  conn.close();
		}
		%>
  </div>
  <script src="js/updateMem.js"></script>
</body>
</html>