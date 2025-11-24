-- 체크리스트 테이블 생성
CREATE TABLE travel_checklist (
    check_no    NUMBER          PRIMARY KEY,    -- 고유 번호
    travel_no   NUMBER          NOT NULL,       -- 어느 여행의 체크리스트인지 (FK)
    content     VARCHAR2(300)   NOT NULL,       -- 준비물 내용
    is_checked  CHAR(1)         DEFAULT 'N',    -- 체크 여부 ('Y' 또는 'N')
    created_at  DATE            DEFAULT SYSDATE -- 생성일
);

-- 번호 자동 생성을 위한 시퀀스 생성
CREATE SEQUENCE seq_checklist_no
START WITH 1
INCREMENT BY 1
NOCACHE;

-- 커밋 (저장)
COMMIT;