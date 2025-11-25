/**
 * * [목차]
 * 1. 전역 변수 및 초기 데이터 설정
 * 2. 페이지 초기화 (DOMContentLoaded)
 * 3. Day 탭 및 리스트 관리
 * 4. 일정 추가/수정/삭제 (모달 및 AJAX)
 * 5. 메인 지도 관리 (Google Maps API)
 * 6. 가계부 (Budget) 기능
 * 7. 체크리스트 (Checklist) 기능
 * 8. 전체 일정 보기 (모달 & 스크롤 맵)
 * 9. 여행 기본 정보 수정
 */





// 1. 전역 변수 및 초기 데이터 설정
let dayCount = 0;
let travelStartDate = null;
let travelEndDate = null;

let currentTravelNo = (typeof window.serverTravelNo !== 'undefined') ? window.serverTravelNo : null;
let savedPlans = (typeof window.serverPlanList !== 'undefined') ? window.serverPlanList : [];

// 지도 관련 전역 변수
let mainMap = null;
let mainMarkers = [];
let mainPath = null;
let isHotelVisible = true; // 숙소 표시 여부
let mapInfoWindow = null;  // 지도 클릭 시 뜨는 정보창

// 모달 지도 관련 전역 변수
let modalMap = null;
let modalMarkers = [];
let modalPath = null;
let currentModalDay = 1;

// 카테고리 데이터 (아이콘, 라벨 등 정의)
const categoryData = {
    'transport': {
        title: '교통', 
        items: [{ t: '항공권', i: '✈️' }, { t: '기차', i: '🚄' }, { t: '지하철', i: '🚇' }, { t: '버스', i: '🚌' }, { t: '택시', i: '🚕' }, { t: '자동차', i: '🚗' }, { t: '배편', i: '🚢' }, { t: '기타', i: '🔖' }], 
        labels: { t: '출발', e: '도착', l: '출발지/터미널' }
    },
    'accommodation': {
        title: '숙소', 
        items: [{ t: '호텔', i: '🏨' }, { t: '에어비앤비', i: '🏠' }, { t: '게스트하우스', i: '🛏️' }, { t: '기타', i: '🔖' }], 
        labels: { t: '체크인', e: '체크아웃', l: '주소' }
    },
    'dining': {
        title: '식사', 
        items: [{ t: '식당', i: '🍽️' }, { t: '카페', i: '☕' }, { t: '술집', i: '🍺' }, { t: '기타', i: '🔖' }], 
        labels: { t: '방문시간', e: '종료시간', l: '위치' }
    },
    'activity': {
        title: '관광', 
        items: [{ t: '관광지', i: '📍' }, { t: '액티비티', i: '🎡' }, { t: '쇼핑', i: '🛍️' }, { t: '기타', i: '🔖' }], 
        labels: { t: '시작', e: '종료', l: '위치' }
    },
    'etc': { 
        title: '기타', 
        items: [{ t: '기타', i: '📝' }], 
        labels: { t: '시작', e: '종료', l: '장소' } 
    }
};


// 2. 페이지 초기화 (DOMContentLoaded)
document.addEventListener("DOMContentLoaded", function() {
    // 달력 라이브러리 한글 설정
    if (typeof flatpickr !== 'undefined') flatpickr.localize(flatpickr.l10ns.ko);

    if (window.serverStartDate && window.serverEndDate) {
        travelStartDate = new Date(window.serverStartDate);
        travelEndDate = new Date(window.serverEndDate);
        travelEndDate.setHours(23, 59, 59);

        initDayButtons(); // Day 버튼 생성 및 초기화
    }

    loadSavedPlans();   // 저장된 일정 화면에 뿌리기
    calculateBudget();  // 가계부 초기 계산
});


