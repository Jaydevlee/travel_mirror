//로컬 스토리지
const ReviewStorage = {
    //모든 리뷰 조회
    getAll() {
        const data = localStorage.getItem('reviews');
        return data ? JSON.parse(data) : [];
    },
    //리뷰저장
    save(review) {
        const reviews = this.getAll();
        review.id = Date.now();
        review.createdAt = new Date().toISOString();
        reviews.push(review);
        localStorage.setItem('reviews', JSON.stringify(reviews));
        return review;
    },
    //리뷰수정
    modify(id, updatedData) {
        const reviews = this.getAll();
        const index = reviews.findIndex(r => r.id === id);
        if (index !== -1) {
            reviews[index] = { ...reviews[index], ...updatedData, updatedAt: new Date().toISOString() };
            localStorage.setItem('reviews', JSON.stringify(reviews));
            return reviews[index];
        }
        return null;
    },
    //리뷰삭제
    delete(id) {
        const reviews = this.getAll();
        const filtered = reviews.filter(r => r.id !== id);
        localStorage.setItem('reviews', JSON.stringify(filtered));
        return true;
    },
    //id로 리뷰 조회(수정 시 사용)
    getById(id) {
        const reviews = this.getAll();
        return reviews.find(r => r.id === id);
    }
}

//이미지 Base64 변환 함수 

function fileToBase64(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result); // data:image/png;base64,xxx 형태
        reader.onerror = reject;
        reader.readAsDataURL(file); // Base64로 읽기
    });
}

/**
 * 여러 파일을 Base64로 변환
 * @param {FileList} files - 파일 목록
 * @returns {Promise<string[]>} Base64 문자열 배열
 */
async function filesToBase64Array(files) {
    const promises = Array.from(files).map(file => {
        // 이미지 파일만 처리
        if (file.type && file.type.startsWith('image/')) {
            return fileToBase64(file);
        }
        return null;
    });
    const results = await Promise.all(promises);
    return results.filter(r => r !== null); // null 제거
}

//google api 전역변수
let map;
let marker;
let labelIndex = 1;
let markers = [];

//google 맵 api 동적로드
(function loadGoogleMaps() {
    const script = document.createElement('script');
    script.src = `https://maps.googleapis.com/maps/api/js?key=${YOUR_API_KEY}&libraries=places,geometry&v=weekly&callback=initMap`;
    script.async = true;
    script.defer = true;
    document.head.appendChild(script);
})();

