$(document).ready(function () {
 //랜덤 배경이미지
let backgrounds = [
  "url('img/travel1.jpg')",
  "url('img/travel2.jpg')",
  "url('img/travel3.jpg')",
  "url('img/travel4.jpg')",
  "url('img/travel5.jpg')",
  "url('img/travel6.jpg')",
  "url('img/travel7.jpg')",
  "url('img/travel8.jpg')",
  "url('img/travel9.jpg')",
  "url('img/travel10.jpg')",
  "url('img/travel11.jpg')",
  "url('img/travel12.jpg')",
]
const body = $('body');
const randomIndex = Math.floor(Math.random() * backgrounds.length);
body.css({"backgroundImage" : backgrounds[randomIndex], 
          "backgroundSize" : "cover",
          "backgroundRepeat" : "no-repeat",
          "backgroundPosition" : "center"
  });

// --------------------------------------------------------------------------------
//pw유효성 검사
const tr_newPw = $('#tr_newPw'); //비밀번호 입력 지정
const resultNewPw = $("#resultNewPw"); //비밀번호 유효성 검사 결과 지정
const pwReg = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!.@#$%^&*])[a-z|A-Z\d!@#$%^&*]{7,20}$/; //pw정규식
function pwCheck(){  
  if(pwReg.test(tr_newPw.val())){
    resultNewPw.html("");
    resultNewPw.css("color", "");
    return true;
  } else {
    resultNewPw.html("PW는 영문자와 숫자, 특수문자를 포함한 7자이상 20자 이내여야 합니다.");
    resultNewPw.css("color", "#A50000");
    return false;
  }
};
tr_newPw.on('input', pwCheck);

//비밀번호 확인 일치여부
const tr_newPwVer = $('#tr_newPwVer');   //비밀번호 확인 입력창 지정
const resultNewPwVer = $("#resultNewPwVer"); //비밀번호 확인 결과 표시 부분
function verifyPw(){
  if (tr_newPwVer.val().trim() === "") {
    resultNewPwVer.html("비밀번호를 확인해주세요!");
    resultNewPwVer.css("color", "#A50000");
    return false;
  }
  if (tr_newPwVer.val() == tr_newPw.val()) {
    resultNewPwVer.html("비밀번호가 일치해요!");
    resultNewPwVer.css("color", "green");
    return true;
  } else {
    resultNewPwVer.html("비밀번호가 일치하지 않아요!");
    resultNewPwVer.css("color", "#A50000");
    return false;
  }
}
tr_newPwVer.on('input', verifyPw);

// --------------------------------------------------------------------------------

//email 유효성 검사
const tr_newEmail = $('#tr_newEmail');  //이메일 입력창 지정
const resultNewEmail = $("#resultNewEmail");  //이메일 유효성 결과 표시
const emailReg = /^[a-zA-Z\d]+@[^\s가-힣]+\.[a-zA-Z]{2,5}$/;     //email정규식
function emailCheck(){
  if(emailReg.test(tr_newEmail.val())){
    resultNewEmail.html("");
    resultNewEmail.css("color", "");
    return true;
  } else {
    resultNewEmail.html("이메일 주소가 올바르지 않아요!");
    resultNewEmail.css("color", "#A50000");
    return false;
  }
};
tr_newEmail.on('input', emailCheck);
// --------------------------------------------------------------------------------
	//phone 유효성 검사
const tr_phoneUpdate = $('#tr_newPhone');  //이메일 입력창 지정
const resultNewPhone = $("#resultNewPhone");  //이메일 유효성 결과 표시
const phoneReg = /^01[016789]\d{7,8}$/;     //email정규식
function phoneCheck(){
  if(phoneReg.test(tr_phoneUpdate.val())){
    resultNewPhone.html("");
    resultNewPhone.css("color", "");
    return true;
  } else {
    resultNewPhone.html("전화번호가 올바르지 않아요!");
    resultNewPhone.css("color", "#A50000");
    return false;
  }
};
tr_phoneUpdate.on('input', phoneCheck);

// --------------------------------------------------------------------------------

$('#updateForm').on("submit", function(e){
    
    // 비밀번호 유효성 검사도 다시 실행
    const pwValid = pwCheck();
    const pwVerValid = verifyPw();

    if (!pwValid) {
        alert("비밀번호 형식이 올바르지 않습니다.");
        e.preventDefault();
        return false;
    }

    if (!pwVerValid) {
        alert("비밀번호 확인 칸을 정확히 입력해야 수정할 수 있습니다.");
        e.preventDefault();
        return false;
    }

    return true;
});
});