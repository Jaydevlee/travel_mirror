<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="com.personalPlan.dao.TravelDAO" %>

<%
    // 파라미터 받기 
    String planNoStr = request.getParameter("planNo");
    String resultMsg = "fail";

    if (planNoStr != null && !planNoStr.equals("")) {
        Connection conn = null;
        
        try {
            conn = DBConnection.getConnection();
            TravelDAO dao = new TravelDAO();
            
            int planNo = Integer.parseInt(planNoStr);
            int result = dao.deleteTravelPlan(conn, planNo);
            
            if (result > 0) {
                resultMsg = "success";
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            resultMsg = "error";
        } finally {
            DBConnection.close(conn);
        }
    }
    
    out.print(resultMsg);
%>