// 데이터 세팅
let dayCount = 0;
let travelStartDate = null;
let travelEndDate = null;


let currentTravelNo = (typeof window.serverTravelNo !== 'undefined') ? window.serverTravelNo : null;
let savedPlans = (typeof window.serverPlanList !== 'undefined') ? window.serverPlanList : [];

// 카테고리  (아이콘, 라벨)
const categoryData = {
	'transport': { title: '교통', items: [{ t: '항공권', i: '✈️' }, { t: '기차', i: '🚄' }, { t: '버스', i: '🚌' }, { t: '택시', i: '🚕' }], labels: { t: '출발', e: '도착', l: '출발지/터미널' } },
	'accommodation': { title: '숙소', items: [{ t: '호텔', i: '🏨' }, { t: '에어비앤비', i: '🏠' }, { t: '게스트하우스', i: '🛏️' }], labels: { t: '체크인', e: '체크아웃', l: '주소' } },
	'dining': { title: '식사', items: [{ t: '맛집', i: '🍽️' }, { t: '카페', i: '☕' }, { t: '술집', i: '🍺' }], labels: { t: '방문시간', e: '종료시간', l: '위치' } },
	'activity': { title: '관광', items: [{ t: '관광지', i: '📍' }, { t: '액티비티', i: '🎡' }, { t: '쇼핑', i: '🛍️' }], labels: { t: '시작', e: '종료', l: '위치' } },
	'etc': { title: '기타', items: [{ t: '기타', i: '📝' }], labels: { t: '시작', e: '종료', l: '장소' } }
};

// 페이지 로드 시 실행되는 메인 
document.addEventListener("DOMContentLoaded", function() {

	//  달력 (flatpickr) 
	if (typeof flatpickr !== 'undefined') flatpickr.localize(flatpickr.l10ns.ko);


	if (window.serverStartDate && window.serverEndDate) {
		travelStartDate = new Date(window.serverStartDate);
		travelEndDate = new Date(window.serverEndDate);

		initDayButtons(); // Day 1, Day 2 버튼 만들기
	}

	loadSavedPlans();

	calculateBudget();	// 가계부 계산
});

// Day 버튼 및 컨텐츠 영역 생성
function initDayButtons() {
	const diffTime = Math.abs(travelEndDate - travelStartDate);
	const days = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1; // 총 일수

	const dayContainer = document.getElementById('day-container');
	const mainContainer = document.getElementById('makeAplan-container');

	dayContainer.innerHTML = '';
	mainContainer.innerHTML = '';

	for (let i = 1; i <= days; i++) {
		// 사이드바 버튼
		const btn = document.createElement('button');
		btn.className = 'plan-btn';
		btn.innerText = 'Day ' + i;
		btn.id = 'btn-day-' + i;
		btn.onclick = function() { switchDay(i); };
		dayContainer.appendChild(btn);

		// 메인 컨텐츠 영역 (처음엔 숨김)
		const contentDiv = document.createElement('div');
		contentDiv.className = 'day-content';
		contentDiv.id = 'content-day-' + i;
		contentDiv.style.display = 'none';

		// 해당 날짜 계산
		let targetDate = new Date(travelStartDate);
		targetDate.setDate(targetDate.getDate() + (i - 1));
		let dateStr = targetDate.toISOString().split('T')[0];

		contentDiv.innerHTML = `
            <div class="day-header" style="border-bottom:2px solid #333; margin-bottom:15px; padding-bottom:10px;">
                <h3 style="display:inline-block; margin-right:10px;">Day ${i}</h3>
                <span style="color:#888;">${dateStr}</span>
            </div>
            <div class="add-btn-group" style="margin-bottom:20px; display:flex; gap:5px; flex-wrap:wrap;">
                ${Object.keys(categoryData).map(key =>
			`<button onclick="openModal('${key}', ${i})" style="padding:5px 10px; border:1px solid #ddd; background:white; border-radius:15px; cursor:pointer;">
                        + ${categoryData[key].title}
                    </button>`
		).join('')}
            </div>
            <div class="plan-list-area" id="plan-list-${i}" style="min-height:200px;"></div>
        `;
		mainContainer.appendChild(contentDiv);
	}

	// 첫 번째 날짜 활성화
	if (days > 0) switchDay(1);
}

