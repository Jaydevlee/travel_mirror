<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
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
	String myId = (String) session.getAttribute("sessionId");

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
if (content != null)
	content = content.replace("\n", "<br>");

// 내 글인지 확인 (수정/삭제 버튼 표시용)
String myId = (String) session.getAttribute("sessionId");

boolean isMyReview = (myId != null && myId.equals(review.getMemberId()));

request.setAttribute("pageTitle", "후기 상세 보기");
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

	<jsp:include page="../header.jsp" />

	<div class="detail-container">
		<div class="detail-header">
			<div class="detail-dest">
				✈️
				<%=review.getDestination()%></div>

			<div class="detail-rating">
				<%
				for (int i = 0; i < review.getRating(); i++) {
				%>★<%
				}
				%>
				<%
				for (int i = 0; i < 5 - review.getRating(); i++) {
				%>☆<%
				}
				%>
				<span
					style="color: #333; font-size: 14px; font-weight: bold; margin-left: 5px;">
					<%=review.getRating()%>점
				</span>
			</div>

			<div class="detail-meta">
				<span>작성자: <%=review.getMemberId()%></span> <span><%=review.getRegDate()%></span>
			</div>
		</div>

		<div class="detail-content">
			<%=content%>
		</div>

		<div class="slider-container">
			<div class="slider-track" id="sliderTrack">
				<%
				if (mediaList != null && !mediaList.isEmpty()) {
					for (ReviewMediaDTO media : mediaList) {
						String savedName = media.getSavedName();
						String type = media.getFileType();
				%>
				<div class="slide-item">
					<%
					if ("VIDEO".equals(type)) {
					%>
					<video controls src="/uploads/<%=savedName%>"></video>
					<%
					} else {
					%>
					<img src="/uploads/<%=savedName%>" alt="여행 사진">
					<%
					}
					%>
				</div>
				<%
				}
				} else {
				%>
				<div class="slide-item">
					<div
						style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: #eee; color: #aaa;">
						이미지가 없습니다.</div>
				</div>
				<%
				}
				%>
			</div>

			<%
			if (mediaList != null && mediaList.size() > 1) {
			%>
			<button class="slider-btn prev-btn" onclick="moveSlide(-1)">&#10094;</button>
			<button class="slider-btn next-btn" onclick="moveSlide(1)">&#10095;</button>
			<%
			}
			%>
		</div>

		<div class="btn-group">
			<button class="btn-basic" onclick="location.href='reviewList.jsp'">목록으로</button>

			<button class="btn-basic btn-wish <%=isSaved ? "active" : ""%>"
				onclick="toggleWish(<%=reviewNo%>)">
				<%=isSaved ? "♥ 저장됨" : "♡ 저장하기"%>
			</button>

			<%
			if (isMyReview) {
			%>
			<button class="btn-basic btn-primary"
				onclick="location.href='editReview.jsp?reviewNo=<%=reviewNo%>'">수정</button>
			<button class="btn-basic btn-danger"
				onclick="deleteReview(<%=reviewNo%>)">삭제</button>
			<%
			}
			%>
		</div>
	</div>

	<script src="../js/travelReview/travelReviewDetail.js"></script>

	<script>
    let currentIndex = 0; // 현재 보고 있는 사진 번호 (0부터 시작)

    function moveSlide(direction) {
        const track = document.getElementById('sliderTrack');
        const slides = track.querySelectorAll('.slide-item');
        const totalSlides = slides.length;

        // 인덱스 계산
        currentIndex += direction;

        // 처음에서 뒤로 가면 맨 끝으로, 끝에서 앞으로 가면 처음으로 순환
        if (currentIndex < 0) {
            currentIndex = totalSlides - 1;
        } else if (currentIndex >= totalSlides) {
            currentIndex = 0;
        }

        // 슬라이드 이동 (가로 크기만큼 이동)
        const movePercentage = currentIndex * -100;
        track.style.transform = 'translateX(' + movePercentage + '%)';
    }
</script>

</body>
</html>