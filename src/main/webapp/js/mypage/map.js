// map.js - Google Maps API 관리 모듈

let map;
let geocoder;
let markers = []; // {marker, groupId, index, position, reviewId}
let polylines = []; // {polyline, groupId}
let currentGroupId = null;
let groupLabelIndexes = {}; // 그룹별 labelIndex 관리

// Google 맵 API 동적로드
function loadGoogleMaps() {
    const script = document.createElement('script');
    script.src = `https://maps.googleapis.com/maps/api/js?key=${YOUR_API_KEY}&libraries=places,geometry&v=weekly&callback=initMap`;
    script.async = true;
    script.defer = true;
    document.head.appendChild(script);
}

async function initMap() {
    // 초기위치
    const initialLocation = { lat: 37.5665, lng: 126.9780 };
    map = new google.maps.Map(document.getElementById("map"), {
        center: initialLocation,
        zoom: 16,
    });

    // 지오코더 (좌표 -> 주소 변환)
    geocoder = new google.maps.Geocoder();
    
    // 장소 검색 설정
    setupPlaceSearch();
    
    // 지도 클릭 이벤트 설정
    setupMapClickEvent();
    
    // 저장된 리뷰 불러오기
    loadReviews();
}

// 장소 검색 기능 설정
function setupPlaceSearch() {
    const search_input = document.getElementById("address_search");
    const searchBtn = document.getElementById("btn_search");
    const autocomplete = new google.maps.places.Autocomplete(search_input, {
        fields: ["geometry", "name", "formatted_address"]
    });

    // 검색 실행 함수
    const performSearch = async () => {
        // 현재 작성 중인 그룹이 있는지 확인
        if (!currentGroupId) {
            alert("먼저 여행 리뷰 작성하기 버튼을 클릭해주세요.");
            return;
        }
        
        const place = autocomplete.getPlace();
        if (!place || !place.geometry || !place.geometry.location) {
            alert("장소를 선택해주세요.");
            return;
        }
        
        // 검색된 장소로 지도 이동 및 확대
        map.setCenter(place.geometry.location);
        map.setZoom(17);

        // 마커 및 리뷰 폼 생성
        await createMarkerAndReview(place.geometry.location, place.name);
        
        // 검색창 초기화
        search_input.value = '';
    };

    // 엔터키로 검색
    search_input.addEventListener("keypress", async function(e) {
        if (e.key === "Enter") {
            e.preventDefault();
            await performSearch();
        }
    });

    // 검색 버튼 클릭
    if (searchBtn) {
        searchBtn.addEventListener("click", async function(e) {
            e.preventDefault();
            await performSearch();
        });
    }
}

// 지도 클릭 이벤트 설정
function setupMapClickEvent() {
    google.maps.event.addListener(map, "click", async function(event) {
        // 현재 작성 중인 그룹이 있는지 확인
        if (!currentGroupId) {
            alert("먼저 여행 리뷰 작성하기 버튼을 클릭해주세요.");
            return;
        }
        
        await createMarkerAndReview(event.latLng);
    });
}

// 마커 및 리뷰 생성 (통합 함수)
async function createMarkerAndReview(latLng, providedPlaceName = null) {
    // 좌표
    const lat = latLng.lat().toFixed(5);
    const lng = latLng.lng().toFixed(5);
    
    // 그룹별 인덱스 가져오기
    if (!groupLabelIndexes[currentGroupId]) {
        groupLabelIndexes[currentGroupId] = 1;
    }
    const currentIndex = groupLabelIndexes[currentGroupId];
    groupLabelIndexes[currentGroupId]++;

    // 마커 생성
    const marker = new google.maps.Marker({
        position: latLng,
        map: map,
        animation: google.maps.Animation.DROP,
        label: {
            text: String(currentIndex),
            color: '#ffffff',
            fontWeight: 'bold'
        },
        draggable: false,
    });
    
    // 마커 정보 저장
    const markerData = {
        marker: marker,
        groupId: currentGroupId,
        index: currentIndex,
        position: latLng,
        reviewId: null // 리뷰 작성 시 업데이트
    };
    markers.push(markerData);

    // 주소 검색
    const address = await getAddress(latLng);
    
    // 장소명 검색
    const placeName = providedPlaceName || await getPlaceName(latLng, address.components);
    const placeName2 = placeName;
    
    // 폴리라인 그리기
    drawPolyline(currentGroupId);
    
    // 리뷰 작성 폼 생성
    createReviewFormInGroup(lat, lng, placeName, placeName2, address.formatted, currentIndex, currentGroupId);
    
    return markerData;
}

