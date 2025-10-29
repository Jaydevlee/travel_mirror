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


const randomIndex = Math.floor(Math.random() * backgrounds.length);
$('body').css({"backgroundImage" : backgrounds[randomIndex], 
          "backgroundSize" : "cover",
          "backgroundRepeat" : "no-repeat",
          "backgroundPosition" : "center"
});

//html body의 class 속성 값 가져와서 html마다 동작 다르게 하기
const bodyClass = $('body').attr('class');


/*-------------------  여기서 부터 tr_findaccount.html -------------------- */
//tr_findaccount.html 일 때
if(bodyClass === "tr_findaccount"){
/*-------------------계정찾기(아이디 찾기) -------------------- */
//아이디 찾기에서 이메일을 입력하지 않았을 때
const tr_formId = $('#tr_formId');
const email_findId = $('.email_findId');
tr_formId.on("submit", (e) => {
  e.preventDefault();
  if(email_findId.val().trim() == ""){
    alert("이메일을 입력해주세요!");
    return;
  } else {
    //이메일 입력 시 기존 회원정보에서 이메일과 일치하는 아이디 찾기
    //회원정보 불러오기
    const users = JSON.parse(localStorage.getItem('users')) || [];
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

/*-------------------계정찾기(비밀번호 찾기) -------------------- */
//비밀번호 찾기에서 필드가 하나라도 비어 있는 경우
const tr_formPw = $('#tr_formPw');
const id_findPw = $('.id_findPw')
const email_findPw = $('.email_findPw');
tr_formPw.on("submit", (e) => {
  e.preventDefault();
  if(id_findPw.val().trim() === "" && email_findPw.val().trim() === ""){
    alert("아이디와 이메일을 입력해주세요!");
    return
  }
  if(id_findPw.val().trim() === ""){
    alert("아이디를 입력해주세요!");
    return;
  }
  if(email_findPw.val().trim() === ""){
    alert("이메일을 입력해주세요!");
    return;
  } 

  //회원정보에서 아이디와 이메일이 일치하는 사용자 찾기
  const users = JSON.parse(localStorage.getItem('users')) || [];
  const inputId = id_findPw.val().trim();
  const inputEmail = email_findPw.val().trim();
  const matchedUser = users.find(user => 
    user.id === inputId && user.email === inputEmail);
  if(matchedUser){
    // 아이디와 이메일을 세션에 저장
    sessionStorage.setItem('resetId', inputId);
    sessionStorage.setItem('resetEmail', inputEmail);
    location.href = "tr_resetPassword.html";
  } else {
    alert("입력하신 아이디와 이메일이 일치하는 비밀번호가 없습니다.");
  }
  });
}
/*------------------- 여기까지 tr_findaccount.html -------------------- */




/*------------------- 여기서부터 tr_resetPassWord.html -------------------- */
  //tr_resetPassword.html 일 때
  if(bodyClass === "tr_resetPw"){

  //sessionStorage 값 불러오기
  const inputId = sessionStorage.getItem('resetId');
  const inputEmail = sessionStorage.getItem('resetEmail');
  //비밀번호 재설정 폼
  const tr_resetForm = $('#tr_resetForm'); 
  const tr_resetPwInput = $('#tr_newPw'); //비밀번호 재설정 입력창
  const tr_resultNewPw = $('#tr_resultNewPw'); //비밀번호 유효성 검사 결과
  const tr_resetPwReg = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!.@#$%^&*])[a-zA-Z\d!@#$%^&*]{7,20}$/;
  function resetPwCheck(){  
    if(tr_resetPwReg.test(tr_resetPwInput.val())){
      tr_resultNewPw.html("");
      tr_resultNewPw.css("color", "");
      return true;
    } else {
      tr_resultNewPw.html("PW는 영문자와 숫자, 특수문자를 포함한 7자이상 20자 이내여야 합니다.");
      tr_resultNewPw.css("color", "#A50000");
      return false;
    }
  };
  tr_resetPwInput.on('input', resetPwCheck);

  //비밀번호 확인 일치여부
  const tr_resetPwVerInput = $('#tr_newPwVer'); //비밀번호 재설정 확인 입력창
  const tr_resultVerPw = $('#tr_resultVerPw'); //비밀번호 확인 결과 표시 부분
  function resetVerifyPw(){
    if (tr_resetPwVerInput.val().trim() === "") return;
    if(tr_resetPwVerInput.val() == tr_resetPwInput.val()){
      tr_resultVerPw.html("비밀번호가 일치해요!");
      tr_resultVerPw.css("color", "green");
      return true;
    } else {
      tr_resultVerPw.html("비밀번호가 일치하지 않아요!");
      tr_resultVerPw.css("color", "#A50000");
      return false;
    };
  }
  tr_resetPwVerInput.on('input', resetVerifyPw);
  

  tr_resetForm.on("submit", (e) => {
    e.preventDefault();
    const newPassword = tr_resetPwInput.val().trim();
    const verifyPassword = tr_resetPwVerInput.val().trim();
    if(newPassword === "" || verifyPassword === ""){
      alert("비밀번호와 비밀번호 확인을 입력해주세요!");
      return;
    } else if(newPassword !== verifyPassword){
      alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
      return;
    };
    if(resetPwCheck() && resetVerifyPw()){
      //회원 정보 불러오기
      let users = JSON.parse(localStorage.getItem('users')) || [];
      //비밀번호 재설정할 사용자 찾기
      const id = inputId;
      const email = inputEmail;
      const userIndex = users.findIndex(user => 
        user.id === id && user.email === email);
      
    if(userIndex === -1){
      alert("해당 회원을 찾을 수 없습니다.");
      return;
    }

    // 비밀번호 변경
    users[userIndex].pw = newPassword;

    // 변경된 users 배열 다시 저장+

    localStorage.setItem('users', JSON.stringify(users));

    alert("비밀번호가 성공적으로 변경되었습니다!");

    sessionStorage.removeItem('resetId');
    sessionStorage.removeItem('resetEmail');

    location.href = "firstPage.html"; //로그인 페이지 이동
    }
});
}
});
/*------------------- 여기까지 tr_resetPassWord.html -------------------- */
