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

	//사진 변경 버튼 클릭하면 파일 선택창이 열림
$('#changePicBtn').on('click', ()=>{
	$('#profilePicFile').click();
});

// 파일 선택하고 미리보기 + 업로드
$('#profilePicFile').on('change', function(){
	
	let file=this.files[0];
	if(!file) return;
	
	//미리보기 
	let reader = new FileReader();
	reader.onload = function(e) {
		$('#tr_profilePreview').attr('src', e.target.result);
	};
	reader.readAsDataURL(file);
	
	//업로드 실행
	$('#uploadProfileForm').submit();
});
});