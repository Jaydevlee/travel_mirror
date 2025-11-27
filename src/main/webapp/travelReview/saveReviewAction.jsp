<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File" %> 
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>

<%
    // 로그인 체크 (세션에서 ID 가져오기 - TR_MEMBER 테이블 기준)
    String memberId = (String) session.getAttribute("sessionId");
System.out.println("현재 세션 ID 값: " + memberId);
	
if (memberId == null) {
    out.print("로그인이 필요한 서비스입니다."); 
    return;
}
	
    // 파일 저장 경로 설정
    //String savePath = request.getServletContext().getRealPath("/uploads/review");
    String savePath = "\\\\192.168.0.141\\sjw_java\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\Travel\\uploads\\review";
    File dir = new File(savePath);
    if (!dir.exists()) dir.mkdirs(); 

    int maxSize = 10 * 1024 * 1024; // 10MB

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 파일 업로드 처리
        MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

        // 폼 데이터 받기
        String planNoStr = multi.getParameter("planNo");
        String content = multi.getParameter("content");
        String ratingStr = multi.getParameter("rating");
        
        int planNo = Integer.parseInt(planNoStr);
        int rating = Integer.parseInt(ratingStr);

        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); // 트랜잭션 시작

        // TRAVEL_INFO 테이블에서 여행 번호(TRAVEL_NO)와 국가(COUNTRY) 조회
        // TRAVEL_PLAN 테이블을 통해 부모 여행 정보를 찾음
        String sqlGetInfo = "SELECT t.TRAVEL_NO, t.COUNTRY " +
                            "FROM TRAVEL_PLAN p " +
                            "JOIN TRAVEL_INFO t ON p.TRAVEL_NO = t.TRAVEL_NO " +
                            "WHERE p.PLAN_NO = ?";
        pstmt = conn.prepareStatement(sqlGetInfo);
        pstmt.setInt(1, planNo);
        rs = pstmt.executeQuery();

        int travelNo = 0;
        String destination = "기타";

        if (rs.next()) {
            travelNo = rs.getInt("TRAVEL_NO");
            destination = rs.getString("COUNTRY");
        }
        rs.close();
        pstmt.close();

        // 후기 저장 (INSERT) - 컬럼명 TR_MEM_ID 사용
        String sqlReview = "INSERT INTO TRAVEL_REVIEW " +
                           "(REVIEW_NO, PLAN_NO, TRAVEL_NO, TR_MEM_ID, DESTINATION, CONTENT, RATING, REG_DATE) " +
                           "VALUES (SEQ_REVIEW_NO.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE)";
        
        // 생성된 PK(REVIEW_NO)를 바로 알아내기 위한 설정
        String[] generatedCols = {"REVIEW_NO"};
        pstmt = conn.prepareStatement(sqlReview, generatedCols);
        
        pstmt.setInt(1, planNo);
        pstmt.setInt(2, travelNo);
        pstmt.setString(3, memberId);    // 작성자 ID
        pstmt.setString(4, destination); // 여행 국가
        pstmt.setString(5, content);     // 내용
        pstmt.setInt(6, rating);         // 별점
        pstmt.executeUpdate();

        // 방금 생성된 리뷰 번호 가져오기
        rs = pstmt.getGeneratedKeys();
        int reviewNo = 0;
        if (rs.next()) {
            reviewNo = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

     // 미디어(사진/동영상) 정보 저장 (INSERT)
        Enumeration files = multi.getFileNames(); 
        String sqlMedia = "INSERT INTO TRAVEL_MEDIA (MEDIA_NO, REVIEW_NO, ORIGINAL_NAME, SAVED_NAME, FILE_TYPE) " +
                  "VALUES (SEQ_MEDIA_NO.NEXTVAL, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sqlMedia);

        while (files.hasMoreElements()) {
            String name = (String) files.nextElement();
            String savedName = multi.getFilesystemName(name);
            String originalName = multi.getOriginalFileName(name);

            if (savedName != null) {
                // 파일 확장자로 타입 구분하기
                String fileType = "IMAGE"; // 기본값
                String ext = savedName.substring(savedName.lastIndexOf(".") + 1).toLowerCase();
                
                if (ext.equals("mp4") || ext.equals("avi") || ext.equals("mov") || ext.equals("wmv")) {
                    fileType = "VIDEO";
                }

                pstmt.setInt(1, reviewNo);
                pstmt.setString(2, originalName);
                pstmt.setString(3, savedName);
                pstmt.setString(4, fileType); // 'IMAGE' or 'VIDEO' 저장
                pstmt.addBatch(); 
            }
        }
        pstmt.executeBatch(); // 일괄 저장 실행

        conn.commit(); 
        out.print("success"); 

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) {} // 에러 나면 롤백
        e.printStackTrace(); 
        out.print("fail: " + e.getMessage()); 
    } finally {

        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        DBConnection.close(conn);
    }
%>