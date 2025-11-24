<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="com.personalPlan.dao.TravelDAO" %>
<%@ page import="com.personalPlan.dto.TravelPlanDTO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 데이터 받기 
    String travelNoStr = request.getParameter("travelNo");
    String dayNoStr = request.getParameter("dayNo");
    String category = request.getParameter("category");
    String title = request.getParameter("title");
    String bookingNo = request.getParameter("bookingNo");
    String startTimeStr = request.getParameter("startTime"); 
    String endTimeStr = request.getParameter("endTime");
    String location = request.getParameter("location");
    String costStr = request.getParameter("cost");

    String resultMsg = "fail";

    Connection conn = null;
    
    try {
        // 숫자 변환
        int travelNo = Integer.parseInt(travelNoStr);
        int dayNo = Integer.parseInt(dayNoStr);
        int cost = (costStr == null || costStr.equals("")) ? 0 : Integer.parseInt(costStr);
        
        // 날짜 변환 
        if(startTimeStr.length() == 16) startTimeStr += ":00";
        if(endTimeStr != null && endTimeStr.length() == 16) endTimeStr += ":00";
        
        Timestamp startTs = Timestamp.valueOf(startTimeStr);
        Timestamp endTs = (endTimeStr == null || endTimeStr.isEmpty()) ? startTs : Timestamp.valueOf(endTimeStr);

        // DTO에 담기
        TravelPlanDTO plan = new TravelPlanDTO();
        plan.setTravelNo(travelNo);
        plan.setDayNo(dayNo);
        plan.setCategory(category);
        plan.setTitle(title);
        plan.setBookingNo(bookingNo);
        plan.setStartTime(startTs);
        plan.setEndTime(endTs);
        plan.setLocation(location);
        plan.setCost(cost);

        // DAO 호출
        conn = DBConnection.getConnection();
        TravelDAO dao = new TravelDAO();
        
        int result = dao.insertTravelPlan(conn, plan);
        
        if(result > 0) {

            resultMsg = "success";
        } else {
            resultMsg = "fail:insert_0";
        }

    } catch (Exception e) {
        e.printStackTrace();
        resultMsg = "fail:" + e.getMessage();
    } finally {
        DBConnection.close(conn);
    }

    out.print(resultMsg);
%>