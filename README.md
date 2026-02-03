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

## Data Flow
```mermaid
flowchart TD
    %% 스타일 정의
    classDef entity fill:#f9f,stroke:#333,stroke-width:2px,color:black;
    classDef process fill:#e1f5fe,stroke:#0277bd,stroke-width:2px,color:black,rx:10,ry:10;
    classDef store fill:#fff9c4,stroke:#fbc02d,stroke-width:2px,shape:cylinder,color:black;

    %% 외부 엔티티 (사용자)
    User[사용자 User]:::entity
    Admin[관리자 Admin]:::entity

    %% 프로세스 (주요 로직)
    subgraph "회원 서비스 (Member Service)"
        P1(회원가입/정보수정):::process
        P2(로그인 인증):::process
    end

    subgraph "여행 계획 서비스 (Planning Service)"
        P3(여행 일정 생성/수정):::process
        P4(체크리스트 관리):::process
        P5(나만의 일정 조회):::process
    end

    subgraph "리뷰 서비스 (Review Service)"
        P6(리뷰 작성/수정):::process
        P7(리뷰 조회/검색):::process
        P8(위시리스트 관리):::process
    end

    %% 데이터 저장소 (DB)
    D1[(Travel_Member)]:::store
    D2[(Travel_Info)]:::store
    D3[(Travel_Checklist)]:::store
    D4[(Travel_Review)]:::store
    D5[(Travel_Wishlist)]:::store

    %% 데이터 흐름 (화살표)
    %% 회원 관리
    User -- ID/PW/정보 --> P1
    P1 -- 회원정보 저장 --> D1
    User -- ID/PW --> P2
    D1 -- 회원정보 확인 --> P2
    P2 -- 세션(Session) 생성 --> User

    %% 여행 계획
    User -- 여행국가/날짜/예산 --> P3
    P3 -- 여행정보 저장 --> D2
    User -- 준비물 체크 --> P4
    P4 -- 체크 상태 업데이트 --> D3
    D2 -- 여행정보 로드 --> P5
    P5 -- 일정 데이터 --> User

    %% 리뷰 관리
    User -- 사진/내용/평점 --> P6
    P6 -- 리뷰 데이터 저장 --> D4
    User -- 검색 키워드 --> P7
    D4 -- 리뷰 리스트 --> P7
    P7 -- 리뷰 상세 정보 --> User
    User -- 찜하기 클릭 --> P8
    P8 -- 위시리스트 추가/삭제 --> D5

    %% 관리자 기능
    Admin -- 회원/게시글 관리 --> P1 & P6
    P1 -- 회원 삭제 --> D1
    P6 -- 부적절 리뷰 삭제 --> D4
```
