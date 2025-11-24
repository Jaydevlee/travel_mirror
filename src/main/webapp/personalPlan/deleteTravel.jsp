<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="com.personalPlan.dao.TravelDAO" %>

<%
    String travelNoStr = request.getParameter("travelNo");
    String resultMsg = "fail";

    if (travelNoStr != null) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            TravelDAO dao = new TravelDAO();
            int travelNo = Integer.parseInt(travelNoStr);
            
            // 여행 정보 삭제 (FK 설정에 따라 하위 일정도 자동 삭제됨) 
            int result = dao.deleteTravelInfo(conn, travelNo);
            
            if (result > 0) resultMsg = "success";
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn);
        }
    }
    out.print(resultMsg);
%>