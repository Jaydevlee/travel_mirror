<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.File, java.util.ArrayList, java.util.List" %>
<%@ page import="com.common.DBConnection" %>

<%
    // 요청 파라미터 확인
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
        conn.setAutoCommit(false); // 트랜잭션 시작

        // 삭제할 파일명 조회 (DB에서 데이터가 지워지기 전에 파일명을 먼저 가져옴)
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

        // DB 데이터 삭제 (ON DELETE CASCADE 설정이 되어 있다면 미디어 테이블도 자동 삭제됨)
        String sqlDelete = "DELETE FROM TRAVEL_REVIEW WHERE REVIEW_NO = ?";
        pstmt = conn.prepareStatement(sqlDelete);
        pstmt.setInt(1, reviewNo);
        int result = pstmt.executeUpdate();

        if(result > 0) {
            conn.commit(); // DB 삭제 확정

            // 서버 폴더(Z드라이브)에서 실제 파일 삭제

            String uploadPath = "Z:/"; 
            
            for(String fileName : fileNames) {
                if(fileName != null && !fileName.isEmpty()) {

                    File f = new File(uploadPath, fileName);
                    if(f.exists()) {
                        f.delete(); // 실제 파일 삭제
                    }
                }
            }
            
            // 삭제 완료 후 목록으로 이동
            out.println("<script>");
            out.println("alert('삭제되었습니다.');");
            out.println("location.href='../personalPlan/travelList.jsp';"); 
            out.println("</script>");
            
        } else {
            throw new Exception("삭제된 행이 없습니다.");
        }

    } catch(Exception e) {
        // 에러 발생 시 롤백
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
        out.println("<script>alert('삭제 실패: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        DBConnection.close(conn);
    }
%>