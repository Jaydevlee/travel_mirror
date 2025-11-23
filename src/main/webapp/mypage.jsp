<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>My Page</title>
  <link rel="stylesheet" href="css/mypage_stlye.css">
</head>
<body>
  <div id="container">
		
    <div id="body">
      <!--지도 영역 -->
      <div id="map"></div>
      
      <!--후기 영역-->
      <div class="button_search_container">
        <!--검색창-->
        <div class="search_frame">
          <div class="search_area">
            <input id="address_search" type="text" placeholder="주소 또는 장소를 검색하세요 (Enter 또는 검색 버튼 클릭)">
            <button type="button" id="btn_search" class="btn_search">검색</button>
          </div>
        </div>
        
        <!-- 리뷰 작성 버튼 -->
        <div class="create_group_btn_area">
          <button type="button" id="btn_create_group" class="btn_create_group">여행 리뷰 작성하기</button>
        </div>
      </div>
      <form>
        <ul class="review_list">
          <!--후기 작성시 동적 li 추가-->
        </ul>
      </form>
    </div>
  </div>
  <!--footer-->
</div>
<!--
1. HTML + CSS 로드
2. jQuery 로드
3. 모듈 파일 로드 (storage, map, review-form 등)
4. main.js 실행
    ├─ UI 이벤트 연결
    ├─ 별점 초기화
    └─ Google Maps API 호출
5. Google Maps 준비 완료 → initMap() 실행
-->
<!--스토리지는 공통으로 사용하기 때문에 외부로-->
<script src="js/jquery-3.7.1.min.js"></script>
<script src="js/storage.js"></script>

<script src="js/mypage/api_key.js"></script>
<script src="js/mypage/review_form.js"></script>
<script src="js/mypage/review_action.js"></script>
<script src="js/mypage/map.js"></script>
<script src="js/mypage/handler.js"></script>
<script src="js/mypage/main.js"></script>

</body>
</html>
