<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="com.common.DBConnection"%>
<%@ page import="com.personalPlan.dao.TravelDAO"%>
<%@ page import="com.personalPlan.dto.TravelPlanDTO"%>
<%@ page import="com.travelReview.dao.ReviewDAO"%> 

<%
    // 파라미터 확인
    String paramNo = request.getParameter("travelNo");
    if(paramNo == null) { response.sendRedirect("../personalPlan/travelList.jsp"); return; }
    
    int travelNo = Integer.parseInt(paramNo);

    Connection conn = null;
    TravelDAO tDao = new TravelDAO();
    ReviewDAO rDao = new ReviewDAO(); // DAO 객체 생성
    
    List<TravelPlanDTO> planList = null;
    Map<Integer, Integer> reviewMap = null;

    try {
        conn = DBConnection.getConnection();
        
        // DAO를 사용해서 데이터 가져오기
        planList = tDao.selectPlanList(conn, travelNo);
        reviewMap = rDao.getReviewMap(conn, travelNo); 
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        DBConnection.close(conn);
    }
    
    request.setAttribute("pageTitle", "여행 후기 작성");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>여행 후기 작성</title>
    <link rel="stylesheet" href="../css/travelReview.css">
    <script src="../js/jquery-3.7.1.min.js"></script>
</head>
<body>
	<jsp:include page="../header.jsp" />

    <div class="container">
        <aside class="left-sidebar">
            <div class="sidebar-title">방문한 장소 목록</div>
            
            <% if(planList != null) { 
                for(TravelPlanDTO plan : planList) { 
                    String category = plan.getCategory();
                    
                    // '교통(transport)' 카테고리면 목록에서 건너뛰기
                    if (category != null && category.startsWith("transport")) {
                        continue; 
                    }

                    // 카테고리별 아이콘 설정
                    String icon = "📍";
                    if (category.contains("accommodation")) {
                        if(category.contains("호텔")) icon = "🏨";
                        else if(category.contains("에어비앤비")) icon = "🏠";
                        else icon = "🛏️";
                    } else if (category.contains("dining")) {
                        if(category.contains("식당")) icon = "🍽️";
                        else if(category.contains("카페")) icon = "☕";
                        else icon = "🍺";
                    } else if (category.contains("activity")) {
                        icon = "🎡";
                    } else if (category.contains("etc")) {
                        icon = "📝";
                    }

                    // 리뷰 작성 여부 확인 (Map에서 조회)
                    Integer reviewNo = reviewMap.get(plan.getPlanNo());
                    boolean isReviewed = (reviewNo != null);
                    String itemClass = isReviewed ? "place-item reviewed" : "place-item";
            %>
                <div class="<%=itemClass%>" 
                     onclick="selectPlace(this)"
                     data-plan-no="<%=plan.getPlanNo()%>"
                     data-title="<%=plan.getTitle()%>"
                     data-day="<%=plan.getDayNo()%>"
                     data-review-no="<%=isReviewed ? reviewNo : ""%>">
                    
                    <div class="place-icon"><%=icon%></div>
                    <div class="place-info">
                        <div class="place-name"><%=plan.getTitle()%></div>
                        <div class="place-day">Day <%=plan.getDayNo()%></div>
                        <div class="review-status">✅ 작성 완료</div>
                    </div>
                </div>
            <% }} %>
        </aside>

        <main class="right-main">
            <div id="empty-view" class="empty-state">
                <span class="empty-icon">📝</span>
                <h3>왼쪽 목록에서 후기를 남길 장소를 선택해주세요.</h3>
            </div>

            <div id="review-form-view" class="review-form-card" style="display:none;">
                <form id="reviewForm">
                    <input type="hidden" name="planNo" id="input-plan-no">
                    
                    <div class="form-header">
                        <h2 class="form-place-name" id="display-place-name">장소 이름</h2>
                        <div class="form-place-date" id="display-place-day">Day 1</div>
                    </div>

                    <div class="star-rating">
                        <input type="hidden" name="rating" id="input-rating" value="5">
                        <span class="star filled" data-value="1" onclick="setRating(1)">★</span>
                        <span class="star filled" data-value="2" onclick="setRating(2)">★</span>
                        <span class="star filled" data-value="3" onclick="setRating(3)">★</span>
                        <span class="star filled" data-value="4" onclick="setRating(4)">★</span>
                        <span class="star filled" data-value="5" onclick="setRating(5)">★</span>
                    </div>

                    <div style="margin-bottom:20px;">
                        <label class="input-label">어떤 점이 좋았나요?</label>
                        <textarea name="content" class="review-textarea" placeholder="솔직한 후기를 남겨주세요 (맛, 분위기, 꿀팁 등)"></textarea>
                    </div>

                    <div class="file-upload-wrapper">
                        <label class="input-label">사진 첨부 (선택)</label>
                        <label for="file-input" class="file-btn">📷 사진 선택하기</label>
                        <input type="file" id="file-input" multiple accept="image/*, video/*" style="display:none;" onchange="handleFiles(this)">
                        
                        <div id="image-preview-area" class="image-preview-grid"></div>
                    </div>

                    <button type="button" class="btn-save-review" onclick="submitReview()">후기 저장하기</button>
                </form>
            </div>
        </main>
    </div>

    <script src="../js/travelReview/travelReview.js"></script>
</body>
</html>