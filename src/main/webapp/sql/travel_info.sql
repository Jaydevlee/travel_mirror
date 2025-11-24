-- 시퀀스 삭제 (순번 초기화)
DROP SEQUENCE SEQ_TRAVEL_INFO_NO;
DROP SEQUENCE SEQ_PLAN_NO;

-- 테이블 삭제 (제약조건이 걸려있어도 강제 삭제)
DROP TABLE TRAVEL_PLAN CASCADE CONSTRAINTS;
DROP TABLE TRAVEL_INFO CASCADE CONSTRAINTS;
COMMIT;

-- 1. 여행 정보(메타데이터) 테이블
CREATE TABLE TRAVEL_INFO (
    -- 여행 고유 번호
    TRAVEL_NO       NUMBER PRIMARY KEY,       
    
    -- 여행 제목
    TITLE           VARCHAR2(200) NOT NULL,   
    
    -- 여행 국가 (유연하게 입력 가능하도록 문자열 유지)
    COUNTRY         VARCHAR2(100) NOT NULL,  
    
    -- [수정] 시작일 (DATE 타입 사용 권장)
    -- 입력시: TO_DATE('2025-11-21', 'YYYY-MM-DD') 등으로 입력
    START_DATE      DATE,             
    
    -- [수정] 종료일
    END_DATE        DATE,             
    
    -- 동행자 정보
    COMPANION       VARCHAR2(200),             
    
    -- 총 예산 (데이터 분석용)
    TOTAL_BUDGET    NUMBER DEFAULT 0,         
    
    -- 생성일
    CREATED_AT      DATE DEFAULT SYSDATE      
);
