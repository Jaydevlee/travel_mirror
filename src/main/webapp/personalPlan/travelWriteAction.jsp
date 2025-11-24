<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Date" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="com.personalPlan.dao.TravelDAO" %>
<%@ page import="com.personalPlan.dto.TravelInfoDTO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String title = request.getParameter("title");
    String country = request.getParameter("country");
    String companion = request.getParameter("companion");
    String startDateStr = request.getParameter("startDate");
    String endDateStr = request.getParameter("endDate");

    int result = 0;
    
    try {
        Connection conn = DBConnection.getConnection();
        TravelDAO dao = new TravelDAO();
        TravelInfoDTO dto = new TravelInfoDTO();

        Date start = Date.valueOf(startDateStr);
        Date end = Date.valueOf(endDateStr);

        // DTO에 값 채우기
        dto.setTitle(title);
        dto.setCountry(country);
        dto.setCompanion(companion);
        dto.setStartDate(start);
        dto.setEndDate(end);
        
        // DAO를 통해 DB에 저장 (INSERT)
        result = dao.insertTravelInfo(conn, dto);
        
        DBConnection.close(conn);
        
    } catch (Exception e) {
        e.printStackTrace();
        result = -1; 
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>처리 중...</title>
</head>
<body>
    <script>
        <% if (result > 0) { %>
            alert("여행 계획이 성공적으로 생성되었습니다! ✈️");
            location.href = "travelList.jsp";
        <% } else { %>
            alert("여행 계획 생성에 실패했습니다.\n입력 정보를 확인해주세요.");
            history.back();
        <% } %>
    </script>
</body>
</html>