// 탭 전환 (Day 1 <-> Day 2)
function switchDay(day) {
	// 모든 컨텐츠 숨기고 버튼 비활성화
	document.querySelectorAll('.day-content').forEach(div => div.style.display = 'none');
	document.querySelectorAll('.plan-btn').forEach(btn => btn.style.backgroundColor = '#f9f9f9'); // 기본색
	document.querySelectorAll('.plan-btn').forEach(btn => btn.style.fontWeight = 'normal');

	// 선택된 것만 보이기
	document.getElementById('content-day-' + day).style.display = 'block';
	const activeBtn = document.getElementById('btn-day-' + day);
	activeBtn.style.backgroundColor = '#e0e0e0'; // 활성색
	activeBtn.style.fontWeight = 'bold';
}

// 모달 및 입력

// 카테고리 선택 
function openModal(category, day) {
	const data = categoryData[category];
	const modalList = document.getElementById('modal-list');
	const overlay = document.getElementById('modal-overlay');

	document.getElementById('modal-title').innerText = `${data.title} 추가 (Day ${day})`;
	modalList.innerHTML = '';

	data.items.forEach(item => {
		const li = document.createElement('li');
		li.innerHTML = `<div style="padding:10px; border-bottom:1px solid #eee; cursor:pointer; font-size:1.1em;">${item.i} ${item.t}</div>`;
		li.onclick = function() {
			showInputForm(item.t, day, category, item.i, data.labels);
		};
		modalList.appendChild(li);
	});
	overlay.style.display = 'flex';
}

function closeModal() { document.getElementById('modal-overlay').style.display = 'none'; }

// 입력 폼 
function showInputForm(titlePrefix, day, category, icon, labels, existingData = null) {
	const modalList = document.getElementById('modal-list');

	// 기존 데이터가 있으면 값 채우기 
	const titleVal = existingData ? existingData.title : titlePrefix;
	const locVal = existingData ? (existingData.location || '') : '';
	const costVal = existingData ? existingData.cost : '';
	const bookingVal = existingData ? (existingData.bookingNo || '') : '';
	const planNoVal = existingData ? existingData.planNo : '';

	// 날짜 시간 처리
	let dateStr = getDateByDay(day); // 기본 날짜
	let startVal = dateStr + " 10:00";
	let endVal = dateStr + " 12:00";

	if (existingData) {
		if (existingData.startTime) startVal = formatForInput(existingData.startTime);
		if (existingData.endTime) endVal = formatForInput(existingData.endTime);
	}

	modalList.innerHTML = `
        <div style="padding:10px;">
            <input type="hidden" id="input-plan-no" value="${planNoVal}">
            
            <div style="margin-bottom:10px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">일정 제목</label>
                <input type="text" id="input-title" value="${titleVal}" style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:10px;">
                <label style="display:block; font-size:0.9em; margin-bottom:5px;">예약번호 (선택)</label>
                <input type="text" id="input-booking-no" value="${bookingVal}" style="width:100%; padding:8px;" placeholder="예: XYZ-12345">
            </div>
            <div style="display:flex; gap:10px; margin-bottom:10px;">
                <div style="flex:1;">
                    <label style="display:block; font-size:0.9em; margin-bottom:5px;">${labels.t}</label>
                    <input type="text" id="input-start-time" class="time-picker" value="${startVal}" style="width:100%; padding:8px;">
                </div>
                <div style="flex:1;">
                    <label style="display:block; font-size:0.9em; margin-bottom:5px;">${labels.e}</label>
                    <input type="text" id="input-end-time" class="time-picker" value="${endVal}" style="width:100%; padding:8px;">
                </div>
            </div>
            <div style="margin-bottom:10px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">${labels.l} (장소)</label>
                <input type="text" id="input-location" value="${locVal}" placeholder="장소 검색 또는 입력" style="width:100%; padding:8px;">
            </div>
			<div style="margin-bottom:15px;">
			                <label style="display:block; font-weight:bold; margin-bottom:5px;">비용 (원)</label>
			                <input type="number" id="input-cost" value="${costVal}" placeholder="0" style="width:100%; padding:8px;">
			            </div>

			            <div style="margin-bottom:15px;">
			                <label style="display:block; font-weight:bold; margin-bottom:5px;">메모</label>
			                <textarea id="input-memo" placeholder="메모" 
			                    style="width:100%; height:60px; padding:8px; resize:none; border:1px solid #ddd;"></textarea>
			            </div>
			            <button onclick="saveToDB(${day}, '${category}')" style="width:100%; padding:10px; background:#333; color:white; border:none; cursor:pointer;">
			                ${existingData ? '수정 완료' : '저장하기'}
			            </button>
        </div>
    `;

	const endPicker = flatpickr("#input-end-time", {
		enableTime: true,
		dateFormat: "Y-m-d H:i",
		time_24hr: false,
		locale: "ko",
		minDate: travelStartDate,
		maxDate: travelEndDate
	});

	flatpickr("#input-start-time", {
		enableTime: true,
		dateFormat: "Y-m-d H:i",
		time_24hr: false,
		locale: "ko",
		minDate: travelStartDate,
		maxDate: travelEndDate,
		onChange: function(selectedDates, dateStr, instance) {
			if (selectedDates.length > 0) {
				endPicker.set('minDate', dateStr);

				// 종료일 달력을 시작일이 있는 달로 점프시킴
				endPicker.jumpToDate(selectedDates[0]);
			}
		}
	});
}

