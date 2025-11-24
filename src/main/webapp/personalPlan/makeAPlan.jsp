<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="com.personalPlan.dao.TravelDAO" %>
<%@ page import="com.personalPlan.dto.TravelInfoDTO" %>
<%@ page import="com.personalPlan.dto.TravelPlanDTO" %>

<%
    // 1. 파라미터 받기 (URL에 있는 travelNo) 
    String paramNo = request.getParameter("travelNo");
    
    // travelNo가 없으면 목록으로 튕겨내기 (유효성 검사)
    if (paramNo == null || paramNo.equals("")) {
        response.sendRedirect("travelList.jsp");
        return;
    }

    int travelNo = Integer.parseInt(paramNo);

    // 2. DB 데이터 조회 준비
    Connection conn = null;
    TravelDAO dao = new TravelDAO();
    
    TravelInfoDTO info = null;      // 여행 기본 정보 (제목, 날짜 등)
    List<TravelPlanDTO> planList = null; // 세부 일정 리스트

    try {
        conn = DBConnection.getConnection();
        
        // (1) 여행 기본 정보 가져오기
        List<TravelInfoDTO> allList = dao.selectTravelList(conn);
        for (TravelInfoDTO dto : allList) {
            if (dto.getTravelNo() == travelNo) {
                info = dto;
                break;
            }
        }
        
        // (2) 세부 일정 가져오기
        planList = dao.selectPlanList(conn, travelNo);
        if (planList == null) planList = new ArrayList<>();

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        DBConnection.close(conn);
    }

    // 데이터가 없으면 목록으로
    if (info == null) {
        response.sendRedirect("travelList.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= info.getTitle() %> - 상세 계획</title>

<link rel="stylesheet" href="../css/makeAPlan.css">

<script src="../js/jquery-3.7.1.min.js"></script> 
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
    // 1. 기본 정보 전달 (이게 있어야 JS가 날짜를 계산해서 Day 버튼을 만듭니다!)
    window.serverTravelNo = "<%= info.getTravelNo() %>";
    window.serverTitle = "<%= info.getTitle().replace("\"", "\\\"") %>";
    window.serverStartDate = "<%= info.getStartDate() %>"; // YYYY-MM-DD
    window.serverEndDate = "<%= info.getEndDate() %>";     // YYYY-MM-DD
    window.serverMate = "<%= info.getCompanion() %>";
    
    // 2. 세부 일정 리스트 (DB에 저장된 일정 불러오기)
    window.serverPlanList = [
    <% 
        if(planList != null) {
            for(int i=0; i<planList.size(); i++) {
                TravelPlanDTO p = planList.get(i);
                
                // 날짜/시간 처리 (Timestamp -> String)
                String startStr = (p.getStartTime() != null) ? p.getStartTime().toString() : "";
                String endStr = (p.getEndTime() != null) ? p.getEndTime().toString() : "";
                
                // .0 (초 단위) 제거 및 포맷팅
                if(startStr.length() > 16) startStr = startStr.substring(0, 16);
                if(endStr.length() > 16) endStr = endStr.substring(0, 16);
    %>
        {
            planNo: <%= p.getPlanNo() %>,
            day: <%= p.getDayNo() %>,  /* JS에서는 day로 사용 */
            category: "<%= p.getCategory() %>",
            title: "<%= p.getTitle().replace("\"", "\\\"") %>",
            startTime: "<%= startStr %>", 
            endTime: "<%= endStr %>",
            bookingNo: "<%= (p.getBookingNo() == null) ? "" : p.getBookingNo() %>",
            location: "<%= (p.getLocation() == null) ? "" : p.getLocation().replace("\"", "\\\"") %>",
            cost: <%= p.getCost() %>
        }<%= (i < planList.size() - 1) ? "," : "" %> /* 마지막 콤마 제거 */
    <% 
            }
        } 
    %>
    ];

    console.log("DB 데이터 로드 완료:", window.serverPlanList); 