async function initMap() {
    //초기위치
    const initialLocation = { lat: 37.5665, lng: 126.9780 };
    map = new google.maps.Map(document.getElementById("map"), {
        center: initialLocation,
        zoom: 16,
    });

    //지오코더 (좌표 -> 주소 변환)
    const geocoder = new google.maps.Geocoder();
    const infowindow = new google.maps.InfoWindow();

    //장소 검색기능
    const serach_input = document.getElementById("address_search");
    const autocomplete = new google.maps.places.Autocomplete(serach_input, {
        fields: ["geometry", "name", "formatted_address"]
    });

    //장소 선택 이벤트
    autocomplete.addListener("place_changed", () => {
        const place = autocomplete.getPlace();
        if (!place.geometry || !place.geometry.location) {
            alert("해당 장소의 위치 정보를 찾을 수 없습니다.");
            return;
        }
        //검색된 장소로 지도 이동 및 확대
        map.setCenter(place.geometry.location);
        map.setZoom(17);

        //검색 장소 마커 추가
        const search_marker = new google.maps.Marker({
            position: place.geometry.location,
            map: map,
            animation: google.maps.Animation.DROP,
            icon: {
                path: google.maps.SymbolPath.CIRCLE,
                scale: 10,
                fillColor: "#4285F4",
                fillOpacity: 0.8,
                strokeColor: "#ffffff",
                strokeWeight: 2
            }
        });
    });

    //지도 클릭시 이벤트 실행
    google.maps.event.addListener(map, "click", async function(event) {
        //좌표
        const lat = event.latLng.lat().toFixed(5);
        const lng = event.latLng.lng().toFixed(5);
        const latLng = event.latLng;
        //마커 애니메이션 인덱스
        const currentIndex = labelIndex;

        //마커 생성
        marker = new google.maps.Marker({
            position: latLng,
            map: map,
            animation: google.maps.Animation.DROP,
            label: '',
            draggable: true,
        });
        markers.push(marker);

        //0.5초 딜레이 후 마커 추가(인덱스가 너무 일찍 나옴)
        setTimeout(() => {
            marker.setLabel(String(currentIndex));
        }, 500);
        labelIndex++; 

        //주소 검색
        let address = "";
        let addressComponents = [];
        try {
            const addr_result = await geocoder.geocode({location: latLng});
            if (addr_result.results[0]) {
                address = addr_result.results[0].formatted_address;
                addressComponents = addr_result.results[0].address_components;
            }
        } catch(e) {
            address = "주소 없음";
        }

        //장소명 검색
        let place_name = "";
        try {
            const service = new google.maps.places.PlacesService(map);
            place_name = await new Promise((resolve) => {
                //5m 이내 장소 검색
                service.nearbySearch({
                    location: latLng,
                    radius: 5,
                },
                (results, status) => {
                    if (status === google.maps.places.PlacesServiceStatus.OK && results && results.length > 0) {
                        let bestPlace = null;
                        let minDistance = null;

                        //가장 가까운 장소 찾기
                        for (let place of results) {
                            const types = place.types || [];
                            const name = place.name;
                            //제외할 타입과 장소
                            const ban_types = ['country','political'];
                            const has_ban_type = types.some(ban_type => ban_types.includes(ban_type));
                            const ban_name = ['대한민국', 'South Korea', '구', '동'];
                            const has_ban_name = ban_name.some(banned => place.name.includes(banned));

                            if (!has_ban_type && !has_ban_name && name && name !== address) {
                                const placeLocation = place.geometry.location;
                                const distance = google.maps.geometry.spherical.computeDistanceBetween(
                                    latLng,
                                    placeLocation
                                );
                                //5미터 이내 가장 가까운 장소 선택
                                if (distance < 5 && (minDistance === null || distance < minDistance)) {
                                    minDistance = distance;
                                    bestPlace = { name, distance };
                                }
                            }
                        }
                        if (bestPlace) {
                            resolve(bestPlace.name);
                        } else {
                            resolve("");
                        }
                    } else {
                        resolve("");
                    }
                });
            });
        } catch(e) {
            console.error("장소명 검색 오류:", e);
            const sublocality = addressComponents.find(comp =>
                comp.types.includes('sublocality_level_2')
            );
            place_name = sublocality ? sublocality.long_name : "";
        }
        //리뷰 작성 폼 생성
        createWriteForm(lat, lng, place_name, address, currentIndex);
    });
    //저장된 리뷰 불러오기
    loadReviews();
}

