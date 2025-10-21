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
const body = $('body')

const randomIndex = Math.floor(Math.random() * backgrounds.length);
body.css({"backgroundImage" : backgrounds[randomIndex], 
          "backgroundSize" : "cover",
          "backgroundRepeat" : "no-repeat",
          "backgroundPosition" : "center"
});

//아이디 찾기에서 이메일을 입력하지 않았을 때
const tr_formId = $('#tr_formId');
const email_findId = $('.email_findId')
const tr_findIdBtn = $('#tr_findIdBtn');
tr_formId.on("submit", (e) => {
  e.preventDefault();
  if(email_findId.val().trim() == ""){
    alert("이메일을 입력해주세요!");
    return;
  } else {
    tr_formId.submit();
  }
});

//비밀번호 찾기에서 필드가 하나라도 비어 있는 경우
const tr_formPw = $('#tr_formPw');
const id_findPw = $('.id_findPw')
const email_findPw = $('.email_findPw');
tr_formPw.on("submit", (e) => {
  e.preventDefault();
  if(id_findPw.val().trim() === "" && email_findPw.val().trim() === ""){
    alert("아이디와 이메일을 입력해주세요!");
  } else if(id_findPw.val().trim() === ""){
    alert("아이디를 입력해주세요!");
  } else if(email_findPw.val().trim() === ""){
    alert("이메일을 입력해주세요!");
  } else{
    tr_formPw.submit();
  }
});
});