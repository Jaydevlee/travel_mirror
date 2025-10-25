// 리뷰 작성 폼
function createWriteForm(lat, lng, placeName, address, currentIndex) {
    const trId = `${lat}_${lng}_${Date.now()}`;
    const $li = $(`
        <li data-mode="write" data-unique-id="${trId}">
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <h2>
                            <input type="text" name="tr_subject" id="tr_subject_${lat}_${lng}" class="tr_subject" value="${placeName}" placeholder="장소명을 입력하세요.">
                        </h2>
                        <div class="addr_area">
                            <input type="text" name="tr_addr" id="tr_addr_${lat}_${lng}" class="tr_addr" value="${address}" disabled>
                        </div>
                    </div>
                    <div class="expend_btn_area">
                        <button type="button">
                            <img src="img/icon/down.png" width="40" alt="펼치기">
                        </button>
                    </div>
                </div>
                <div class="card_body off">
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
                                <img src="img/icon/input_icon.png" alt="업로드 버튼 이미지" width="10px">
                            </label>
                            <input type="file" id="file_upload_${trId}" class="file_upload" multiple>
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
    
    $li.data('location', {lat, lng, currentIndex});
    $(".review_list").prepend($li);
}

// 리뷰 보기 폼
function createViewForm(review) {
    const $li = $(`
        <li data-mode="view" data-review-id="${review.id}">
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <h2>${review.tr_subject}</h2>
                        <div class="addr_area">
                            <span class="tr_addr">${review.tr_address}</span>
                        </div>
                    </div>
                    <div class="expend_btn_area">
                        <button type="button">
                            <img src="img/icon/down.png" width="40" alt="펼치기">
                        </button>
                    </div>
                </div>
                <div class="card_body on">
                    <div class="content_write_area">
                        <div class="view_head">
                            <div class="rating_display">
                                <span class="stars">${'★'.repeat(review.tr_ratingVal)}${'☆'.repeat(5-review.tr_ratingVal)}</span>
                            </div>
                            <div class="btn_area">
                                <button type="button" class="menu_btn">⋮</button>
                                <ul class="btn_ul off">
                                    <li><button type="button" class="btn_edit">수정</button></li>
                                    <li><button type="button" class="btn_delete">삭제</button></li>
                                </ul>
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
    
    const $mod = $(`
        <li data-mode="edit" data-review-id="${review.id}" data-unique-id="${uniqueId}">
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <h2>
                            <input type="text" name="tr_subject" class="tr_subject" value="${review.tr_subject}">
                        </h2>
                        <div class="addr_area">
                            <input type="text" name="tr_addr" class="tr_addr" value="${review.tr_address}" disabled>
                        </div>
                    </div>
                    <div class="expend_btn_area">
                        <button type="button">
                            <img src="img/icon/up.png" width="40" alt="접기">
                        </button>
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
                            <div class="image_list">
                                ${review.images.map((img, idx) => `
                                    <div class="image_item" data-index="${idx}">
                                        <img src="${img}" alt="기존 이미지" style="max-width:100px; height:auto; border-radius:8px;">
                                        <button type="button" class="btn_remove_img" data-index="${idx}">×</button>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                        ` : ''}
                        <div class="file_area">
                            <label for="file_upload_${uniqueId}" class="file_label">
                                <img src="img/icon/input_icon.png" alt="업로드 버튼 이미지" width="10px">
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
    reviews.forEach(function(review) {
        const $viewLi = createViewForm(review);
        $(".review_list").append($viewLi);
    });
}