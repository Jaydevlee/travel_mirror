<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.common.DBConnection" %> 
<%
    request.setCharacterEncoding("UTF-8");

    String cmd = request.getParameter("cmd"); 
    String travelNoStr = request.getParameter("travelNo");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String resultJson = ""; 

    try {
        conn = DBConnection.getConnection();

        // 목록 조회 (list)
        if ("list".equals(cmd)) {
            String sql = "SELECT check_no, content, is_checked FROM travel_checklist WHERE travel_no = ? ORDER BY check_no ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(travelNoStr));
            rs = pstmt.executeQuery();
            
            StringBuilder sb = new StringBuilder();
            sb.append("[");
            boolean isFirst = true;
            while (rs.next()) {
                if (!isFirst) sb.append(",");
                sb.append("{");
                sb.append("\"check_no\": " + rs.getInt("check_no") + ",");
                sb.append("\"content\": \"" + rs.getString("content").replace("\"", "\\\"") + "\",");
                sb.append("\"is_checked\": \"" + rs.getString("is_checked") + "\"");
                sb.append("}");
                isFirst = false;
            }
            sb.append("]");
            resultJson = sb.toString();

        // 추가 (add)
        } else if ("add".equals(cmd)) {
            String content = request.getParameter("content");
            String sql = "INSERT INTO travel_checklist (check_no, travel_no, content) VALUES (seq_checklist_no.nextval, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(travelNoStr));
            pstmt.setString(2, content);
            pstmt.executeUpdate();
            resultJson = "{\"result\":\"success\"}";

        // 체크 상태 변경 (toggle)
        } else if ("toggle".equals(cmd)) {
            String checkNo = request.getParameter("checkNo");
            String status = request.getParameter("status"); // 'Y' or 'N'
            String sql = "UPDATE travel_checklist SET is_checked = ? WHERE check_no = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setInt(2, Integer.parseInt(checkNo));
            pstmt.executeUpdate();
            resultJson = "{\"result\":\"success\"}";

        // 삭제 (delete)
        } else if ("delete".equals(cmd)) {
            String checkNo = request.getParameter("checkNo");
            String sql = "DELETE FROM travel_checklist WHERE check_no = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(checkNo));
            pstmt.executeUpdate();
            resultJson = "{\"result\":\"success\"}";
        }

    } catch (Exception e) {
        e.printStackTrace();
        
        String errMsg = e.getMessage().replace("\"", "'").replace("\n", " ");
        resultJson = "{\"result\":\"error\", \"message\":\"" + errMsg + "\"}";
    } finally {
        
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
      
    }
    
    out.print(resultJson);
%>