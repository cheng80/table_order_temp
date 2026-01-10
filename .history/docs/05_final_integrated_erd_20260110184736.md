# [설계] 최종 통합 ERD (v3.1)

> - **문서 파일명:** 05_final_integrated_erd.md
> - **작성 일자:** 2026.01.10
> - **버전:** v3.1 (Final)
> - **문서 설명:** 시스템의 물리적 데이터베이스 구조 시각화 (Mermaid ERD) 및 테이블 상세 정의

---

## 1. ERD 시각화 (Mermaid Diagram)

전체 테이블의 관계와 핵심 키(PK, FK) 구조입니다.

```mermaid
---
config:
  layout: elk
---
erDiagram
    %% ---------------------------------------------------------
    %% 1. 핵심 도메인 (계정 및 매장)
    %% ---------------------------------------------------------
    USERS {
        BigInt user_id PK "Auto Increment"
        Varchar login_id UK "로그인 ID (이메일)"
        Varchar password "BCrypt 암호화"
        Varchar access_token "UUID v4 (자동로그인)"
        Timestamp last_login_at
        Timestamp created_at
    }

    STORES {
        BigInt store_id PK
        BigInt user_id FK
        Varchar name "매장명"
        Boolean is_open "영업중 여부"
        Int total_table_count
        Timestamp created_at
    }

    TABLES {
        BigInt table_id PK
        BigInt store_id FK
        Int table_number "테이블 번호"
        Varchar auth_code "기기 인증 PIN"
        Timestamp created_at
    }

    USERS ||--o{ STORES : "소유"
    STORES ||--o{ TABLES : "포함"

    %% ---------------------------------------------------------
    %% 2. 상품 도메인 (메뉴 및 옵션)
    %% ---------------------------------------------------------
    MENU_CATEGORIES {
        BigInt menu_category_id PK
        BigInt store_id FK
        Varchar name "카테고리명"
        Int sort_order
    }

    MENUS {
        BigInt menu_id PK
        BigInt menu_category_id FK
        Varchar name "메뉴명"
        Int price
        Varchar image_url
        Boolean is_soldout
        Boolean is_hidden
    }

    OPTION_GROUPS {
        BigInt option_group_id PK
        BigInt store_id FK
        Varchar name "옵션 그룹명"
        Boolean is_exclusive "True:라디오 / False:체크박스"
        Int min_select
        Int max_select
    }

    OPTIONS {
        BigInt option_id PK
        BigInt option_group_id FK
        Varchar name "옵션명"
        Int extra_price "추가금"
    }

    MENU_OPTION_MAPPINGS {
        BigInt mapping_id PK
        BigInt menu_id FK
        BigInt option_group_id FK
    }

    STORES ||--o{ MENU_CATEGORIES : "정의"
    MENU_CATEGORIES ||--o{ MENUS : "분류"
    STORES ||--o{ OPTION_GROUPS : "정의"
    OPTION_GROUPS ||--o{ OPTIONS : "포함"
    MENUS ||--o{ MENU_OPTION_MAPPINGS : "보유"
    OPTION_GROUPS ||--o{ MENU_OPTION_MAPPINGS : "적용됨"

    %% ---------------------------------------------------------
    %% 3. 거래 도메인 (주문 및 결제)
    %% ---------------------------------------------------------
    ORDERS {
        BigInt order_id PK
        Varchar order_uuid UK "Toss 주문번호"
        BigInt store_id FK
        BigInt table_id FK
        Int total_price
        Timestamp created_at
    }

    PAYMENTS {
        BigInt payment_id PK
        BigInt order_id FK
        Varchar payment_key "Toss Payment Key"
        Varchar toss_order_id "Toss 주문번호"
        Varchar method "카드/간편결제"
        Int total_amount
        Varchar status "DONE/CANCELED"
        Timestamp approved_at
    }

    ORDER_DETAILS {
        BigInt order_detail_id PK
        BigInt order_id FK
        BigInt menu_id FK
        Int quantity
        Int price_snapshot "시점 가격"
        Varchar cook_status "대기/조리/완료"
    }

    ORDER_DETAIL_OPTIONS {
        BigInt order_detail_option_id PK
        BigInt order_detail_id FK
        BigInt option_id FK
        Int price_snapshot "시점 추가금"
    }

    TABLES ||--o{ ORDERS : "주문함"
    STORES ||--o{ ORDERS : "접수함"
    ORDERS ||--|| PAYMENTS : "결제됨"
    ORDERS ||--o{ ORDER_DETAILS : "구성됨"
    ORDER_DETAILS ||--o{ ORDER_DETAIL_OPTIONS : "포함"
    MENUS ||--o{ ORDER_DETAILS : "참조"
    OPTIONS ||--o{ ORDER_DETAIL_OPTIONS : "참조"

    %% ---------------------------------------------------------
    %% 4. 지원 도메인 (직원 호출)
    %% ---------------------------------------------------------
    STAFF_CALL_ITEMS {
        BigInt staff_call_item_id PK
        BigInt store_id FK
        Varchar name "호출 항목명"
        Varchar icon_code
    }

    STAFF_CALLS {
        BigInt staff_call_id PK
        BigInt table_id FK
        BigInt staff_call_item_id FK
        Boolean is_completed
        Timestamp created_at
    }

    STORES ||--o{ STAFF_CALL_ITEMS : "정의"
    STAFF_CALL_ITEMS ||--o{ STAFF_CALLS : "유형"
    TABLES ||--o{ STAFF_CALLS : "요청함"