package com.travelReview.dto;

import java.sql.Date; 

public class ReviewDTO {
    
    private int reviewNo;       // REVIEW_NO
    private int planNo;         // PLAN_NO
    private int travelNo;       // TRAVEL_NO
    private String memberId;    // TR_MEM_ID
    private String destination; // DESTINATION
    private String content;     // CONTENT
    private int rating;         // RATING
    private Date regDate;       // REG_DATE
    private String planTitle;  // 구체적인 장소 이름 (예: 에펠탑, 오사카 성)
    private int mediaCount;    // 사진/영상 개수 (미디어 필터링용)

    // 기본 생성자
    public ReviewDTO() {
        super();
    }

    // Getter & Setter 메서드
    public int getReviewNo() {
        return reviewNo;
    }

    public void setReviewNo(int reviewNo) {
        this.reviewNo = reviewNo;
    }

    public int getPlanNo() {
        return planNo;
    }

    public void setPlanNo(int planNo) {
        this.planNo = planNo;
    }

    public int getTravelNo() {
        return travelNo;
    }

    public void setTravelNo(int travelNo) {
        this.travelNo = travelNo;
    }

    public String getMemberId() {
        return memberId;
    }

    public void setMemberId(String memberId) {
        this.memberId = memberId;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public String getContent() {
        // 내용이 null이면 "null" 글자 대신 빈 문자열("") 반환
        if (content == null) {
            return "";
        }
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public Date getRegDate() {
        return regDate;
    }

    public void setRegDate(Date regDate) {
        this.regDate = regDate;
    }
    
 // 리스트 화면 표시용 변수 (DB 컬럼 아님, JOIN해서 가져올 값)
    private String thumbnail; // 대표 사진 파일명

    public String getThumbnail() {
        return thumbnail;
    }
    public void setThumbnail(String thumbnail) {
        this.thumbnail = thumbnail;
    }
    
 // 위시리스트 목록 화면용 변수 (DB 컬럼 아님, JOIN해서 가져올 값)
    private String category; 

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public String getPlanTitle() { return planTitle; }
    public void setPlanTitle(String planTitle) { this.planTitle = planTitle; }

    public int getMediaCount() { return mediaCount; }
    public void setMediaCount(int mediaCount) { this.mediaCount = mediaCount; }

}