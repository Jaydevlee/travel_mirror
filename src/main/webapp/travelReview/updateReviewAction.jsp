<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File, java.util.Enumeration, java.sql.*, com.common.DBConnection" %>
<%@ page import="com.oreilly.servlet.MultipartRequest, com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
 
<%
	String savePath = "Z:/";
	String urlPath = "/uploads/";  // 브라우저에서 접근할 URL 경로
    int maxSize = 10 * 1024 * 1024; 

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

        String reviewNoStr = multi.getParameter("reviewNo");
        String content = multi.getParameter("content");
        String ratingStr = multi.getParameter("rating");
        // 삭제할 미디어 번호들 (여러 개일 수 있음)
        String[] deleteMediaNos = multi.getParameterValues("deleteMediaNo");

        int reviewNo = Integer.parseInt(reviewNoStr);
        int rating = Integer.parseInt(ratingStr);

        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        // 리뷰 본문 업데이트
        String sqlUpdate = "UPDATE TRAVEL_REVIEW SET CONTENT=?, RATING=? WHERE REVIEW_NO=?";
        pstmt = conn.prepareStatement(sqlUpdate);
        pstmt.setString(1, content);
        pstmt.setInt(2, rating);
        pstmt.setInt(3, reviewNo);
        pstmt.executeUpdate();
        pstmt.close();

        // 기존 미디어 삭제 처리 (DB + 파일)
        if (deleteMediaNos != null) {
            for (String mediaNo : deleteMediaNos) {
                // 파일명 조회 (삭제 위해)
                String sqlSel = "SELECT SAVED_NAME FROM TRAVEL_MEDIA WHERE MEDIA_NO=?";
                pstmt = conn.prepareStatement(sqlSel);
                pstmt.setInt(1, Integer.parseInt(mediaNo));
                ResultSet rs = pstmt.executeQuery();
                if(rs.next()) {
                    File f = new File(savePath + File.separator + rs.getString("SAVED_NAME"));
                    if(f.exists()) f.delete();
                }
                rs.close();
                pstmt.close();

                // DB 삭제
                String sqlDel = "DELETE FROM TRAVEL_MEDIA WHERE MEDIA_NO=?";
                pstmt = conn.prepareStatement(sqlDel);
                pstmt.setInt(1, Integer.parseInt(mediaNo));
                pstmt.executeUpdate();
                pstmt.close();
            }
        }

        // 새 미디어 추가 (INSERT)
        Enumeration files = multi.getFileNames();
        String sqlInsert = "INSERT INTO TRAVEL_MEDIA (MEDIA_NO, REVIEW_NO, ORIGINAL_NAME, SAVED_NAME, FILE_TYPE) VALUES (SEQ_MEDIA_NO.NEXTVAL, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sqlInsert);

        while (files.hasMoreElements()) {
            String name = (String) files.nextElement();
            String savedName = multi.getFilesystemName(name);
            String originalName = multi.getOriginalFileName(name);

            if (savedName != null) {
                String fileType = "IMAGE";
                String ext = savedName.substring(savedName.lastIndexOf(".") + 1).toLowerCase();
                if (ext.matches("mp4|avi|mov|wmv")) fileType = "VIDEO";

                pstmt.setInt(1, reviewNo);
                pstmt.setString(2, originalName);
                pstmt.setString(3, savedName);
                pstmt.setString(4, fileType);
                pstmt.addBatch();
            }
        }
        pstmt.executeBatch();

        conn.commit();
        out.print("success");

    } catch (Exception e) {
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
        out.print("fail: " + e.getMessage());
    } finally {
        if(pstmt != null) pstmt.close();
        DBConnection.close(conn);
    }
%>