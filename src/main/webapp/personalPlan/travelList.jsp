<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="com.common.DBConnection"%>
<%@ page import="com.personalPlan.dao.TravelDAO"%>
<%@ page import="com.personalPlan.dto.TravelInfoDTO"%>

<%
// DB에서 여행 목록 가져오기 
Connection conn = null;
TravelDAO dao = new TravelDAO();
List<TravelInfoDTO> list = null;

try {
	conn = DBConnection.getConnection();
	list = dao.selectTravelList(conn);
} catch (Exception e) {
	e.printStackTrace();
} finally {
	DBConnection.close(conn);
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>나의 여행 계획 - Dashboard</title>

<link rel="stylesheet" href="../css/travelList.css">

<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

<link
	href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css"
	rel="stylesheet" />
<script src="../js/jquery-3.7.1.min.js"></script>
<script
	src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<script src="../js/countryData.js"></script>

<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.2.3/css/flag-icons.min.css" />

<style>
.select2-results__option span {
	display: inline-flex;
	align-items: center;
}

.fi {
	margin-right: 8px;
	font-size: 1.2em;
}
</style>
</head>
<body>

	<div class="dashboard-container">
		<div class="dashboard-header">
			<h2>✈️ 나의 여행 리스트</h2>
		</div>

		<div class="plan-grid">

			<div class="plan-card add-new-card" onclick="openInitModal()">
				<div class="add-icon">+</div>
				<div class="add-text">새로운 여행 떠나기</div>
			</div>

			<%
			if (list != null) {
				for (TravelInfoDTO dto : list) {
					String bgClass = "bg-default";
					String country = dto.getCountry();
					if (country.contains("일본"))
				bgClass = "bg-japan";
					else if (country.contains("유럽") || country.contains("프랑스") || country.contains("영국"))
				bgClass = "bg-europe";
					else if (country.contains("바다") || country.contains("휴양"))
				bgClass = "bg-sea";
			%>
			<div class="plan-card" data-country="<%=dto.getCountry()%>"
				onclick="location.href='makeAPlan.jsp?travelNo=<%=dto.getTravelNo()%>'">

				<button class="delete-travel-btn"
					onclick="deleteTravel(event, <%=dto.getTravelNo()%>)">×</button>

				<div class="card-img-placeholder <%=bgClass%>">
					<span class="flag-icon">✈️</span>
				</div>

				<div class="card-body">
					<div>
						<div class="card-title"><%=dto.getTitle()%></div>
						<div class="card-meta">
							📍
							<%=dto.getCountry()%>
						</div>
						<div class="card-meta">
							<%
							String mate = dto.getCompanion();
							if (mate == null || mate.equals("null")) {
								mate = "미정";
							} else {
								if (mate.contains("나홀로") && !mate.contains("🚶"))
									mate += " 🚶";
								else if (mate.contains("연인") && !mate.contains("💑"))
									mate += " 💑";
								else if (mate.contains("친구") && !mate.contains("👭"))
									mate += " 👭";
								else if (mate.contains("가족") && !mate.contains("👨‍👩‍👧‍👦"))
									mate += " 👨‍👩‍👧‍👦";
								else if (mate.contains("반려동물") && !mate.contains("🐕"))
									mate += " 🐕";
							}
							%>
							👥
							<%=mate%>
						</div>
					</div>
					<div class="card-date">
						<%=dto.getStartDate()%>
						~
						<%=dto.getEndDate()%>
					</div>
				</div>
			</div>
			<%
			}
			}
			%>
		</div>
	</div>

	<div id="init-modal-overlay" class="modal-overlay">
		<div class="modal-window">
			<div
				style="display: flex; justify-content: space-between; margin-bottom: 20px;">
				<h3 style="margin: 0;">여행 정보 입력</h3>
				<button onclick="closeInitModal()"
					style="border: none; background: none; font-size: 24px; cursor: pointer;">×</button>
			</div>

			<form action="travelWriteAction.jsp" method="post">
				<div class="input-group">
					<label>여행 제목</label> <input type="text" name="title"
						placeholder="예: 3박 4일 도쿄 먹방" required>
				</div>

				<div class="input-group">
					<label>여행 국가</label> <select id="select-country" name="country"
						multiple="multiple" style="width: 100%;">
						<option></option>
					</select>
				</div>

				<div class="input-group">
					<label>누구와 함께?</label> <select name="companion">
						<option value="나홀로">나홀로 🚶</option>
						<option value="친구와">친구와 👭</option>
						<option value="연인과">연인과 💑</option>
						<option value="가족과">가족과 👨‍👩‍👧‍👦</option>
						<option value="반려동물과">반려동물과 🐕</option>
					</select>
				</div>

				<div class="input-group">
					<label>여행 기간</label>
					<div style="display: flex; gap: 10px;">
						<input type="text" name="startDate" class="date-picker"
							placeholder="가는 날" required> <input type="text"
							name="endDate" class="date-picker" placeholder="오는 날" required>
					</div>
				</div>

				<button type="submit" class="btn-submit">일정 생성하기</button>
			</form>
		</div>
	</div>

	<script>
		// 모달 열기/닫기
		function openInitModal() {
			document.getElementById('init-modal-overlay').style.display = 'flex';
		}

		function closeInitModal() {
			document.getElementById('init-modal-overlay').style.display = 'none';
		}

		// 배경 클릭 시 닫기
		document.getElementById('init-modal-overlay').addEventListener('click', function(e) {
			if (e.target === this) closeInitModal();
		});

		function formatCountry (state) {
			if (!state.id) { return state.text; } 

			var textOnly = state.text;
			if(state.text.includes(' ')) {
				textOnly = state.text.substring(state.text.indexOf(' ') + 1);
			}

			// flag-icons 라이브러리 클래스 적용
			var $state = $(
				'<span><span class="fi fi-' + state.id.toLowerCase() + '"></span> ' + textOnly + '</span>'
			);
			return $state;
		};

		$(document).ready(function() {
			$('#select-country').select2({
				data : countryList, // countryData.js 데이터
				placeholder : "여행할 국가를 검색하세요(다중 선택 가능)",
				allowClear : true,
				width : '100%',
				dropdownParent : $('#init-modal-overlay'),
				templateResult: formatCountry,
				templateSelection: formatCountry
			});
		});

		// 달력 (Flatpickr)
		document.addEventListener('DOMContentLoaded', function() {
    
    const endPicker = flatpickr("input[name='endDate']", {
        locale : "ko",
        dateFormat : "Y-m-d"
    });

    
    flatpickr("input[name='startDate']", {
        locale : "ko",
        dateFormat : "Y-m-d",
        onChange: function(selectedDates, dateStr, instance) {
            
            if (selectedDates.length > 0) {
                
                endPicker.set('minDate', dateStr);
                
                // 달력 내가 선택한 일정쯤으로 점프
                endPicker.jumpToDate(selectedDates[0]);
            }
        }
    });
});

		// 여행 삭제 
		function deleteTravel(event, travelNo) {
			event.stopPropagation(); 
			
			if(!confirm("정말 이 여행 계획을 삭제하시겠습니까?\n(복구할 수 없습니다)")) return;
			
			$.ajax({
				url: 'deleteTravel.jsp',
				type: 'POST',
				data: { travelNo: travelNo },
				success: function(res) {
					if(res.trim() === 'success') {
						location.reload();
					} else {
						alert("삭제 실패");
					}
				},
				error: function() {
					alert("서버 통신 오류");
				}
			});
		}

		$(document).ready(function() {
			$('.plan-card').each(function() {
				var dbCountryName = $(this).data('country'); 
				var $iconContainer = $(this).find('.flag-icon'); 
				
				// 기본값 설정 (못 찾으면 비행기)
				$iconContainer.text('✈️'); 

				if(dbCountryName && typeof countryList !== 'undefined') {
					var found = countryList.find(function(item) {
						if (item.id === dbCountryName) {
							return true;
						}

						var itemTextOnly = item.text;
						if(item.text.includes(' ')) {
							itemTextOnly = item.text.split(' ')[1]; 
						}
						return item.text.includes(dbCountryName) || dbCountryName.includes(itemTextOnly); 
					});

					if(found && found.id) {
						var cssClass = 'fi fi-' + found.id.toLowerCase();
						
						// 아이콘 교체 (비행기 -> 국기 이미지)
						$iconContainer.html('<span class="' + cssClass + '" style="font-size: 1.5em;"></span>');
					}
				}
			});
		});
	</script>
</body>
</html>