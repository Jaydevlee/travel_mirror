<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.File, java.util.ArrayList, java.util.List" %>
<%@ page import="com.common.DBConnection" %>

<%
    String reviewNoStr = request.getParameter("reviewNo");
    if(reviewNoStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int reviewNo = Integer.parseInt(reviewNoStr);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        // 삭제할 파일명 조회 (서버에서 파일도 지우기 위해)
        List<String> fileNames = new ArrayList<>();
        String sqlSelectFiles = "SELECT SAVED_NAME FROM TRAVEL_MEDIA WHERE REVIEW_NO = ?";
        pstmt = conn.prepareStatement(sqlSelectFiles);
        pstmt.setInt(1, reviewNo);
        rs = pstmt.executeQuery();
        while(rs.next()) {
            fileNames.add(rs.getString("SAVED_NAME"));
        }
        rs.close();
        pstmt.close();

        // DB 데이터 삭제 (ON DELETE CASCADE 덕분에 사진 테이블 데이터는 자동 삭제됨)
        String sqlDelete = "DELETE FROM TRAVEL_REVIEW WHERE REVIEW_NO = ?";
        pstmt = conn.prepareStatement(sqlDelete);
        pstmt.setInt(1, reviewNo);
        int result = pstmt.executeUpdate();

        if(result > 0) {
            conn.commit();
            
            // 서버 폴더에서 실제 파일 삭제
            String uploadPath = request.getServletContext().getRealPath("/uploads/review");
            for(String fileName : fileNames) {
                File f = new File(uploadPath + File.separator + fileName);
                if(f.exists()) f.delete();
            }
            
            // 삭제 후 목록이나 이전 페이지로 이동
            out.println("<script>");
            out.println("alert('삭제되었습니다.');");
            out.println("location.href='../personalPlan/travelList.jsp';"); // 목록으로 이동
            out.println("</script>");
        } else {
            throw new Exception("삭제된 행이 없습니다.");
        }

    } catch(Exception e) {
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
        out.println("<script>alert('삭제 실패: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if(rs != null) rs.close();
        if(pstmt != null) pstmt.close();
        DBConnection.close(conn);
    }
%>