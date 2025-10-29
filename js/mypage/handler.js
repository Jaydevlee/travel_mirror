// ui-handlers.js - UI 이벤트 핸들러

// 별점 관련 상수 및 함수
const STAR_COLORS = {
    gray: '#d1d5db',
    fill: '#f59e0b'
};

function paintStars($stars, $hidden, score) {
    $stars.each(function() {
        const val = Number($(this).data('val')); 
        $(this).css('color', val <= score ? STAR_COLORS.fill : STAR_COLORS.gray); 
    });
    $hidden.val(score);
}

// 전역 접근을 위해 window에 등록
window.paintStars = paintStars;

// 이벤트 핸들러 초기화
function initUIHandlers() {
    // 리뷰 작성 완료
    $(document).on('click', '.btn_submit', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const $li = $(this).closest('li');
        handleReviewSubmit($li);
    });

    // 리뷰 작성 취소
    $(document).on('click', '.btn_cancel', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const $li = $(this).closest('li');
        handleReviewCancel($li);
    });

    // 리뷰 수정
    $(document).on('click', '.btn_edit', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const $li = $(this).closest('li[data-review-id]');
        handleReviewEdit($li);
    });

    // 리뷰 수정 완료
    $(document).on('click', '.btn_update', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const $li = $(this).closest('li');
        handleReviewUpdate($li);
    });

    // 리뷰 수정 취소
    $(document).on('click', '.btn_cancel_edit', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const $li = $(this).closest('li');
        handleReviewEditCancel($li);
    });

    // 리뷰 삭제
    $(document).on('click', '.btn_delete', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const $li = $(this).closest('li[data-review-id]');
        handleReviewDelete($li);
    });

    // 기존 이미지 삭제
    $(document).on('click', '.btn_remove_img', function(e) {
        e.preventDefault();
        e.stopPropagation();
        handleExistingImageRemove($(this));
    });

    // 수정/삭제 메뉴 토글
    $(document).on('click', '.menu_btn', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const $ul = $(this).siblings('.btn_ul');
        $('.btn_ul').not($ul).removeClass('on').addClass('off');
        $ul.toggleClass('on off');
    });

    // 카드 펼치기/접기
    $(document).on('click', '.expend_btn_area', function(e) {
        e.stopPropagation();
        
        const $cardHead = $(this).closest('.card_head');
        const $cardBody = $cardHead.siblings('.card_body');
        
        $cardBody.toggleClass('on off');
        
        const $img = $(this).find('button img');
        $img.attr('src', $cardBody.hasClass('on') ? 'img/icon/up.png' : 'img/icon/down.png');
    });

    // 별점 클릭
    $(document).on('click', '.tr_starBox button[data-val]', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const $btn = $(this);
        const score = Number($btn.data('val'));
        const $form = $btn.closest('.tr_starForm');
        const $stars = $form.find('.tr_starBox button[data-val]');
        const $hidden = $form.find('.tr_ratingVal');

        paintStars($stars, $hidden, score);
        $form.closest('.content_write_area').find('textarea').removeAttr('disabled');
    });

    // 별점 폼 리셋
    $(document).on('reset', '.tr_starForm', function() {
        const $form = $(this);
        const $stars = $form.find('.tr_starBox button[data-val]');
        const $hidden = $form.find('.tr_ratingVal');
        setTimeout(() => paintStars($stars, $hidden, 0), 0);
    });

    // 파일 업로드 미리보기
    $(document).off('change.preview').on('change.preview', '.file_upload', async function() {
        const input = this;
        const $writeArea = $(input).closest('.content_write_area');
        const $starForm = $writeArea.find('.tr_starForm').first();

        // 별점과 미리보기를 같은 행에 배치
        let $row = $writeArea.find('.tr_starRow');
        if (!$row.length) {
            $row = $('<div class="tr_starRow"></div>');
            $row.insertBefore($starForm);
            $row.append($starForm);
        }

        let $preview = $row.find('.file_preview');
        if (!$preview.length) {
            $preview = $('<div class="file_preview"></div>');
            $row.prepend($preview);
        }

        const current = $preview.children().length;
        const MAX = 8;
        const remain = MAX - current;
        
        if (remain <= 0) {
            alert('최대 8개까지 첨부 가능합니다.');
            return;
        }

        const files = Array.from(input.files).slice(0, remain);
        
        for (const file of files) {
            if (!file.type || !file.type.startsWith('image/')) continue;
            
            try {
                const base64 = await fileToBase64(file);
                const $img = $(
                    `<img alt="첨부 이미지 미리보기"
                        src="${base64}"
                        style="max-width:100%; height:auto; display:block; border-radius:8px; margin-top:6px;">`
                );
                $preview.append($img);
            } catch (error) {
                console.error('이미지 변환 오류:', error);
                alert('이미지 처리 중 오류가 발생했습니다.');
            }
        }
        input.value = '';
    });

    // 리뷰 클릭 시 지도 이동
    $(document).on('click', '.review_list li[data-review-id]', function(e) {
        e.preventDefault();
        e.stopPropagation();

        const reviewId = $(this).data('review-id');
        const review = ReviewStorage.getById(reviewId);
        
        if (review) {
            moveToReviewLocation(review);
        }
    });

    // 문서 클릭 시 메뉴 닫기
    $(document).on('click', function(e) {
        if (!$(e.target).closest('.btn_area').length) {
            $('.btn_ul').removeClass('on').addClass('off');
        }
    });

    // // 1026 별점 필터 동작 추가 //

    // 장소(같은 주소)그룹 별 별점 필터
    $(document).on('click', '.place_group .rating_filter button', function(e) {
        e.preventDefault();
        e.stopPropagation();

        const $btn = $(this);
        const star = $btn.data('star'); 
        const $group = $btn.closest('.place_group');
        const $list    = $group.find('.group_reviews');     
        const $reviews = $list.find('> li[data-mode="view"]'); 

    // 버튼 전체, 각 별점 별로 all, 별1,2,3,4,5 
        $btn.addClass('active').siblings().removeClass('active');

        if (star === 'all') {
            $reviews.show();
        } else {
            const s = parseInt(star, 10);
            $reviews.each(function() {
            const r = parseInt($(this).data('rating'), 10);
            $(this).toggle(r === s);
            });
        }
    // 해당 별점에 리뷰가 없다면 안내 메시지 표시하기
        let $empty = $list.children('li.no_rating_msg');
            if (!$empty.length) {
            $empty = $('<li class="no_rating_msg" aria-live="polite">해당 별점 리뷰가 없습니다.</li>').hide();
            $list.append($empty);
        }
        const hasVisible = $reviews.filter(':visible').length > 0;
        $empty.toggle(!hasVisible);
        $group.show();
});
// 1028 이미지 확대 // 
// 등록된 리뷰 이미지 클릭 → 확대
    $(document).on('click', '.image_preview_area img', function(e){
    e.preventDefault(); e.stopPropagation();
    const $imgs = $(this).closest('.image_preview_area').find('img');
    openLightbox($imgs, $imgs.index(this));
    });

}
// 별점 초기화
function initStarRatings() {
    $('.tr_starForm').each(function() {
        const $form = $(this);
        const $stars = $form.find('.tr_starBox button[data-val]');
        const $hidden = $form.find('.tr_ratingVal');
        paintStars($stars, $hidden, 0);
    });
}
$(document).on('click', '.file_label, .file_upload', function(e) {
        e.stopPropagation();
    });

