$(document).ready(function () {


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
const emailReg = /^[0-9a-zA-Z]([._-]?[0-9a-zA-Z])*@[0-9a-zA-Z]([._-]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/;     //email정규식
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
const tr_phoneUpdate = $('#tr_newPhone');  //전화번호 입력창 지정
const resultNewPhone = $("#resultNewPhone");  //전화번호 유효성 결과 표시
const phoneReg = /^01[016789]\d{7,8}$/;     //전화번호 정규식
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
    
    // 유효성 검사 다시 실행
    const pwValid = pwCheck();
    const pwVerValid = verifyPw();
		const emailValid = emailCheck();
		const phoneValid = phoneCheck();

    if (!pwValid) {
        alert("비밀번호 형식이 올바르지 않습니다!");
        e.preventDefault();
        return false;
    }

    if (!pwVerValid) {
        alert("비밀번호가 일치하지 않습니다!");
        e.preventDefault();
        return false;
    }
		if (!emailValid) {
        alert("이메일양식이 올바르지 않습니다!");
        e.preventDefault();
        return false;
    }
		if (!phoneValid) {
        alert("전화번호 양식이 올바르지 않습니다!");
        e.preventDefault();
        return false;
    }

    return true;
});
// --------------------------------------------------------------------------------
//회원 탈퇴 버튼 클릭하면 confirm창 띄우기
$('#deleteMemBtn').on("click", function(e){
	e.preventDefault();
		if(confirm("탈퇴하시면 모든 데이터가 삭제되며 복구할 수 없습니다. 그래도 삭제하시겠습니까?")){
			location.href="deleteMem.jsp";
			return true;
		} return false;
	});
});