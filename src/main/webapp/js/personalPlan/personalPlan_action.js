// 데이터 세팅
let dayCount = 0;
let travelStartDate = null;
let travelEndDate = null;


let currentTravelNo = (typeof window.serverTravelNo !== 'undefined') ? window.serverTravelNo : null;
let savedPlans = (typeof window.serverPlanList !== 'undefined') ? window.serverPlanList : [];

// 메인 지도용 변수 선언 
let mainMap = null;
let mainMarkers = [];
let mainPath = null;

// 카테고리  (아이콘, 라벨)
const categoryData = {
	'transport': {
		title: '교통', items: [{ t: '항공권', i: '✈️' }, { t: '기차', i: '🚄' }, { t: '지하철', i: '🚇' },
		{ t: '버스', i: '🚌' }, { t: '택시', i: '🚕' }, { t: '자동차', i: '🚗' },
		{ t: '배편', i: '🚢' }, { t: '기타', i: '🔖' }], labels: { t: '출발', e: '도착', l: '출발지/터미널' }
	},
	'accommodation': {
		title: '숙소', items: [{ t: '호텔', i: '🏨' }, { t: '에어비앤비', i: '🏠' }, { t: '게스트하우스', i: '🛏️' },
		{ t: '기타', i: '🔖' }], labels: { t: '체크인', e: '체크아웃', l: '주소' }
	},
	'dining': {
		title: '식사', items: [{ t: '식당', i: '🍽️' }, { t: '카페', i: '☕' }, { t: '술집', i: '🍺' },
		{ t: '기타', i: '🔖' }], labels: { t: '방문시간', e: '종료시간', l: '위치' }
	},
	'activity': {
		title: '관광', items: [{ t: '관광지', i: '📍' }, { t: '액티비티', i: '🎡' }, { t: '쇼핑', i: '🛍️' },
		{ t: '기타', i: '🔖' }], labels: { t: '시작', e: '종료', l: '위치' }
	},
	'etc': { title: '기타', items: [{ t: '기타', i: '📝' }], labels: { t: '시작', e: '종료', l: '장소' } }
};

// 페이지 로드 시 실행되는 메인 
document.addEventListener("DOMContentLoaded", function() {

	//  달력 (flatpickr) 
	if (typeof flatpickr !== 'undefined') flatpickr.localize(flatpickr.l10ns.ko);


	if (window.serverStartDate && window.serverEndDate) {
		travelStartDate = new Date(window.serverStartDate);
		travelEndDate = new Date(window.serverEndDate);

		travelEndDate.setHours(23, 59, 59);

		initDayButtons(); // Day 1, Day 2 버튼 만들기
	}

	loadSavedPlans();

	calculateBudget();	// 가계부 계산
	
	setTimeout(() => {		// 지도
	        updateMainMap(); 
	    }, 500); 
	    
	});

// Day 버튼 및 컨텐츠 영역 생성
function initDayButtons() {
	const d1 = new Date(travelStartDate);
	const d2 = new Date(travelEndDate);

	d1.setHours(0, 0, 0, 0);
	d2.setHours(0, 0, 0, 0);

	const diffTime = Math.abs(d2 - d1);
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
		li.innerHTML = `<div style="padding:10px; cursor:pointer; font-size:1.1em;">${item.i} ${item.t}</div>`;

		li.onclick = function() {

			showInputForm(item.t, day, category, item.i, data.labels, null, item.t);
		};
		modalList.appendChild(li);
	});
	overlay.style.display = 'flex';
}

function closeModal() { document.getElementById('modal-overlay').style.display = 'none'; }

