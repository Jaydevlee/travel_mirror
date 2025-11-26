let password = document.getElementById('password');
let password_confirm = document.getElementById('password_confirm');
let name = document.getElementById('name');
let email = document.getElementById('email');
let phone = document.getElementById('phone');

function validatePw() {
    const password_test = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[!.@#$%^&*])[A-Za-z\d!@#$%^&*]{6,12}$/.test(password.value);
    return password_test;
}

function validatePw_confirm() {
    return password.value === password_confirm.value;
}

function validateEmail() {
    const email_test = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(email.value);
    return email_test;
}

function validatePhone() {
    const phone_test = /^01([0|1|6|7|8|9])[-]?\d{3,4}[-]?\d{4}$/.test(phone.value);
    return phone_test;
}

function updateValid() {
    
    if (!validatePw()) {
        alert("유효하지 않은 비밀번호입니다. (영문+숫자+특수문자 6~12자)");
        return false;
    }

    // 비밀번호 동일 여부만 체크해야 함
    if (!validatePw_confirm()) {
        alert("비밀번호가 일치하지 않습니다.");
        return false;
    }

    if (!validateEmail()) {
        alert("유효하지 않은 이메일입니다.");
        return false;
    }

    if (!validatePhone()) {
        alert("유효하지 않은 전화번호입니다.");
        return false;
    }

    return true;
}
