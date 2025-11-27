<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="com.common.DBConnection"%>
<%@ page import="com.personalPlan.dao.TravelDAO"%>
<%@ page import="com.personalPlan.dto.TravelInfoDTO"%>

<%
    // 세션에서 로그인한 아이디 가져오기 (sessionId)
    String memberId = (String) session.getAttribute("sessionId");

    // 로그인 안 했으면 로그인 페이지로 보내기
    if (memberId == null) {
        response.sendRedirect("../login/login.jsp"); 
        return;
    }

    Connection conn = null;
    TravelDAO dao = new TravelDAO();
    List<TravelInfoDTO> list = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 내 아이디(memberId)를 넣어서 '내 여행만' 조회하기
        list = dao.selectMyTravelList(conn, memberId);
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        DBConnection.close(conn);
    }
    request.setAttribute("pageTitle", "내 여행 리스트");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>나의 여행 계획 - Dashboard</title>

    <link rel="stylesheet" href="../css/travelList.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.2.3/css/flag-icons.min.css" />

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

    <script src="../js/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
</head>
<body>
	<jsp:include page="../header.jsp" />

    <div class="dashboard-container">

        <div class="plan-grid">
            <div class="plan-card add-new-card" onclick="openInitModal()">
                <div class="add-icon">+</div>
                <div class="add-text">새로운 여행 떠나기</div>
            </div>

            <%-- 여행 리스트 반복 출력 --%>
            <%
            if (list != null) {
                for (TravelInfoDTO dto : list) {
                    String bgClass = "bg-default";
                    String country = dto.getCountry();
                    
                    // 국가별 배경색 지정
                    if (country.contains("일본")) bgClass = "bg-japan";
                    else if (country.contains("유럽") || country.contains("프랑스") || country.contains("영국")) bgClass = "bg-europe";
                    else if (country.contains("바다") || country.contains("휴양")) bgClass = "bg-sea";
            %>
            <div class="plan-card" data-country="<%=dto.getCountry()%>"
                onclick="location.href='makeAPlan.jsp?travelNo=<%=dto.getTravelNo()%>'">

                <button class="delete-travel-btn"
                    onclick="deleteTravel(event, <%=dto.getTravelNo()%>)">×</button>

                <div class="card-img-placeholder <%=bgClass%>">
                    <span class="flag-icon">✈️</span>
                </div>

                <div class="card-body">
                    <div>
                        <div class="card-title"><%=dto.getTitle()%></div>
                        <div class="card-meta">📍 <%=dto.getCountry()%></div>
                        <div class="card-meta">
                            <%
                            String mate = dto.getCompanion();
                            if (mate == null || mate.equals("null")) {
                                mate = "미정";
                            } else {
                                if (mate.contains("나홀로") && !mate.contains("🚶")) mate += " 🚶";
                                else if (mate.contains("연인") && !mate.contains("💑")) mate += " 💑";
                                else if (mate.contains("친구") && !mate.contains("👭")) mate += " 👭";
                                else if (mate.contains("가족") && !mate.contains("👨‍👩‍👧‍👦")) mate += " 👨‍👩‍👧‍👦";
                                else if (mate.contains("반려동물") && !mate.contains("🐕")) mate += " 🐕";
                            }
                            %>
                            👥 <%=mate%>
                        </div>
                    </div>
                    <div class="card-date">
                        <%=dto.getStartDate()%> ~ <%=dto.getEndDate()%>
                    </div>
                </div>
            </div>
            <%
                }
            }
            %>
        </div>
    </div>

    <div id="init-modal-overlay" class="modal-overlay">
        <div class="modal-window">
            <div style="display: flex; justify-content: space-between; margin-bottom: 20px;">
                <h3 style="margin: 0;">여행 정보 입력</h3>
                <button onclick="closeInitModal()" style="border: none; background: none; font-size: 24px; cursor: pointer;">×</button>
            </div>

            <form action="travelWriteAction.jsp" method="post">
                <div class="input-group">
                    <label>여행 제목</label> 
                    <input type="text" name="title" placeholder="예: 3박 4일 도쿄 먹방" required>
                </div>

                <div class="input-group">
                    <label>여행 국가</label> 
                    <select id="select-country" name="country" multiple="multiple" style="width: 100%;">
                        <option></option>
                    </select>
                </div>

                <div class="input-group">
                    <label>누구와 함께?</label> 
                    <select name="companion">
                        <option value="나홀로">나홀로 🚶</option>
                        <option value="친구와">친구와 👭</option>
                        <option value="연인과">연인과 💑</option>
                        <option value="가족과">가족과 👨‍👩‍👧‍👦</option>
                        <option value="반려동물과">반려동물과 🐕</option>
                    </select>
                </div>

                <div class="input-group">
                    <label>여행 기간</label>
                    <div style="display: flex; gap: 10px;">
                        <input type="text" name="startDate" class="date-picker" placeholder="가는 날" required> 
                        <input type="text" name="endDate" class="date-picker" placeholder="오는 날" required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">일정 생성하기</button>
            </form>
        </div>
    </div>

    <script src="../js/countryData.js"></script>
    <script src="../js/personalPlan/travelList.js"></script>

</body>
</html>