// 입력 폼 
// [수정 3] 입력 폼 보여주기 (selectedType 매개변수 추가됨)
function showInputForm(titlePrefix, day, category, icon, labels, existingData = null, selectedType = "") {
	const modalList = document.getElementById('modal-list');

	// 기존 데이터가 있으면 제목 그대로, 없으면 빈칸
	const titleVal = existingData ? existingData.title : "";

	// selectedType이 없으면 titlePrefix(예: '기차')를 사용
	const finalSubType = selectedType || titlePrefix;

	const locVal = existingData ? (existingData.location || '') : '';
	const costVal = existingData ? existingData.cost : '';
	const bookingVal = existingData ? (existingData.bookingNo || '') : '';
	const planNoVal = existingData ? existingData.planNo : '';

	// 날짜 시간 처리
	let dateStr = getDateByDay(day);
	let startVal = dateStr + " 10:00";
	let endVal = dateStr + " 12:00";

	if (existingData) {
		if (existingData.startTime) startVal = formatForInput(existingData.startTime);
		if (existingData.endTime) endVal = formatForInput(existingData.endTime);
	}

	modalList.innerHTML = `
        <div style="padding:10px;">
            <input type="hidden" id="input-plan-no" value="${planNoVal}">
            
            <input type="hidden" id="input-subtype" value="${finalSubType}">

            <div style="margin-bottom:10px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">일정 제목</label>
                <input type="text" id="input-title" value="${titleVal}" placeholder="${titlePrefix}" style="width:100%; padding:8px;">
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
                <input type="text" id="input-location" value="${locVal}" placeholder="장소 / 주소" style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:15px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">비용 (원)</label>
                <input type="number" id="input-cost" value="${costVal}" placeholder="0" style="width:100%; padding:8px;">
            </div>
            <div style="margin-bottom:15px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">메모</label>
                <textarea id="input-memo" placeholder="메모" style="width:100%; height:60px; padding:8px; resize:none; border:1px solid #ddd;"></textarea>
            </div>
            <button onclick="saveToDB(${day}, '${category}')" style="width:100%; padding:10px; background:#333; color:white; border:none; cursor:pointer;">
                ${existingData ? '수정 완료' : '저장하기'}
            </button>
        </div>
    `;

	// 달력 설정 부분 (기존과 동일)
	const endPicker = flatpickr("#input-end-time", {
		enableTime: true, dateFormat: "Y-m-d H:i", time_24hr: false, locale: "ko",
		minDate: travelStartDate, maxDate: travelEndDate
	});
	flatpickr("#input-start-time", {
		enableTime: true, dateFormat: "Y-m-d H:i", time_24hr: false, locale: "ko",
		minDate: travelStartDate, maxDate: travelEndDate,
		onChange: function(selectedDates, dateStr, instance) {
			if (selectedDates.length > 0) {
				endPicker.set('minDate', dateStr);
				endPicker.jumpToDate(selectedDates[0]);
			}
		}
	});
}

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