// 3. Day 탭 및 리스트 관리
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
        // 사이드바 버튼 생성
        const btn = document.createElement('button');
        btn.className = 'plan-btn';
        btn.innerText = 'Day ' + i;
        btn.id = 'btn-day-' + i;
        btn.onclick = function() { switchDay(i); };
        dayContainer.appendChild(btn);

        // 메인 컨텐츠 영역 생성 (처음엔 숨김)
        const contentDiv = document.createElement('div');
        contentDiv.className = 'day-content';
        contentDiv.id = 'content-day-' + i;
        contentDiv.style.display = 'none';

        // 해당 날짜 계산 및 날짜 문자열 생성
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

    // 마지막으로 작업했던 Day 기억해서 열기
    const lastDay = sessionStorage.getItem('savedDay');
    if (lastDay && parseInt(lastDay) <= days) {
        switchDay(parseInt(lastDay)); 
        sessionStorage.removeItem('savedDay'); 
    } else {
        if (days > 0) switchDay(1);
    }
}

// 탭 전환 (Day 1 <-> Day 2)
function switchDay(day) {
    // 모든 컨텐츠 숨기고 버튼 비활성화
    document.querySelectorAll('.day-content').forEach(div => div.style.display = 'none');
    document.querySelectorAll('.plan-btn').forEach(btn => {
        btn.style.backgroundColor = '#f9f9f9';
        btn.style.fontWeight = 'normal';
    });

    // 선택된 것만 보이기
    document.getElementById('content-day-' + day).style.display = 'block';
    const activeBtn = document.getElementById('btn-day-' + day);
    if(activeBtn) {
        activeBtn.style.backgroundColor = '#e0e0e0';
        activeBtn.style.fontWeight = 'bold';
    }

    // 지도 업데이트 (약간의 딜레이)
    setTimeout(() => {
        updateMainMap(day);
    }, 100);
}

