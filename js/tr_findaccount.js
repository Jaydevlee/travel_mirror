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
    //이메일 입력 시 기존 회원정보에서 이메일과 일치하는 아이디 찾기
    //회원정보 불러오기
    let users = JSON.parse(localStorage.getItem('users')) || [];
    //이메일 입력값 저장
    const inputEmail = email_findId.val().trim();
    //이메일과 일치하는 사용자 찾기
    const matchedUser = users.find(user => user.email === inputEmail);
    if(matchedUser){
      alert(`회원님의 아이디는 ${matchedUser.id} 입니다.`);
    } else {
      alert("입력하신 이메일과 일치하는 아이디가 없습니다.");
    }
  }
  });

//비밀번호 찾기에서 필드가 하나라도 비어 있는 경우
const tr_formPw = $('#tr_formPw');
const id_findPw = $('.id_findPw')
const email_findPw = $('.email_findPw');

//비밀번호 찾기(재생성을 연결할 예정이지만 우선은 기존 비밀번호를 알려주는 방식으로 구현)
tr_formPw.on("submit", (e) => {
  e.preventDefault();
  if(id_findPw.val().trim() === "" && email_findPw.val().trim() === ""){
    alert("아이디와 이메일을 입력해주세요!");
  } else if(id_findPw.val().trim() === ""){
    alert("아이디를 입력해주세요!");
  } else if(email_findPw.val().trim() === ""){
    alert("이메일을 입력해주세요!");
  } else{
    let users = JSON.parse(localStorage.getItem('users')) || [];
    const inputId = id_findPw.val().trim();
    const inputEmail = email_findPw.val().trim();
    const matchedUser = users.find(user => user.id === inputId && user.email === inputEmail);
    if(matchedUser){
      alert(`회원님의 비밀번호는 ${matchedUser.pw} 입니다.`);
      //비밀번호 재설정 페이지(window.location.href = 'tr_resetpassword.html';)로 이동하는 방식으로 변경 예정
    } else {
      alert("입력하신 아이디와 이메일과 일치하는 비밀번호가 없습니다.");
    }
  }
});
});