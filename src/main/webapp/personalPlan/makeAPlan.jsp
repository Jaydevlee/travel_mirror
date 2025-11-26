<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.Timestamp"%>
<%@ page import="com.common.DBConnection"%>
<%@ page import="com.personalPlan.dao.TravelDAO"%>
<%@ page import="com.personalPlan.dto.TravelInfoDTO"%>
<%@ page import="com.personalPlan.dto.TravelPlanDTO"%>

<%
// 파라미터 확인
String paramNo = request.getParameter("travelNo");
if (paramNo == null || paramNo.equals("")) {
	response.sendRedirect("travelList.jsp");
	return;
}

int travelNo = Integer.parseInt(paramNo);
Connection conn = null;
TravelDAO dao = new TravelDAO();
TravelInfoDTO info = null;
List<TravelPlanDTO> planList = null;

// DB 조회
try {
    conn = DBConnection.getConnection();
    
    // 여행 정보 조회
    info = dao.selectTravelInfo(conn, travelNo);
    
    // 일정 리스트 조회
    planList = dao.selectPlanList(conn, travelNo);
    if (planList == null) planList = new ArrayList<>();

} catch (Exception e) {
    e.printStackTrace();
} finally {
    DBConnection.close(conn);
}

// 여행 정보가 없으면 목록으로
if (info == null) {
	response.sendRedirect("travelList.jsp");
	return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%=info.getTitle()%> - 상세 계획</title>

<link rel="stylesheet" href="../css/makeAPlan.css">

<script src="../js/jquery-3.7.1.min.js"></script>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>
<link
	href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css"
	rel="stylesheet" />
<script
	src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script>
        window.serverTravelNo = "<%=info.getTravelNo()%>";
        window.serverTitle = "<%=info.getTitle().replace("\"", "\\\"")%>";
        window.serverStartDate = "<%=info.getStartDate()%>"; 
        window.serverEndDate = "<%=info.getEndDate()%>";
        window.serverMate = "<%=info.getCompanion()%>";
        window.currentUserId = "<%= (String)session.getAttribute("sessionId") != null ? (String)session.getAttribute("sessionId") : "" %>";
        
        window.serverPlanList = [
        <%if (planList != null) {
	for (int i = 0; i < planList.size(); i++) {
		TravelPlanDTO p = planList.get(i);
		String startStr = (p.getStartTime() != null) ? p.getStartTime().toString() : "";
		String endStr = (p.getEndTime() != null) ? p.getEndTime().toString() : "";
		if (startStr.length() > 16)
			startStr = startStr.substring(0, 16);
		if (endStr.length() > 16)
			endStr = endStr.substring(0, 16);%>
            {
                planNo: <%=p.getPlanNo()%>,
                day: <%=p.getDayNo()%>,  
                category: "<%=p.getCategory()%>",
                title: "<%=p.getTitle().replace("\"", "\\\"")%>",
                startTime: "<%=startStr%>", 
                endTime: "<%=endStr%>",
                bookingNo: "<%=(p.getBookingNo() == null) ? "" : p.getBookingNo()%>",
                location: "<%=(p.getLocation() == null) ? "" : p.getLocation().replace("\"", "\\\"")%>",
                cost: <%=p.getCost()%>
            }<%=(i < planList.size() - 1) ? "," : ""%> 
        <%}
}%>
        ];
    </script>
