<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File" %> 
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.common.DBConnection" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>

<%

    String memberId = (String) session.getAttribute("sessionId");
    if (memberId == null) {
        out.print("로그인이 필요한 서비스입니다."); 
        return;
    }

    // 파일 저장 경로 설정
    //String savePath = request.getServletContext().getRealPath("/uploads/review");
    //String savePath = "\\\\192.168.0.141\\sjw_java\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\Travel\\uploads\\review";
    String savePath = "\\\\192.168.0.141\\travel_uploads";
    //String savePath = "Z:/";
	//String urlPath = "/uploads/";  // 브라우저에서 접근할 URL 경로
	
    File dir = new File(savePath);
    if (!dir.exists()) dir.mkdirs();

    int maxSize = 100 * 1024 * 1024; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 파일 업로드 (일단 원본 이름으로 서버에 저장됨)
        MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());


        String planNoStr = multi.getParameter("planNo");
        String content = multi.getParameter("content");
        String ratingStr = multi.getParameter("rating");
        
        int planNo = Integer.parseInt(planNoStr);
        int rating = Integer.parseInt(ratingStr);

        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); // 트랜잭션 시작

        // 여행 정보 조회 (국가명 알아내기 위해)
        String sqlGetInfo = "SELECT t.TRAVEL_NO, t.COUNTRY FROM TRAVEL_PLAN p " +
                            "JOIN TRAVEL_INFO t ON p.TRAVEL_NO = t.TRAVEL_NO " +
                            "WHERE p.PLAN_NO = ?";
        pstmt = conn.prepareStatement(sqlGetInfo);
        pstmt.setInt(1, planNo);
        rs = pstmt.executeQuery();

        int travelNo = 0;
        String destination = "기타"; // 국가명 (파일명에 쓰일 예정)
        
        if (rs.next()) {
            travelNo = rs.getInt("TRAVEL_NO");
            destination = rs.getString("COUNTRY");
            
            // 파일명에 쓸 수 없는 특수문자 제거 (예: 공백, / 등)
            if(destination != null) {
                destination = destination.replaceAll("[^a-zA-Z0-9가-힣]", ""); 
            }
        }
        rs.close();
        pstmt.close();

        // 리뷰 저장 (먼저 리뷰 번호를 따야 함)
        String sqlReview = "INSERT INTO TRAVEL_REVIEW " +
                           "(REVIEW_NO, PLAN_NO, TRAVEL_NO, TR_MEM_ID, DESTINATION, CONTENT, RATING, REG_DATE) " +
                           "VALUES (SEQ_REVIEW_NO.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE)";
        
        String[] generatedCols = {"REVIEW_NO"};
        pstmt = conn.prepareStatement(sqlReview, generatedCols);
        
        pstmt.setInt(1, planNo);
        pstmt.setInt(2, travelNo);
        pstmt.setString(3, memberId);
        pstmt.setString(4, destination);
        pstmt.setString(5, content);
        pstmt.setInt(6, rating);
        pstmt.executeUpdate();

        // 생성된 리뷰 번호 가져오기
        rs = pstmt.getGeneratedKeys();
        int reviewNo = 0;
        if (rs.next()) {
            reviewNo = rs.getInt(1);
        }
        rs.close();
        pstmt.close();

        // 미디어 파일 이름 변경 및 DB 저장
        Enumeration files = multi.getFileNames();
        String sqlMedia = "INSERT INTO TRAVEL_MEDIA (MEDIA_NO, REVIEW_NO, ORIGINAL_NAME, SAVED_NAME, FILE_TYPE) " +
                          "VALUES (SEQ_MEDIA_NO.NEXTVAL, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sqlMedia);

        int count = 1; 

        while (files.hasMoreElements()) {
            String name = (String) files.nextElement();
            String originalSavedName = multi.getFilesystemName(name); 
            String originalName = multi.getOriginalFileName(name);    

            if (originalSavedName != null) {
                // 파일 객체 생성
                File oldFile = new File(savePath, originalSavedName);
                
                // 확장자 추출
                String ext = "";
                int dotIndex = originalSavedName.lastIndexOf(".");
                if (dotIndex != -1) {
                    ext = originalSavedName.substring(dotIndex).toLowerCase(); 
                }

                String newFileName = destination + "_" + reviewNo + "_" + count + ext;
                File newFile = new File(savePath, newFileName);

                if (oldFile.exists()) {
                    oldFile.renameTo(newFile); 
                }

                String fileType = "IMAGE";
                if (ext.equals(".mp4") || ext.equals(".avi") || ext.equals(".mov") || ext.equals(".wmv")) {
                    fileType = "VIDEO";
                }

                pstmt.setInt(1, reviewNo);
                pstmt.setString(2, originalName); 
                pstmt.setString(3, newFileName);  
                pstmt.setString(4, fileType);
                pstmt.addBatch();
                
                count++; 
            }
        }
        pstmt.executeBatch();

        conn.commit(); 
        out.print("success");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
        out.print("fail: " + e.getMessage()); 
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        DBConnection.close(conn);
    }
%>