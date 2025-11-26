package com.travelReview.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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
    
 // 전체 리뷰 목록 조회 (최신순 + 썸네일 포함)
    public List<ReviewDTO> selectAllReviews(Connection conn) {
        List<ReviewDTO> list = new ArrayList<>();
        // 서브쿼리를 이용해 각 리뷰당 첫 번째 사진 하나만 가져옴
        String sql = "SELECT r.*, " +
                     " (SELECT saved_name FROM travel_media m WHERE m.review_no = r.review_no AND ROWNUM = 1) as thumbnail " +
                     "FROM travel_review r " +
                     "ORDER BY r.review_no DESC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ReviewDTO dto = new ReviewDTO();
                dto.setReviewNo(rs.getInt("REVIEW_NO"));
                dto.setMemberId(rs.getString("TR_MEM_ID"));
                dto.setDestination(rs.getString("DESTINATION"));
                dto.setContent(rs.getString("CONTENT"));
                dto.setRating(rs.getInt("RATING"));
                dto.setRegDate(rs.getDate("REG_DATE"));
                // 썸네일 저장
                String thumb = rs.getString("thumbnail");
                dto.setThumbnail(thumb); 
                
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
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

    // 내가 찜한 목록 조회 (아이콘 표시를 위해 PLAN 테이블과 조인)
    public List<ReviewDTO> selectMyWishlist(Connection conn, String memberId) {
        List<ReviewDTO> list = new ArrayList<>();
        String sql = "SELECT r.*, p.CATEGORY, " +
                     " (SELECT saved_name FROM travel_media m WHERE m.review_no = r.review_no AND ROWNUM = 1) as thumbnail " +
                     "FROM TRAVEL_WISHLIST w " +
                     "JOIN TRAVEL_REVIEW r ON w.review_no = r.review_no " +
                     "JOIN TRAVEL_PLAN p ON r.plan_no = p.plan_no " +
                     "WHERE w.tr_mem_id = ? " +
                     "ORDER BY w.wish_no DESC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                ReviewDTO dto = new ReviewDTO();
                dto.setReviewNo(rs.getInt("REVIEW_NO"));
                dto.setMemberId(rs.getString("TR_MEM_ID"));
                dto.setDestination(rs.getString("DESTINATION"));
                dto.setContent(rs.getString("CONTENT"));
                dto.setRating(rs.getInt("RATING"));
                dto.setThumbnail(rs.getString("thumbnail"));
                dto.setCategory(rs.getString("CATEGORY")); // ★ 카테고리 저장
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    
}