//리뷰 작성 폼
function createWriteForm(lat, lng, place_name, address, currentIndex){
    const tr_id = `${lat}_${lng}_${Date.now()}`;
    const $li = $(`
        <li data-mode="write" data-unique-id="${tr_id}">
            <div class="card">
                <div class="card_head">
                    <div class="card_title">
                        <h2>
                            <input type="text" name="tr_subject" id="tr_subject_${lat}_${lng}" class="tr_subject" value="${place_name}" placeholder="장소명을 입력하세요.">
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
                            <label for="file_upload_${tr_id}" class="file_label" multiple>
                                <img src="img/icon/input_icon.png" alt="업로드 버튼 이미지" width="10px">
                            </label>
                            <input type="file" id="file_upload_${tr_id}" class="file_upload" multiple>
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
    //위치 정보 저장
    $li.data('location',{lat, lng, currentIndex});
    $(".review_list").prepend($li);
}

//리뷰 보기 폼
function createViewForm(review){
    const tr_id = review.id;
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

//리뷰 수정 폼
function modifyReview($li) {
    const review_id = $li.data('review-id');
    const review = ReviewStorage.getById(review_id);
    
    if (!review) {
        console.error('리뷰를 찾을 수 없습니다:', review_id);
        return;
    }
    
    const unique_id = `edit_${review_id}`;

    const $mod = $(`
        <li data-mode="edit" data-review-id="${review_id}" data-unique-id="${unique_id}">
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
                            <label for="file_upload_${unique_id}" class="file_label">
                                <img src="img/icon/input_icon.png" alt="업로드 버튼 이미지" width="10px">
                            </label>
                            <input type="file" id="file_upload_${unique_id}" class="file_upload" multiple accept="image/*">
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
    
    $li.replaceWith($mod);
    
    //별점 UI
    const $starForm = $mod.find('.tr_starForm');
    const $stars = $starForm.find('.tr_starBox button[data-val]');
    const $hidden = $starForm.find('.tr_ratingVal');
    
    setTimeout(() => {
        if (window.paintStars) {
            window.paintStars($stars, $hidden, review.tr_ratingVal);
        }
    }, 100);
}

//저장 리뷰 불러오기
function loadReviews() {
    const reviews = ReviewStorage.getAll();
    reviews.forEach(function(review) {
        const $viewLi = createViewForm(review);
        $(".review_list").append($viewLi);
    });
}

//리뷰 작성 완료 버튼
$(document).on('click', '.btn_submit', function(e) {
    e.preventDefault();
    e.stopPropagation();
    
    const $li = $(this).closest('li');
    const tr_subject = $li.find('.tr_subject').val().trim();
    const tr_address = $li.find('.tr_addr').val();
    const tr_ratingVal = Number($li.find('.tr_ratingVal').val());
    const content = $li.find('.text_area').val().trim();
    const location = $li.data('location');

    //유효성 검사
    if (!tr_subject) {
        alert('장소명을 입력해주세요.');
        return;
    }
    if (tr_ratingVal === 0) {
        alert('별점을 선택해주세요.');
        return;
    }
    if (!content) {
        alert('후기 내용을 작성해주세요.');
        return;
    }
    
    const images = [];
    $li.find('.file_preview img').each(function() {
        images.push($(this).attr('src'));
    });
    
    const reviewData = {
        tr_subject,
        tr_address,
        tr_ratingVal,
        content,
        images,
        location
    };
    
    //리뷰저장
    const savedReview = ReviewStorage.save(reviewData);
    //뷰 폼 전환
    const $viewLi = createViewForm(savedReview);
    $li.replaceWith($viewLi);
    
    alert('후기가 작성되었습니다.');
});

// 리뷰 작성 취소 버튼
$(document).on('click', '.btn_cancel', function(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const $li = $(this).closest('li');
    
    //작성 모드면 해당 li 삭제
    if ($li.data('mode') === 'write') {
        if (confirm('작성을 취소하시겠습니까?')) {
            $li.remove(); 
        }
    }
});

//리뷰 수정 버튼
$(document).on('click', '.btn_edit', function(e) {
    e.preventDefault();
    e.stopPropagation();
    
    const $li = $(this).closest('li[data-review-id]');
    // console.log('리뷰 id:', $li.data('review-id'));
    modifyReview($li);
});

//수정 완료 버튼
$(document).on('click', '.btn_update', function(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const $li = $(this).closest('li');
    const review_id = $li.data('review-id');
    
    const tr_subject = $li.find('.tr_subject').val().trim();
    const tr_ratingVal = Number($li.find('.tr_ratingVal').val());
    const content = $li.find('.text_area').val().trim();
    
    //유효성
    if (!tr_subject || tr_ratingVal === 0 || !content) {
        alert('모든 항목을 입력해주세요.');
        return;
    }
    
    //삭제되지 않은 이미지는 유지
    let existingImages = $li.data('existingImages') || [];
    const imagesToRemove = $li.data('imagesToRemove') || [];
    
    existingImages = existingImages.filter((img, idx) => !imagesToRemove.includes(idx));
    
    //추가 이미지가 있으면 추가
    const newImages = [];
    $li.find('.file_preview img').each(function() {
        newImages.push($(this).attr('src'));
    });
    
    //추가 이미지 합치기
    const allImages = [...existingImages, ...newImages];
    
    //리뷰 업데이트
    const updatedReview = ReviewStorage.modify(review_id, {
        tr_subject,
        tr_ratingVal,
        content,
        images: allImages
    });
    
    if (updatedReview) {
        const $viewLi = createViewForm(updatedReview);
        $li.replaceWith($viewLi);
        alert('수정되었습니다.');
    }
});

//수정 취소 버튼
$(document).on('click', '.btn_cancel_edit', function(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const $li = $(this).closest('li');
    const review_id = $li.data('review-id');
    const review = ReviewStorage.getById(review_id);
    
    if (review) {
        const $viewLi = createViewForm(review);
        $li.replaceWith($viewLi);
    }
});

//리뷰삭제버튼
$(document).on('click', '.btn_delete', function(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const $li = $(this).closest('li[data-review-id]');
    const review_id = $li.data('review-id');
    
    console.log('삭제 시도:', review_id);
    
    if (confirm('정말 삭제하시겠습니까?')) {
        const result = ReviewStorage.delete(review_id);
        console.log('삭제 결과:', result);
        
        $li.remove();
        alert('삭제되었습니다.');
    }
});

//기존 이미지 삭제
$(document).on('click', '.btn_remove_img', function(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const $btn = $(this);
    const idx = Number($btn.data('index'));
    const $li = $btn.closest('li');
    const imagesToRemove = $li.data('imagesToRemove') || [];
    
    imagesToRemove.push(idx);
    $li.data('imagesToRemove', imagesToRemove);
    
    $btn.closest('.image_item').remove();
});

//수정삭제버튼 토글
$(document).on('click', '.menu_btn', function(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const $ul = $(this).siblings('.btn_ul');
    $('.btn_ul').not($ul).removeClass('on').addClass('off');
    $ul.toggleClass('on off');
});

$(document).ready(function() {
    //카드 펼치기 접기
    $(document).on('click', '.expend_btn_area', function(e) {
        e.stopPropagation();
        
        const $card_head = $(this).closest('.card_head');
        const $card_body = $card_head.siblings('.card_body');
        
        $card_body.toggleClass('on off');
        //펼치기 접기 아이콘 수정
        const $img = $(this).find('button img');
        $img.attr('src', $card_body.hasClass('on') ? 'img/icon/up.png' : 'img/icon/down.png');
    });

    //별점
    const gray = '#d1d5db';
    const fill = '#f59e0b';

    function paintStars($stars, $hidden, score) {
        $stars.each(function() {
            const val = Number($(this).data('val')); 
            $(this).css('color', val <= score ? fill : gray); 
        });
        $hidden.val(score);
    }
    window.paintStars = paintStars;

    //별점 클릭 이벤트
    $(document).on('click', '.tr_starBox button[data-val]', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const $btn = $(this);
        const score = Number($btn.data('val'));
        const $form = $btn.closest('.tr_starForm');
        const $stars = $form.find('.tr_starBox button[data-val]');
        const $hidden = $form.find('.tr_ratingVal');

        paintStars($stars, $hidden, score);
        $form.closest('.content_write_area').find('textarea').removeAttr('disabled');
    });

    //별점 폼 리셋
    $(document).on('reset', '.tr_starForm', function() {
        const $form = $(this);
        const $stars = $form.find('.tr_starBox button[data-val]');
        const $hidden = $form.find('.tr_ratingVal');
        setTimeout(() => paintStars($stars, $hidden, 0), 0);
    });

    $('.tr_starForm').each(function() {
        const $form = $(this);
        const $stars = $form.find('.tr_starBox button[data-val]');
        const $hidden = $form.find('.tr_ratingVal');
        paintStars($stars, $hidden, 0);
    });

    $(document)
        .off('change.preview') 
        .on('change.preview', '.file_upload', async function() {
            const input = this;
            const $writeArea = $(input).closest('.content_write_area');

            const $starForm = $writeArea.find('.tr_starForm').first();

            //별점과 미리보기를 같은 행에 배치하기 위한 컨테이너
            let $row = $writeArea.find('.tr_starRow');
            if (!$row.length) {
                $row = $('<div class="tr_starRow"></div>');
                $row.insertBefore($starForm);
                $row.append($starForm);
            }

            // 이미지 미리보기 영역
            let $preview = $row.find('.file_preview');
            if (!$preview.length) {
                $preview = $('<div class="file_preview"></div>');
                $row.prepend($preview);
            }

            const current = $preview.children().length;
            const MAX = 8;
            const remain = MAX - current;
            if (remain <= 0) {
                alert('최대 8개까지 첨부 가능합니다.');
                return;
            }

            // Array.from(input.files).forEach((file) => {
            //     if (!file.type || !file.type.startsWith('image/') || file.type.startsWith('video/')) return;
            //     const url = URL.createObjectURL(file);
            //     const $img = $(
            //         `<img alt="첨부 이미지 미리보기"
            //             src="${url}"
            //             style="max-width:100%; height:auto; display:block; border-radius:8px; margin-top:6px;">`
            //     );
            //     $preview.append($img);
            // });

            // 선택된 파일들을 Base64로 변환
            const files = Array.from(input.files).slice(0, remain); // 남은 개수만큼만
            
            for (const file of files) {
                // 이미지 파일만 처리
                if (!file.type || !file.type.startsWith('image/')) continue;
                
                try {
                    //저장방식 Base64로 변환
                    const base64 = await fileToBase64(file);
                    
                    // Base64 이미지를 미리보기에 표시
                    const $img = $(
                        `<img alt="첨부 이미지 미리보기"
                            src="${base64}"
                            style="max-width:100%; height:auto; display:block; border-radius:8px; margin-top:6px;">`
                    );
                    $preview.append($img);
                } catch (error) {
                    console.error('이미지 변환 오류:', error);
                    alert('이미지 처리 중 오류가 발생했습니다.');
                }
            }
            input.value = '';
        });
    
    // 문서 다른 곳 클릭 시 메뉴 닫기
    $(document).on('click', function(event) {
        if (!$(event.target).closest('.btn_area').length) {
            $('.btn_ul').removeClass('on').addClass('off');
        }
    });
});