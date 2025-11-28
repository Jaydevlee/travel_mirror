<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ page import="java.util.List, java.sql.Connection, com.common.DBConnection"%>
<%@ page import="com.travelReview.dao.ReviewDAO, com.travelReview.dto.ReviewDTO"%>

<%
    String memberId = (String) session.getAttribute("sessionId");
    if (memberId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login/login.jsp';</script>");
        return;
    }

    String pCountry = request.getParameter("country");
    String pCategory = request.getParameter("category");
    String pRating = request.getParameter("rating");
    String pMedia = request.getParameter("media");

    if(pCountry == null) pCountry = "all";
    if(pCategory == null) pCategory = "all";
    if(pRating == null) pRating = "all";
    if(pMedia == null) pMedia = "all";

    // DB 조회
    Connection conn = null;
    ReviewDAO dao = new ReviewDAO();
    
    // 페이징 변수 설정
    int pageSize = 9; 
    String pageNumStr = request.getParameter("pageNum");
    int pageNum = (pageNumStr == null) ? 1 : Integer.parseInt(pageNumStr);
    
    List<ReviewDTO> list = null;      
    List<ReviewDTO> viewList = null;  
    int totalCount = 0;

    try {
        conn = DBConnection.getConnection();

        list = dao.selectMyWishList(conn, memberId, pCountry, pCategory, pRating, pMedia);
        
        if (list != null && !list.isEmpty()) {
            totalCount = list.size();
            
            int startRow = (pageNum - 1) * pageSize;
            int endRow = Math.min(startRow + pageSize, totalCount);
            
            if (startRow < totalCount) {
                viewList = list.subList(startRow, endRow);
            }
        }
    } catch(Exception e) { 
        e.printStackTrace();
    } finally { 
        DBConnection.close(conn);
    }
    
    request.setAttribute("pageTitle", "wishList");
    String searchParams = "&country=" + pCountry + "&category=" + pCategory + "&rating=" + pRating + "&media=" + pMedia;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>가보고 싶은 곳</title>
    <link rel="stylesheet" href="../css/reviewList.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.2.3/css/flag-icons.min.css" />
    
    <script src="../js/countryData.js"></script>
    
    <script>
    window.onload = function() {
        var select = document.getElementById("searchCountry");
        var selectedValue = "<%=pCountry%>"; // 현재 선택된 값

        if(typeof countryList !== 'undefined') {
            countryList.forEach(function(item) {
                if (item.id === '') return; 

                var option = document.createElement("option");
                option.value = item.id; 
                option.text = item.text; 

                if (item.id === selectedValue) {
                    option.selected = true;
                }
                select.appendChild(option);
            });
        }
    };

    function filterWishList() {
        var country = document.getElementById("searchCountry").value;
        var category = document.getElementById("searchCategory").value;
        var rating = document.getElementById("searchRating").value;
        var media = document.getElementById("searchMedia").value;
        
        location.href = "wishList.jsp?country=" + country + "&category=" + category + "&rating=" + rating + "&media=" + media;
    }
    </script>
    
    <style>
        .filter-bar { display: flex; gap: 10px; justify-content: center; margin: 20px 0; flex-wrap: wrap; }
        .filter-bar select { padding: 8px 12px; border: 1px solid #ddd; border-radius: 5px; cursor: pointer; font-size: 14px; }
        .card-header-badge { font-size: 0.8rem; color: #888; margin-bottom: 5px; display: block; }
    </style>
</head>
<body>
    <jsp:include page="../header.jsp" />

    <div class="container">
        <div class="page-header">
            <h2>💖 가보고 싶은 곳</h2>
            <p>내가 찜한 여행지들을 모아봤어요!</p>

            <div class="filter-bar">
                <select id="searchCountry" onchange="filterWishList()">
                    <option value="all">🌍 전세계</option>
                </select>

                <select id="searchCategory" onchange="filterWishList()">
                    <option value="all">📂 전체 카테고리</option>
                    <option value="accommodation" <%= "accommodation".equals(pCategory)?"selected":"" %>>🏨 숙소</option>
                    <option value="dining" <%= "dining".equals(pCategory)?"selected":"" %>>🍽️ 식당/카페</option>
                    <option value="activity" <%= "activity".equals(pCategory)?"selected":"" %>>🎡 관광/액티비티</option>
                </select>

                <select id="searchRating" onchange="filterWishList()">
                    <option value="all">⭐ 별점 전체</option>
                    <option value="5" <%= "5".equals(pRating)?"selected":"" %>>⭐⭐⭐⭐⭐ (5점)</option>
                    <option value="4" <%= "4".equals(pRating)?"selected":"" %>>⭐⭐⭐⭐ (4점)</option>
                    <option value="3" <%= "3".equals(pRating)?"selected":"" %>>⭐⭐⭐ (3점)</option>
                    <option value="2" <%= "2".equals(pRating)?"selected":"" %>>⭐⭐ (2점)</option>
                    <option value="1" <%= "1".equals(pRating)?"selected":"" %>>⭐ (1점)</option>
                </select>

                <select id="searchMedia" onchange="filterWishList()">
                    <option value="all">📷 전체 글</option>
                    <option value="photo" <%= "photo".equals(pMedia)?"selected":"" %>>🖼️ 비디오/포토 후기만 보기 </option>
                    <option value="text" <%= "text".equals(pMedia)?"selected":"" %>>📝 텍스트 후기만 보기</option>
                </select>
            </div>

            <button onclick="location.href='../personalPlan/travelList.jsp'" 
                    style="margin-top:5px; padding:8px 15px; cursor:pointer; background:#333; color:white; border:none; border-radius:20px;">
                내 여행 계획 보러가기
            </button>
        </div>

        <div class="review-grid">
            <% 
            if(viewList != null && !viewList.isEmpty()) { 
                for(ReviewDTO dto : viewList) {

                    String rawCat = dto.getCategory();
                    String displayCat = "일반";
                    String catIcon = "📍";
                    
                    if (rawCat != null && !rawCat.isEmpty()) {
                    	
                        if(rawCat.contains("accommodation")) catIcon = "🏨";
                        else if(rawCat.contains("dining")) catIcon = "🍽️";
                        else if(rawCat.contains("activity")) catIcon = "🎡";
                        else if(rawCat.contains("transport")) catIcon = "🚌";
                        
                        if (rawCat.contains("_")) {
                            String[] parts = rawCat.split("_");
                            if (parts.length > 1) {
                                displayCat = parts[1]; 
                            } else {
                                displayCat = rawCat;
                            }
                        } else {
                            displayCat = rawCat;
                        }
                    }
            %>
                <div class="review-card" onclick="location.href='travelReviewDetail.jsp?reviewNo=<%=dto.getReviewNo()%>'">
                    <div class="card-image">
                    <% if(dto.getThumbnail() != null) { %>
                        <img src="/uploads/<%=dto.getThumbnail()%>" alt="썸네일">
                        
                        <% if(dto.getMediaCount() > 1) { %>
                           <span style="position:absolute; top:10px; right:10px; background:rgba(0,0,0,0.6); color:white; padding:2px 6px; border-radius:4px; font-size:12px;">+<%=dto.getMediaCount()-1%></span>
                        <% } %>
                        
                    <% } else { 
                        // 사진 없을 때: 카테고리별 기본 이미지 설정
                        String defaultImg = "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400&h=300&fit=crop";
                        String cat = dto.getCategory();
                        
                        if(cat != null) {
                            if(cat.contains("accommodation")) { 
                                defaultImg = "https://plus.unsplash.com/premium_vector-1723276520942-038022e77269?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
                            } else if(cat.contains("dining")) { 
                                defaultImg = "https://plus.unsplash.com/premium_vector-1731665822463-397eb4d930d3?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
                            } else if(cat.contains("activity")) { 
                                defaultImg = "https://plus.unsplash.com/premium_vector-1723276521346-5d76662a06b8?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
                            }
                        }
                    %>
                        <img src="<%=defaultImg%>" alt="기본이미지" style="filter: grayscale(30%); opacity: 0.9;">
                        
                        <div style="position:absolute; top:15px; left:15px; font-size:35px; text-shadow:0 2px 5px rgba(0,0,0,0.5);">
						    <%=catIcon%>
						</div>
                    <% } %>
                    </div>
                    
                    <div class="card-body">
                        <div class="card-dest">
                            <% String countryCode = dto.getDestination(); %>
                            <% if (countryCode != null && countryCode.length() == 2) { %>
                                <span class="fi fi-<%=countryCode.toLowerCase()%>" 
							          style="margin-right:5px; border: 1px solid #ccc; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
							    </span>
                            <% } %>
                            
                            <span style="font-weight:bold; color:#333;">
                                <%= (dto.getPlanTitle() != null) ? dto.getPlanTitle() : "기타 장소" %>
                            </span>
                        </div>
                        
                        <span class="card-header-badge"><%=catIcon%> <%= displayCat %></span>
                        
                        <div class="card-content" style="color:#666; font-size:0.9rem;">
                            <%=dto.getContent()%>
                        </div>
 
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
                    <h3>조건에 맞는 찜 목록이 없어요! 😅</h3>
                    <p>다른 필터를 선택하거나 후기를 구경해보세요.</p>
                </div>
            <% } %>
        </div> 

        <div style="text-align: center; margin-top: 50px; margin-bottom: 20px;">
        <%
            if (totalCount > 0) {
                int pageBlock = 5;
                int pageCount = totalCount / pageSize + (totalCount % pageSize == 0 ? 0 : 1);
                int startPage = (int)((pageNum - 1) / pageBlock) * pageBlock + 1;
                int endPage = startPage + pageBlock - 1;
                if (endPage > pageCount) endPage = pageCount;
                
                // [이전]
                if (startPage > pageBlock) {
        %>
                <a href="wishList.jsp?pageNum=<%= startPage - pageBlock %><%=searchParams%>" 
                   style="text-decoration: none; color: #666; margin-right: 10px;">[이전]</a>
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
                    <a href="wishList.jsp?pageNum=<%= i %><%=searchParams%>" 
                       style="text-decoration: none; color: #666; font-size: 16px; margin: 0 8px;"><%= i %></a>
        <%
                    }
                }
                
                // [다음]
                if (endPage < pageCount) {
        %>
                <a href="wishList.jsp?pageNum=<%= startPage + pageBlock %><%=searchParams%>" 
                   style="text-decoration: none; color: #666; margin-left: 10px;">[다음]</a>
        <%
                }
            }
        %>
        </div>
        
    </div>
</body>
</html>