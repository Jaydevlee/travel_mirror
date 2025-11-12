// main.js - 메인 초기화 및 통합

// 페이지 로드 시 초기화
$(document).ready(function() {
    // UI 이벤트 핸들러 초기화
    initUIHandlers();
    
    // 별점 초기화
    initStarRatings();
    
    // Google Maps 로드
    loadGoogleMaps();
});

// Google Maps 콜백 함수 (전역으로 등록)
window.initMap = initMap;