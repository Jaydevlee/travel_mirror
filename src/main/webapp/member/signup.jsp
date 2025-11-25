<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원가입</title>
  <script src='../js/jquery-3.7.1.min.js'></script>
  <link rel="stylesheet" href="../css/accountStyle.css">
</head>
<body class="tr_create">
<jsp:include page="/header.jsp" />
	<div class="tr_mainContainer">
  <div class="tr_signUpcontainer">
  	<div class="titleArea">
    <h1>회원가입</h1>
    <h2>Sign UP</h2>
    <p>막상 여행 계획을 짜려니 복잡하셨죠?<br> travel과 함께 편리하게 여행계획을 해보세요</p>
    </div>
      <div class="tr_signUp">
        <form action="process_signup.jsp" method="post">
          <div class="idInput">   <!-- 아이디 -->
            <input type="text" id="tr_id" name="tr_id" class="trInput" placeholder="아이디(영문자, 숫자포함5~15자)" required>
            <button type="button" id="dupCheck">중복확인</button>
             <!-- 중복확인 버튼 iput안에 -->
            <p id="resultId"></p> <!-- id 유효성검사 -->
          </div>
          <div class="pwInput">    <!-- 비밀번호 -->
            <input type="password" id="tr_pw" name="tr_pw" class="trInput" placeholder="비밀번호(영대소문자, 숫자 및 특수문자 포함 7~20자)">
            <p id="resultPw"></p> <!-- pw 유효성검사 -->
            </div>
          <div class="pwVerInput">  <!-- 비밀번호 확인 -->
            <input type="password" id="tr_pwVer" name="tr_pwVer" class="trInput" placeholder="비밀번호 확인">
            <p id="resultPwVer"></p> <!-- pw 확인 검사 -->
          </div>
          <div class="nameInput">  
            <input type="text" id="tr_name" name="tr_name" class="trInput" placeholder="이름">
            <p id="resultName"></p> <!-- name 유효성검사 -->
          </div>
          <div class="emailInput"> <!-- 이메일 -->
            <input type="email" id="tr_email" name="tr_email" class="trInput" placeholder="이메일">
            <p id="resultEmail"></p> <!-- email 유효성검사 -->
          </div>
          <div class="phoneInput">
            <input type="text" id="tr_phone" name="tr_phone" class="trInput" placeholder="휴대폰 번호('-'제외 숫자만 입력)">
            <p id="resultPhone"></p> <!-- phone 유효성검사 -->
          </div>
          <div class="tr_terms">
            <input type="checkbox" id="tr_check" name="agree" value="agree"><label for="tr_check">
            필수 이용약관 동의 <a href="#">(전문보기)</a></label> 
          </div>
          <button type="submit" id="signUpBtn">회원가입</button>
        </form>
      </div>  
  </div>
  </div>
   <!-- 약관 모달 -->
    <div id="tr_termsModal" class="modal">
      <div class="modal-content">
        <span class="close">&times;</span>
        <h4>제1조 (목적)</h4>
        <p>본 약관은 travel(이하"웹사이트")에서 제공하는 서비스(이하"서비스")를 이용함에 있어서 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.</p>

        <h4>제2조 (용어의 정의)</h4>
        <p>본 약관에서 사용하는 용어의 정의는 다음과 같습니다.</p>
          <ol>
            <li>"이용자"란 "웹사이트"에 접속하여 서비스를 이용하는 회원을 말합니다.</li>
            <li>
              "웹사이트"란 회사가 재화 또는 용역을 이용자에게 제공하기 위해 정보통신설비를 이용하여
              재화 또는 용역을 거래할 수 있도록 설정한 가상의 영업장을 말합니다.
            </li>
          </ol>

        <h4>제3조 (약관의 공시 및 효력과 변경)</h4>
          <ol>
            <li>본 약관은 회원가입 화면에 게시하며 회사는 사정변경 등의 사유가 있을 경우 약관을 변경할 수 있으며
                변경된 약관은 공지사항을 통해 공시한다.
            </li>
            <li>본 약관 및 차후 회사사정에 따라 변경된 약관은 이용자에게 공시함으로써 효력을 발생한다.</li>
          </ol>

        <h4>제4조 (약관외 준칙)</h4>
        <p>
          본 약관에 명시되지 않은 사항이 전기통신기본법, 소비자보호법, 약관의 규제에 관한 법률 등 기타 관계
          법령에 규정되어 있을 경우에는 그 규정을 따르도록 한다.
        </p>

         <h4>제5조 (회원가입)</h4>
          <ol>
            <li>
                이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후
                이 약관에 동의함으로써 회원가입을 신청합니다.
            </li>
            <li>
              회사는 다음 각 호에 해당하지 않는 한 회원으로 등록합니다.
               <ol>
                <li>가입 신청자가 본 약관에 의하여 이전에 회원자격을 상실한 적이 있는 경우</li>
                <li>등록 내용에 허위, 기재누락, 오기가 있는 경우</li>
                <li>기타 회원으로 등록하는 것이 회사의 기술상 현저히 지장이 있다고 판단되는 경우</li>
              </ol>
            </li>
          </ol>
          <h4>제6조 (회원 탈퇴 및 자격 상실 등)</h4>
          <ol>
            <li>
                회원은 언제든지 회사에 회우너 탈퇴를 요청할 수 있으며, 회사는 지체 없이 회원탈퇴를 처리합니다.
            </li>
            <li>
              회사는 회원이 다음 각 호에 해당하는 경우, 회원자격을 제한 또는 상실시킬 수 있습니다.
               <ol>
                <li>가입 신청 시에 허위 내용을 등록한 경우</li>
                <li>서비스 이용과 관련하여 부당한 행위를 한 경우</li>
                <li>타인의 권리나 명예를 침해하거나 법령을 위반한 경우</li>
              </ol> 
              </li>      
          </ol>  
          <h4>제7조 (서비스의 제공 및 변경)</h4>
          <ol>
            <li>
                회사는 다음과 같은 업무를 수행하며, 필요 시 그 내용을 변경할 수 있습니다.
                <ol>
                  <li>재화 또는 용역에 대한 정보 제공 및 구매계약의 체결</li>
                  <li>구매계약이 체결된 재화 또는 용역의 배송</li>
                 <li>기타 회사가 정하는 업무</li>
              </ol>
            </li>
          </ol>  
      </div>
    </div>
  <script src="../js/signup.js"></script>
</body>
</html>