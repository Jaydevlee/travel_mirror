<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FristPage</title>
    <script src='js/jquery-3.7.1.min.js'></script>
    <link rel="stylesheet" href="css/firstPage.css">
    <link rel="preload" href="img/bg/bg_1.jpg" as="image">
    <link rel="preload" href="img/bg/bg_2.jpg" as="image">
    <link rel="preload" href="img/bg/bg_3.jpg" as="image">
    <link rel="preload" href="img/bg/bg_4.jpg" as="image">
</head>
<body>
    <div id="totalForm">
        <h1>Travel</h1>
    <div id="register">
        <form action="login/processlogin_page.jsp" onsubmit="return confirmvalid()" method="post">
            <p>아이디</p>
            <input type="text" name="tr_id" id="tr_id">
            <div id="id_warring"></div>
            <p>비밀번호</p>
            <input type="password" name="tr_psw" id="tr_psw">
            <div id="psw_warring"></div>
            <div id="reg_box">
                <p class="reg"><a href="signup.jsp">회원가입</a></p>
                <p class="reg"><a href ="findaccount.jsp">아이디 / 비밀번호 찾기</a></p>
            </div>
            <button type="submit" id="login_btn">로그인</button>
        </form>
    </div>
    </div>
    <script src="js/login.js"></script>
</body>
</html>