// 그룹 폼 생성
function createGroupForm() {
    const groupId = `group_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const $groupLi = $(`
        <li class="group_form" data-mode="group-write" data-group-id="${groupId}">
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <h2>
                            <input type="text" name="group_title" class="group_title_input" placeholder="여행 제목을 입력하세요" value="">
                        </h2>
                        <div class="date_range_area">
                            <label>여행 기간:</label>
                            <input type="date" name="start_date" class="start_date" required>
                            <span>~</span>
                            <input type="date" name="end_date" class="end_date" required>
                        </div>
                    </div>
                    <div class="head_right">
                        <div class="expend_btn_area">
                            <button type="button">
                                <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='white'%3E%3Cpath d='M7 10l5 5 5-5z'/%3E%3C/svg%3E" width="80" alt="접기">
                            </button>
                        </div>
                        <div class="btn_area">
                            <button type="button" class="menu_btn">⋮</button>
                            <ul class="btn_ul off">
                                <li><button type="button" class="btn_delete_group">삭제</button></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="card_body on">
                    <ul class="group_reviews">
                        <!-- 리뷰 폼들이 여기에 추가됨 -->
                    </ul>
                    <div class="group_action_area" style="text-align: right; padding: 10px;">
                        <button type="button" class="btn_complete_group" style="padding: 10px 20px; background-color: #41E9C2; color: #fff; border: none; border-radius: 5px; font-weight: bold; cursor: pointer;">여행 계획 완료</button>
                    </div>
                </div>
            </div>
        </li>
    `);
    
    $(".review_list").prepend($groupLi);
    
    // 현재 작성 중인 그룹 ID 설정
    if (window.setCurrentGroupId) {
        window.setCurrentGroupId(groupId);
    }
    
    // 검색창에 포커스
    if (window.focusSearchInput) {
        window.focusSearchInput();
    }
    
    return groupId;
}

// 그룹 내부에 리뷰 폼 생성
function createReviewFormInGroup(lat, lng, placeName, placeName2, address, markerIndex, groupId) {
    const trId = `${lat}_${lng}_${Date.now()}`;
    const $li = $(`
        <li data-mode="write" data-unique-id="${trId}" data-marker-index="${markerIndex}">
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <div style="display: flex; align-items: center;margin-top:1rem;">
                            <span class="marker_index">${markerIndex}</span>
                            <h2 style="flex: 1; margin: 0;">
                                <input type="text" name="tr_subject" id="tr_subject_${lat}_${lng}" class="tr_subject" value="${placeName}" placeholder="장소명을 입력하세요.">
                                <input type="hidden" name="tr_placeName" id="tr_placeName" class="tr_placeName" value="${placeName2}">
                            </h2>
                        </div>
                        <div class="addr_area">
                            <input type="text" name="tr_addr" id="tr_addr_${lat}_${lng}" class="tr_addr" value="${address}" disabled>
                        </div>
                    </div>
                    <div class="head_right">
                        <div class="expend_btn_area">
                            <button type="button">
                                <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='white'%3E%3Cpath d='M7 10l5 5 5-5z'/%3E%3C/svg%3E" width="80" alt="접기">
                            </button>
	                        <button type="button" class="btn_close_review" title="닫기">✕</button>
                        </div>
                    </div>
                </div>
                <div class="card_body on">
                    <div class="content_write_area">
                        <form class="tr_starForm" autocomplete="off">
                            <div>
                                <strong>별점</strong>
                                <div class="tr_starBox" role="radiogroup" aria-label="별점 선택">
                                    <button type="button" data-val="1">★</button>
                                    <button type="button" data-val="2">★</button>
                                    <button type="button" data-val="3">★</button>
                                    <button type="button" data-val="4">★</button>
                                    <button type="button" data-val="5">★</button>
                                    <input type="hidden" name="rating" class="tr_ratingVal" value="0">
                                </div>
                            </div>
                        </form>
                        <div class="text_area_box">
                            <textarea class="text_area" rows="6" placeholder="후기를 작성해주세요."></textarea>
                        </div>
                        <div class="file_area">
                            <label for="file_upload_${trId}" class="file_label" multiple>
                                <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='25' height='25' fill='%23666'%3E%3Cpath d='M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z'/%3E%3C/svg%3E" alt="업로드 버튼 이미지" width="25px">
                            </label>
                            <input type="file" id="file_upload_${trId}" class="file_upload" multiple accept="image/*">
                        </div>
                        <div class="write_btn_area btn">
                            <button type="button" class="btn_submit">작성</button>
                            <button type="reset" class="btn_cancel">취소</button>
                        </div>
                    </div>
                </div>
            </div>
        </li>
    `);
    
    $li.data('location', {lat, lng, currentIndex: markerIndex});
    $li.data('groupId', groupId);
    
    // 해당 그룹의 리뷰 목록에 추가
    const $group = $(`.review_list > li[data-group-id="${groupId}"]`);
    if ($group.length) {
        $group.find('.group_reviews').append($li);
    }
}

// 리뷰 보기 폼
function createViewForm(review) {
    const markerIndexDisplay = review.markerIndex ? `<span class="marker_index">${review.markerIndex}</span>` : '';
    
    const $li = $(`
        <li data-mode="view" data-review-id="${review.id}"
            data-place-id="${review.placeId || ''}" data-rating="${review.tr_ratingVal}"
            data-marker-index="${review.markerIndex || ''}"> 
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <div style="display: flex; align-items: center;">
                            ${markerIndexDisplay}
                            <h2 style="flex: 1; margin: 0;">${review.tr_subject}</h2>
                        </div>
                        <div class="addr_area">
                            <span class="tr_addr">${review.tr_address}</span>
                        </div>
                    </div>
                    <div class="head_right">
                        <div class="expend_btn_area">
                            <button type="button">
                                <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='white'%3E%3Cpath d='M7 14l5-5 5 5z'/%3E%3C/svg%3E" width="80" alt="펼치기">
                            </button>
                        </div>
                        <div class="btn_area">
                            <button type="button" class="menu_btn">⋮</button>
                            <ul class="btn_ul off">
                                <li><button type="button" class="btn_edit">수정</button></li>
                                <li><button type="button" class="btn_delete">삭제</button></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="card_body on">
                    <div class="content_write_area">
                        <div class="view_head">
                            <div class="rating_display">
                                <span class="stars">${'★'.repeat(review.tr_ratingVal)}${'☆'.repeat(5-review.tr_ratingVal)}</span>
                            </div>
                        </div>
                        <div class="content_view_area">
                            ${review.images && review.images.length > 0 ? `
                            <div class="image_preview_area">
                                ${review.images.map(img => `<img src="${img}" alt="첨부 이미지" style="max-width:150px; height:auto; border-radius:8px; margin:5px;">`).join('')}
                            </div>
                            ` : ''}
                            <div class="content_text">
                                <p>${review.content.replace(/\n/g, '<br>')}</p>
                            </div>
                            <div class="review_date">
                                <span>${new Date(review.createdAt).toLocaleString('ko-KR')}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </li>
    `);
    return $li;
}

// 리뷰 수정 폼
function createEditForm(review) {
    const uniqueId = `edit_${review.id}`;
    const markerIndexDisplay = review.markerIndex ? `<span class="marker_index">${review.markerIndex}</span>` : '';
    
    const $mod = $(`
        <li data-mode="edit" data-review-id="${review.id}" data-unique-id="${uniqueId}" data-marker-index="${review.markerIndex || ''}">
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <div style="display: flex; align-items: center;">
                            ${markerIndexDisplay}
                            <h2 style="flex: 1; margin: 0;">
                                <input type="text" name="tr_subject" class="tr_subject" value="${review.tr_subject}">
                            </h2>
                        </div>
                        <div class="addr_area">
                            <input type="text" name="tr_addr" class="tr_addr" value="${review.tr_address}" disabled>
                        </div>
                    </div>
                    <div class="head_right">
                        <div class="expend_btn_area">
                            <button type="button">
                                <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='white'%3E%3Cpath d='M7 10l5 5 5-5z'/%3E%3C/svg%3E" width="80" alt="접기">
                            </button>
                        </div>
                    </div>
                </div>
                <div class="card_body on">
                    <div class="content_write_area">
                        <form class="tr_starForm" autocomplete="off">
                            <div>
                                <strong>별점</strong>
                                <div class="tr_starBox" role="radiogroup" aria-label="별점 선택">
                                    <button type="button" data-val="1">★</button>
                                    <button type="button" data-val="2">★</button>
                                    <button type="button" data-val="3">★</button>
                                    <button type="button" data-val="4">★</button>
                                    <button type="button" data-val="5">★</button>
                                    <input type="hidden" name="rating" class="tr_ratingVal" value="${review.tr_ratingVal}">
                                </div>
                            </div>
                        </form>
                        <div class="text_area_box">
                            <textarea class="text_area" rows="6">${review.content}</textarea>
                        </div>
                        ${review.images && review.images.length > 0 ? `
                        <div class="existing_images">
                            <strong>기존 이미지:</strong>
                            <div class="image_list" style="display: flex; gap: 10px; flex-wrap: wrap; margin: 10px 0;">
                                ${review.images.map((img, idx) => `
                                    <div class="image_item" data-index="${idx}" style="position: relative;">
                                        <img src="${img}" alt="기존 이미지" style="max-width:100px; height:auto; border-radius:8px;">
                                        <button type="button" class="btn_remove_img" data-index="${idx}" style="position: absolute; top: -5px; right: -5px; background: red; color: white; border: none; border-radius: 50%; width: 25px; height: 25px; cursor: pointer; font-weight: bold;">×</button>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                        ` : ''}
                        <div class="file_area">
                            <label for="file_upload_${uniqueId}" class="file_label">
                                <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='25' height='25' fill='%23666'%3E%3Cpath d='M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z'/%3E%3C/svg%3E" alt="업로드 버튼 이미지" width="25px">
                            </label>
                            <input type="file" id="file_upload_${uniqueId}" class="file_upload" multiple accept="image/*">
                        </div>
                        <div class="write_btn_area btn">
                            <button type="button" class="btn_update">수정완료</button>
                            <button type="button" class="btn_cancel_edit">취소</button>
                        </div>
                    </div>
                </div>
            </div>
        </li>
    `);
    
    $mod.data('existingImages', review.images || []);
    $mod.data('imagesToRemove', []);
    
    return $mod;
}

