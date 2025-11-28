<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="com.common.DBConnection"%>
<%@ page import="com.travelReview.dao.ReviewDAO"%>
<%@ page import="com.travelReview.dto.ReviewDTO"%>

<%
	Connection conn = null;
	ReviewDAO dao = new ReviewDAO();
	List<ReviewDTO> list = null;      // 전체 데이터 리스트
	List<ReviewDTO> viewList = null;  // 현재 페이지에 보여줄 6개 리스트

	// 페이징 설정
	int pageSize = 6; // 한 페이지당 6개
	String pageNumStr = request.getParameter("pageNum");
	int pageNum = (pageNumStr == null) ? 1 : Integer.parseInt(pageNumStr);
	int totalCount = 0; // 전체 글 개수

	try {
		conn = DBConnection.getConnection();
		list = dao.selectAllReviews(conn); // DB에서 전체 가져오기
		
		if (list != null) {
			totalCount = list.size();
			
			// 리스트 자르기 (Pagination Logic)
			int startRow = (pageNum - 1) * pageSize;
			int endRow = Math.min(startRow + pageSize, totalCount);
			
			if (startRow < totalCount) {
				viewList = list.subList(startRow, endRow); // 6개만 추출
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		DBConnection.close(conn);
	}

	request.setAttribute("pageTitle", "여행 후기 게시판");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>여행 후기 게시판</title>
<link rel="stylesheet" href="../css/reviewList.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.2.3/css/flag-icons.min.css" />
</head>
<body>
	<jsp:include page="../header.jsp" />

	<div class="container">
		<div class="page-header">
			<h2>📸 여행 후기 갤러리</h2>
			<p>다른 여행자들의 생생한 이야기를 확인해보세요!</p>

			<button onclick="location.href='../personalPlan/travelList.jsp'"
				style="margin-top: 15px; padding: 8px 15px; cursor: pointer; background: #333; color: white; border: none; border-radius: 20px;">
				내 여행 계획 보러가기</button>
		</div>

		<div class="review-grid">
			<%
				if (viewList != null && !viewList.isEmpty()) { 
				    for (ReviewDTO dto : viewList) {
			%>
			<div class="review-card" onclick="location.href='travelReviewDetail.jsp?reviewNo=<%=dto.getReviewNo()%>'">
				<div class="card-image">
					<%
					if (dto.getThumbnail() != null) {
					%>
					<img src="/uploads/<%=dto.getThumbnail()%>" alt="썸네일">
					<%
					} else {
					%>
					<div class="no-image">✈️</div>
					<%
					}
					%>
				</div>

				<div class="card-body">
					<div class="card-dest">
						<%
						String countryCode = dto.getDestination();
						if (countryCode != null && countryCode.length() == 2) {
						%>
						<span class="fi fi-<%=countryCode.toLowerCase()%>"></span>
						<%=countryCode%>
						<%
						} else {
						%>
						📍 <%=countryCode%>
						<%
						}
						%>
					</div>
					<div class="card-content"><%=dto.getContent()%></div>

					<div class="card-footer">
						<div class="rating">
							<%
							for (int i = 0; i < dto.getRating(); i++) {
							%>★<%
							}
							%>
						</div>
						<div class="writer">
							👤 <%=dto.getMemberId()%>
						</div>
					</div>
				</div>
			</div>
			<%
				    } // for문 종료
				} else {
			%>
			<div style="text-align: center; grid-column: 1/-1; padding: 50px; color: #888;">
				<h3>아직 등록된 후기가 없습니다. 😅</h3>
				<p>첫 번째 후기의 주인공이 되어보세요!</p>
			</div>
			<%
				}
			%>
		</div> <div style="text-align: center; margin-top: 50px; margin-bottom: 20px;">
		<%
			if (totalCount > 0) {
				int pageBlock = 5; // 밑에 보여줄 번호 개수 (1~5)
				int pageCount = totalCount / pageSize + (totalCount % pageSize == 0 ? 0 : 1);
				
				int startPage = (int)((pageNum - 1) / pageBlock) * pageBlock + 1;
				int endPage = startPage + pageBlock - 1;
				if (endPage > pageCount) endPage = pageCount;
				
				// [이전] 버튼
				if (startPage > pageBlock) {
		%>
				<a href="reviewList.jsp?pageNum=<%= startPage - pageBlock %>" 
				   style="text-decoration: none; color: #666; margin-right: 10px;">[이전]</a>
		<%
				}
				
				// 페이지 번호 (1, 2, 3...)
				for (int i = startPage; i <= endPage; i++) {
					if (i == pageNum) {
		%>
					<span style="font-weight: bold; color: #3b82f6; font-size: 18px; margin: 0 8px;"><%= i %></span>
		<%
					} else {
		%>
					<a href="reviewList.jsp?pageNum=<%= i %>" 
					   style="text-decoration: none; color: #666; font-size: 16px; margin: 0 8px;"><%= i %></a>
		<%
					}
				}
				
				// [다음] 버튼
				if (endPage < pageCount) {
		%>
				<a href="reviewList.jsp?pageNum=<%= startPage + pageBlock %>" 
				   style="text-decoration: none; color: #666; margin-left: 10px;">[다음]</a>
		<%
				}
			}
		%>
		</div>
		</div> </body>
</html>