$(document).ready(function () {
 //랜덤 배경이미지


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