// DB 저장 (Ajax) -> savePlan.jsp / editPlan.jsp 호출
function saveToDB(day, category) {
	const planNo = document.getElementById('input-plan-no').value;
	const title = document.getElementById('input-title').value;
	const bookingNo = document.getElementById('input-booking-no').value || '';
	const start = document.getElementById('input-start-time').value;
	const end = document.getElementById('input-end-time').value;
	const loc = document.getElementById('input-location').value;
	const cost = document.getElementById('input-cost').value || 0;

	const subType = document.getElementById('input-subtype').value;

	if (!title) { alert("제목을 입력해주세요"); return; }

	if (start && window.serverStartDate) {
		const selectedDateStr = start.substring(0, 10);
		const sDate = new Date(window.serverStartDate);
		const tDate = new Date(selectedDateStr);
		sDate.setHours(0, 0, 0, 0); tDate.setHours(0, 0, 0, 0);
		const diffTime = tDate.getTime() - sDate.getTime();
		const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));
		day = diffDays + 1;
	}

	const targetUrl = planNo ? "editPlan.jsp" : "savePlan.jsp";

	const fullCategory = subType ? (category + "__" + subType) : category;

	$.ajax({
		type: "POST",
		url: targetUrl,
		data: {
			planNo: planNo,
			travelNo: currentTravelNo,
			dayNo: day,
			category: fullCategory,
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


				const catParts = plan.category.split('__');
				const mainCategory = catParts[0];
				const subType = catParts.length > 1 ? catParts[1] : null;


				if (categoryData[mainCategory]) {

					icon = categoryData[mainCategory].items[0].i;


					if (subType) {
						const foundItem = categoryData[mainCategory].items.find(item => item.t === subType);
						if (foundItem) icon = foundItem.i;
					}

					else {
						const items = categoryData[mainCategory].items;
						for (let k = 0; k < items.length; k++) {
							if (plan.title.includes(items[k].t)) {
								icon = items[k].i;
								break;
							}
						}
					}
				}

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

// 가계부 계산 
function calculateBudget() {
	let total = 0;
	const tbody = document.getElementById('budget-list-body');
	if (tbody) tbody.innerHTML = '';

	let categorySum = {};

	savedPlans.forEach(p => {
		if (p.cost > 0) {
			let cost = parseInt(p.cost);
			total += cost;

			let catKey = p.category.split('__')[0]; 

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

	// 합산된 카테고리별로 출력
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

	const catParts = data.category.split('__');
	const mainCategory = catParts[0];
	const subType = catParts.length > 1 ? catParts[1] : data.title;

	const catInfo = categoryData[mainCategory];
	const labels = catInfo ? catInfo.labels : { t: '시작', e: '종료', l: '위치' };

	let icon = '✏️';
	if (catInfo) {
		const foundItem = catInfo.items.find(it => it.t === subType);
		icon = foundItem ? foundItem.i : catInfo.items[0].i;
	}

	document.getElementById('modal-title').innerText = "일정 수정";
	showInputForm(data.title, data.day, mainCategory, icon, labels, data, subType);
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

// 체크리스트

// 모달 열기 및 목록 불러오기
function openChecklistModal() {
	document.getElementById('checklist-modal').style.display = 'flex';
	loadChecklist(); // 열릴 때마다 최신 목록 가져오기
}

function closeChecklistModal() {
	document.getElementById('checklist-modal').style.display = 'none';
}

// 목록 불러오기 (AJAX)
function loadChecklist() {
	if (!currentTravelNo) {
		alert("여행 정보를 불러오지 못했습니다.");
		return;
	}

	$.ajax({
		url: "checkList.jsp",
		type: "POST",
		data: { cmd: "list", travelNo: currentTravelNo },
		dataType: "json",
		success: function(list) {
			const ul = document.getElementById('checklist-ul');
			ul.innerHTML = '';

			if (list.length === 0) {
				ul.innerHTML = '<li style="color:#999; text-align:center; margin-top:20px;">준비물을 추가해보세요!</li>';
				return;
			}

			list.forEach(item => {

				const isChecked = (item.is_checked === 'Y');

				const li = document.createElement('li');
				li.style.cssText = "padding:10px; border-bottom:1px solid #f0f0f0; display:flex; align-items:center; justify-content:space-between;";

				const contentStyle = isChecked ? 'text-decoration:line-through; color:#ccc;' : 'color:#333;';

				li.innerHTML = `
                    <div style="display:flex; align-items:center; flex:1;">
                        <input type="checkbox" ${isChecked ? 'checked' : ''} 
                            onchange="toggleCheck(${item.check_no}, this)" 
                            style="margin-right:10px; cursor:pointer; width:18px; height:18px;">
                        <span style="font-size:1.1em; ${contentStyle}">${item.content}</span>
                    </div>
                    <button onclick="deleteCheck(${item.check_no})" style="background:none; border:none; cursor:pointer; font-size:1.2em; color:#ff6b6b;">×</button>
                `;
				ul.appendChild(li);
			});
		},
		error: function(err) {
			console.error("체크리스트 로드 실패:", err);
		}
	});
}

function addCheckItem() {
	const input = document.getElementById('new-check-item');
	const content = input.value.trim();

	if (!content) {
		alert("내용을 입력하세요.");
		return;
	}

	$.ajax({
		url: "checkList.jsp",
		type: "POST",
		data: {
			cmd: "add",
			travelNo: currentTravelNo,
			content: content
		},
		success: function(res) {
			input.value = '';
			loadChecklist();
		},
		error: function(err) { alert("저장 실패"); }
	});
}

// 체크박스 토글 (완료/미완료 저장)
function toggleCheck(checkNo, checkbox) {
	const status = checkbox.checked ? 'Y' : 'N';

	$.ajax({
		url: "checkList.jsp",
		type: "POST",
		data: {
			cmd: "toggle",
			checkNo: checkNo,
			status: status
		},
		success: function(res) {
			loadChecklist();
		}
	});
}

// 삭제
function deleteCheck(checkNo) {
	if (!confirm("삭제하시겠습니까?")) return;

	$.ajax({
		url: "checkList.jsp",
		type: "POST",
		data: {
			cmd: "delete",
			checkNo: checkNo
		},
		success: function(res) {
			loadChecklist();
		}
	});
}

// ==========================================
//  [전체 일정 보기 & 구글 맵 연동]
// ==========================================

let modalMap = null;    // 모달용 지도 객체
let modalMarkers = [];  // 마커들 저장
let modalPath = null;   // 경로 선 저장

// 모달 열기 함수
function openAllPlanModal() {
    const modal = document.getElementById('all-plan-modal');
    const content = document.getElementById('all-plan-content');
    modal.style.display = 'flex';
    content.innerHTML = ''; // 초기화

    // 1. 날짜순 정렬
    savedPlans.sort((a, b) => new Date(a.startTime) - new Date(b.startTime));

    // 2. 여행 기간 계산 (총 며칠인지)
    const d1 = new Date(travelStartDate);
    const d2 = new Date(travelEndDate);
    d1.setHours(0,0,0,0); d2.setHours(0,0,0,0);
    const diffTime = Math.abs(d2 - d1);
    const totalDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;

    let html = '';
    
    // 지도는 모달이 완전히 뜬 뒤에 그려야 깨지지 않음 (0.1초 뒤 실행)
    setTimeout(() => {
        initModalMap(); 
    }, 100);

    // 3. 타임라인 HTML 생성 반복문
    for (let i = 1; i <= totalDays; i++) {
        // 해당 일차의 일정만 필터링
        const dayPlans = savedPlans.filter(p => p.day === i);
        
        // 날짜 텍스트 (예: 2025-11-26)
        let targetDate = new Date(travelStartDate);
        targetDate.setDate(targetDate.getDate() + (i - 1));
        let dateStr = targetDate.toISOString().split('T')[0];

        // Day 헤더 추가
        html += `<div class="day-divider">Day ${i} <span style="font-size:0.7em; font-weight:normal; color:#888;">(${dateStr})</span></div>`;

        if(dayPlans.length === 0) {
            html += `<div style="text-align:center; color:#999; margin-bottom:30px;">일정이 없습니다.</div>`;
        } else {
            dayPlans.forEach(plan => {
                // 아이콘 찾기 (기존 로직 활용)
                let icon = "📍";
                const catParts = plan.category.split('__');
                const mainCat = catParts[0];
                const subType = catParts.length > 1 ? catParts[1] : null;

                if (categoryData[mainCat]) {
                    icon = categoryData[mainCat].items[0].i;
                    if (subType) {
                        const found = categoryData[mainCat].items.find(it => it.t === subType);
                        if(found) icon = found.i;
                    }
                }

                // 시간 포맷 (14:00)
                let timeStr = "";
                if(plan.startTime) {
                    const t = new Date(plan.startTime);
                    timeStr = `${t.getHours()}:${t.getMinutes() < 10 ? '0'+t.getMinutes() : t.getMinutes()}`;
                }

                // 타임라인 아이템 HTML 조립
                html += `
                <div class="timeline-item">
                    <div class="tl-time">${timeStr}</div>
                    <div class="tl-divider">
                        <div class="tl-icon-bg">${icon}</div>
                        <div class="tl-line"></div>
                    </div>
                    <div class="tl-content">
                        <div style="font-weight:bold; font-size:1.1em; color:#333;">${plan.title}</div>
                        <div style="font-size:0.9em; color:#666; margin-top:5px;">
                            ${mainCat === 'transport' ? '이동' : (plan.location || '')}
                        </div>
                        ${plan.cost > 0 ? `<div style="text-align:right; font-size:0.85em; color:#3b82f6; font-weight:bold; margin-top:5px;">${Number(plan.cost).toLocaleString()}원</div>` : ''}
                    </div>
                </div>`;
            });
        }
    }
    content.innerHTML = html;
}

// 모달 닫기
function closeAllPlanModal() {
    document.getElementById('all-plan-modal').style.display = 'none';
}

// 지도 초기화 및 핀 찍기 함수
// [수정된 버전] 지도 초기화 및 핀 찍기 함수 (순서 보장)
function initModalMap() {
    const mapDiv = document.getElementById('modal-map-area');
    if (!mapDiv) return;

    // 1. 지도 생성 (기본값: 서울)
    const defaultCenter = { lat: 37.5665, lng: 126.9780 };
    
    if (!modalMap) {
        modalMap = new google.maps.Map(mapDiv, {
            center: defaultCenter,
            zoom: 10
        });
    } else {
        google.maps.event.trigger(modalMap, 'resize');
    }

    // 2. 기존 마커/경로 삭제 (초기화)
    modalMarkers.forEach(m => m.setMap(null));
    modalMarkers = [];
    if(modalPath) modalPath.setMap(null);

    // 3. 주소 -> 좌표 변환 (Geocoding)
    const geocoder = new google.maps.Geocoder();
    const bounds = new google.maps.LatLngBounds();

    // 위치 정보가 있는 일정만 골라냄
    const locationPlans = savedPlans.filter(p => p.location && p.location.trim() !== "");

    if (locationPlans.length === 0) {
        modalMap.setCenter(defaultCenter);
        return;
    }

    // [핵심 수정] 순서를 보장하기 위해 미리 빈 배열을 만들어둡니다.
    // 응답이 늦게 와도 자기 자리에(index) 정확히 들어가게 됩니다.
    const sortedCoordinates = new Array(locationPlans.length);
    let processedCount = 0;

    locationPlans.forEach((plan, index) => {
        geocoder.geocode({ 'address': plan.location }, function(results, status) {
            if (status === 'OK') {
                const location = results[0].geometry.location;
                
                // 마커 생성 (번호 표시)
                const marker = new google.maps.Marker({
                    map: modalMap,
                    position: location,
                    label: (index + 1).toString(), // 1, 2, 3...
                    title: plan.title,
                    zIndex: 100 + index // 순서대로 위에 오게
                });

                // 마커 클릭 시 이름 표시
                const infowindow = new google.maps.InfoWindow({
                    content: `<div style="padding:5px; font-weight:bold;">${plan.title}</div>`
                });
                marker.addListener("click", () => {
                    infowindow.open(modalMap, marker);
                });

                modalMarkers.push(marker);
                
                // [핵심] 그냥 push가 아니라, '원래 순서(index)' 자리에 넣습니다.
                sortedCoordinates[index] = location;
                
                bounds.extend(location);
            } else {
                console.log('위치 찾기 실패: ' + plan.location);
            }

            // 모든 비동기 처리가 끝났는지 확인
            processedCount++;
            if (processedCount === locationPlans.length) {
                // 지도 범위 자동 조절
                if (!bounds.isEmpty()) {
                    modalMap.fitBounds(bounds);
                }
                
                // [핵심] 빈 구멍(실패한 좌표)을 제거하고 선을 그립니다.
                const finalPath = sortedCoordinates.filter(coord => coord !== undefined);

                // 경로 선 그리기
                modalPath = new google.maps.Polyline({
                    path: finalPath, // 순서대로 정렬된 좌표 배열
                    geodesic: true,
                    strokeColor: '#FF0000',
                    strokeOpacity: 0.8,
                    strokeWeight: 3,
                    icons: [{ // 화살표 추가 (방향 표시)
                        icon: { path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW },
                        offset: '100%',
                        repeat: '100px'
                    }]
                });
                modalPath.setMap(modalMap);
            }
        });
    });
}

// ▼▼▼ [3. 여기 추가하세요] 파일 맨 끝에 붙여넣기 ▼▼▼

// ==========================================
//  [메인 지도 업데이트 함수] (순서 보장 & 경로 연결)
// ==========================================
function updateMainMap() {
    const mapDiv = document.getElementById('map');
    if (!mapDiv) return;

    // 1. 날짜/시간순 정렬 (필수)
    savedPlans.sort((a, b) => new Date(a.startTime) - new Date(b.startTime));

    // 2. 지도 생성 (처음 한 번만)
    const defaultCenter = { lat: 37.5665, lng: 126.9780 };
    if (!mainMap) {
        mainMap = new google.maps.Map(mapDiv, {
            center: defaultCenter,
            zoom: 10
        });
    }

    // 3. 기존 마커/선 싹 지우기 (초기화)
    mainMarkers.forEach(m => m.setMap(null));
    mainMarkers = [];
    if (mainPath) mainPath.setMap(null);

    // 4. 위치 정보가 있는 일정만 골라내기
    const locationPlans = savedPlans.filter(p => p.location && p.location.trim() !== "");

    if (locationPlans.length === 0) {
        // 일정이 없으면 서울(기본값)로 이동
        mainMap.setCenter(defaultCenter);
        return;
    }

    // 5. 지오코딩 및 마커 찍기 (순서 보장 로직)
    const geocoder = new google.maps.Geocoder();
    const bounds = new google.maps.LatLngBounds();
    
    // [핵심] 응답 순서가 뒤죽박죽이어도 제자리를 찾아가도록 배열을 미리 만듦
    const sortedCoordinates = new Array(locationPlans.length);
    let processedCount = 0;

    locationPlans.forEach((plan, index) => {
        geocoder.geocode({ 'address': plan.location }, function(results, status) {
            if (status === 'OK') {
                const location = results[0].geometry.location;

                // 마커 생성 (라벨: 1, 2, 3...)
                const marker = new google.maps.Marker({
                    map: mainMap,
                    position: location,
                    label: {
                        text: (index + 1).toString(), // 번호 표시
                        color: "white",
                        fontWeight: "bold"
                    },
                    title: plan.title,
                    zIndex: 100 + index
                });

                // 클릭 시 정보창
                const infowindow = new google.maps.InfoWindow({
                    content: `<div style="padding:5px; font-weight:bold;">${plan.title}</div>`
                });
                marker.addListener("click", () => {
                    infowindow.open(mainMap, marker);
                });

                mainMarkers.push(marker);
                
                // [핵심] 원래 순서(index) 자리에 좌표 저장
                sortedCoordinates[index] = location;
                bounds.extend(location);
            }

            processedCount++;
            
            // 모든 처리가 끝났을 때
            if (processedCount === locationPlans.length) {
                // 지도 범위 조절
                if (!bounds.isEmpty()) {
                    mainMap.fitBounds(bounds);
                }

                // 빈 구멍(실패한 좌표) 제거 후 경로 그리기
                const finalPath = sortedCoordinates.filter(c => c !== undefined);
                
                mainPath = new google.maps.Polyline({
                    path: finalPath,
                    geodesic: true,
                    strokeColor: '#FF0000', // 빨간 선
                    strokeOpacity: 0.8,
                    strokeWeight: 4,      // 메인 지도는 조금 더 굵게
                    icons: [{
                        icon: { path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW },
                        offset: '100%',
                        repeat: '100px'
                    }]
                });
                mainPath.setMap(mainMap);
            }
        });
    });
}