-- 위시리스트 테이블 (가보고 싶은 곳)
CREATE TABLE TRAVEL_WISHLIST (
    WISH_NO     NUMBER          PRIMARY KEY,
    TR_MEM_ID   VARCHAR2(20)    NOT NULL, -- 누가 (회원 FK)
    REVIEW_NO   NUMBER          NOT NULL, -- 무엇을 (리뷰 FK)
    REG_DATE    DATE            DEFAULT SYSDATE, -- 언제 (트렌드 분석용)
    
    -- 한 사람이 같은 글을 중복 저장 못하게 막음
    CONSTRAINT UQ_WISHLIST UNIQUE (TR_MEM_ID, REVIEW_NO),
    -- 리뷰가 삭제되면 위시리스트에서도 자동 삭제
    CONSTRAINT FK_WISH_REVIEW FOREIGN KEY (REVIEW_NO) REFERENCES TRAVEL_REVIEW(REVIEW_NO) ON DELETE CASCADE
);

-- 시퀀스
CREATE SEQUENCE SEQ_WISH_NO NOCACHE NOCYCLE;

-- 저장
COMMIT;