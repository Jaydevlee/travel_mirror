<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.common.DBConnection" %>
<%
    request.setCharacterEncoding("UTF-8");

    String reviewNoStr = request.getParameter("reviewNo");
    int reviewNo = Integer.parseInt(reviewNoStr);    
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String id = null;
    conn = DBConnection.getConnection();
    
    String sql = "SELECT * FROM travel_review WHERE review_no = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, reviewNo);
    rs = pstmt.executeQuery();
    rs.next();
    id = rs.getString("tr_mem_id");

    sql = "DELETE FROM travel_review WHERE review_no = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, reviewNo);
    int result = pstmt.executeUpdate();
    
    if(result > 0){
        response.sendRedirect("admin_memberReview.jsp?id="+id);
    } else {
        out.println("여행리뷰 삭제 실패");
    }

    DBConnection.close(rs);
    DBConnection.close(pstmt);
    DBConnection.close(conn);
%>
