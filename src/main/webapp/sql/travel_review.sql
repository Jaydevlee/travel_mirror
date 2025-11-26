-- 여행 후기 테이블 (TRAVEL_REVIEW)
CREATE TABLE TRAVEL_REVIEW (
    REVIEW_NO   NUMBER          PRIMARY KEY, -- 후기 고유 번호 (PK)
    PLAN_NO     NUMBER          NOT NULL,    -- 어떤 세부 일정에 대한 후기인지 (FK: TRAVEL_PLAN)
    TRAVEL_NO   NUMBER          NOT NULL,    -- 어떤 여행 전체에 속하는지 (FK: TRAVEL_INFO)
    TR_MEM_ID   VARCHAR2(20)    NOT NULL,    -- 작성자 아이디 (TR_MEMBER 테이블의 ID)
    DESTINATION VARCHAR2(100),               -- 여행지 구분 (예: 오사카, 스위스) - 게시판 필터링용
    CONTENT     CLOB,                        -- 후기 내용 (긴 글)
    RATING      NUMBER(1)       DEFAULT 5,   -- 별점 (1~5)
    REG_DATE    DATE            DEFAULT SYSDATE, -- 작성일
    
    -- 외래키 설정 (부모 데이터 삭제 시 후기도 자동 삭제)
    CONSTRAINT FK_REVIEW_PLAN FOREIGN KEY (PLAN_NO) REFERENCES TRAVEL_PLAN(PLAN_NO) ON DELETE CASCADE,
    CONSTRAINT FK_REVIEW_TRAVEL FOREIGN KEY (TRAVEL_NO) REFERENCES TRAVEL_INFO(TRAVEL_NO) ON DELETE CASCADE
);

-- 후기 번호 시퀀스
CREATE SEQUENCE SEQ_REVIEW_NO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;