// 저장된 일정 화면에 렌더링
function loadSavedPlans() {
    if (!savedPlans || savedPlans.length === 0) return;
    savedPlans.sort((a, b) => new Date(a.startTime) - new Date(b.startTime));

    savedPlans.forEach(plan => {
        const startDay = plan.day;
        let duration = 1;
        
        // 기간(Duration) 및 연박 계산
        if (plan.endTime && plan.startTime) {
            const start = new Date(plan.startTime);
            const end = new Date(plan.endTime);
            const diffTime = end.setHours(0, 0, 0, 0) - start.setHours(0, 0, 0, 0);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            
            if (diffDays > 0) duration = diffDays + 1;
            
            if (plan.category.includes('accommodation')) {
                duration = diffDays + 1; 
            }
            if (duration < 1) duration = 1;
        }

        // 기간만큼 반복해서 일정 바(Bar) 생성
        for (let i = 0; i < duration; i++) {
            const currentDay = startDay + i;
            const container = document.getElementById("plan-list-" + currentDay);

            if (container) {
                let timeHtml = "";
                let displayTitle = plan.title;
                let styleClass = "";
                let actionBtns = "";
                let icon = "📍"; 

                // 아이콘 설정
                const catParts = plan.category.split('__');
                const mainCategory = catParts[0];
                const subType = catParts.length > 1 ? catParts[1] : null;

                if (categoryData[mainCategory]) {
                    icon = categoryData[mainCategory].items[0].i;
                    if (subType) {
                        const foundItem = categoryData[mainCategory].items.find(item => item.t === subType);
                        if (foundItem) icon = foundItem.i;
                    } else {
                        const items = categoryData[mainCategory].items;
                        for (let k = 0; k < items.length; k++) {
                            if (plan.title.includes(items[k].t)) {
                                icon = items[k].i;
                                break;
                            }
                        }
                    }
                }

                // 날짜별 표시 방식 결정 (첫날 vs 연박 vs 체크아웃)
                if (i === 0) {
                    // 첫째 날
                    timeHtml = formatSmartTime(plan.startTime, plan.endTime, plan.category);
                    const dataJson = JSON.stringify(plan).replace(/"/g, '&quot;');
                    
                    actionBtns = `
                        <button onclick="openEditModal(this)" data-info="${dataJson}" style="margin-left:10px; border:none; background:none; cursor:pointer; font-size:1.2em;">✏️</button>
                        <button onclick="deletePlan(${plan.planNo})" style="border:none; background:none; cursor:pointer; font-size:1.2em; opacity:0.5;">🗑️</button>
                    `;
                } 
                else if (i === duration - 1 && plan.category.includes('accommodation')) {
                    // 마지막 날 (체크아웃)
                    timeHtml = `<span style="color:#e74c3c; font-weight:bold; font-size:0.8em;">(Day ${i + 1})</span>`;
                    displayTitle = plan.title + " <span style='font-size:0.9em; color:#e74c3c; font-weight:bold;'> (체크아웃)</span>";
                    styleClass = "background:#fff5f5; border:1px solid #ffcccc;"; 
                } 
                else {
                    // 중간 날짜 (연박)
                    timeHtml = `<span style="color:#888; font-size:0.8em;">(Day ${i + 1})</span>`;
                    styleClass = "opacity: 0.7;";
                    displayTitle += " <span style='font-size:0.8em; color:#888;'>(연박)</span>";
                }

                // HTML 생성 및 추가
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
    });
}

// 4. 일정 추가/수정/삭제 (모달 및 AJAX)
// 카테고리 선택 모달 열기
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

// 일정 수정 모달 열기
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

// 입력 폼 생성 및 표시
function showInputForm(titlePrefix, day, category, icon, labels, existingData = null, selectedType = "") {
    const modalList = document.getElementById('modal-list');

    // 기존 데이터 바인딩
    const titleVal = existingData ? existingData.title : "";
    const locVal = existingData ? (existingData.location || '') : '';
    const costVal = existingData ? existingData.cost : '';
    const bookingVal = existingData ? (existingData.bookingNo || '') : '';
    const planNoVal = existingData ? existingData.planNo : '';
    const memoVal = existingData ? (existingData.memo || '') : '';

    // 현재 선택된 타입 설정
    let currentType = selectedType || titlePrefix;
    if (existingData && existingData.category) {
        const parts = existingData.category.split('__');
        if (parts.length > 1) currentType = parts[1];
    }

    // 날짜 시간 초기값 설정
    let dateStr = getDateByDay(day);
    let startVal = dateStr + " 10:00";
    let endVal = dateStr + " 12:00";

    if (existingData) {
        if (existingData.startTime) startVal = formatForInput(existingData.startTime);
        if (existingData.endTime) endVal = formatForInput(existingData.endTime);
    }

    // 카테고리 드롭다운 옵션 생성
    let optionsHtml = "";
    Object.keys(categoryData).forEach(key => {
        const group = categoryData[key];
        optionsHtml += `<optgroup label="${group.title}">`;
        group.items.forEach(item => {
            const isSelected = (item.t === currentType) ? "selected" : "";
            optionsHtml += `<option value="${key}__${item.t}" ${isSelected}>${item.i} ${item.t}</option>`;
        });
        optionsHtml += `</optgroup>`;
    });

    // HTML 삽입
    modalList.innerHTML = `
        <div style="padding:10px;">
            <input type="hidden" id="input-plan-no" value="${planNoVal}">
            
            <div style="margin-bottom:15px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">카테고리 (유형)</label>
                <select id="input-category-full" style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px; font-size:1em;">
                    ${optionsHtml}
                </select>
            </div>

            <div style="margin-bottom:10px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">일정 제목</label>
                <input type="text" id="input-title" value="${titleVal}" placeholder="일정 제목 입력" style="width:100%; padding:8px;">
            </div>
            
            <div style="margin-bottom:10px;">
                <label style="display:block; font-size:0.9em; margin-bottom:5px;">예약번호 (선택)</label>
                <input type="text" id="input-booking-no" value="${bookingVal}" style="width:100%; padding:8px;" placeholder="예: XYZ-12345">
            </div>
            
            <div style="display:flex; gap:10px; margin-bottom:10px;">
                <div style="flex:1;">
                    <label style="display:block; font-size:0.9em; margin-bottom:5px;">시작 시간</label>
                    <input type="text" id="input-start-time" class="time-picker" value="${startVal}" style="width:100%; padding:8px;">
                </div>
                <div style="flex:1;">
                    <label style="display:block; font-size:0.9em; margin-bottom:5px;">종료 시간</label>
                    <input type="text" id="input-end-time" class="time-picker" value="${endVal}" style="width:100%; padding:8px;">
                </div>
            </div>
            
            <div style="margin-bottom:10px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">위치 (장소)</label>
                <input type="text" id="input-location" value="${locVal}" placeholder="장소 검색 또는 주소" style="width:100%; padding:8px;">
            </div>
            
            <div style="margin-bottom:15px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">비용 (원)</label>
                <input type="number" id="input-cost" value="${costVal}" placeholder="0" style="width:100%; padding:8px;">
            </div>
            
            <div style="margin-bottom:15px;">
                <label style="display:block; font-weight:bold; margin-bottom:5px;">메모</label>
                <textarea id="input-memo" placeholder="메모" style="width:100%; height:60px; padding:8px; resize:none; border:1px solid #ddd;">${memoVal}</textarea>
            </div>
            
            <button onclick="saveToDB(${day})" style="width:100%; padding:10px; background:#333; color:white; border:none; cursor:pointer; font-weight:bold; border-radius:4px;">
                ${existingData ? '수정 완료' : '저장하기'}
            </button>
        </div>
    `;

    // 달력(Flatpickr) 설정
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

// DB 저장 (AJAX 호출)
function saveToDB(day) {
    const planNo = document.getElementById('input-plan-no').value;
    const title = document.getElementById('input-title').value;
    const bookingNo = document.getElementById('input-booking-no').value || '';
    const start = document.getElementById('input-start-time').value;
    const end = document.getElementById('input-end-time').value;
    const loc = document.getElementById('input-location').value;
    const cost = document.getElementById('input-cost').value || 0;
    
    // 드롭다운 선택값 가져오기
    const fullCategory = document.getElementById('input-category-full').value;

    if (!title) { alert("제목을 입력해주세요"); return; }

    // 날짜 자동 보정 (시작 날짜가 바뀌었을 때 Day 번호 재계산)
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
                sessionStorage.setItem('savedDay', day);
                location.reload();
            } else {
                alert("처리 실패: " + res);
            }
        },
        error: function(err) { console.error(err); alert("통신 오류"); }
    });
}

