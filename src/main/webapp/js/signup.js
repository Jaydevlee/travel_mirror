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

//id 유효성 검사
const tr_id = $('#tr_id');  //아이디 입력창 지정
const resultId = $('#resultId');  // 유효성 결과 표시부분
const idReg = /^(?=.*[a-zA-Z])(?=.*\d)[a-z|A-Z\d]{5,20}$/; //id정규식
function idCheck(){
  if(idReg.test(tr_id.val())){
    resultId.html("");
    resultId.css("color", "");
    return true;
  } else {
    resultId.html("아이디는 영문자와 숫자포함 5자이상 20자 이내여야 합니다.");
    resultId.css("color", "#A50000");
    return false;
  }
};
tr_id.on('input', idCheck);
//id입력시 중복확인 초기화
tr_id.on('input', () => {
  isIdChecked = false;
});

// --------------------------------------------------------------------------------

//id중복확인
let isIdChecked = false; //const 사용X const 쓰면 false로 고정됨.
const dupCheck = $('#dupCheck'); //중복확인 버튼 지정
dupCheck.on('click', () => {
  if(!tr_id.val().trim()){
    alert("아이디를 입력하세요.");
    isIdChecked = false;
    return;
  }

//기존 회원가입된 정보 가져오기
const users = JSON.parse(localStorage.getItem('users')) || [];

const isDuplicate = users.some(user => user.id === tr_id.val());
if(isDuplicate){
  alert("이미 사용중인 아이디입니다.");
  isIdChecked = false;
} else {
   alert("사용가능한 아이디입니다.");
  isIdChecked = true;
  }
});

// --------------------------------------------------------------------------------

//pw유효성 검사
const tr_pw = $('#tr_pw'); //비밀번호 입력 지정
const resultPw = $("#resultPw"); //비밀번호 유효성 검사 결과 지정
const pwReg = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!.@#$%^&*])[a-z|A-Z\d!@#$%^&*]{7,20}$/; //pw정규식
function pwCheck(){  
  if(pwReg.test(tr_pw.val())){
    resultPw.html("");
    resultPw.css("color", "");
    return true;
  } else {
    resultPw.html("PW는 영문자와 숫자, 특수문자를 포함한 7자이상 20자 이내여야 합니다.");
    resultPw.css("color", "#A50000");
    return false;
  }
};
tr_pw.on('input', pwCheck);

//비밀번호 확인 일치여부
const tr_pwVer = $('#tr_pwVer');   //비밀번호 확인 입력창 지정
const resultPwVer = $("#resultPwVer"); //비밀번호 확인 결과 표시 부분
function verifyPw(){
  if (tr_pwVer.val().trim() === "") return;
  if(tr_pwVer.val() == tr_pw.val()){
    resultPwVer.html("비밀번호가 일치해요!");
    resultPwVer.css("color", "green");
    return true;
  } else {
    resultPwVer.html("비밀번호가 일치하지 않아요!");
    resultPwVer.css("color", "#A50000");
    return false;
  };
}
tr_pwVer.on('input', verifyPw);

// --------------------------------------------------------------------------------

//email 유효성 검사
const tr_email = $('#tr_email');  //이메일 입력창 지정
const resultEmail = $("#resultEmail");  //이메일 유효성 결과 표시
const emailReg = /^[a-z|A-Z|\d]+@[^\s가-힣]+\.[a-z|A-Z]{2,5}$/;     //email정규식
function emailCheck(){
  if(emailReg.test(tr_email.val())){
    resultEmail.html("");
    resultEmail.css("color", "");
    return true;
  } else {
    resultEmail.html("이메일 주소가 올바르지 않아요!");
    resultEmail.css("color", "#A50000");
    return false;
  }
};
tr_email.on('input', emailCheck);

// --------------------------------------------------------------------------------

//약관 팝업
const modal = $("#tr_termsModal");
const openBtn = $(".tr_terms a");
const closeBtn = $(".close");
//팝업 열기
openBtn.on("click", (e) => {
  e.preventDefault();
  modal.css("display", "block");
});
//팝업 닫기
closeBtn.on("click", () => {
  modal.css("display", "none");
})
//모달 바깥 클릭 시 닫기
$(window).on("click", (e) => {
  if (e.target === modal) {
    modal.css("display", "none");
  }
});

// --------------------------------------------------------------------------------

//회원가입버튼 이벤트
const form = $('form');
form.on('submit', (e) => {
  e.preventDefault();
  let terms = $('#tr_check');
  
  if(!isIdChecked){  //중복확인 하지 않고 버튼 누를 때 이벤트
    alert("아이디 중복확인을 해주세요.");
    return;
  }
  if(!terms.prop('checked')){ //약관에 동의하지 않았을 때 이벤트
    alert("필수 이용약관에 동의해주세요.");
    return;
  }
  if(idCheck() && pwCheck() && verifyPw() && emailCheck()){     
    //회원정보 저장 변수
    let users = JSON.parse(localStorage.getItem('users')) || []; //const 사용X
    //배열 형태로 보정
    if(!Array.isArray(users)){
      users = [];
    }
    //회원정보
    const userData = {
      id: tr_id.val(),
      pw: tr_pw.val(),
      email: tr_email.val()
    };

    users.push(userData);

    // 로컬 스토리지에 회원 정보 저장
    localStorage.setItem('users', JSON.stringify(users));

    // 세션 스토리지에 로그인 상태 유지 (사용자가 로그인한 상태로 처리)
    sessionStorage.setItem('isLoggedIn', 'true');

    alert("회원가입이 완료되었습니다!");

    // 회원가입 후 마이페이지 이동 
    window.location.href = '/mypage.jsp';
}
});
});