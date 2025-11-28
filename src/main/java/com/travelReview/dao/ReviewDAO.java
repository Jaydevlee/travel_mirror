package com.travelReview.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.travelReview.dto.ReviewDTO;
import com.travelReview.dto.ReviewMediaDTO;

public class ReviewDAO {

    // 리뷰 번호 조회 (Map<planNo, reviewNo>)
    public Map<Integer, Integer> getReviewMap(Connection conn, int travelNo) {
        Map<Integer, Integer> map = new HashMap<>();
        String sql = "SELECT PLAN_NO, REVIEW_NO FROM TRAVEL_REVIEW WHERE TRAVEL_NO = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, travelNo);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("PLAN_NO"), rs.getInt("REVIEW_NO"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    // 리뷰 상세 조회 (ReviewDTO)
    public ReviewDTO selectReview(Connection conn, int reviewNo) {
        ReviewDTO dto = null;
        String sql = "SELECT * FROM TRAVEL_REVIEW WHERE REVIEW_NO = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, reviewNo);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    dto = new ReviewDTO();
                    dto.setReviewNo(rs.getInt("REVIEW_NO"));
                    dto.setPlanNo(rs.getInt("PLAN_NO"));
                    dto.setTravelNo(rs.getInt("TRAVEL_NO"));
                    dto.setMemberId(rs.getString("TR_MEM_ID"));
                    dto.setDestination(rs.getString("DESTINATION"));
                    dto.setContent(rs.getString("CONTENT"));
                    dto.setRating(rs.getInt("RATING"));
                    dto.setRegDate(rs.getDate("REG_DATE"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dto;
    }

    // 미디어 리스트 조회 (List<ReviewMediaDTO>)
    public List<ReviewMediaDTO> selectMediaList(Connection conn, int reviewNo) {
        List<ReviewMediaDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM TRAVEL_MEDIA WHERE REVIEW_NO = ? ORDER BY MEDIA_NO ASC";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, reviewNo);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ReviewMediaDTO dto = new ReviewMediaDTO();
                    dto.setMediaNo(rs.getInt("MEDIA_NO"));
                    dto.setReviewNo(rs.getInt("REVIEW_NO"));
                    dto.setOriginalName(rs.getString("ORIGINAL_NAME"));
                    dto.setSavedName(rs.getString("SAVED_NAME"));
                    dto.setFileType(rs.getString("FILE_TYPE"));
                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
 // 필터링 기능이 포함된 리뷰 조회 메서드
    public List<ReviewDTO> selectFilteredReviews(Connection conn, String country, String category, String rating, String mediaType) {
        List<ReviewDTO> list = new ArrayList<>();
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.*, p.CATEGORY, p.TITLE AS PLAN_TITLE, ");
        sql.append(" (SELECT saved_name FROM travel_media m WHERE m.review_no = r.review_no AND ROWNUM = 1) as thumbnail, ");
        sql.append(" (SELECT count(*) FROM travel_media m WHERE m.review_no = r.review_no) as media_cnt ");
        sql.append("FROM TRAVEL_REVIEW r ");
        sql.append("JOIN TRAVEL_PLAN p ON r.PLAN_NO = p.PLAN_NO "); // ★ 핵심 JOIN
        sql.append("WHERE 1=1 ");

        if (country != null && !country.equals("all")) sql.append("AND r.DESTINATION = ? ");
        if (category != null && !category.equals("all")) sql.append("AND p.CATEGORY LIKE ? ");
        if (rating != null && !rating.equals("all")) sql.append("AND r.RATING = ? ");
        
        // 미디어 필터 (사진있음 vs 글만있음)
        if ("photo".equals(mediaType)) {
            sql.append("AND (SELECT count(*) FROM travel_media m WHERE m.review_no = r.review_no) > 0 ");
        } else if ("text".equals(mediaType)) {
            sql.append("AND (SELECT count(*) FROM travel_media m WHERE m.review_no = r.review_no) = 0 ");
        }
        
        sql.append("ORDER BY r.REVIEW_NO DESC");

        try {
            pstmt = conn.prepareStatement(sql.toString());
            
            // 물음표(?) 인덱스 설정
            int idx = 1;
            if (country != null && !country.equals("all")) pstmt.setString(idx++, country);
            if (category != null && !category.equals("all")) pstmt.setString(idx++, "%" + category + "%");
            if (rating != null && !rating.equals("all")) pstmt.setInt(idx++, Integer.parseInt(rating));

            rs = pstmt.executeQuery();

            while (rs.next()) {
                ReviewDTO dto = new ReviewDTO();
                dto.setReviewNo(rs.getInt("REVIEW_NO"));
                dto.setMemberId(rs.getString("TR_MEM_ID"));
                dto.setDestination(rs.getString("DESTINATION"));
                dto.setContent(rs.getString("CONTENT"));
                dto.setRating(rs.getInt("RATING"));
                dto.setRegDate(rs.getDate("REG_DATE"));
                dto.setThumbnail(rs.getString("thumbnail"));
                
                // 새로 추가한 정보 담기
                dto.setCategory(rs.getString("CATEGORY"));
                dto.setPlanTitle(rs.getString("PLAN_TITLE")); // 장소 이름
                dto.setMediaCount(rs.getInt("media_cnt"));

                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
        return list;
    }
    
 // 위시리스트 토글 (저장 <-> 삭제)
    public String toggleWishlist(Connection conn, String memberId, int reviewNo) {
        String status = "fail";
        // 이미 저장했는지 확인
        String sqlCheck = "SELECT count(*) FROM TRAVEL_WISHLIST WHERE TR_MEM_ID=? AND REVIEW_NO=?";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlCheck)) {
            pstmt.setString(1, memberId);
            pstmt.setInt(2, reviewNo);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                // 이미 있음 -> 삭제
                String sqlDel = "DELETE FROM TRAVEL_WISHLIST WHERE TR_MEM_ID=? AND REVIEW_NO=?";
                try(PreparedStatement pDel = conn.prepareStatement(sqlDel)) {
                    pDel.setString(1, memberId);
                    pDel.setInt(2, reviewNo);
                    pDel.executeUpdate();
                }
                status = "removed";
            } else {
                // 없음 -> 저장
                String sqlIns = "INSERT INTO TRAVEL_WISHLIST (WISH_NO, TR_MEM_ID, REVIEW_NO) VALUES (SEQ_WISH_NO.NEXTVAL, ?, ?)";
                try(PreparedStatement pIns = conn.prepareStatement(sqlIns)) {
                    pIns.setString(1, memberId);
                    pIns.setInt(2, reviewNo);
                    pIns.executeUpdate();
                }
                status = "saved";
            }
        } catch (Exception e) { e.printStackTrace(); }
        return status;
    }

    // 저장 여부 확인 (상세 페이지에서 하트 색깔 표시용)
    public boolean isSaved(Connection conn, String memberId, int reviewNo) {
        boolean isSaved = false;
        String sql = "SELECT 1 FROM TRAVEL_WISHLIST WHERE TR_MEM_ID=? AND REVIEW_NO=?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            pstmt.setInt(2, reviewNo);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) isSaved = true;
        } catch (Exception e) { e.printStackTrace(); }
        return isSaved;
    }

    
 // 위시리스트 조회 (필터링 기능 추가됨)
    public List<ReviewDTO> selectMyWishList(Connection conn, String userId, String country, String category, String rating, String mediaType) {
        List<ReviewDTO> list = new ArrayList<>();
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT r.*, p.CATEGORY, p.TITLE AS PLAN_TITLE, ");
        sql.append(" (SELECT saved_name FROM travel_media m WHERE m.review_no = r.review_no AND ROWNUM = 1) as thumbnail, ");
        sql.append(" (SELECT count(*) FROM travel_media m WHERE m.review_no = r.review_no) as media_cnt ");
        sql.append("FROM TRAVEL_REVIEW r ");
        sql.append("JOIN TRAVEL_WISHLIST w ON r.REVIEW_NO = w.REVIEW_NO ");
        sql.append("JOIN TRAVEL_PLAN p ON r.PLAN_NO = p.PLAN_NO ");
        sql.append("WHERE w.TR_MEM_ID = ? "); // 내 아이디 조건 필수


        if (country != null && !country.equals("all")) {
            sql.append("AND r.DESTINATION = ? ");
        }
        if (category != null && !category.equals("all")) {
            sql.append("AND p.CATEGORY LIKE ? ");
        }
        if (rating != null && !rating.equals("all")) {
            sql.append("AND r.RATING = ? ");
        }
        // 미디어 필터
        if ("photo".equals(mediaType)) {
            sql.append("AND (SELECT count(*) FROM travel_media m WHERE m.review_no = r.review_no) > 0 ");
        } else if ("text".equals(mediaType)) {
            sql.append("AND (SELECT count(*) FROM travel_media m WHERE m.review_no = r.review_no) = 0 ");
        }

        sql.append("ORDER BY w.WISH_NO DESC");

        try {
            pstmt = conn.prepareStatement(sql.toString());
            
            int idx = 1;
            pstmt.setString(idx++, userId); 

            if (country != null && !country.equals("all")) pstmt.setString(idx++, country);
            if (category != null && !category.equals("all")) pstmt.setString(idx++, "%" + category + "%");
            if (rating != null && !rating.equals("all")) pstmt.setInt(idx++, Integer.parseInt(rating));

            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ReviewDTO dto = new ReviewDTO();
                dto.setReviewNo(rs.getInt("REVIEW_NO"));
                dto.setMemberId(rs.getString("TR_MEM_ID"));
                dto.setDestination(rs.getString("DESTINATION"));
                dto.setContent(rs.getString("CONTENT"));
                dto.setRating(rs.getInt("RATING"));
                dto.setRegDate(rs.getDate("REG_DATE"));
                dto.setThumbnail(rs.getString("thumbnail"));
                
                // 추가 정보
                dto.setCategory(rs.getString("CATEGORY"));
                dto.setPlanTitle(rs.getString("PLAN_TITLE"));
                dto.setMediaCount(rs.getInt("media_cnt")); // 미디어 개수

                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
        return list;
    }
    
 // 리뷰가 존재하는 국가 코드 목록만 조회 (중복 제거)
    public List<String> selectExistCountries(Connection conn) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT DESTINATION FROM TRAVEL_REVIEW " +
                     "WHERE DESTINATION IS NOT NULL ORDER BY DESTINATION ASC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                list.add(rs.getString("DESTINATION")); 
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}