// 일정 삭제
function deletePlan(planNo) {
    if (!confirm("삭제하시겠습니까?")) return;
    $.ajax({
        url: "deletePlan.jsp",
        type: "POST",
        data: { planNo: planNo },
        success: function(res) { location.reload(); }
    });
}

// 날짜 계산 유틸리티
function getDateByDay(day) {
    let d = new Date(travelStartDate);
    d.setDate(d.getDate() + (day - 1));
    return d.toISOString().split('T')[0];
}

// 시간 포맷 유틸리티 (YYYY-MM-DD HH:MM)
function formatForInput(tsStr) {
    if (!tsStr) return "";
    return tsStr.substring(0, 16);
}

// 시간 표시 포맷 (UI용)
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

            if (category.includes('accommodation')) {
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

// 5. 메인 지도 관리 (Google Maps API)
// 메인 지도 업데이트 (숙소 필터링 + 검색창 연결 포함)
function updateMainMap(targetDay) {
    const mapDiv = document.getElementById('map');
    if (!mapDiv) return;

    // 날짜/시간순 정렬
    savedPlans.sort((a, b) => new Date(a.startTime) - new Date(b.startTime));

    // 해당 날짜(targetDay)의 일정 필터링 (연박 숙소 포함)
    let displayPlans = savedPlans;
    if (targetDay) {
        displayPlans = savedPlans.filter(p => {
            if (p.day == targetDay) return true;
            // 연박 숙소 로직 (체크아웃 날 포함)
            if (p.category.includes('accommodation') && p.day < targetDay) {
                 if (!p.endTime) return false;
                 const start = new Date(p.startTime);
                 const end = new Date(p.endTime);
                 start.setHours(0,0,0,0); end.setHours(0,0,0,0);
                 const stayNights = Math.round((end - start) / (1000 * 60 * 60 * 24));
                 return targetDay <= (p.day + stayNights);
            }
            return false;
        });
    }

    // 지도 생성 (처음 한 번만)
    const defaultCenter = { lat: 37.5665, lng: 126.9780 };
    if (!mainMap) {
        mainMap = new google.maps.Map(mapDiv, {
            center: defaultCenter,
            zoom: 10,
            clickableIcons: true,
            disableDefaultUI: false,
            mapTypeControl: false
        });

        setupMapClickListener(mainMap); // 지도 클릭 이벤트 연결

        // 검색창과 숙소 필터 버튼을 지도 좌측 상단에 고정
        const controls = document.getElementById('map-controls');
        if(controls) {
            controls.style.display = 'flex'; 
            mainMap.controls[google.maps.ControlPosition.TOP_LEFT].push(controls);
            initSearchBox(mainMap); // 검색창 기능 활성화
        }
    }

    // 기존 마커/선 초기화
    mainMarkers.forEach(m => m.setMap(null));
    mainMarkers = [];
    if (mainPath) mainPath.setMap(null);

    // 숙소 표시 체크박스 확인
    if (!isHotelVisible) {
        displayPlans = displayPlans.filter(p => !p.category.includes('accommodation'));
    }

    // 위치 정보가 있는 일정만 골라내기
    const locationPlans = displayPlans.filter(p => p.location && p.location.trim() !== "");

    if (locationPlans.length === 0) return;

    // 지오코딩 및 마커 찍기
    const geocoder = new google.maps.Geocoder();
    const bounds = new google.maps.LatLngBounds();
    const sortedCoordinates = new Array(locationPlans.length);
    let processedCount = 0;

    locationPlans.forEach((plan, index) => {
        geocoder.geocode({ 'address': plan.location }, function(results, status) {
            if (status === 'OK') {
                const location = results[0].geometry.location;

                const marker = new google.maps.Marker({
                    map: mainMap,
                    position: location,
                    label: { text: (index + 1).toString(), color: "white", fontWeight: "bold" },
                    title: plan.title,
                    zIndex: 100 + index
                });

                const infowindow = new google.maps.InfoWindow({
                    content: `<div style="padding:5px; font-weight:bold;">${plan.title}</div>`
                });
                marker.addListener("click", () => {
                    infowindow.open(mainMap, marker);
                });

                mainMarkers.push(marker);
                sortedCoordinates[index] = location;
                bounds.extend(location);
            }

            processedCount++;
            if (processedCount === locationPlans.length) {
                if (!bounds.isEmpty()) {
                    mainMap.fitBounds(bounds);
                }
                // 경로 그리기
                const finalPath = sortedCoordinates.filter(c => c !== undefined);
                mainPath = new google.maps.Polyline({
                    path: finalPath,
                    geodesic: true,
                    strokeColor: '#FF0000',
                    strokeOpacity: 0.8,
                    strokeWeight: 4,
                    icons: [{ icon: { path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW }, offset: '100%', repeat: '100px' }]
                });
                mainPath.setMap(mainMap);
            }
        });
    });
}

// 지도 클릭 시 '일정 추가' 팝업 띄우기
function setupMapClickListener(map) {
    mapInfoWindow = new google.maps.InfoWindow();
    map.addListener("click", function(e) {
        if (e.placeId) {
            e.stop(); 
            const service = new google.maps.places.PlacesService(map);
            service.getDetails({ placeId: e.placeId }, function(place, status) {
                if (status === google.maps.places.PlacesServiceStatus.OK) {
                    showCustomInfoWindow(place, e.latLng, map);
                }
            });
        }
    });
}

function showCustomInfoWindow(place, latLng, map) {
    const name = place.name;
    const address = place.formatted_address || "";
    const safeName = name.replace(/'/g, "\\'"); 
    const safeAddress = address.replace(/'/g, "\\'");

    const contentString = `
        <div style="padding:10px; min-width:200px;">
            <h3 style="margin:0 0 5px 0; font-size:16px;">${name}</h3>
            <p style="margin:0 0 10px 0; font-size:13px; color:#555;">${address}</p>
            <div style="text-align:right;">
                <button onclick="addPlanFromMap('${safeName}', '${safeAddress}')" 
                    style="background:#4285F4; color:white; border:none; padding:8px 15px; border-radius:4px; cursor:pointer; font-weight:bold;">
                    + 일정에 추가
                </button>
            </div>
            <div style="margin-top:5px; font-size:12px;">
                <a href="${place.url}" target="_blank" style="color:#4285F4; text-decoration:none;">구글 지도에서 보기</a>
            </div>
        </div>
    `;

    mapInfoWindow.setContent(contentString);
    mapInfoWindow.setPosition(latLng);
    mapInfoWindow.open(map);
}

function addPlanFromMap(placeName, placeAddress) {
    let activeDay = 1;
    const activeContent = document.querySelector('.day-content[style*="block"]');
    if (activeContent) {
        const parts = activeContent.id.split('-'); 
        activeDay = parseInt(parts[parts.length - 1]);
    }

    const category = 'activity'; 
    const labels = categoryData[category].labels;
    const icon = '📍';

    if(mapInfoWindow) mapInfoWindow.close();

    document.getElementById('modal-title').innerText = `일정 추가 (Day ${activeDay}) - 지도 선택`;
    document.getElementById('modal-overlay').style.display = 'flex';
    
    showInputForm(placeName, activeDay, category, icon, labels, null, '관광지');
    
    setTimeout(() => {
        document.getElementById('input-title').value = placeName;
        document.getElementById('input-location').value = placeAddress;
    }, 100);
}

// 검색창 기능 (Autocomplete)
function initSearchBox(map) {
    const input = document.getElementById("pac-input");
    if(!input) return;
    
    const autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.bindTo("bounds", map);

    autocomplete.addListener("place_changed", () => {
        const place = autocomplete.getPlace();
        if (!place.geometry || !place.geometry.location) {
            alert("장소를 찾을 수 없습니다.");
            return;
        }
        if (place.geometry.viewport) {
            map.fitBounds(place.geometry.viewport);
        } else {
            map.setCenter(place.geometry.location);
            map.setZoom(15);
        }
        showCustomInfoWindow(place, place.geometry.location, map);
    });
}

// 숙소 표시 토글
function toggleAccommodation() {
    const checkbox = document.getElementById('show-hotel-check');
    isHotelVisible = checkbox.checked; 
    
    const activeContent = document.querySelector('.day-content[style*="block"]');
    if (activeContent) {
        const parts = activeContent.id.split('-');
        const currentDay = parseInt(parts[parts.length - 1]);
        updateMainMap(currentDay);
    }
}

// 6. 가계부 (Budget) 기능
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

            let catKey = p.category.split('__')[0]; 
            let catName = categoryData[catKey] ? categoryData[catKey].title : "기타";

            if (!categorySum[catName]) categorySum[catName] = 0;
            categorySum[catName] += cost;
        }
    });

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

    const display = document.getElementById('total-budget-display');
    if (display) display.innerText = Number(total).toLocaleString() + "원";
}

