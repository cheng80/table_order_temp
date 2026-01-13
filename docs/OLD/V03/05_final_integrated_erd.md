# [설계] 최종 통합 ERD (v4.0)

> - **문서 파일명:** 05_final_integrated_erd.md. 
> - **작성 일자:** 2026.01.12. 
> - **버전:** v4.0 (Full Integration: 07번 문서 명세 100% 반영). 
> - **문서 설명:** 카레 전문점 시나리오 및 매장 통합 관리 시스템의 물리적 ERD 시각화.  

---

## 1. ERD 시각화 (Mermaid Diagram)

```mermaid
---
config:
  layout: elk
---
erDiagram
    %% 1. 계정 및 매장
    MEMBERS ||--o{ STORES : "소유"
    STORES ||--o{ DAILY_WEATHER : "날씨 수집"
    STORES ||--o{ STORE_TABLES : "보유"
    STORES ||--o{ WAITING_LISTS : "대기 관리"

    %% 2. 상품 및 옵션 매핑
    STORES ||--o{ MENU_CATEGORIES : "정의"
    MENU_CATEGORIES ||--o{ MENUS : "분류"
    STORES ||--o{ OPTION_GROUPS : "정의"
    OPTION_GROUPS ||--o{ OPTIONS : "포함"
    MENUS ||--o{ MENU_OPTION_MAPPINGS : "옵션 연결"
    OPTION_GROUPS ||--o{ MENU_OPTION_MAPPINGS : "매핑"

    %% 3. 거래 (주문 및 결제)
    STORE_TABLES ||--o{ STORE_ORDERS : "주문 발생"
    DAILY_WEATHER ||--o{ STORE_ORDERS : "날씨 스냅샷"
    STORE_ORDERS ||--|| PAYMENTS : "결제 처리"
    STORE_ORDERS ||--o{ ORDER_DETAILS : "상세 포함"
    ORDER_DETAILS ||--o{ ORDER_DETAIL_OPTIONS : "옵션 상세"
    MENUS ||--o{ ORDER_DETAILS : "참조"
    OPTIONS ||--o{ ORDER_DETAIL_OPTIONS : "참조"

    %% 4. 서비스 및 예약
    STORES ||--o{ STAFF_CALL_ITEMS : "프리셋"
    STORES ||--o{ RESERVATIONS : "관리"
    STORE_TABLES ||--o{ STAFF_CALL_LOGS : "호출 발생"
    STAFF_CALL_ITEMS ||--o{ STAFF_CALL_LOGS : "유형"
    STORE_TABLES ||--o{ RESERVATIONS : "테이블 배정"

    MEMBERS {
        BigInt member_id PK
        Varchar login_id
        Varchar password
        Varchar access_token
    }

    STORES {
        BigInt store_id PK
        Varchar name
        Int avg_eating_time
        Boolean is_open
    }

    DAILY_WEATHER {
        BigInt weather_id PK
        Varchar weather_condition_id
        Varchar icon_code
        Date target_date
    }

    STORE_TABLES {
        BigInt store_table_id PK
        Int table_number
        Varchar auth_code
        Varchar status
    }

    WAITING_LISTS {
        BigInt waiting_id PK
        Int waiting_number
        Varchar customer_name
        Varchar status
    }

    MENUS {
        BigInt menu_id PK
        Int price
        Int cost
        Boolean is_soldout
    }

    OPTION_GROUPS {
        BigInt option_group_id PK
        Varchar name
        Boolean is_exclusive
    }

    OPTIONS {
        BigInt option_id PK
        Int extra_price
        Int cost
    }

    STORE_ORDERS {
        BigInt store_order_id PK
        Varchar store_order_uuid
        BigInt weather_id FK
        Int total_price
    }

    PAYMENTS {
        BigInt payment_id PK
        Varchar payment_key
        Varchar method
        Varchar status
    }

    ORDER_DETAILS {
        BigInt order_detail_id PK
        Int price_snapshot
        Int cost_snapshot
        Varchar cook_status
    }

    RESERVATIONS {
        BigInt reservation_id PK
        Varchar customer_name
        Date reserve_date
        Time reserve_time
        Varchar status
    }

```

---

## 2. 핵심 관계 설계 요약

### 2.1 거래 기록 보존 (Snapshot)
- `ORDER_DETAILS` 및 `ORDER_DETAIL_OPTIONS`: 메뉴의 가격이나 원가가 나중에 수정되더라도 과거 매출/이익 통계가 변하지 않도록 `price_snapshot`과 `cost_snapshot`을 저장합니다.

### 2.2 실무형 통계 연결 (Weather Link)
- `DAILY_WEATHER`와 `STORE_ORDERS`: 모든 주문은 발생 시점의 일일 날씨 ID를 FK로 가집니다. 이를 통해 "비 오는 날 가장 많이 팔린 카레" 등의 통계 분석이 데이터베이스 수준에서 즉시 가능합니다.

### 2.3 옵션 유연성 (Associative Mapping)
- `MENU_OPTION_MAPPINGS`: 메뉴와 옵션 그룹을 다대다(N:M)로 연결하여, '맵기 단계' 옵션 그룹을 여러 종류의 카레 메뉴에 재사용할 수 있도록 설계했습니다.

### 2.4 매장 통합 운영 (Waiting & Call)
- `WAITING_LISTS` (대기)와 `STAFF_CALL_LOGS` (호출): 테이블오더 시스템에 통합되어 점주 앱 하나로 매장의 모든 유입과 서비스를 관리할 수 있는 기반을 제공합니다.

---
