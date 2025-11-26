$(document).ready(function () {


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

//기존 회원가입된 정보 가져오기(DB에서 가져오기)
$.ajax({
	url:"dup_check.jsp",
	type: "post",
	data: {tr_id: tr_id.val()},
	success: function(response){
		if(response.trim() === "duplicate"){
			alert("이미 사용중인 아이디입니다.");
			isIdChecked = false;
		} else {
			alert("사용 가능한 아이디입니다.");
			isIdChecked = true;
		}
	},
	error: function(){
		alert("서버 오류가 발생했습니다.");
	}
})
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
const tr_name = $('#tr_name');
const resultName = $("#resultName");
const nameReg= /^[A-Za-z가-힣]+$/; 
function nameCheck(){  
  if(nameReg.test(tr_name.val())){
    resultName.html("");
    resultName.css("color", "");
    return true;
  } else {
    resultName.html("이름에 숫자를 포함할 수 없습니다.");
    resultName.css("color", "#A50000");
    return false;
  }
};
tr_name.on('input', nameCheck);


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
	//phone 유효성 검사
	const tr_phone = $('#tr_phone');  //전화번호 입력창 지정
	const resultPhone = $("#resultPhone");  //전화번호 유효성 결과 표시
	const phoneReg = /^01[016789]\d{7,8}$/;     //전화번호정규식
	function phoneCheck(){
	  if(phoneReg.test(tr_phone.val())){
	    resultPhone.html("");
	    resultPhone.css("color", "");
	    return true;
	  } else {
	    resultPhone.html("전화번호가 올바르지 않아요!");
	    resultPhone.css("color", "#A50000");
	    return false;
	  }
	};
	tr_phone.on('input', phoneCheck);
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
//모달 바깥 클릭 시 닫기s
$(window).on("click", (e) => {
  if (e.target === modal) {
    modal.css("display", "none");
  }
});

// --------------------------------------------------------------------------------

//회원가입버튼 이벤트 DB연결로 인한여 삭제 예정 localsession 다지워라
const form = $('form');
form.on('submit', () => {

  if(!isIdChecked){  //중복확인 하지 않고 버튼 누를 때 이벤트
    alert("아이디 중복확인을 해주세요.");
    return false;
  }
  if(!$('#tr_check').prop('checked')){ //약관에 동의하지 않았을 때 이벤트
    alert("필수 이용약관에 동의해주세요.");
    return false;
  }
  if(!idCheck() || !pwCheck() || !verifyPw() || !emailCheck() || !phoneCheck()){     
    alert("입력값을 다시 확인해주세요.");
		return false;
	}
	return true;
});
});