// 7. 체크리스트 (Checklist) 기능
function openChecklistModal() {
    document.getElementById('checklist-modal').style.display = 'flex';
    loadChecklist(); 
}

function closeChecklistModal() {
    document.getElementById('checklist-modal').style.display = 'none';
}

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
        error: function(err) { console.error("체크리스트 로드 실패:", err); }
    });
}

function addCheckItem() {
    const input = document.getElementById('new-check-item');
    const content = input.value.trim();

    if (!content) { alert("내용을 입력하세요."); return; }

    $.ajax({
        url: "checkList.jsp",
        type: "POST",
        data: { cmd: "add", travelNo: currentTravelNo, content: content },
        success: function(res) { input.value = ''; loadChecklist(); },
        error: function(err) { alert("저장 실패"); }
    });
}

function toggleCheck(checkNo, checkbox) {
    const status = checkbox.checked ? 'Y' : 'N';
    $.ajax({
        url: "checkList.jsp",
        type: "POST",
        data: { cmd: "toggle", checkNo: checkNo, status: status },
        success: function(res) { loadChecklist(); }
    });
}

function deleteCheck(checkNo) {
    if (!confirm("삭제하시겠습니까?")) return;
    $.ajax({
        url: "checkList.jsp",
        type: "POST",
        data: { cmd: "delete", checkNo: checkNo },
        success: function(res) { loadChecklist(); }
    });
}

