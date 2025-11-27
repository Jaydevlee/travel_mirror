<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.util.*, java.sql.Connection, com.common.DBConnection"%>
<%@ page import="com.travelReview.dao.ReviewDAO"%>
<%@ page import="com.travelReview.dto.ReviewDTO"%>
<%@ page import="com.travelReview.dto.ReviewMediaDTO"%>

<%
String reviewNoStr = request.getParameter("reviewNo");
if (reviewNoStr == null) {
	response.sendRedirect("reviewList.jsp");
	return;
}
int reviewNo = Integer.parseInt(reviewNoStr);

Connection conn = null;
ReviewDAO dao = new ReviewDAO(); // DAO 생성

String content = "";
int rating = 5;
int planNo = 0;

// 기존 사진 리스트 (HTML 호환성을 위해 Map 구조 유지)
List<Map<String, String>> mediaList = new ArrayList<>();

try {
	conn = DBConnection.getConnection();

	// 리뷰 내용 가져오기 (DAO 사용)
	ReviewDTO review = dao.selectReview(conn, reviewNo);
	if (review != null) {
		content = review.getContent();
		rating = review.getRating();
		planNo = review.getPlanNo();
	}

	// 기존 사진 리스트 가져오기 (DAO 사용)
	List<ReviewMediaDTO> dtos = dao.selectMediaList(conn, reviewNo);

	// DTO 데이터를 Map으로 변환 (기존 HTML 코드 수정을 최소화하기 위함)
	for (ReviewMediaDTO dto : dtos) {
		Map<String, String> map = new HashMap<>();
		map.put("no", String.valueOf(dto.getMediaNo()));
		map.put("name", dto.getSavedName());
		map.put("type", dto.getFileType());
		mediaList.add(map);
	}

} catch (Exception e) {
	e.printStackTrace();
} finally {
	DBConnection.close(conn);
}

request.setAttribute("pageTitle", "후기 수정하기");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>후기 수정</title>
<link rel="stylesheet" href="../css/travelReview.css">
<script src="../js/jquery-3.7.1.min.js"></script>
<style>
/* 기존 이미지 표시용 스타일 */
.old-media-item {
	position: relative;
	display: inline-block;
	margin: 5px;
	width: 100px;
	height: 100px;
}

.old-media-item img, .old-media-item video {
	width: 100%;
	height: 100%;
	object-fit: cover;
	border-radius: 8px;
}

.btn-del-old {
	position: absolute;
	top: -5px;
	right: -5px;
	background: red;
	color: white;
	border: none;
	border-radius: 50%;
	width: 20px;
	height: 20px;
	cursor: pointer;
}
</style>
</head>
<body>
	<jsp:include page="../header.jsp" />

	<div class="container">

		<div class="container" style="justify-content: center;">
			<main class="right-main" style="width: 100%; max-width: 800px;">
				<div class="review-form-card">
					<form id="editForm">
						<input type="hidden" name="reviewNo" value="<%=reviewNo%>">
						<input type="hidden" name="planNo" value="<%=planNo%>">

						<div class="star-rating">
							<input type="hidden" name="rating" id="input-rating"
								value="<%=rating%>">
							<%
							for (int i = 1; i <= 5; i++) {
							%>
							<span class="star <%=i <= rating ? "filled" : ""%>"
								data-value="<%=i%>" onclick="setRating(<%=i%>)">★</span>
							<%
							}
							%>
						</div>

						<div style="margin-bottom: 20px;">
							<label class="input-label">내용 수정</label>
							<textarea name="content" class="review-textarea"><%=content%></textarea>
						</div>

						<div style="margin-bottom: 20px;">
							<label class="input-label">기존 사진/동영상 (삭제할 것만 X 클릭)</label>
							<div id="old-media-area">
								<%
								for (Map<String, String> media : mediaList) {
								%>
								<div class="old-media-item" id="media-<%=media.get("no")%>">
									<%
									if ("VIDEO".equals(media.get("type"))) {
									%>
									<video src="/uploads/<%=media.get("name")%>" controls></video>
									<%
									} else {
									%>
									<img src="/uploads/<%=media.get("name")%>">
									<%
									}
									%>
									<button type="button" class="btn-del-old"
										onclick="deleteOldMedia(<%=media.get("no")%>)">×</button>
								</div>
								<%
								}
								%>
							</div>
							<div id="delete-media-inputs"></div>
						</div>

						<div class="file-upload-wrapper">
							<label class="input-label">새 사진 추가</label> <label
								for="file-input" class="file-btn">📷 추가하기</label> <input
								type="file" id="file-input" multiple accept="image/*, video/*"
								style="display: none;" onchange="handleFiles(this)">
							<div id="image-preview-area" class="image-preview-grid"></div>
						</div>

						<button type="button" class="btn-save-review"
							onclick="submitEdit()">수정 완료</button>
					</form>
				</div>
			</main>
		</div>

		<script>
        // 별점 기능
        function setRating(score) {
            document.getElementById('input-rating').value = score;
            document.querySelectorAll('.star').forEach(star => {
                const val = parseInt(star.getAttribute('data-value'));
                star.classList.toggle('filled', val <= score);
                star.innerText = val <= score ? '★' : '☆';
            });
        }

        // 기존 미디어 삭제 버튼 클릭 시
        function deleteOldMedia(mediaNo) {
            if(confirm('이 파일을 삭제 목록에 추가합니까? (수정 완료 시 삭제됨)')) {
                // 화면에서 숨김
                document.getElementById('media-' + mediaNo).style.display = 'none';
                
                // form에 삭제할 번호 input 추가
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'deleteMediaNo';
                input.value = mediaNo;
                document.getElementById('delete-media-inputs').appendChild(input);
            }
        }

        // 새 파일 미리보기 (travelReview.js와 동일 로직)
        let selectedFiles = [];
        function handleFiles(input) {
            const files = Array.from(input.files);
            const previewArea = document.getElementById('image-preview-area');
            files.forEach(file => {
                selectedFiles.push(file);
                const reader = new FileReader();
                reader.onload = function(e) {
                    const div = document.createElement('div');
                    div.className = 'preview-box';
                    if (file.type.startsWith('video/')) {
                        div.innerHTML = `<video src="${e.target.result}" style="width:100%; height:100%; object-fit:cover;"></video>`;
                    } else {
                        div.innerHTML = `<img src="${e.target.result}">`;
                    }
                    // 삭제 버튼 추가 (새로 올린 것만 취소)
                    const btn = document.createElement('button');
                    btn.className = 'btn-remove-img';
                    btn.innerText = '×';
                    btn.onclick = function() { div.remove(); selectedFiles = selectedFiles.filter(f => f !== file); };
                    div.appendChild(btn);
                    previewArea.appendChild(div);
                };
                reader.readAsDataURL(file);
            });
        }

        // 수정 전송
        function submitEdit() {
            const form = document.getElementById('editForm');
            const formData = new FormData(form);
            selectedFiles.forEach(file => { formData.append('newImages', file); });

            $.ajax({
                url: 'updateReviewAction.jsp',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(res) {
                    if(res.trim() === 'success') {
                        alert('수정되었습니다.');
                        // ★ 파일명 수정됨: travelReviewDetail.jsp로 이동
                        location.href = 'travelReviewDetail.jsp?reviewNo=' + form.reviewNo.value;
                    } else {
                        alert('수정 실패: ' + res);
                    }
                },
                error: function() { alert('통신 오류'); }
            });
        }
    </script>
</body>
</html>