// 저장된 리뷰 불러오기
function loadReviews() {
    const reviews = ReviewStorage.getAll();
    
    // 그룹별로 리뷰 분류
    const groupedReviews = {};
    reviews.forEach(review => {
        const groupId = review.groupId || 'default';
        if (!groupedReviews[groupId]) {
            groupedReviews[groupId] = [];
        }
        groupedReviews[groupId].push(review);
    });
    
    // 각 그룹별로 표시
    Object.keys(groupedReviews).forEach(groupId => {
        const groupReviews = groupedReviews[groupId];
        if (groupReviews.length > 0) {
            const firstReview = groupReviews[0];
            
            // 그룹 정보가 있으면 그룹 폼 생성
            if (firstReview.groupTitle) {
                const $groupLi = createSavedGroupForm(firstReview);
                groupReviews.forEach(review => {
                    const $viewLi = createViewForm(review);
                    $groupLi.find('.group_reviews').append($viewLi);
                });
            }
        }
    });
    
    // 마커 복원
    if (window.restoreMarkersForReviews) {
        window.restoreMarkersForReviews(reviews);
    }
}

// 저장된 그룹 폼 생성
function createSavedGroupForm(reviewData) {
    const groupId = reviewData.groupId;
    
    const $groupLi = $(`
        <li class="group_form" data-mode="group-view" data-group-id="${groupId}">
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <h2>${reviewData.groupTitle}</h2>
                        <div class="date_range_area" style="color: #fff;">
                            <span>여행 기간: ${reviewData.startDate} ~ ${reviewData.endDate}</span>
                        </div>
                    </div>
                    <div class="head_right">
                        <div class="expend_btn_area">
                            <button type="button">
                                <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='white'%3E%3Cpath d='M7 14l5-5 5 5z'/%3E%3C/svg%3E" width="80" alt="펼치기">
                            </button>
                        </div>
                        <div class="btn_area">
                            <button type="button" class="menu_btn">⋮</button>
                            <ul class="btn_ul off">
                                <li><button type="button" class="btn_delete_group">삭제</button></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="card_body on">
                    <ul class="group_reviews">
                        <!-- 리뷰들이 여기에 추가됨 -->
                    </ul>
                </div>
            </div>
        </li>
    `);
    
    $(".review_list").prepend($groupLi);
    return $groupLi;
}

// 전역에서 접근 가능하게
window.createGroupForm = createGroupForm;
window.createReviewFormInGroup = createReviewFormInGroup;
