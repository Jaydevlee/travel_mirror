<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="com.common.DBConnection"%>
<%@ page import="com.travelReview.dao.ReviewDAO"%>
<%@ page import="com.travelReview.dto.ReviewDTO"%>

<%
Connection conn = null;
ReviewDAO dao = new ReviewDAO();
List<ReviewDTO> list = null;

try {
	conn = DBConnection.getConnection();
	list = dao.selectAllReviews(conn);
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
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.2.3/css/flag-icons.min.css" />
</head>
<body>
<jsp:include page="../header.jsp" />

    <div class="review-container">
        </div>
        
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
			if (list != null && !list.isEmpty()) {
				for (ReviewDTO dto : list) {
			%>
			<div class="review-card"
				onclick="location.href='travelReviewDetail.jsp?reviewNo=<%=dto.getReviewNo()%>'">
				<div class="card-image">
					<%
					if (dto.getThumbnail() != null) {
					%>
					<img src="../uploads/review/<%=dto.getThumbnail()%>" alt="썸네일">
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
						📍
						<%=countryCode%>
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
							👤
							<%=dto.getMemberId()%>
						</div>
					</div>
				</div>
			</div>
			<%
			}
			} else {
			%>
			<div
				style="text-align: center; grid-column: 1/-1; padding: 50px; color: #888;">
				<h3>아직 등록된 후기가 없습니다. 😅</h3>
				<p>첫 번째 후기의 주인공이 되어보세요!</p>
			</div>
			<%
			}
			%>
		</div>
	</div>

</body>
</html>