// 주소 검색
async function getAddress(latLng) {
    try {
        const result = await geocoder.geocode({location: latLng});
        if (result.results[0]) {
            return {
                formatted: result.results[0].formatted_address,
                components: result.results[0].address_components
            };
        }
    } catch(e) {
        console.error("주소 검색 오류:", e);
    }
    return {
        formatted: "주소 없음",
        components: []
    };
}

// 장소명 검색
async function getPlaceName(latLng, addressComponents) {
    try {
        const service = new google.maps.places.PlacesService(map);
        const placeName = await new Promise((resolve) => {
            service.nearbySearch({
                location: latLng,
                radius: 5,
            }, (results, status) => {
                if (status === google.maps.places.PlacesServiceStatus.OK && results && results.length > 0) {
                    let bestPlace = null;
                    let minDistance = null;

                    for (let place of results) {
                        const types = place.types || [];
                        const name = place.name;
                        
                        const banTypes = ['country','political'];
                        const hasBanType = types.some(type => banTypes.includes(type));
                        const banName = ['대한민국', 'South Korea', '구', '동'];
                        const hasBanName = banName.some(banned => name.includes(banned));

                        if (!hasBanType && !hasBanName && name) {
                            const placeLocation = place.geometry.location;
                            const distance = google.maps.geometry.spherical.computeDistanceBetween(
                                latLng,
                                placeLocation
                            );
                            
                            if (distance < 5 && (minDistance === null || distance < minDistance)) {
                                minDistance = distance;
                                bestPlace = { name, distance };
                            }
                        }
                    }
                    resolve(bestPlace ? bestPlace.name : "");
                } else {
                    resolve("");
                }
            });
        });
        
        return placeName;
    } catch(e) {
        console.error("장소명 검색 오류:", e);
        const sublocality = addressComponents.find(comp =>
            comp.types.includes('sublocality_level_2')
        );
        return sublocality ? sublocality.long_name : "";
    }
}

// 폴리라인 그리기
function drawPolyline(groupId) {
    // 해당 그룹의 마커들만 필터링
    const groupMarkers = markers.filter(m => m.groupId === groupId);
    
    if (groupMarkers.length < 2) {
        return; // 마커가 2개 미만이면 선을 그리지 않음
    }
    
    // 기존 폴리라인 제거
    const existingPolylines = polylines.filter(p => p.groupId === groupId);
    existingPolylines.forEach(p => p.polyline.setMap(null));
    polylines = polylines.filter(p => p.groupId !== groupId);
    
    // 새 폴리라인 그리기
    const path = groupMarkers.map(m => m.position);
    const polyline = new google.maps.Polyline({
        path: path,
        geodesic: true,
        strokeColor: '#41E9C2',
        strokeOpacity: 1.0,
        strokeWeight: 3
    });
    
    polyline.setMap(map);
    polylines.push({
        polyline: polyline,
        groupId: groupId
    });
    
    // 거리 계산 및 표시
    calculateAndDisplayDistance(groupMarkers, groupId);
}

