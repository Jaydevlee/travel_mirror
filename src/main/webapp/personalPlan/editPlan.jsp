<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="com.personalPlan.dao.TravelDAO" %>
<%@ page import="com.personalPlan.dto.TravelPlanDTO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 파라미터 받기
    String planNoStr = request.getParameter("planNo"); // PK
    String category = request.getParameter("category");
    String title = request.getParameter("title");
    String bookingNo = request.getParameter("bookingNo");
    String startTimeStr = request.getParameter("startTime"); 
    String endTimeStr = request.getParameter("endTime");
    String location = request.getParameter("location");
    String costStr = request.getParameter("cost");

    String resultMsg = "fail";

    if(planNoStr != null && !planNoStr.isEmpty()) {
        Connection conn = null;
        try {

            int planNo = Integer.parseInt(planNoStr);
            int cost = (costStr == null || costStr.equals("")) ? 0 : Integer.parseInt(costStr);
            
            if(startTimeStr.length() == 16) startTimeStr += ":00";
            if(endTimeStr != null && endTimeStr.length() == 16) endTimeStr += ":00";
            
            Timestamp startTs = Timestamp.valueOf(startTimeStr);
            Timestamp endTs = (endTimeStr == null || endTimeStr.isEmpty()) ? startTs : Timestamp.valueOf(endTimeStr);

            //  DTO 생성 및 값 세팅
            TravelPlanDTO plan = new TravelPlanDTO();
            plan.setPlanNo(planNo);      // WHERE 조건
            plan.setCategory(category);  // SET
            plan.setTitle(title);
            plan.setBookingNo(bookingNo);
            plan.setStartTime(startTs);
            plan.setEndTime(endTs);
            plan.setLocation(location);
            plan.setCost(cost);

            // DAO 호출 (UPDATE 실행)
            conn = DBConnection.getConnection();
            TravelDAO dao = new TravelDAO();
            
            int result = dao.updateTravelPlan(conn, plan);
            
            if(result > 0) {
                resultMsg = "success";
            }

        } catch (Exception e) {
            e.printStackTrace();
            resultMsg = "error: " + e.getMessage();
        } finally {
            DBConnection.close(conn);
        }
    }
    out.print(resultMsg);
%>