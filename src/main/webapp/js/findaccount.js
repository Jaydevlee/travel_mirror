$(document).ready(function () {


//html body의 class 속성 값 가져와서 html마다 동작 다르게 하기
const bodyClass = $('body').attr('class');


/*-------------------  여기서 부터 tr_findaccount.html -------------------- */
//tr_findaccount.html 일 때
if(bodyClass === "tr_findaccount"){
/*-------------------계정찾기(아이디 찾기) -------------------- */
//아이디 찾기에서 이메일을 입력하지 않았을 때
const tr_formId = $('#tr_formId');
const email_findId = $('.email_findId');
tr_formId.on("submit", () => {
  if(email_findId.val().trim() == ""){
    alert("이메일을 입력해주세요!");
    return false;
  } else {
    return true;
  }
});
//js에서 DB에서 찾은 ID를 받아올 수 없기 때문에 ID를 알려주는 alert는 JSP페이지에 있음

/*-------------------계정찾기(비밀번호 찾기) -------------------- */
//비밀번호 찾기에서 필드가 하나라도 비어 있는 경우
const tr_formPw = $('#tr_formPw');
const id_findPw = $('.id_findPw')
const email_findPw = $('.email_findPw');
tr_formPw.on("submit", () => {
  if(id_findPw.val().trim() === "" && email_findPw.val().trim() === ""){
    alert("아이디와 이메일을 입력해주세요!");
    return false;
  }
  if(id_findPw.val().trim() === ""){
    alert("아이디를 입력해주세요!");
    return false;
  }
  if(email_findPw.val().trim() === ""){
    alert("이메일을 입력해주세요!");
    return false;
  } else {
		return true;
	}
  });
}
/*------------------- 여기까지 tr_findaccount.html -------------------- */




/*------------------- 여기서부터 tr_resetPassWord.html -------------------- */
  //tr_resetPassword.html 일 때
  if(bodyClass === "tr_resetPw"){

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
  const tr_resultNewVerPw = $('#tr_resultNewPwVer'); //비밀번호 확인 결과 표시 부분
  function resetVerifyPw(){
    if (tr_resetPwVerInput.val().trim() === "") return;
    if(tr_resetPwVerInput.val() == tr_resetPwInput.val()){
      tr_resultNewVerPw.html("비밀번호가 일치해요!");
      tr_resultNewVerPw.css("color", "green");
      return true;
    } else {
      tr_resultNewVerPw.html("비밀번호가 일치하지 않아요!");
      tr_resultNewVerPw.css("color", "#A50000");
      return false;
    };
  }
  tr_resetPwVerInput.on('input', resetVerifyPw);
  

  tr_resetForm.on("submit", () => {
    const newPassword = tr_resetPwInput.val().trim();
    const verifyPassword = tr_resetPwVerInput.val().trim();
    if(newPassword === "" || verifyPassword === ""){
      alert("비밀번호를 입력해주세요!");
      return false;
    } else if(newPassword !== verifyPassword){
      alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
      return false;
    }else{
			return true;
		}
    
});
}
});
/*------------------- 여기까지 tr_resetPassWord.html -------------------- */
