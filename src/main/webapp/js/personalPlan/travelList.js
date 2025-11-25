//모달(Modal) 제어

// 여행 생성 모달 열기
function openInitModal() {
    document.getElementById('init-modal-overlay').style.display = 'flex';
}

// 여행 생성 모달 닫기
function closeInitModal() {
    document.getElementById('init-modal-overlay').style.display = 'none';
}

// 모달 배경 클릭 시 닫기 이벤트 연결
document.addEventListener('DOMContentLoaded', function() {
    const modalOverlay = document.getElementById('init-modal-overlay');
    if (modalOverlay) {
        modalOverlay.addEventListener('click', function(e) {
            if (e.target === this) closeInitModal();
        });
    }
});

// Select2 (국가 검색) 라이브러리 설정

// Select2 결과 포맷팅 (국기 아이콘 표시)
function formatCountry(state) {
    if (!state.id) { return state.text; }

    var textOnly = state.text;
    if (state.text.includes(' ')) {
        textOnly = state.text.substring(state.text.indexOf(' ') + 1);
    }

    // flag-icons 라이브러리 클래스 적용
    var $state = $(
        '<span><span class="fi fi-' + state.id.toLowerCase() + '"></span> ' + textOnly + '</span>'
    );
    return $state;
};

// Select2 초기화
$(document).ready(function() {
    $('#select-country').select2({
        data: countryList, // countryData.js 데이터 사용
        placeholder: "여행할 국가를 검색하세요(다중 선택 가능)",
        allowClear: true,
        width: '100%',
        dropdownParent: $('#init-modal-overlay'),
        templateResult: formatCountry,
        templateSelection: formatCountry
    });
});

// Flatpickr (달력) 라이브러리 설정

document.addEventListener('DOMContentLoaded', function() {
    // 종료일 설정
    const endPicker = flatpickr("input[name='endDate']", {
        locale: "ko",
        dateFormat: "Y-m-d"
    });

    // 시작일 설정 (선택 시 종료일 최소 날짜 자동 변경)
    flatpickr("input[name='startDate']", {
        locale: "ko",
        dateFormat: "Y-m-d",
        onChange: function(selectedDates, dateStr, instance) {
            if (selectedDates.length > 0) {
                endPicker.set('minDate', dateStr);
                // 달력을 내가 선택한 시작일 근처로 점프
                endPicker.jumpToDate(selectedDates[0]);
            }
        }
    });
});

// 여행 삭제 (AJAX)

function deleteTravel(event, travelNo) {
    event.stopPropagation(); // 카드 클릭 이벤트 버블링 방지

    if (!confirm("정말 이 여행 계획을 삭제하시겠습니까?\n(복구할 수 없습니다)")) return;

    $.ajax({
        url: 'deleteTravel.jsp',
        type: 'POST',
        data: { travelNo: travelNo },
        success: function(res) {
            if (res.trim() === 'success') {
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

// 카드 리스트 UI 초기화 (국기 아이콘 매칭)

$(document).ready(function() {
    $('.plan-card').each(function() {
        var dbCountryName = $(this).data('country');
        var $iconContainer = $(this).find('.flag-icon');

        // 기본값 설정 (못 찾으면 비행기)
        $iconContainer.text('✈️');

        if (dbCountryName && typeof countryList !== 'undefined') {
            // DB에 저장된 국가 이름과 countryList의 이름 매칭 시도
            var found = countryList.find(function(item) {
                if (item.id === dbCountryName) {
                    return true;
                }

                var itemTextOnly = item.text;
                if (item.text.includes(' ')) {
                    itemTextOnly = item.text.split(' ')[1];
                }
                return item.text.includes(dbCountryName) || dbCountryName.includes(itemTextOnly);
            });

            // 매칭되면 국기 아이콘으로 교체
            if (found && found.id) {
                var cssClass = 'fi fi-' + found.id.toLowerCase();
                $iconContainer.html('<span class="' + cssClass + '" style="font-size: 1.5em;"></span>');
            }
        }
    });
});