//1028 이미지 확대 //
// lb = lightbox == enlarge image

function ensureLightboxDOM(){
  let $lb = $('#lightbox');
  if ($lb.length) return $lb;
  $lb = $(`
    <div id="lightbox" class="lightbox off" aria-hidden="true">
      <div class="lightbox_inner" role="dialog" aria-label="이미지 확대 보기">
        <button type="button" class="lightbox_close" aria-label="닫기">×</button>
        <img class="lightbox_img" alt="확대 이미지">
        <button type="button" class="lightbox_prev" aria-label="이전">‹</button>
        <button type="button" class="lightbox_next" aria-label="다음">›</button>
      </div>
    </div>
  `);
  $('body').append($lb);

  // 닫기(배경/버튼/ESC)
  $lb.on('click', function(e){
    if (e.target === this) closeLightbox();
  });
  $lb.find('.lightbox_close').on('click', closeLightbox);
  $(document).on('keydown.lightbox', function(e){
    if ($('#lightbox').hasClass('on') && e.key === 'Escape') closeLightbox();
    if ($('#lightbox').hasClass('on') && (e.key === 'ArrowLeft' || e.key === 'ArrowRight')) {
      e.preventDefault();
      if (e.key === 'ArrowLeft') navLightbox(-1);
      if (e.key === 'ArrowRight') navLightbox(1);
    }
  });

  // 이전/다음
  $lb.find('.lightbox_prev').on('click', ()=> navLightbox(-1));
  $lb.find('.lightbox_next').on('click', ()=> navLightbox(1));

  return $lb;
}

function openLightbox($imgs, idx){
  const $lb = ensureLightboxDOM();
  $lb.data({ list: $imgs, idx: idx });
  updateLightboxView();
  $lb.removeClass('off').addClass('on').attr('aria-hidden','false');
}

function closeLightbox(){
  const $lb = $('#lightbox');
  $lb.removeClass('on').addClass('off').attr('aria-hidden','true');
}

function navLightbox(step){
  const $lb = $('#lightbox');
  const $imgs = $lb.data('list'); let idx = $lb.data('idx') || 0;
  idx = Math.min(Math.max(idx + step, 0), $imgs.length - 1);
  $lb.data('idx', idx);
  updateLightboxView();
}

function updateLightboxView(){
  const $lb   = $('#lightbox');
  const $imgs = $lb.data('list') || $();
  const idx   = $lb.data('idx') || 0;
  const src   = $imgs.eq(idx).attr('src');
  $lb.find('.lightbox_img').attr('src', src);
  $lb.find('.lightbox_prev').toggle(idx > 0);
  $lb.find('.lightbox_next').toggle(idx < $imgs.length - 1);
}
    //1028 이미지 확대 //