//  8. 전체 일정 보기 (모달 & 스크롤 맵)

function openAllPlanModal() {
    const modal = document.getElementById('all-plan-modal');
    const content = document.getElementById('all-plan-content');
    modal.style.display = 'flex';
    content.innerHTML = '';

    savedPlans.sort((a, b) => new Date(a.startTime) - new Date(b.startTime));

    const d1 = new Date(travelStartDate);
    const d2 = new Date(travelEndDate);
    d1.setHours(0,0,0,0); d2.setHours(0,0,0,0);
    const diffTime = Math.abs(d2 - d1);
    const totalDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;

    let html = '';
    
    for (let i = 1; i <= totalDays; i++) {
        const dayPlans = savedPlans.filter(p => p.day === i);
        let targetDate = new Date(travelStartDate);
        targetDate.setDate(targetDate.getDate() + (i - 1));
        let dateStr = targetDate.toISOString().split('T')[0];

        // 스크롤 감지 구역
        html += `<div class="modal-day-section" id="modal-day-section-${i}" data-day="${i}" style="margin-bottom: 40px; min-height: 100px;">`;
        html += `<div class="day-divider" style="position: sticky; top: 0; background: #fff; z-index: 10; padding: 15px 0; border-bottom: 2px solid #333; font-weight: bold;">Day ${i} <span style="font-size:0.8em; font-weight:normal; color:#888;">(${dateStr})</span></div>`;

        if(dayPlans.length === 0) {
            html += `<div style="text-align:center; color:#999; margin: 30px 0;">일정이 없습니다.</div>`;
        } else {
            html += `<div style="padding-top: 10px;">`;
            dayPlans.forEach(plan => {
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
                
                let timeStr = "";
                if(plan.startTime) {
                    const t = new Date(plan.startTime);
                    timeStr = `${t.getHours()}:${t.getMinutes() < 10 ? '0'+t.getMinutes() : t.getMinutes()}`;
                }

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
            html += `</div>`;
        }
        html += `</div>`;
    }
    content.innerHTML = html;

    setTimeout(() => {
        updateModalMap(1);
        setupModalScrollObserver();
    }, 300);
}

function closeAllPlanModal() {
    document.getElementById('all-plan-modal').style.display = 'none';
}

// 인쇄
function printAllPlan() {
    window.print();
}

function setupModalScrollObserver() {
    const container = document.getElementById('all-plan-content');
    const sections = document.querySelectorAll('.modal-day-section');

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const day = parseInt(entry.target.getAttribute('data-day'));
                if (currentModalDay !== day) {
                    currentModalDay = day;
                    updateModalMap(day);
                }
            }
        });
    }, {
        root: container,
        threshold: 0.1,
        rootMargin: "-40% 0px -40% 0px"
    });

    sections.forEach(section => {
        observer.observe(section);
    });
}

