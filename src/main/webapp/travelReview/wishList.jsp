<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ page import="java.util.List, java.sql.Connection, com.common.DBConnection, com.travelReview.dao.ReviewDAO, com.travelReview.dto.ReviewDTO"%>

<%
	// 세션 체크 (기존 유지)
	String memberId = (String) session.getAttribute("sessionId");
	if (memberId == null) {
	    out.println("<script>alert('로그인이 필요합니다.'); location.href='../login/login.jsp';</script>");
	    return;
	}

    // 변수 선언 및 페이징 설정
    Connection conn = null;
    ReviewDAO dao = new ReviewDAO();
    List<ReviewDTO> list = null;      // 전체 리스트
    List<ReviewDTO> viewList = null;  // 화면에 보여줄 6개 리스트

    int pageSize = 6; // 한 페이지당 6개
    String pageNumStr = request.getParameter("pageNum");
    int pageNum = (pageNumStr == null) ? 1 : Integer.parseInt(pageNumStr);
    int totalCount = 0; // 전체 글 개수

    try {
        conn = DBConnection.getConnection();
        list = dao.selectMyWishList(conn, memberId); // 전체 다 가져옴
        
        if (list != null) {
            totalCount = list.size();
            
            // 리스트 자르기 (Pagination Logic)
            int startRow = (pageNum - 1) * pageSize;
            int endRow = Math.min(startRow + pageSize, totalCount);
            
            if (startRow < totalCount) {
                viewList = list.subList(startRow, endRow); // 6개만 추출
            }
        }
    } catch(Exception e) { 
        e.printStackTrace();
    } finally { 
        DBConnection.close(conn);
    }
    
    request.setAttribute("pageTitle", "wishList");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>가보고 싶은 곳</title>
    <link rel="stylesheet" href="../css/reviewList.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.2.3/css/flag-icons.min.css" />
</head>
<body>
<jsp:include page="../header.jsp" />

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
            <% 
            // viewList(6개)를 기준으로 반복문 실행
            if(viewList != null && !viewList.isEmpty()) { 
                for(ReviewDTO dto : viewList) {
                    // 아이콘 결정 로직 (기존 코드 유지)
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
                            <img src="/uploads/<%=dto.getThumbnail()%>" alt="썸네일">
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
            <% 
                } // for문 종료
            } else { 
            %>
                <div style="text-align:center; grid-column:1/-1; padding:50px; color:#888;">
                    <h3>아직 찜한 장소가 없어요! 😅</h3>
                    <p>후기를 구경하며 마음에 드는 곳을 저장해보세요.</p>
                    <button onclick="location.href='reviewList.jsp'" 
                            style="margin-top:20px; padding:10px 20px; background:#3b82f6; color:white; border:none; border-radius:5px; cursor:pointer;">
                        여행 후기 구경하러 가기
                    </button>
                </div>
            <% } %>
        </div> <div style="text-align: center; margin-top: 50px; margin-bottom: 20px;">
        <%
            if (totalCount > 0) {
                int pageBlock = 5;
                int pageCount = totalCount / pageSize + (totalCount % pageSize == 0 ? 0 : 1);
                
                int startPage = (int)((pageNum - 1) / pageBlock) * pageBlock + 1;
                int endPage = startPage + pageBlock - 1;
                if (endPage > pageCount) endPage = pageCount;
                
                String pageFile = "wishList.jsp"; 
                
                // [이전]
                if (startPage > pageBlock) {
        %>
                <a href="<%=pageFile%>?pageNum=<%= startPage - pageBlock %>" style="text-decoration: none; color: #666; margin-right: 10px;">[이전]</a>
        <%
                }
                
                // [번호]
                for (int i = startPage; i <= endPage; i++) {
                    if (i == pageNum) {
        %>
                    <span style="font-weight: bold; color: #3b82f6; font-size: 18px; margin: 0 8px;"><%= i %></span>
        <%
                    } else {
        %>
                    <a href="<%=pageFile%>?pageNum=<%= i %>" style="text-decoration: none; color: #666; font-size: 16px; margin: 0 8px;"><%= i %></a>
        <%
                    }
                }
                
                // [다음]
                if (endPage < pageCount) {
        %>
                <a href="<%=pageFile%>?pageNum=<%= startPage + pageBlock %>" style="text-decoration: none; color: #666; margin-left: 10px;">[다음]</a>
        <%
                }
            }
        %>
        </div>
        </div> </body>
</html>