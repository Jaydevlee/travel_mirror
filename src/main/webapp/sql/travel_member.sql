--회원 테이블 생성
CREATE TABLE tr_member(
    --회원번호 시퀀스로 회원가입시 자동 생성
    tr_mem_no NUMBER PRIMARY KEY,
    tr_mem_id VARCHAR2(20), 
    tr_mem_password VARCHAR2(20),
    tr_mem_name VARCHAR2(20),
    tr_mem_email VARCHAR2(20),
    tr_mem_phone VARCHAR2(30) NOT NULL,
    tr_mem_level NUMBER,
    --프로필 사진(myInfoPage에서 확인 가능)
    tr_mem_pic  VARCHAR2(50)
);

-- 회원번호 생성
CREATE SEQUENCE tr_member_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE;

-- 회원번호 삭제
DROP SEQUENCE TR_MEMBER_SEQ;