<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File, java.util.Enumeration, java.sql.*, com.common.DBConnection" %>
<%@ page import="com.oreilly.servlet.MultipartRequest, com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
 
<%
	String savePath = "Z:/";
	String urlPath = "/uploads/";  // 브라우저에서 접근할 URL 경로
    int maxSize = 10 * 1024 * 1024;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());
        
        String reviewNoStr = multi.getParameter("reviewNo");
        String content = multi.getParameter("content");
        String ratingStr = multi.getParameter("rating");
        // 삭제할 미디어 번호들
        String[] deleteMediaNos = multi.getParameterValues("deleteMediaNo");
        
        int reviewNo = Integer.parseInt(reviewNoStr);
        int rating = Integer.parseInt(ratingStr);

        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); // 트랜잭션 시작

        String sqlUpdate = "UPDATE TRAVEL_REVIEW SET CONTENT=?, RATING=? WHERE REVIEW_NO=?";
        pstmt = conn.prepareStatement(sqlUpdate);
        pstmt.setString(1, content);
        pstmt.setInt(2, rating);
        pstmt.setInt(3, reviewNo);
        pstmt.executeUpdate();
        pstmt.close();

        if (deleteMediaNos != null) {
            for (String mediaNo : deleteMediaNos) {
                // 파일명 조회 (삭제 위해)
                String sqlSel = "SELECT SAVED_NAME FROM TRAVEL_MEDIA WHERE MEDIA_NO=?";
                pstmt = conn.prepareStatement(sqlSel);
                pstmt.setInt(1, Integer.parseInt(mediaNo));
                rs = pstmt.executeQuery();
                if(rs.next()) {
                    File f = new File(savePath, rs.getString("SAVED_NAME"));
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

        String destination = "기타";
        String sqlGetCountry = "SELECT DESTINATION FROM TRAVEL_REVIEW WHERE REVIEW_NO=?";
        pstmt = conn.prepareStatement(sqlGetCountry);
        pstmt.setInt(1, reviewNo);
        rs = pstmt.executeQuery();
        if(rs.next()){
            destination = rs.getString("DESTINATION");
             // 파일명에 쓸 수 없는 특수문자 제거
            if(destination != null) {
                destination = destination.replaceAll("[^a-zA-Z0-9가-힣]", ""); 
            }
        }
        rs.close();
        pstmt.close();


        Enumeration files = multi.getFileNames();
        String sqlInsert = "INSERT INTO TRAVEL_MEDIA (MEDIA_NO, REVIEW_NO, ORIGINAL_NAME, SAVED_NAME, FILE_TYPE) VALUES (SEQ_MEDIA_NO.NEXTVAL, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sqlInsert);
        
        int count = 1;

        long timeStamp = System.currentTimeMillis(); 

        while (files.hasMoreElements()) {
            String name = (String) files.nextElement();
            String originalSavedName = multi.getFilesystemName(name);
            String originalName = multi.getOriginalFileName(name);    

            if (originalSavedName != null) {
 
                File oldFile = new File(savePath, originalSavedName);
                
                String ext = "";
                int dotIndex = originalSavedName.lastIndexOf(".");
                if (dotIndex != -1) {
                    ext = originalSavedName.substring(dotIndex).toLowerCase(); 
                }


                String newFileName = destination + "_" + reviewNo + "_" + timeStamp + "_" + count + ext;
                File newFile = new File(savePath, newFileName);

                if (oldFile.exists()) {
                    oldFile.renameTo(newFile); 
                }

                String fileType = "IMAGE";
                if (ext.matches(".*(mp4|avi|mov|wmv)$")) fileType = "VIDEO"; // 정규식으로 간단 체크

                pstmt.setInt(1, reviewNo);
                pstmt.setString(2, originalName);
                pstmt.setString(3, newFileName); // ★ 바뀐 이름
                pstmt.setString(4, fileType);
                pstmt.addBatch();
                
                count++;
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
        if(rs != null) try { rs.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        DBConnection.close(conn);
    }
%>