// review-actions.js - 리뷰 CRUD 액션 핸들러

// 리뷰 작성 완료
function handleReviewSubmit($li) {
    const trSubject = $li.find('.tr_subject').val().trim();
    const trPlaceName = $li.find('.tr_placeName').val().trim();
    const trAddress = $li.find('.tr_addr').val();
    const trRatingVal = Number($li.find('.tr_ratingVal').val());
    const content = $li.find('.text_area').val().trim();
    const location = $li.data('location');
// 1026 같은 장소는 한 카드로 묶고(place_group), 그 카드 안에서 별점으로 필터링하기 위해서 // 
    //1026 장소키 생성, 추가 // 
    const placeId = window.makePlaceId ? window.makePlaceId(location) : '';

    // 유효성 검사
    if (!trSubject) {
        alert('장소명을 입력해주세요.');
        return false;
    }
    if (trRatingVal === 0) {
        alert('별점을 선택해주세요.');
        return false;
    }
    if (!content) {
        alert('후기 내용을 작성해주세요.');
        return false;
    }
    
    const images = [];
    $li.find('.file_preview img').each(function() {
        images.push($(this).attr('src'));
    });
    
    const reviewData = {
        tr_subject: trSubject,
        tr_placeName : trPlaceName,
        tr_address: trAddress,
        tr_ratingVal: trRatingVal,
        content,
        images,
        location,
        placeId //1026 위에 추가한 장소키 생성 데이터 저장 
    };
    console.log(reviewData);
    
     // 1026 수정, 뷰 폼으로 전환을 그룹에 삽입으로 변경//

        // 리뷰 저장
        const savedReview = ReviewStorage.save(reviewData);

        // 그룹 밑으로 삽입
        const $viewLi = createViewForm(savedReview);
        const $group = window.ensurePlaceGroup ? window.ensurePlaceGroup(savedReview) : null;

        if ($group && $group.length) {
        $group.find('.group_reviews').prepend($viewLi);
        $li.remove(); // 작성 li 제거
        } else { // 그룹이 안된다면 그대로
        $li.replaceWith($viewLi);
        }

        alert('후기가 작성되었습니다.');
        return true;
}

// 리뷰 작성 취소
function handleReviewCancel($li) {
    if ($li.data('mode') === 'write') {
        if (confirm('작성을 취소하시겠습니까?')) {
            $li.remove();
            return true;
        }
    }
    return false;
}

// 리뷰 수정 모드로 전환
function handleReviewEdit($li) {
    const reviewId = $li.data('review-id');
    const review = ReviewStorage.getById(reviewId);
    
    if (!review) {
        console.error('리뷰를 찾을 수 없습니다:', reviewId);
        return false;
    }
    
    const $editForm = createEditForm(review);
    $li.replaceWith($editForm);
    
    // 별점 UI 업데이트
    const $starForm = $editForm.find('.tr_starForm');
    const $stars = $starForm.find('.tr_starBox button[data-val]');
    const $hidden = $starForm.find('.tr_ratingVal');
    
    setTimeout(() => {
        if (window.paintStars) {
            window.paintStars($stars, $hidden, review.tr_ratingVal);
        }
    }, 100);
    
    return true;
}

// 리뷰 수정 완료
function handleReviewUpdate($li) {
    const reviewId = $li.data('review-id');
    const trSubject = $li.find('.tr_subject').val().trim();
    const trRatingVal = Number($li.find('.tr_ratingVal').val());
    const content = $li.find('.text_area').val().trim();
    
    // 유효성 검사
    if (!trSubject || trRatingVal === 0 || !content) {
        alert('모든 항목을 입력해주세요.');
        return false;
    }
    
    // 기존 이미지 처리
    let existingImages = $li.data('existingImages') || [];
    const imagesToRemove = $li.data('imagesToRemove') || [];
    existingImages = existingImages.filter((img, idx) => !imagesToRemove.includes(idx));
    
    // 새 이미지 추가
    const newImages = [];
    $li.find('.file_preview img').each(function() {
        newImages.push($(this).attr('src'));
    });
    
    const allImages = [...existingImages, ...newImages];
    
    // 리뷰 업데이트
    const updatedReview = ReviewStorage.modify(reviewId, {
        tr_subject: trSubject,
        tr_ratingVal: trRatingVal,
        content,
        images: allImages
    });
      // 1026 수정 하고도 해당 그룹(같은 장소)으로 가게//
        if (updatedReview) {
            const $viewLi = createViewForm(updatedReview);
            const $group = window.ensurePlaceGroup ? window.ensurePlaceGroup(updatedReview) : null;

        $li.replaceWith($viewLi);
         if ($group && !$viewLi.closest('.group_reviews').length) {
            $group.find('.group_reviews').prepend($viewLi);
        }

        alert('수정되었습니다.');
        return true;
     }
    return false;
}

// 리뷰 수정 취소
function handleReviewEditCancel($li) {
    const reviewId = $li.data('review-id');
    const review = ReviewStorage.getById(reviewId);
    
    if (review) {
        const $viewLi = createViewForm(review);
        $li.replaceWith($viewLi);
        return true;
    }
    return false;
}

// 리뷰 삭제
function handleReviewDelete($li) {
    const reviewId = $li.data('review-id');
    // 1026 삭제시, 비어있는 그룹은 정리하기 //
    
    if (confirm('정말 삭제하시겠습니까?')) {
        const result = ReviewStorage.delete(reviewId);
        console.log('삭제 결과:', result);

        // 그룹 참조 확보 후 삭제
        const $group = $li.closest('li.place_group');
        $li.remove();

        // 그룹이 비면 (아무 리뷰가 없으면) 제거
        if ($group.length && $group.find('.group_reviews > li[data-mode="view"]').length === 0) {
            $group.remove();
        }

        alert('삭제되었습니다.');
        return true;
    }
    return false;
}

// 기존 이미지 삭제 (수정 모드)
function handleExistingImageRemove($btn) {
    const idx = Number($btn.data('index'));
    const $li = $btn.closest('li');
    const imagesToRemove = $li.data('imagesToRemove') || [];
    
    imagesToRemove.push(idx);
    $li.data('imagesToRemove', imagesToRemove);
    
    $btn.closest('.image_item').remove();
}