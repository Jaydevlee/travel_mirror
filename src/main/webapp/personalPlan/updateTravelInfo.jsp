<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    request.setCharacterEncoding("UTF-8");

    String travelNoStr = request.getParameter("travelNo");
    String title = request.getParameter("title");
    String startDateStr = request.getParameter("startDate");
    String endDateStr = request.getParameter("endDate");
    String companion = request.getParameter("companion");

    if (travelNoStr == null || title == null || startDateStr == null) {
        out.print("fail: missing parameters");
        return;
    }

    int travelNo = Integer.parseInt(travelNoStr);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        // 여행 기본 정보(travel_info) 업데이트
        String sqlInfo = "UPDATE travel_info SET title=?, start_date=?, end_date=?, companion=? WHERE travel_no=?";
        pstmt = conn.prepareStatement(sqlInfo);
        pstmt.setString(1, title);
        pstmt.setString(2, startDateStr);
        pstmt.setString(3, endDateStr);
        pstmt.setString(4, companion);
        pstmt.setInt(5, travelNo);
        pstmt.executeUpdate();
        pstmt.close();


        String sqlSelectPlans = "SELECT plan_no, start_time FROM travel_plan WHERE travel_no = ?";
        pstmt = conn.prepareStatement(sqlSelectPlans);
        pstmt.setInt(1, travelNo);
        rs = pstmt.executeQuery();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date newStartDate = sdf.parse(startDateStr); // 새로운 시작일

        // 일괄 업데이트 준비
        String sqlUpdatePlanDay = "UPDATE travel_plan SET day_no = ? WHERE plan_no = ?";
        PreparedStatement pstmtUpdate = conn.prepareStatement(sqlUpdatePlanDay);

        while (rs.next()) {
            int planNo = rs.getInt("plan_no");
            Timestamp startTime = rs.getTimestamp("start_time");

            if (startTime != null) {

                long diff = startTime.getTime() - newStartDate.getTime();
                

                Date planDate = new Date(startTime.getTime());
                String planDateStr = sdf.format(planDate);
                Date planDateZero = sdf.parse(planDateStr); 

                long diffDays = (planDateZero.getTime() - newStartDate.getTime()) / (24 * 60 * 60 * 1000);
                int newDayNo = (int) diffDays + 1;

                // Day 번호 업데이트
                pstmtUpdate.setInt(1, newDayNo);
                pstmtUpdate.setInt(2, planNo);
                pstmtUpdate.addBatch();
            }
        }
        pstmtUpdate.executeBatch();
        pstmtUpdate.close();

        conn.commit(); // 모든 변경사항 저장
        out.print("success");

    } catch (Exception e) {
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
        out.print("fail: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        DBConnection.close(conn);
    }
%>