function updateModalMap(targetDay) {
    const mapDiv = document.getElementById('modal-map-area');
    if (!mapDiv) return;

    const defaultCenter = { lat: 37.5665, lng: 126.9780 };
    
    if (!modalMap) {
        modalMap = new google.maps.Map(mapDiv, { center: defaultCenter, zoom: 10 });
    }

    if (modalMarkers) modalMarkers.forEach(m => m.setMap(null));
    modalMarkers = [];
    if (modalPath) { modalPath.setMap(null); modalPath = null; }

    const dayPlans = savedPlans.filter(p => {
        if (p.day == targetDay) return true;
        if (p.category.includes('accommodation') && p.day < targetDay) {
             if (!p.endTime) return false;
             const start = new Date(p.startTime);
             const end = new Date(p.endTime);
             start.setHours(0,0,0,0); end.setHours(0,0,0,0);
             const stayNights = Math.round((end - start) / (1000 * 60 * 60 * 24));
             return targetDay <= (p.day + stayNights);
        }
        return false;
    });

    const locationPlans = dayPlans.filter(p => p.location && p.location.trim() !== "");
    if (locationPlans.length === 0) return;

    const geocoder = new google.maps.Geocoder();
    const bounds = new google.maps.LatLngBounds();
    const sortedCoordinates = new Array(locationPlans.length);
    let processedCount = 0;

    locationPlans.forEach((plan, index) => {
        geocoder.geocode({ 'address': plan.location }, function(results, status) {
            if (status === 'OK') {
                const location = results[0].geometry.location;
                const marker = new google.maps.Marker({
                    map: modalMap,
                    position: location,
                    label: (index + 1).toString(),
                    title: plan.title,
                    zIndex: 100 + index
                });
                modalMarkers.push(marker);
                sortedCoordinates[index] = location;
                bounds.extend(location);
            }
            
            processedCount++;
            if (processedCount === locationPlans.length) {
                if (!bounds.isEmpty()) {
                    modalMap.fitBounds(bounds);
                    if (locationPlans.length === 1) modalMap.setZoom(15);
                }
                
                const finalPath = sortedCoordinates.filter(c => c !== undefined);
                modalPath = new google.maps.Polyline({
                    path: finalPath,
                    geodesic: true,
                    strokeColor: '#FF0000',
                    strokeOpacity: 0.8,
                    strokeWeight: 3,
                    icons: [{ icon: { path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW }, offset: '100%', repeat: '100px' }]
                });
                modalPath.setMap(modalMap);
            }
        });
    });
}