// DB 저장 (Ajax) -> savePlan.jsp / editPlan.jsp 호출
function saveToDB(day, category) {
	const planNo = document.getElementById('input-plan-no').value;
	const title = document.getElementById('input-title').value;
	const bookingNo = document.getElementById('input-booking-no').value || '';
	const start = document.getElementById('input-start-time').value;
	const end = document.getElementById('input-end-time').value;
	const loc = document.getElementById('input-location').value;
	const cost = document.getElementById('input-cost').value || 0;

	if (!title) { alert("제목을 입력해주세요"); return; }

	if (start && window.serverStartDate) {
		const selectedDateStr = start.substring(0, 10);

		const sDate = new Date(window.serverStartDate);
		const tDate = new Date(selectedDateStr);

		sDate.setHours(0, 0, 0, 0);
		tDate.setHours(0, 0, 0, 0);

		const diffTime = tDate.getTime() - sDate.getTime();
		const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));

		day = diffDays + 1;

		console.log("날짜 변경 감지 -> Day " + day + "로 저장됩니다.");
	}

	const targetUrl = planNo ? "editPlan.jsp" : "savePlan.jsp";

	$.ajax({
		type: "POST",
		url: targetUrl,
		data: {
			planNo: planNo,
			travelNo: currentTravelNo,
			dayNo: day,
			category: category,
			title: title,
			bookingNo: bookingNo,
			startTime: start,
			endTime: end,
			location: loc,
			cost: cost
		},
		success: function(res) {
			if (res.trim().includes("success")) {
				location.reload();
			} else {
				alert("처리 실패: " + res);
			}
		},
		error: function(err) { console.error(err); alert("통신 오류"); }
	});
}