</script>

</head>
<body>

    <div class="header">
        <h2 onclick="location.href='travelList.jsp'" style="cursor: pointer;">
            ✈️ My 여행계획
        </h2>
    </div>

    <div class="container">
        
        <aside class="left-sidebar">
            <div class="travel-info-box">
                <h3><%= info.getTitle() %></h3> <p>📍 <%= info.getCountry() %></p> <p>📅 <%= info.getStartDate() %> ~ <%= info.getEndDate() %></p>
                
                <%
                    String mate = info.getCompanion();
                    if (mate == null || mate.equals("null") || mate.trim().isEmpty()) {
                        mate = "미정";
                    } else {
                        // DB에 텍스트만 있을 경우 이모티콘 다시 붙여주기
                        if (mate.contains("나홀로") && !mate.contains("🚶")) mate += " 🚶";
                        else if (mate.contains("연인") && !mate.contains("💑")) mate += " 💑";
                        else if (mate.contains("친구") && !mate.contains("👭")) mate += " 👭";
                        else if (mate.contains("가족") && !mate.contains("👨‍👩‍👧‍👦")) mate += " 👨‍👩‍👧‍👦";
                        else if (mate.contains("반려동물") && !mate.contains("🐕")) mate += " 🐕";
                    }
                %>
                <p>👥 <%= mate %></p>
                </div>

            <div id="day-container"></div>

            <div style="margin: 20px 0; border-top: 1px solid #eee;"></div>
            
            <button class="sidebar-footer-btn btn-budget" onclick="openBudgetModal()">💸 가계부 보기</button>
            <button class="sidebar-footer-btn btn-check" onclick="openChecklistModal()">✅ 체크리스트</button>
            <button class="sidebar-footer-btn btn-total" onclick="alert('준비중입니다!')">🗓 전체 일정 보기</button>
        </aside>

        <main class="right-main">
            <section class="map-area">
                <div id="map" style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; color:#888;">
                    🗺️ 지도 로딩중... (map.js)
                </div>
            </section>

            <section class="makeAplan">
                <div id="makeAplan-container">
                    </div>
            </section>
        </main>
    </div>

    <div id="modal-overlay" class="modal-overlay">
        <div class="modal-window">
            <div style="display:flex; justify-content:space-between; margin-bottom:15px;">
                <h3 id="modal-title" style="margin:0;">일정 추가</h3>
                <button onclick="closeModal()" style="border:none; background:none; font-size:24px; cursor:pointer;">×</button>
            </div>
            <ul id="modal-list" class="option-list"></ul>
        </div>
    </div>
    
    <div id="budget-modal" class="modal-overlay">
        <div class="modal-window" style="width: 500px;">
            <div style="display:flex; justify-content:space-between; margin-bottom:20px;">
                <h3 style="margin:0;">💸 여행 가계부</h3>
                <button onclick="closeBudgetModal()" style="border:none; background:none; font-size:24px; cursor:pointer;">×</button>
            </div>
            <div style="text-align:center; margin-bottom:20px;">
                <span style="font-size:18px; color:#333;">총 비용: </span>
                <span id="total-budget-display" style="font-size:24px; font-weight:bold; color:#3b82f6;">0원</span>
            </div>
            <div id="budget-segment-summary"></div>
            <div style="max-height:300px; overflow-y:auto; border-top:1px solid #eee; margin-top:10px;">
                <table style="width:100%; border-collapse:collapse;">
                    <tbody id="budget-list-body"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="../js/mypage/api_key.js"></script>
    <script src="../js/countryData.js"></script>
    <script src="../js/mypage/map.js"></script>
    <script src="../js/personalPlan/personalPlan_action.js"></script>
    

	<script src="../js/mypage/review_form.js"></script>
	<script src="../js/mypage/review_action.js"></script>
	<script src="../js/mypage/handler.js"></script>
	<script src="../js/mypage/main.js"></script>

</body>
</html>