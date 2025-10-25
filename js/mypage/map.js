// map.js - Google Maps API 관리 모듈

let map;
let marker;
let labelIndex = 1;
let markers = [];

// Google 맵 API 동적로드
function loadGoogleMaps() {
    const script = document.createElement('script');
    script.src = `https://maps.googleapis.com/maps/api/js?key=${YOUR_API_KEY}&libraries=places,geometry&v=weekly&callback=initMap`;
    script.async = true;
    script.defer = true;
    document.head.appendChild(script);
}

async function initMap() {
    //초기위치
    const initialLocation = { lat: 37.5665, lng: 126.9780 };
    map = new google.maps.Map(document.getElementById("map"), {
        center: initialLocation,
        zoom: 16,
    });

    //지오코더 (좌표 -> 주소 변환)
    const geocoder = new google.maps.Geocoder();
    
    //장소 검색 설정
    setupPlaceSearch();
    
    //지도 클릭 이벤트 설정
    setupMapClickEvent(geocoder);
    
    //저장된 리뷰 불러오기
    loadReviews();
}

// 장소 검색 기능 설정
function setupPlaceSearch() {
    const serach_input = document.getElementById("address_search");
    const autocomplete = new google.maps.places.Autocomplete(serach_input, {
        fields: ["geometry", "name", "formatted_address"]
    });

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
        new google.maps.Marker({
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
}

// 지도 클릭 이벤트 설정
function setupMapClickEvent(geocoder) {
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

        //0.5초 딜레이 후 마커 추가
        setTimeout(() => {
            marker.setLabel(String(currentIndex));
        }, 500);
        labelIndex++; 

        //주소 검색
        const address = await getAddress(geocoder, latLng);
        
        //장소명 검색
        const placeName = await getPlaceName(latLng, address.components);
        
        //리뷰 작성 폼 생성
        createWriteForm(lat, lng, placeName, address.formatted, currentIndex);
    });
}

// 주소 검색
async function getAddress(geocoder, latLng) {
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
    
    new google.maps.Marker({
        position: position,
        map: map,
        animation: google.maps.Animation.DROP
    });
}