// 거리 계산 및 표시
function calculateAndDisplayDistance(groupMarkers, groupId) {
    let totalDistance = 0;
    
    // 첫 번째 마커의 거리 정보 제거
    if (groupMarkers.length > 0) {
        const $firstReview = $(`.review_list li[data-group-id="${groupId}"] li[data-marker-index="1"]`);
        if ($firstReview.length) {
            $firstReview.find('.distance_info').remove();
        }
    }
    
    for (let i = 0; i < groupMarkers.length - 1; i++) {
        const from = groupMarkers[i].position;
        const to = groupMarkers[i + 1].position;
        const distance = google.maps.geometry.spherical.computeDistanceBetween(from, to);
        totalDistance += distance;
        
        // 각 구간 거리를 리뷰 폼에 표시 (두 번째부터)
        const distanceText = formatDistance(distance);
        updateReviewDistance(groupMarkers[i + 1].index, distanceText, groupId);
    }
    
    // 전체 거리를 그룹 폼에 표시
    const totalDistanceText = formatDistance(totalDistance);
    updateGroupDistance(groupId, totalDistanceText);
}

// 거리 포맷팅 (1km 미만은 m 단위)
function formatDistance(meters) {
    if (meters < 1000) {
        return `${Math.round(meters)}m`;
    } else {
        return `${(meters / 1000).toFixed(2)}km`;
    }
}

// 리뷰에 거리 정보 업데이트
function updateReviewDistance(markerIndex, distance, groupId) {
    const $review = $(`.review_list li[data-group-id="${groupId}"] li[data-marker-index="${markerIndex}"]`);
    if ($review.length) {
        let $distanceInfo = $review.find('.distance_info');
        if (!$distanceInfo.length) {
            $distanceInfo = $('<div class="distance_info"></div>');
            $review.find('.addr_area').after($distanceInfo);
        }
        $distanceInfo.text(`이전 위치로부터 ${distance}`);
    }
}

// 그룹에 전체 거리 정보 업데이트
function updateGroupDistance(groupId, totalDistance) {
    const $group = $(`.review_list > li[data-group-id="${groupId}"]`);
    if ($group.length) {
        let $totalDistance = $group.find('.total_distance_info');
        if (!$totalDistance.length) {
            $totalDistance = $('<div class="total_distance_info" style="color: #fff; font-size: 0.9rem; margin-top: 5px;"></div>');
            $group.find('.card_head .card_title').append($totalDistance);
        }
        $totalDistance.text(`전체 거리: ${totalDistance}`);
    }
}

// 마커 제거 (인덱스로) 및 재정렬
function removeMarkerByIndex(groupId, markerIndex) {
    const markerData = markers.find(m => m.groupId === groupId && m.index === markerIndex);
    if (markerData) {
        // 지도에서 마커 제거
        markerData.marker.setMap(null);
        
        // 배열에서 제거
        markers = markers.filter(m => !(m.groupId === groupId && m.index === markerIndex));
        
        // 해당 그룹의 남은 마커들을 재정렬
        reorderGroupMarkers(groupId);
        
        // 폴리라인 다시 그리기
        drawPolyline(groupId);
        
        return true;
    }
    return false;
}

// 그룹 마커 재정렬
function reorderGroupMarkers(groupId) {
    // 해당 그룹의 마커들을 가져와서 정렬
    const groupMarkers = markers.filter(m => m.groupId === groupId);
    groupMarkers.sort((a, b) => a.index - b.index);
    
    // 마커 번호 재할당
    groupMarkers.forEach((markerData, idx) => {
        const newIndex = idx + 1;
        const oldIndex = markerData.index;
        
        // 인덱스 업데이트
        markerData.index = newIndex;
        
        // 마커 라벨 업데이트
        markerData.marker.setLabel({
            text: String(newIndex),
            color: '#ffffff',
            fontWeight: 'bold'
        });
        
        // DOM에서 해당 리뷰 폼의 마커 인덱스도 업데이트
        const $reviewLi = $(`.review_list li[data-group-id="${groupId}"] li[data-marker-index="${oldIndex}"]`);
        if ($reviewLi.length) {
            $reviewLi.attr('data-marker-index', newIndex);
            
            // 마커 인덱스 표시 업데이트
            $reviewLi.find('.marker_index').text(newIndex);
        }
    });
    
    // 그룹의 labelIndex를 현재 마커 개수 + 1로 설정
    groupLabelIndexes[groupId] = groupMarkers.length + 1;
}

