<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="com.common.DBConnection"%>
<%@ page import="com.travelReview.dao.ReviewDAO"%>
<%@ page import="com.travelReview.dto.ReviewDTO"%>
<%@ page import="com.travelReview.dto.ReviewMediaDTO"%>

<%

    String reviewNoStr = request.getParameter("reviewNo");
    if (reviewNoStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int reviewNo = Integer.parseInt(reviewNoStr);

    Connection conn = null;
    ReviewDAO dao = new ReviewDAO();
    
    ReviewDTO review = null;
    List<ReviewMediaDTO> mediaList = null;
    boolean isSaved = false;

    try {
        conn = DBConnection.getConnection();
        
        // 리뷰 내용 가져오기 (DAO 사용)
        review = dao.selectReview(conn, reviewNo);
        
        if (review == null) {
            out.println("<script>alert('삭제된 리뷰입니다.'); history.back();</script>");
            return;
        }

        // 미디어 리스트 가져오기
        mediaList = dao.selectMediaList(conn, reviewNo);

        // 위시리스트 저장 여부 확인
        String myId = (String) session.getAttribute("id");
        // if(myId == null) myId = "testUser"; // 테스트용
        
        if (myId != null) {
            isSaved = dao.isSaved(conn, myId, reviewNo);
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        DBConnection.close(conn);
    }

    // 줄바꿈 처리 (본문만 별도 변수로 처리)
    String content = review.getContent();
    if (content != null) content = content.replace("\n", "<br>");
    
    // 내 글인지 확인 (수정/삭제 버튼 표시용)
    String myId = (String) session.getAttribute("id");
    // if(myId == null) myId = "testUser"; // 테스트용
    
    boolean isMyReview = (myId != null && myId.equals(review.getMemberId()));
    // boolean isMyReview = true; // 테스트용 (로그인 없이 수정 버튼 보고 싶으면 주석 해제)
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>여행 후기 상세</title>
    <link rel="stylesheet" href="../css/travelReview.css">
    <link rel="stylesheet" href="../css/travelReviewDetail.css">
    <script src="../js/jquery-3.7.1.min.js"></script>
</head>
<body>

    <div class="header">
        <h2 onclick="history.back()">⬅️ 후기 상세 보기</h2>
    </div>

    <div class="detail-container">
        <div class="detail-header">
            <div class="detail-dest">✈️ <%=review.getDestination()%></div>
            
            <div class="detail-rating">
                <% for (int i = 0; i < review.getRating(); i++) { %>★<% } %>
                <% for (int i = 0; i < 5 - review.getRating(); i++) { %>☆<% } %>
                <span style="color: #333; font-size: 14px; font-weight: bold; margin-left: 5px;">
                    <%=review.getRating()%>점
                </span>
            </div>
            
            <div class="detail-meta">
                <span>작성자: <%=review.getMemberId()%></span> 
                <span><%=review.getRegDate()%></span>
            </div>
        </div>

        <div class="detail-content">
            <%=content%> </div>

        <div class="media-grid">
            <% 
            if (mediaList != null) {
                for (ReviewMediaDTO media : mediaList) { 
                   // DTO에서 값 꺼내기
                   String savedName = media.getSavedName();
                   String type = media.getFileType();
            %>
            <div class="media-item">
                <% if ("VIDEO".equals(type)) { %>
                    <video controls src="../uploads/review/<%=savedName%>"></video>
                <% } else { %>
                    <img src="../uploads/review/<%=savedName%>" onclick="window.open(this.src)">
                <% } %>
            </div>
            <% 
                } 
            }
            %>
        </div>

        <div class="btn-group">
            <button class="btn-basic" onclick="location.href='reviewList.jsp'">목록으로</button>

            <button class="btn-basic btn-wish <%=isSaved ? "active" : ""%>"
                    onclick="toggleWish(<%=reviewNo%>)">
                <%=isSaved ? "♥ 저장됨" : "♡ 저장하기"%>
            </button>

            <% if (isMyReview) { %>
                <button class="btn-basic btn-primary" onclick="location.href='editReview.jsp?reviewNo=<%=reviewNo%>'">수정</button>
                <button class="btn-basic btn-danger" onclick="deleteReview(<%=reviewNo%>)">삭제</button>
            <% } %>
        </div>
    </div>

    <script src="../js/travelReview/travelReviewDetail.js"></script>

</body>
</html>