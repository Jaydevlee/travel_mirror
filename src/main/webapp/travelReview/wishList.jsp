<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.sql.Connection, com.common.DBConnection, com.travelReview.dao.ReviewDAO, com.travelReview.dto.ReviewDTO"%>

<%
    String memberId = (String) session.getAttribute("id");
    // if(memberId == null) memberId = "testUser";

    Connection conn = null;
    ReviewDAO dao = new ReviewDAO();
    List<ReviewDTO> list = null;

    try {
        conn = DBConnection.getConnection();
        list = dao.selectMyWishlist(conn, memberId);
    } catch(Exception e) { e.printStackTrace();
    } finally { DBConnection.close(conn); }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>가보고 싶은 곳</title>
    <link rel="stylesheet" href="../css/reviewList.css">
</head>
<body>
    <div class="container">
        <div class="page-header">
            <h2>💖 가보고 싶은 곳</h2>
            <p>내가 찜한 여행지들을 모아봤어요!</p>
            <button onclick="location.href='../personalPlan/travelList.jsp'" 
                    style="margin-top:15px; padding:8px 15px; cursor:pointer; background:#333; color:white; border:none; border-radius:20px;">
                내 여행 계획 보러가기
            </button>
        </div>

        <div class="review-grid">
            <% if(list != null && !list.isEmpty()) { 
                for(ReviewDTO dto : list) {
                    // 아이콘 결정 로직
                    String icon = "📍";
                    String cat = dto.getCategory();
                    if(cat != null) {
                        if(cat.contains("accommodation")) icon = "🏨";
                        else if(cat.contains("dining")) icon = "🍽️";
                        else if(cat.contains("activity")) icon = "🎡";
                    }
            %>
                <div class="review-card" onclick="location.href='travelReviewDetail.jsp?reviewNo=<%=dto.getReviewNo()%>'">
                    <div class="card-image">
                        <% if(dto.getThumbnail() != null) { %>
                            <img src="../uploads/review/<%=dto.getThumbnail()%>">
                        <% } else { %>
                            <div class="no-image"><%=icon%></div>
                        <% } %>
                    </div>
                    <div class="card-body">
                        <div class="card-dest"><%=icon%> <%=dto.getDestination()%></div>
                        <div class="card-content"><%=dto.getContent()%></div>
                        <div class="card-footer">
                            <div class="rating"><% for(int i=0; i<dto.getRating(); i++) { %>★<% } %></div>
                            <div class="writer">👤 <%=dto.getMemberId()%></div>
                        </div>
                    </div>
                </div>
            <% } } else { %>
                <div style="text-align:center; grid-column:1/-1; padding:50px; color:#888;">
                    <h3>아직 찜한 장소가 없어요! 😅</h3>
                    <p>후기를 구경하며 마음에 드는 곳을 저장해보세요.</p>
                    <button onclick="location.href='reviewList.jsp'" 
                            style="margin-top:20px; padding:10px 20px; background:#3b82f6; color:white; border:none; border-radius:5px; cursor:pointer;">
                        여행 후기 구경하러 가기
                    </button>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>