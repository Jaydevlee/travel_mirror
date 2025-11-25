-- 2. 여행 세부 일정 테이블
CREATE TABLE TRAVEL_PLAN (
    -- 일정 고유 번호
    PLAN_NO         NUMBER PRIMARY KEY,       
    
    -- 여행 정보 연결 (FK)
    TRAVEL_NO       NUMBER NOT NULL,
    
    -- Day 번호 (1일차, 2일차...)
    DAY_NO          NUMBER NOT NULL,         
    
    -- 카테고리 (transport, accommodation, dining, attraction 등)
    -- 이 값을 기준으로 화면에서 아이콘을 다르게 보여주면 됨 (ICON 컬럼 불필요)
    CATEGORY        VARCHAR2(50),             
    
    -- 일정 제목
    TITLE           VARCHAR2(200) NOT NULL,   
    
    -- 예약번호 (선택사항이므로 NULL 허용)
    BOOKING_NO      VARCHAR2(100),            
    
    -- [수정] 시작 시간 (DATE 타입 하나에 날짜+시간 다 들어감)
    -- 정렬 및 시간 계산을 위해 필수
    START_TIME      DATE,             
    
    -- [수정] 종료 시간
    END_TIME        DATE,             
    
    -- 장소/주소 (구글 맵 연동용 텍스트)    
    LOCATION        VARCHAR2(200),            
    
    -- 비용 (가계부 통계용)   
    COST            NUMBER DEFAULT 0,         
    
    -- [삭제] ICON : CATEGORY로 대체하여 로직 처리 추천
    -- [삭제] REG_DATE : 불필요하여 삭제
    
    -- 외래키 설정
    CONSTRAINT FK_TRAVEL_PLAN_INFO FOREIGN KEY (TRAVEL_NO) 
    REFERENCES TRAVEL_INFO(TRAVEL_NO) ON DELETE CASCADE
);

-- 시퀀스 생성
CREATE SEQUENCE SEQ_TRAVEL_INFO_NO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PLAN_NO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 확인
SELECT * FROM TRAVEL_INFO;
SELECT * FROM TRAVEL_PLAN;

-- 변경사항 반영
COMMIT;

INSERT INTO TRAVEL_INFO 
(TRAVEL_NO, TITLE, COUNTRY, START_DATE, END_DATE, COMPANION, TR_MEM_ID)
VALUES 
(SEQ_TRAVEL_INFO_NO.NEXTVAL, '나의 첫 유럽 여행', '프랑스, 스위스', TO_DATE('2025-12-01','YYYY-MM-DD'), TO_DATE('2025-12-10','YYYY-MM-DD'), '혼자', '가입한 아이디');

COMMIT;
