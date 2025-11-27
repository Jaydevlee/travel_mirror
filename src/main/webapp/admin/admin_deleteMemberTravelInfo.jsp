<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.common.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");

    String travelNoStr = request.getParameter("travelNo");
    int travelNo = Integer.parseInt(travelNoStr);    
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String id = null;
    conn = DBConnection.getConnection();
    
    String sql = "SELECT * FROM travel_info WHERE travel_no = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, travelNo);
    rs = pstmt.executeQuery();
    rs.next();
    id = rs.getString("tr_mem_id");

    sql = "DELETE FROM travel_info WHERE travel_no = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, travelNo);
    int result = pstmt.executeUpdate();
    
    if(result > 0){
        response.sendRedirect("admin_memberTravelInfo.jsp?id="+id);
    } else {
        out.println("여행정보 삭제 실패");
    }

    DBConnection.close(rs);
    DBConnection.close(pstmt);
    DBConnection.close(conn);
%>
