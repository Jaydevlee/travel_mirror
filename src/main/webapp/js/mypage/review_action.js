// review-actions.js - 리뷰 CRUD 액션 핸들러

// 리뷰 작성 완료
function handleReviewSubmit($li) {
    const trSubject = $li.find('.tr_subject').val().trim();
    const trPlaceName = $li.find('.tr_placeName').val().trim();
    const trAddress = $li.find('.tr_addr').val();
    const trRatingVal = Number($li.find('.tr_ratingVal').val());
    const content = $li.find('.text_area').val().trim();
    const location = $li.data('location');
    const groupId = $li.data('groupId');
    const markerIndex = $li.data('marker-index');

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
    
    // 그룹 정보 가져오기
    const $group = $(`.review_list > li[data-group-id="${groupId}"]`);
    const groupTitle = $group.find('.group_title_input').val() || '제목 없음';
    const startDate = $group.find('.start_date').val() || '';
    const endDate = $group.find('.end_date').val() || '';
    
    const reviewData = {
        tr_subject: trSubject,
        tr_placeName : trPlaceName,
        tr_address: trAddress,
        tr_ratingVal: trRatingVal,
        content,
        images,
        location,
        groupId,
        groupTitle,
        startDate,
        endDate,
        markerIndex
    };
    
    // 리뷰 저장
    const savedReview = ReviewStorage.save(reviewData);
    
    // 마커와 리뷰 연결
    if (window.linkReviewToMarker) {
        window.linkReviewToMarker(groupId, markerIndex, savedReview.id);
    }
    
    // 뷰 폼으로 전환
    const $viewLi = createViewForm(savedReview);
    $li.replaceWith($viewLi);
    
    alert('후기가 작성되었습니다.');
    return true;
}

// 리뷰 작성 취소
function handleReviewCancel($li) {
    if ($li.data('mode') === 'write') {
        if (confirm('작성을 취소하시겠습니까?')) {
            const groupId = $li.data('groupId');
            const markerIndex = $li.data('marker-index');
            
            // 마커 제거 (재정렬 포함)
            if (window.removeMarkerByIndex && groupId && markerIndex) {
                window.removeMarkerByIndex(groupId, markerIndex);
            }
            
            $li.remove();
            return true;
        }
    }
    return false;
}

// 리뷰 닫기 (X 버튼)
function handleReviewClose($li) {
    const groupId = $li.data('groupId');
    const markerIndex = $li.data('marker-index');
    
    // 마커 제거 (재정렬 포함)
    if (window.removeMarkerByIndex && groupId && markerIndex) {
        window.removeMarkerByIndex(groupId, markerIndex);
    }
    
    $li.remove();
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
    
    if (updatedReview) {
        const $viewLi = createViewForm(updatedReview);
        $li.replaceWith($viewLi);
        
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
    const review = ReviewStorage.getById(reviewId);
    
    if (confirm('정말 삭제하시겠습니까?')) {
        // 마커 제거 (재정렬 포함)
        if (review && review.groupId && review.markerIndex) {
            if (window.removeMarkerByIndex) {
                window.removeMarkerByIndex(review.groupId, review.markerIndex);
            }
        }
        
        // 리뷰 삭제
        ReviewStorage.delete(reviewId);
        $li.remove();
        
        // 그룹이 비어있는지 확인
        const $group = $li.closest('li.group_form');
        if ($group.length) {
            const remainingReviews = $group.find('.group_reviews > li[data-mode="view"]').length;
            
            if (remainingReviews === 0) {
                // 그룹이 비어있으면 그룹도 삭제할지 물어봄
                if (confirm('이 여행 계획에 더 이상 리뷰가 없습니다. 여행 계획도 삭제하시겠습니까?')) {
                    handleGroupDelete($group);
                }
            } else {
                // 남은 리뷰들의 거리 정보 업데이트
                setTimeout(() => {
                    if (review && review.groupId && window.drawPolyline) {
                        window.drawPolyline(review.groupId);
                    }
                }, 100);
            }
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

// 그룹 작성 완료
function handleGroupComplete($group) {
    const groupId = $group.data('group-id');
    const groupTitle = $group.find('.group_title_input').val().trim();
    const startDate = $group.find('.start_date').val();
    const endDate = $group.find('.end_date').val();
    
    // 유효성 검사
    if (!groupTitle) {
        alert('여행 제목을 입력해주세요.');
        return false;
    }
    
    if (!startDate || !endDate) {
        alert('여행 기간을 설정해주세요.');
        return false;
    }
    
    // 날짜 유효성 검사
    if (new Date(startDate) > new Date(endDate)) {
        alert('종료일은 시작일보다 늦어야 합니다.');
        return false;
    }
    
    // 리뷰가 하나라도 있는지 확인
    const reviewCount = $group.find('.group_reviews > li[data-mode="view"]').length;
    if (reviewCount === 0) {
        alert('최소 한 개 이상의 장소를 추가해주세요.');
        return false;
    }
    
    // 작성되지 않은 리뷰가 있는지 확인
    const unfinishedReviews = $group.find('.group_reviews > li[data-mode="write"]').length;
    if (unfinishedReviews > 0) {
        alert('작성하지 않은 리뷰가 있습니다. 모든 리뷰를 작성하거나 취소해주세요.');
        return false;
    }
    
    // 그룹 모드를 view로 변경
    $group.attr('data-mode', 'group-view');
    
    // 입력 폼을 텍스트로 변경
    const $cardTitle = $group.find('.card_title');
    const totalDistance = $cardTitle.find('.total_distance_info').text() || '';
    
    $cardTitle.html(`
        <h2>${groupTitle}</h2>
        <div class="date_range_area" style="color: #fff;">
            <span>여행 기간: ${startDate} ~ ${endDate}</span>
        </div>
        ${totalDistance ? `<div class="total_distance_info" style="color: #fff; font-size: 0.9rem; margin-top: 5px;">${totalDistance}</div>` : ''}
    `);
    
    // 완료 버튼 제거
    $group.find('.group_action_area').remove();
    
    // 현재 그룹 ID 초기화
    if (window.setCurrentGroupId) {
        window.setCurrentGroupId(null);
    }
    
    alert('여행 계획이 저장되었습니다!');
    return true;
}

// 그룹 삭제
function handleGroupDelete($group) {
    const groupId = $group.data('group-id');
    
    if (!confirm('여행 계획과 모든 리뷰를 삭제하시겠습니까?')) {
        return false;
    }
    
    // 그룹의 모든 마커 제거
    if (window.removeGroupMarkers) {
        window.removeGroupMarkers(groupId);
    }
    
    // 그룹 내 모든 리뷰 삭제
    $group.find('.group_reviews > li[data-review-id]').each(function() {
        const reviewId = $(this).data('review-id');
        ReviewStorage.delete(reviewId);
    });
    
    // 그룹 제거
    $group.remove();
    
    // 현재 그룹 ID 초기화
    if (window.setCurrentGroupId) {
        window.setCurrentGroupId(null);
    }
    
    return true;
}