// 9. 여행 기본 정보 수정
function openTravelEditModal() {
    document.getElementById('edit-travel-title').value = window.serverTitle || "";
    document.getElementById('edit-start-date').value = window.serverStartDate || "";
    document.getElementById('edit-end-date').value = window.serverEndDate || "";
    
    const mateSelect = document.getElementById('edit-travel-mate');
    const currentMate = window.serverMate || "나홀로";
    for(let i=0; i<mateSelect.options.length; i++) {
        if(currentMate.includes(mateSelect.options[i].value)) {
            mateSelect.selectedIndex = i;
            break;
        }
    }
    document.getElementById('travel-edit-modal').style.display = 'flex';
}

function closeTravelEditModal() {
    document.getElementById('travel-edit-modal').style.display = 'none';
}

function submitTravelEdit() {
    const newTitle = document.getElementById('edit-travel-title').value;
    const newStart = document.getElementById('edit-start-date').value;
    const newEnd = document.getElementById('edit-end-date').value;
    const newMate = document.getElementById('edit-travel-mate').value;

    if(!newTitle || !newStart || !newEnd) { alert("모든 정보를 입력해주세요."); return; }
    if(newStart > newEnd) { alert("종료일은 시작일보다 빠를 수 없습니다."); return; }

    $.ajax({
        url: "updateTravelInfo.jsp",
        type: "POST",
        data: {
            travelNo: currentTravelNo,
            title: newTitle,
            startDate: newStart,
            endDate: newEnd,
            companion: newMate
        },
        success: function(res) {
            if(res.trim().includes("success")) {
                alert("여행 정보가 수정되었습니다.");
                location.reload();
            } else {
                alert("수정 실패: " + res);
            }
        },
        error: function(err) { console.error(err); alert("통신 오류가 발생했습니다."); }
    });
}