//google 맵 api
(function loadGoogleMaps() {
    const script = document.createElement('script');
    script.src = `https://maps.googleapis.com/maps/api/js?key=${YOUR_API_KEY}&libraries=places,geometry&v=weekly&callback=initMap`;
    script.async = true;
    script.defer = true;
    document.head.appendChild(script);
})();

let map;
let marker;
let labelIndex = 1; // 마커 라벨
let markers = []; // 마커를 저장할 배열
let addr;

async function initMap() {
  // 초기 맵 설정 (서울 시청 좌표 기준 예시)
    const initialLocation = { lat: 37.5665, lng: 126.9780 };
    map = new google.maps.Map(document.getElementById("map"), {
        center: initialLocation,
        zoom: 16,
    });

  // 주소값 호출
    const geocoder = new google.maps.Geocoder();
    const infowindow = new google.maps.InfoWindow();

  // 주소검색
    const serach_input = document.getElementById("address_search");
    const autocomplete = new google.maps.places.Autocomplete(serach_input, {
        fields: ["geometry", "name", "formatted_address"]
    });

    autocomplete.addListener("place_changed", () => {
    const place = autocomplete.getPlace();
    // 위치정보 없을시
    if (!place.geometry || !place.geometry.location) {
        alert("해당 장소의 위치 정보를 찾을 수 없습니다.");
        return;
    }

    // 맵 중앙으로 줌
    map.setCenter(place.geometry.location);
    map.setZoom(17);

    // 검색한 위치에 임시 마커 표시
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

  // 맵 클릭시 마커 생성
    google.maps.event.addListener(map, "click", async function(event) {
        // 좌표
        const lat = event.latLng.lat().toFixed(5);
        const lng = event.latLng.lng().toFixed(5);
        const latLng = event.latLng;
        const currentIndex = labelIndex;

        marker = new google.maps.Marker({
        position: latLng,
        map: map,
        animation: google.maps.Animation.DROP,
        label: '',
        draggable: true,
        });
        markers.push(marker);

        //마커 숫자 지연
        setTimeout(() => {
            marker.setLabel(String(currentIndex));
        }, 500);
        labelIndex++; 

    // 주소 가져오기
    let address = "";
    let addressComponents = [];

    // 역지오코딩(좌표 -> 주소)
    try {
        const addr_result = await geocoder.geocode({location: latLng});
        if (addr_result.results[0]) {
            address = addr_result.results[0].formatted_address;
            addressComponents = addr_result.results[0].address_components;
        }
    } catch(e) {
        address = "주소 없음";
    }
    addr = address;

    // 장소명 가져오기
    let place_name = "";
    try {
      // placeService 객체
        const service = new google.maps.places.PlacesService(map);
        place_name = await new Promise((resolve) => {
        service.nearbySearch({
            location: latLng,
            radius: 5, // 반경 5미터
        },
        (results, status) => {
            if (status === google.maps.places.PlacesServiceStatus.OK && results && results.length > 0) {
            // console.log("nearbySearch results:", results);
                let bestPlace = null;
                let minDistance = null;

            for (let place of results) {
                const types = place.types || [];
                const name = place.name;
                // 제외할 키워드
                const ban_types = ['country','political'];
                const has_ban_type = types.some(ban_type => ban_types.includes(ban_type));
                const ban_name = ['대한민국', 'South Korea', '구', '동'];
                const has_ban_name = ban_name.some(banned => place.name.includes(banned));

                if (!has_ban_type && !has_ban_name && name && name !== address) {
                    // 좌표와 근처 거리 계산
                    const placeLocation = place.geometry.location;
                    const distance = google.maps.geometry.spherical.computeDistanceBetween(
                    latLng,
                    placeLocation
                );
                
                    // 5미터 이내의 가장 가까운 장소
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

    // li 템플릿 생성
    const $li = $(`
        <li>
            <div class="card">
            <div class="card_head">
                <div class="card_title">
                <h3>
                    <input type="text" name="tr_subject" id="tr_subject_${lat}_${lng}" class="tr_subject" value="${place_name}">
                </h3>
                <div class="addr_area">
                    <input type="text" name="tr_addr" id="tr_addr_${lat}_${lng}" class="tr_addr" value="${address}" disabled>
                </div>
                </div>
                <div class="expend_btn_area">
                <button type="button">
                    <img src="img/icon/down.png" width="40">
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
                    <textarea class="text_area" rows="6"></textarea>
                </div>
                <div class="file_area">
                    <label for="file_upload_${lat}_${lng}" class="file_label" multiple>
                    <img src="img/icon/input_icon.png" alt="업로드 버튼 이미지" width="10px">
                    </label>
                    <input type="file" id="file_upload_${lat}_${lng}" class="file_upload" multiple>
                </div>
                <div class="write_btn_area btn">
                    <button type="button">작성</button>
                    <button type="reset">취소</button>
                </div>
                </div>
            </div>
            </div>
        </li>
    `);
    
    // review_list에 append
    $(".review_list").append($li);
    });
}

        $(document).ready(function() {
        // expend_btn_area 버튼 클릭 시 적용
        $(document).on('click', '.expend_btn_area', function(e) {
            const $card_head = $(this).closest('.card_head');
            const $card_body = $card_head.siblings('.card_body');
            toggleOnOff($card_body);

            // 버튼 화살표 이미지 교체 (down ↔ up)
            const $img = $(this).find('button img');
            $img.attr('src', $card_body.hasClass('on') ? 'img/icon/up.png' : 'img/icon/down.png');
        });

        // btn_area 버튼 클릭 시 적용
        $(document).on('click', '.btn_area', function() {
            const $ul = $(this).find('.btn_ul'); // 수정/삭제 메뉴
            toggleOnOff($ul);
        });

        $(document).on('click', '.tr_subject_self', function() {
            const $tr_subject = $('#tr_subject');
            toggleOnOff($tr_subject);
        });

        // on/off 토글 함수
        function toggleOnOff(element) {
            const $el = $(element);
            $el.toggleClass('on off');
        }

        /* ===================== 별점 기능 ===================== */
        const gray = '#d1d5db'; // 선택 안 된 별 색
        const fill = '#f59e0b'; // 선택된 별 색

        // 별 색 칠하는 함수
        function paintStars($stars, $hidden, score) {
            $stars.each(function() {
            const val = Number($(this).data('val')); 
            $(this).css('color', val <= score ? fill : gray); 
            });
            $hidden.val(score); // 선택한 점수를 hidden input에 저장
        }

        // 별 클릭 시
        $(document).on('click', '.tr_starBox button[data-val]', function() {
            const $btn = $(this);
            const score = Number($btn.data('val')); // 클릭한 별 점수
            const $form = $btn.closest('.tr_starForm'); // 현재 별점 폼
            const $stars = $form.find('.tr_starBox button[data-val]');
            const $hidden = $form.find('.tr_ratingVal');

            paintStars($stars, $hidden, score); // 별 색칠
            $form.find('textarea').removeAttr('disabled'); // 텍스트 작성 가능하게
        });

        // 폼 리셋 시 (취소 버튼 눌렀을 때 별 다시 회색으로)
        $(document).on('reset', '.tr_starForm', function() {
            const $form = $(this);
            const $stars = $form.find('.tr_starBox button[data-val]');
            const $hidden = $form.find('.tr_ratingVal');
            setTimeout(() => paintStars($stars, $hidden, 0), 0); // 0점으로 초기화
        });

        // 페이지 로드 시 초기 별점 0으로 세팅
        $('.tr_starForm').each(function() {
            const $form = $(this);
            const $stars = $form.find('.tr_starBox button[data-val]');
            const $hidden = $form.find('.tr_ratingVal');
            paintStars($stars, $hidden, 0);
        });

        // ==================== 이미지 미리보기 ====================
        $(document)
            .off('change.preview') 
            .on('change.preview', '.file_upload', function() {
            const input = this;
            const $writeArea = $(input).closest('.content_write_area');

            // 별점 폼라인에 같이 위에 미리보기
            const $starForm = $writeArea.find('.tr_starForm').first();

            // 별점 폼 라인
            let $row = $writeArea.find('.tr_starRow');
            if (!$row.length) {
                $row = $('<div class="tr_starRow"></div>');
                $row.insertBefore($starForm);
                $row.append($starForm);
            }

            // 별점 폼 라인에 같이 보이게 
            let $preview = $row.find('.file_preview');
            if (!$preview.length) {
                $preview = $('<div class="file_preview"></div>');
                $row.prepend($preview); // 왼쪽엔 사진 미리보기, 오른쪽엔 별점.
            }

            // 첨부파일 최대 8개
            const current = $preview.children().length;
            const MAX = 8;
            const remain = MAX - current;
            if (remain <= 0) {
                alert('최대 8개까지 첨부 가능합니다.');
                return;
            }

            // 이미지만 미리보기 (파일명 X)
            Array.from(input.files).forEach((file) => {
                if (!file.type || !file.type.startsWith('image/') || file.type.startsWith('video/')) return; // 사진 또는 이미지
                const url = URL.createObjectURL(file); // 브라우저 내부에서 보이는 임시url로 바꿔야 보임.
                const $img = $(
                `<img alt="첨부 이미지 미리보기"
                        src="${url}"
                        style="max-width:100%; height:auto; display:block; border-radius:8px; margin-top:6px;">`
                );
                $img.on('load', () => URL.revokeObjectURL(url));
                $preview.append($img);
            });
    });
});