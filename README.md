# TRAVEL
> 여행 계획 관리 애플리케이션

## 프로젝트 개요 (Project Overview)
Travel은 여행 계획 관리 애플리케이션으로 사용자의 여행 계획을 보다 편리하게 관리할 수 있는 시스템입니다. 

## 주요 기능 (Key Feature)
- **여행 계획 관리**: 여행 계획을 생성하여 관리할 수 있습니다.

## 기술 스택 (Tech Stack)
- **Backend**: Java 25, JSP
- **FrontEnd**: JavaScript(ES6), CSS3
- **DataBase**: Oracle 21c
- **형상 관리**: Git

## ERD
```mermaid
  erDiagram
    travel_member ||--o{ travel_info : "creates"
    travel_member {
        NUMBER tr_mem_no PK "회원번호"
        VARCHAR2 tr_mem_id "아이디"
        VARCHAR2 tr_mem_password "비밀번호"
        VARCHAR2 tr_mem_name "이름"
        VARCHAR2 tr_mem_email "이메일"
        VARCHAR2 tr_mem_phone "전화번호"
        VARCHAR2 tr_mem_pic "프로필 사진"
    }

    travel_info ||--o{ travel_checklist : "has"
    travel_info ||--o{ travel_plan : "contains"
    travel_info ||--o{ TRAVEL_REVIEW : "reviewed"
    travel_info {
        NUMBER TRAVEL_NO PK "여행번호"
        VARCHAR2 TITLE "여행 제목"
        VARCHAR2 COUNTRY "여행 국가"
        DATE START_DATE "시작일"
        DATE END_DATE "종료일"
        VARCHAR2 COMPANION "동행자"
        NUMBER TOTAL_BUDGET "총 예산"
        DATE CREATED_AT "생성일"
        NUMBER tr_mem_no FK "회원번호"
    }

    travel_checklist {
        NUMBER CHECK_NO PK "체크리스트 번호"
        VARCHAR2 CONTENT "내용"
        CHAR IS_CHECKED "체크여부(Y/N)"
        DATE CREATED_AT "생성일"
        NUMBER TRAVEL_NO FK "여행번호"
    }

    travel_plan ||--o{ TRAVEL_REVIEW : "referenced in"
    travel_plan {
        NUMBER PLAN_NO PK "일정 번호"
        NUMBER DAY_NO "일차(Day N)"
        VARCHAR2 TITLE "일정 제목"
        VARCHAR2 DESCRIPTION "설명"
        DATE START_TIME "시작 시간"
        DATE END_TIME "종료 시간"
        VARCHAR2 LOCATION "장소"
        NUMBER COST "비용"
        NUMBER TRAVEL_NO FK "여행번호"
    }

    TRAVEL_REVIEW ||--o{ TRAVEL_MEDIA : "has media"
    TRAVEL_REVIEW {
        NUMBER REVIEW_NO PK "리뷰 번호"
        VARCHAR2 DESTINATION "목적지/장소명"
        CLOB CONTENT "리뷰 내용"
        NUMBER RATING "평점"
        DATE REG_DATE "등록일"
        NUMBER TRAVEL_NO FK "여행번호"
        NUMBER PLAN_NO FK "일정 번호"
    }

    TRAVEL_MEDIA {
        NUMBER MEDIA_NO PK "미디어 번호"
        VARCHAR2 ORIGINAL_NAME "원본 파일명"
        VARCHAR2 SAVE_NAME "저장 파일명"
        VARCHAR2 FILE_TYPE "파일 타입"
        NUMBER REVIEW_NO FK "리뷰 번호"
    }
```