</head>
<body>

	<div class="header">
		<h2 onclick="location.href='travelList.jsp'">✈️ My 여행계획</h2>
	</div>

	<div class="container">
		<aside class="left-sidebar">
			<div class="travel-info-box">
				<div class="info-header">
					<h3><%=info.getTitle()%></h3>
					<button onclick="openTravelEditModal()" class="btn-icon-edit"
						title="여행 정보 수정">✏️</button>
				</div>
				<p>
					📍
					<%=info.getCountry()%></p>
				<p>
					📅 <span id="disp-start-date"><%=info.getStartDate()%></span> ~ <span
						id="disp-end-date"><%=info.getEndDate()%></span>
				</p>

				<%
				String mate = info.getCompanion();
				if (mate == null || mate.equals("null") || mate.trim().isEmpty()) {
					mate = "미정";
				} else {
					if (mate.contains("나홀로") && !mate.contains("🚶"))
						mate += " 🚶";
					else if (mate.contains("연인") && !mate.contains("💑"))
						mate += " 💑";
					else if (mate.contains("친구") && !mate.contains("👭"))
						mate += " 👭";
					else if (mate.contains("가족") && !mate.contains("👨‍👩‍👧‍👦"))
						mate += " 👨‍👩‍👧‍👦";
					else if (mate.contains("반려동물") && !mate.contains("🐕"))
						mate += " 🐕";
				}
				%>
				<p>
					👥
					<%=mate%></p>
			</div>

			<div id="day-container"></div>

			<div style="margin: 20px 0; border-top: 1px solid #eee;"></div>

			<button class="sidebar-footer-btn btn-budget"
				onclick="openBudgetModal()">💸 가계부 보기</button>
			<button class="sidebar-footer-btn btn-check"
				onclick="openChecklistModal()">✅ 체크리스트</button>
			<button class="sidebar-footer-btn btn-total"
				onclick="openAllPlanModal()">🗓 전체 일정 보기</button>

			<button class="sidebar-footer-btn btn-review"
				onclick="location.href='../travelReview/travelReview.jsp?travelNo=<%=info.getTravelNo()%>'">
				📝 여행 후기 작성</button>
				
				<button class="sidebar-footer-btn btn-wishlist"
				 onclick="location.href='../travelReview/wishList.jsp'" >
    					♥ 찜한 여행 보기 </button>
		</aside>

		<main class="right-main">
			<section class="map-area">
				<div id="map-controls" class="map-controls-container">
					<input id="pac-input" class="map-search-input" type="text"
						placeholder="장소 검색 (예: 에펠탑)">
					<div class="map-checkbox-wrapper">
						<input type="checkbox" id="show-hotel-check" checked
							onchange="toggleAccommodation()" class="map-checkbox"> <label
							for="show-hotel-check" class="map-checkbox-label">숙소 표시</label>
					</div>
				</div>
				<div id="map" class="map-loading">🗺️ 지도 로딩중...</div>
			</section>

			<section class="makeAplan">
				<div id="makeAplan-container"></div>
			</section>
		</main>
	</div>

	<div id="modal-overlay" class="modal-overlay">
		<div class="modal-window" style="width: 400px;">
			<div class="modal-header">
				<h3 id="modal-title">일정 추가</h3>
				<button onclick="closeModal()" class="btn-close-modal">×</button>
			</div>
			<ul id="modal-list" class="option-list"></ul>
		</div>
	</div>

	<div id="budget-modal" class="modal-overlay">
		<div class="modal-window" style="width: 500px;">
			<div class="modal-header">
				<h3>💸 여행 가계부</h3>
				<button onclick="closeBudgetModal()" class="btn-close-modal">×</button>
			</div>
			<div class="budget-total-area">
				<span class="budget-total-label">총 비용: </span> <span
					id="total-budget-display" class="budget-total-amount">0원</span>
			</div>
			<div class="budget-table-container">
				<table class="budget-table">
					<tbody id="budget-list-body"></tbody>
				</table>
			</div>
		</div>
	</div>

	<div id="checklist-modal" class="modal-overlay">
		<div class="modal-window">
			<div class="modal-header">
				<h3>✅ 체크리스트</h3>
			</div>

			<div class="checklist-input-group">
				<input type="text" id="new-check-item" class="checklist-input"
					placeholder="준비물 입력">
				<button onclick="addCheckItem()" class="btn-checklist-add">추가</button>
			</div>
			<ul id="checklist-ul" class="checklist-ul"></ul>

			<button onclick="closeChecklistModal()" class="btn-checklist-close">닫기</button>
		</div>
	</div>

	<div id="all-plan-modal" class="modal-overlay">
		<div class="modal-window all-plan-window">
			<div class="all-plan-header-area">
				<h3>🗺️ 전체 여행 경로 & 일정</h3>
				<div>
					<button onclick="printAllPlan()" class="btn-modal-submit"
						style="width: auto; padding: 5px 10px; margin: 0;">🖨️ 인쇄</button>
					<button onclick="closeAllPlanModal()" class="btn-close-modal">✖</button>
				</div>
			</div>
			<div id="modal-map-area"></div>
			<div id="all-plan-content"></div>
		</div>
	</div>

	<div id="travel-edit-modal" class="modal-overlay">
		<div class="modal-window" style="width: 400px;">
			<div class="modal-header">
				<h3>여행 정보 수정</h3>
				<button onclick="closeTravelEditModal()" class="btn-close-modal">×</button>
			</div>
			<div style="margin-bottom: 15px;">
				<label class="modal-label">여행 제목</label> <input type="text"
					id="edit-travel-title" class="modal-input-text">
			</div>
			<div style="margin-bottom: 15px;">
				<label class="modal-label">누구와 함께?</label> <select
					id="edit-travel-mate" class="modal-select">
					<option value="나홀로">나홀로 🚶</option>
					<option value="연인과">연인과 💑</option>
					<option value="친구와">친구와 👭</option>
					<option value="가족과">가족과 👨‍👩‍👧‍👦</option>
					<option value="반려동물과">반려동물과 🐕</option>
				</select>
			</div>
			<div style="margin-bottom: 20px;">
				<label class="modal-label">여행 기간</label>
				<div style="display: flex; gap: 10px;">
					<input type="date" id="edit-start-date" class="modal-input-date">
					<span style="align-self: center;">~</span> <input type="date"
						id="edit-end-date" class="modal-input-date">
				</div>
			</div>
			<button onclick="submitTravelEdit()" class="btn-modal-submit">수정
				완료</button>
		</div>
	</div>

	<script src="../js/countryData.js"></script>
	<script
		src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBdoGjJDp1c2WPiM8zSdTJbHx5OUBhyFY8&libraries=places&language=ko"></script>
	<script src="../js/personalPlan/personalPlan_action.js"></script>

</body>
</html>