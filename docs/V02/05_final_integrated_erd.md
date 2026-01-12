# [설계] 최종 통합 ERD (v3.8)

> - **문서 파일명:** 05_final_integrated_erd.md
> - **작성 일자:** 2026.01.10
> - **버전:** v3.8 (Final + Audit)
> - **문서 설명:** 시스템의 물리적 데이터베이스 구조 시각화 (Mermaid ERD) 및 스키마 구조 정의.
> - **주요 변경:**
>   1. **Naming:** `MEMBERS`, `STORE_TABLES`, `STORE_ORDERS` 적용 (예약어 회피).
>   2. **Audit:** 모든 테이블 `created_at` 컬럼 적용 시각화.
>   3. **New Domain:** `RESERVATIONS` (예약) 추가.

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
    MEMBERS {
        BigInt member_id PK "Auto Increment"
        Varchar login_id UK "로그인 ID"
        Varchar password "BCrypt"
        Varchar access_token "UUID v4"
        Timestamp last_login_at
        Timestamp created_at
    }

    STORES {
        BigInt store_id PK
        BigInt member_id FK
        Varchar name "매장명"
        Boolean is_open
        Int total_table_count
        Timestamp created_at
    }

    STORE_TABLES {
        BigInt store_table_id PK
        BigInt store_id FK
        Int table_number
        Varchar auth_code "PIN"
        Varchar status "운영/예약/미사용"
        Int capacity "수용인원"
        Timestamp created_at
    }

    MEMBERS ||--o{ STORES : "소유"
    STORES ||--o{ STORE_TABLES : "보유"

    %% ---------------------------------------------------------
    %% 2. 상품 도메인 (메뉴 및 옵션)
    %% ---------------------------------------------------------
    MENU_CATEGORIES {
        BigInt menu_category_id PK
        BigInt store_id FK
        Varchar name
        Int sort_order
        Timestamp created_at
    }

    MENUS {
        BigInt menu_id PK
        BigInt menu_category_id FK
        Varchar name
        Int price
        Varchar image_url
        Boolean is_soldout
        Boolean is_hidden
        Timestamp created_at
    }

    OPTION_GROUPS {
        BigInt option_group_id PK
        BigInt store_id FK
        Varchar name
        Boolean is_exclusive
        Int min_select
        Int max_select
        Timestamp created_at
    }

    OPTIONS {
        BigInt option_id PK
        BigInt option_group_id FK
        Varchar name
        Int extra_price
        Timestamp created_at
    }

    MENU_OPTION_MAPPINGS {
        BigInt mapping_id PK
        BigInt menu_id FK
        BigInt option_group_id FK
        Timestamp created_at
    }

    STORES ||--o{ MENU_CATEGORIES : "정의"
    MENU_CATEGORIES ||--o{ MENUS : "분류"
    STORES ||--o{ OPTION_GROUPS : "정의"
    OPTION_GROUPS ||--o{ OPTIONS : "포함"
    MENUS ||--o{ MENU_OPTION_MAPPINGS : "구성"
    OPTION_GROUPS ||--o{ MENU_OPTION_MAPPINGS : "적용"

    %% ---------------------------------------------------------
    %% 3. 거래 도메인 (주문 및 결제)
    %% ---------------------------------------------------------
    STORE_ORDERS {
        BigInt store_order_id PK
        Varchar store_order_uuid UK "Toss 연동용"
        BigInt store_id FK
        BigInt store_table_id FK
        Int total_price
        Timestamp created_at
    }

    PAYMENTS {
        BigInt payment_id PK
        BigInt store_order_id FK
        Varchar payment_key "Toss Key"
        Varchar method
        Int total_amount
        Varchar status "DONE/CANCELED"
        Timestamp approved_at
        Timestamp created_at
    }

    ORDER_DETAILS {
        BigInt order_detail_id PK
        BigInt store_order_id FK
        BigInt menu_id FK
        Int quantity
        Int price_snapshot
        Varchar cook_status
        Timestamp created_at
    }

    ORDER_DETAIL_OPTIONS {
        BigInt order_detail_option_id PK
        BigInt order_detail_id FK
        BigInt option_id FK
        Int price_snapshot
        Timestamp created_at
    }

    STORE_TABLES ||--o{ STORE_ORDERS : "주문함"
    STORES ||--o{ STORE_ORDERS : "접수함"
    STORE_ORDERS ||--|| PAYMENTS : "결제됨"
    STORE_ORDERS ||--o{ ORDER_DETAILS : "포함"
    ORDER_DETAILS ||--o{ ORDER_DETAIL_OPTIONS : "선택함"
    MENUS ||--o{ ORDER_DETAILS : "참조"
    OPTIONS ||--o{ ORDER_DETAIL_OPTIONS : "참조"

    %% ---------------------------------------------------------
    %% 4. 지원 및 예약 도메인
    %% ---------------------------------------------------------
    STAFF_CALL_ITEMS {
        BigInt staff_call_item_id PK
        BigInt store_id FK
        Varchar name
        Timestamp created_at
    }

    STAFF_CALL_LOGS {
        BigInt staff_call_id PK
        BigInt store_table_id FK
        BigInt staff_call_item_id FK
        Boolean is_completed
        Timestamp created_at
    }

    RESERVATIONS {
        BigInt reservation_id PK
        BigInt store_id FK
        BigInt store_table_id FK
        Varchar customer_name
        Varchar customer_phone
        Int guest_count
        Date reserve_date
        Time reserve_time
        Varchar status
        Timestamp created_at
    }

    STORES ||--o{ STAFF_CALL_ITEMS : "설정"
    STAFF_CALL_ITEMS ||--o{ STAFF_CALL_LOGS : "유형"
    STORE_TABLES ||--o{ STAFF_CALL_LOGS : "호출함"
    
    STORE_TABLES ||--o{ RESERVATIONS : "예약됨"