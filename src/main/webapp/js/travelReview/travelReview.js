// travelReview.js

// 장소 선택 (왼쪽 사이드바 클릭)
function selectPlace(element) {
    const reviewNo = element.getAttribute('data-review-no');
    
    // 이미 작성된 리뷰라면 상세 페이지로 이동 (파일명 확인!)
    if (reviewNo) {
        location.href = 'travelReviewDetail.jsp?reviewNo=' + reviewNo;
        return; 
    }

    // 활성화 스타일 처리
    document.querySelectorAll('.place-item').forEach(item => item.classList.remove('active'));
    element.classList.add('active');

    // 데이터 가져오기
    const planNo = element.getAttribute('data-plan-no');
    const title = element.getAttribute('data-title');
    const day = element.getAttribute('data-day');

    // 오른쪽 폼에 데이터 세팅
    document.getElementById('input-plan-no').value = planNo;
    document.getElementById('display-place-name').innerText = title;
    document.getElementById('display-place-day').innerText = 'Day ' + day;

    // 화면 전환 (안내문구 숨기고 폼 보이기)
    document.getElementById('empty-view').style.display = 'none';
    document.getElementById('review-form-view').style.display = 'block';

    // 폼 초기화
    document.getElementById('reviewForm').reset();
    document.getElementById('image-preview-area').innerHTML = '';
    setRating(5); // 별점 5점으로 초기화
}

// 별점 기능
function setRating(score) {
    document.getElementById('input-rating').value = score;
    const stars = document.querySelectorAll('.star');
    
    stars.forEach(star => {
        const val = parseInt(star.getAttribute('data-value'));
        if (val <= score) {
            star.classList.add('filled');
            star.innerText = '★';
        } else {
            star.classList.remove('filled');
            star.innerText = '☆';
        }
    });
}

// 이미지/동영상 미리보기 기능
let selectedFiles = []; // 파일 객체 저장용 배열

function handleFiles(input) {
    const files = Array.from(input.files);
    const previewArea = document.getElementById('image-preview-area');

    files.forEach(file => {
        selectedFiles.push(file); // 배열에 추가

        const reader = new FileReader();
        reader.onload = function(e) {
            const div = document.createElement('div');
            div.className = 'preview-box';
            
            // 파일 타입 확인 (이미지 or 비디오)
            if (file.type.startsWith('video/')) {
                div.innerHTML = `
                    <video src="${e.target.result}" controls style="width:100%; height:100%; object-fit:cover;"></video>
                    <button type="button" class="btn-remove-img" onclick="removeImage(this, '${file.name}')">×</button>
                `;
            } else {
                div.innerHTML = `
                    <img src="${e.target.result}">
                    <button type="button" class="btn-remove-img" onclick="removeImage(this, '${file.name}')">×</button>
                `;
            }
            previewArea.appendChild(div);
        };
        reader.readAsDataURL(file);
    });
}

function removeImage(btn, fileName) {
    btn.parentElement.remove();
    selectedFiles = selectedFiles.filter(f => f.name !== fileName);
}

// 후기 저장 (AJAX)
function submitReview() {
    const form = document.getElementById('reviewForm');
    const formData = new FormData(form);

    selectedFiles.forEach(file => {
        formData.append('images', file);
    });

    $.ajax({
        url: 'saveReviewAction.jsp', 
        type: 'POST',
        data: formData,
        processData: false, 
        contentType: false, 
        success: function(res) {
            if(res.trim() === 'success') {
                alert("후기가 저장되었습니다!");
                location.reload(); 
            } else {
                alert("저장 실패: " + res);
            }
        },
        error: function() {
            alert("서버 통신 오류");
        }
    });
}