// 화면 렌더링 (저장된 일정 뿌리기)
function loadSavedPlans() {
	if (!savedPlans || savedPlans.length === 0) return;
	savedPlans.sort((a, b) => new Date(a.startTime) - new Date(b.startTime));

	savedPlans.forEach(plan => {
		const startDay = plan.day;
		let duration = 1;
		if (plan.endTime && plan.startTime) {
			const start = new Date(plan.startTime);
			const end = new Date(plan.endTime);
			const diffTime = end.setHours(0, 0, 0, 0) - start.setHours(0, 0, 0, 0);
			const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
			if (diffDays > 0) duration = diffDays + 1;
			if (plan.category === 'accommodation') duration = diffDays;
			if (duration < 1) duration = 1;
		}

		for (let i = 0; i < duration; i++) {
			const currentDay = startDay + i;
			const container = document.getElementById("plan-list-" + currentDay);

			if (container) {
				let timeHtml = "";
				let displayTitle = plan.title;
				let styleClass = "";
				let actionBtns = "";

				// 아이콘 찾기
				let icon = "📍";
				if (categoryData[plan.category]) icon = categoryData[plan.category].items[0].i;

				if (i === 0) {
					// 수정/삭제 버튼 표시
					timeHtml = formatSmartTime(plan.startTime, plan.endTime, plan.category);

					const dataJson = JSON.stringify(plan).replace(/"/g, '&quot;');

					actionBtns = `
                        <button onclick="openEditModal(this)" data-info="${dataJson}" style="margin-left:10px; border:none; background:none; cursor:pointer; font-size:1.2em;">✏️</button>
                        <button onclick="deletePlan(${plan.planNo})" style="border:none; background:none; cursor:pointer; font-size:1.2em; opacity:0.5;">🗑️</button>
                    `;
				} else {
					// 연박 표시
					timeHtml = `<span style="color:#888; font-size:0.8em;">(Day ${i + 1})</span>`;
					styleClass = "opacity: 0.7;";
					displayTitle += " <span style='font-size:0.8em; color:#888;'>(연박)</span>";
				}

				const itemDiv = document.createElement('div');
				itemDiv.className = 'plan-item';
				itemDiv.style.cssText = `background:white; border:1px solid #eee; padding:15px; margin-bottom:10px; border-radius:8px; display:flex; align-items:center; ${styleClass}`;

				itemDiv.innerHTML = `
                    <div style="font-weight:bold; color:#555; width:100px; font-size:0.9em; line-height:1.4;">${timeHtml}</div>
                    <div style="font-size:1.5em; margin-right:15px; margin-left:5px;">${icon}</div>
                    <div style="flex:1;">
                        <div style="font-weight:bold; font-size:1.1em;">${displayTitle}</div>
                        ${plan.bookingNo ? `<div style="font-size:0.8em; color:#007bff;">No. ${plan.bookingNo}</div>` : ''}
                        <div style="font-size:0.9em; color:#888;">${plan.location || ''}</div>
                    </div>
                    <div style="font-weight:bold; color:#007bff;">${(i === 0 ? Number(plan.cost).toLocaleString() + '원' : '-')}</div>
                    ${actionBtns}
                `;
				container.appendChild(itemDiv);
			}
		}
		// 체크아웃 표시
		if (plan.category === 'accommodation') {
			const checkOutDayNo = startDay + duration;
			const checkOutContainer = document.getElementById("plan-list-" + checkOutDayNo);

			if (checkOutContainer) {
				let timeStr = "";
				if (plan.endTime) {
					const t = new Date(plan.endTime);
					let h = t.getHours();
					let m = t.getMinutes();
					timeStr = `${h}:${m < 10 ? '0' + m : m}`;
				}

				const coDiv = document.createElement('div');
				coDiv.className = 'plan-item';
				coDiv.style.cssText = `background:#f8f9fa; border:1px dashed #ccc; padding:15px; margin-bottom:10px; border-radius:8px; display:flex; align-items:center; color:#666;`;

				coDiv.innerHTML = `
		                    <div style="font-weight:bold; width:100px; font-size:0.9em;">${timeStr}</div>
		                    <div style="font-size:1.5em; margin-right:15px; margin-left:5px;">🧳</div>
		                    <div style="flex:1;">
		                        <div style="font-weight:bold; font-size:1.0em;">${plan.title}</div>
		                        <div style="font-size:0.9em; color:#e74c3c; font-weight:bold;">체크아웃 (Check-out)</div>
		                    </div>
		                `;
				checkOutContainer.appendChild(coDiv);
			}
		}
	});
}

// 삭제
function deletePlan(planNo) {
	if (!confirm("삭제하시겠습니까?")) return;
	$.ajax({
		url: "deletePlan.jsp",
		type: "POST",
		data: { planNo: planNo },
		success: function(res) { location.reload(); }
	});
}

// 가계부 열기/계산
function openBudgetModal() { document.getElementById('budget-modal').style.display = 'flex'; calculateBudget(); }
function closeBudgetModal() { document.getElementById('budget-modal').style.display = 'none'; }

function calculateBudget() {
	let total = 0;
	const tbody = document.getElementById('budget-list-body');
	if (tbody) tbody.innerHTML = '';

	let categorySum = {};

	savedPlans.forEach(p => {
		if (p.cost > 0) {
			let cost = parseInt(p.cost);
			total += cost;

			let catKey = p.category;
			let catName = "기타";

			if (categoryData[catKey]) {
				catName = categoryData[catKey].title;
			}

			if (!categorySum[catName]) {
				categorySum[catName] = 0;
			}
			categorySum[catName] += cost;
		}
	});

	// 합산된 카테고리별로 
	for (let name in categorySum) {
		let sum = categorySum[name];

		if (tbody) {
			tbody.innerHTML += `
                <tr style="border-bottom:1px solid #f0f0f0;">
                    <td style="padding:10px; font-weight:bold; color:#555;">${name}</td>
                    <td style="padding:10px; text-align:right; font-weight:bold;">
                        ${Number(sum).toLocaleString()}원
                    </td>
                </tr>`;
		}
	}

	// 총 비용 표시
	const display = document.getElementById('total-budget-display');
	if (display) display.innerText = Number(total).toLocaleString() + "원";
}

// 시간
function formatSmartTime(startStr, endStr, category) {
	if (!startStr) return "";

	const start = new Date(startStr);
	const end = endStr ? new Date(endStr) : null;

	const formatHM = (date) => {
		let h = date.getHours();
		let m = date.getMinutes();
		return `${h}:${m < 10 ? '0' + m : m}`;
	};

	const formatMD = (date) => {
		return `${date.getMonth() + 1}.${date.getDate()}`;
	};

	let result = formatHM(start);

	if (end) {
		const isSameDay = start.toDateString() === end.toDateString();

		if (isSameDay) {
			result += ` ~ ${formatHM(end)}`;
		} else {
			const diffTime = end - start;
			const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

			if (category === 'accommodation') {
				result = `<span style="font-size:0.9em; color:#555;">${formatMD(start)} ~ ${formatMD(end)}</span>`;
				if (diffDays > 0) {
					result += ` <br><span style="font-weight:bold; color:#e67e22;">(${diffDays}박)</span>`;
				}
			} else {
				result += ` ~ ${formatHM(end)}`;
				if (diffDays > 0) {
					result += ` <span style="color:red; font-size:0.8em;">(+${diffDays})</span>`;
				}
			}
		}
	}
	return result;
}

// 수정 모달 열기 
function openEditModal(btn) {
	const dataJson = btn.getAttribute('data-info');
	const data = JSON.parse(dataJson);

	const catInfo = categoryData[data.category];
	const labels = catInfo ? catInfo.labels : { t: '시작', e: '종료', l: '위치' };
	const icon = catInfo ? catInfo.items[0].i : '✏️';

	document.getElementById('modal-title').innerText = "일정 수정";
	showInputForm(data.title, data.day, data.category, icon, labels, data);
	document.getElementById('modal-overlay').style.display = 'flex';
}

// 날짜 계산
function getDateByDay(day) {
	let d = new Date(travelStartDate);
	d.setDate(d.getDate() + (day - 1));
	return d.toISOString().split('T')[0];
}

// 시간 포맷
function formatForInput(tsStr) {
	if (!tsStr) return "";
	return tsStr.substring(0, 16);
}

// 하는중.....언제하냐
function openChecklistModal() { alert("체크리스트 기능 준비중입니다!"); }
function closeChecklistModal() { /* 닫기 로직 */ }
function openTravelListModal() { location.href = 'travelList.jsp'; }