// travelReviewDetail.js - 상세 보기 페이지 기능

// 위시리스트(찜하기) 토글 함수
function toggleWish(reviewNo) {
    $.ajax({
        url: 'toggleWishAction.jsp',
        type: 'POST',
        data: { reviewNo: reviewNo },
        success: function(res) {
            const result = res.trim();
            if (result === 'saved') {
                alert("가보고 싶은 곳에 저장되었습니다! 💖");
                location.reload(); // 버튼 색상 변경을 위해 새로고침
            } else if (result === 'removed') {
                alert("저장이 취소되었습니다.");
                location.reload();
            } else {
                alert("로그인이 필요합니다.");
            }
        },
        error: function() {
            alert("오류가 발생했습니다.");
        }
    });
}

// 리뷰 삭제 함수
function deleteReview(reviewNo) {
    if (confirm('정말 삭제하시겠습니까? (복구할 수 없습니다)')) {
        location.href = 'deleteReviewAction.jsp?reviewNo=' + reviewNo;
    }
}