// 그룹의 모든 마커 제거
function removeGroupMarkers(groupId) {
    // 해당 그룹의 마커들 찾기
    const groupMarkers = markers.filter(m => m.groupId === groupId);
    
    // 각 마커를 지도에서 제거
    groupMarkers.forEach(markerData => {
        markerData.marker.setMap(null);
    });
    
    // 배열에서 제거
    markers = markers.filter(m => m.groupId !== groupId);
    
    // 폴리라인 제거
    const groupPolylines = polylines.filter(p => p.groupId === groupId);
    groupPolylines.forEach(p => p.polyline.setMap(null));
    polylines = polylines.filter(p => p.groupId !== groupId);
    
    // 그룹 인덱스 초기화
    delete groupLabelIndexes[groupId];
}

// 리뷰 ID와 마커 연결
function linkReviewToMarker(groupId, markerIndex, reviewId) {
    const markerData = markers.find(m => m.groupId === groupId && m.index === markerIndex);
    if (markerData) {
        markerData.reviewId = reviewId;
    }
}

// 리뷰 위치로 지도 이동
function moveToReviewLocation(review) {
    if (!review || !review.location) {
        console.warn('리뷰에 위치 정보가 없습니다.');
        return;
    }

    const { lat, lng } = review.location;
    const position = new google.maps.LatLng(Number(lat), Number(lng));
    
    map.setCenter(position);
    map.setZoom(18);
}

// 현재 그룹 ID 설정
function setCurrentGroupId(groupId) {
    currentGroupId = groupId;
}

// 현재 그룹 ID 가져오기
function getCurrentGroupId() {
    return currentGroupId;
}

// 검색창 포커스
function focusSearchInput() {
    const searchInput = document.getElementById("address_search");
    if (searchInput) {
        searchInput.focus();
    }
}

// 저장된 리뷰 로드 시 마커 복원
function restoreMarkersForReviews(reviews) {
    // 그룹별로 리뷰 분류
    const groupedReviews = {};
    reviews.forEach(review => {
        const groupId = review.groupId || 'default';
        if (!groupedReviews[groupId]) {
            groupedReviews[groupId] = [];
        }
        groupedReviews[groupId].push(review);
    });
    
    // 각 그룹의 리뷰에 대해 마커 복원
    Object.keys(groupedReviews).forEach(groupId => {
        const groupReviews = groupedReviews[groupId];
        
        groupReviews.forEach(review => {
            if (review.location && review.markerIndex) {
                const latLng = new google.maps.LatLng(
                    Number(review.location.lat),
                    Number(review.location.lng)
                );
                
                const marker = new google.maps.Marker({
                    position: latLng,
                    map: map,
                    label: {
                        text: String(review.markerIndex),
                        color: '#ffffff',
                        fontWeight: 'bold'
                    },
                    draggable: false,
                });
                
                markers.push({
                    marker: marker,
                    groupId: review.groupId,
                    index: review.markerIndex,
                    position: latLng,
                    reviewId: review.id
                });
                
                // 그룹 인덱스 업데이트
                if (!groupLabelIndexes[groupId]) {
                    groupLabelIndexes[groupId] = 1;
                }
                if (review.markerIndex >= groupLabelIndexes[groupId]) {
                    groupLabelIndexes[groupId] = review.markerIndex + 1;
                }
            }
        });
        
        // 폴리라인 그리기
        if (groupReviews.length > 1) {
            drawPolyline(groupId);
        }
    });
}
