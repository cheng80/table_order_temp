# [설계] 테이블오더 시스템 데이터베이스 명세서 (v2.6)

> **문서 번호:** 05_database_design_spec.md
> **변경 사항:** PK-FK 컬럼명 일치화 (Natural Join Friendly)
> **네이밍 규칙:**
> * **PK:** `테이블명(단수)_id` (예: `users` 테이블 -> `user_id`)
> * **FK:** 참조하는 테이블의 PK 컬럼명과 **100% 동일하게** 설정
> * **생성일시:** `created_at` (공통)

---

## 1. 계정 및 매장 (Core Domain)

### 1.1 USERS
> **Type: [Entity]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **user_id** | BigInt | PK, AI | **사용자 고유 ID** |
| login_id | Varchar | UK, Not Null | 로그인 아이디 |
| password | Varchar | Not Null | 비밀번호 |
| business_number | Varchar | - | 사업자 번호 |
| owner_name | Varchar | - | 점주 성명 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 1.2 STORES
> **Type: [Entity]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **store_id** | BigInt | PK, AI | **매장 고유 ID** |
| user_id | BigInt | FK (USERS) | 소유 점주 ID (**PK와 동일**) |
| name | Varchar | Not Null | 매장명 |
| is_open | Boolean | Default False | 영업 상태 |
| total_table_count | Int | Default 0 | 총 좌석 수 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 1.3 TABLES
> **Type: [Entity]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **table_id** | BigInt | PK, AI | **테이블 고유 ID** |
| store_id | BigInt | FK (STORES) | 소속 매장 ID (**PK와 동일**) |
| table_number | Int | Not Null | 테이블 번호 |
| auth_code | Varchar | Not Null | 인증 PIN/QR |
| created_at | Timestamp | Not Null | 생성 일시 |

---

## 2. 메뉴 및 옵션 (Product Domain)

### 2.1 MENU_CATEGORIES
> **Type: [Category/Lookup]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **menu_category_id** | BigInt | PK, AI | **카테고리 ID** |
| store_id | BigInt | FK (STORES) | 소속 매장 ID |
| name | Varchar | Not Null | 카테고리명 |
| sort_order | Int | Default 0 | 정렬 순서 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 2.2 MENUS
> **Type: [Entity]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **menu_id** | BigInt | PK, AI | **메뉴 ID** |
| menu_category_id | BigInt | FK (CATEGORIES) | 소속 카테고리 ID (**PK와 동일**) |
| name | Varchar | Not Null | 메뉴명 |
| price | Int | Not Null | 가격 |
| description | Text | - | 설명 |
| image_url | Varchar | - | 이미지 |
| is_soldout | Boolean | Default False | 품절 여부 |
| is_hidden | Boolean | Default False | 숨김 여부 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 2.3 OPTION_GROUPS
> **Type: [Category/Lookup]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **option_group_id** | BigInt | PK, AI | **옵션 그룹 ID** |
| store_id | BigInt | FK (STORES) | 소속 매장 ID |
| name | Varchar | Not Null | 그룹명 (맵기 등) |
| is_exclusive | Boolean | Not Null | 라디오/체크 구분 |
| min_select | Int | Default 0 | 최소 선택 |
| max_select | Int | Default 1 | 최대 선택 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 2.4 OPTIONS
> **Type: [Entity]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **option_id** | BigInt | PK, AI | **옵션 상세 ID** |
| option_group_id | BigInt | FK (GROUPS) | 소속 그룹 ID (**PK와 동일**) |
| name | Varchar | Not Null | 옵션명 |
| extra_price | Int | Default 0 | 추가 가격 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 2.5 MENU_OPTION_MAPPINGS
> **Type: [Relationship]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **mapping_id** | BigInt | PK, AI | **매핑 고유 ID** |
| menu_id | BigInt | FK (MENUS) | 메뉴 ID |
| option_group_id | BigInt | FK (GROUPS) | 옵션 그룹 ID |
| created_at | Timestamp | Not Null | 연결 일시 |

---

## 3. 주문 및 트랜잭션 (Transaction Domain)

### 3.1 ORDERS
> **Type: [Entity (Transaction)]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **order_id** | BigInt | PK, AI | **주문 고유 ID** |
| store_id | BigInt | FK (STORES) | 매장 ID |
| table_id | BigInt | FK (TABLES) | 테이블 ID |
| payment_type | Varchar | ENUM | CARD/CASH |
| payment_status | Varchar | ENUM | PENDING/PAID |
| total_price | Int | Not Null | 총 금액 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 3.2 ORDER_DETAILS
> **Type: [Entity (Detail)]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **order_detail_id** | BigInt | PK, AI | **주문 상세 ID** |
| order_id | BigInt | FK (ORDERS) | 소속 주문 ID |
| menu_id | BigInt | FK (MENUS) | 메뉴 ID |
| quantity | Int | Not Null | 수량 |
| price_snapshot | Int | Not Null | 시점 가격 |
| cook_status | Varchar | ENUM | PENDING/DONE |
| created_at | Timestamp | Not Null | 생성 일시 |

### 3.3 ORDER_DETAIL_OPTIONS
> **Type: [Entity (Detail)]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **order_detail_option_id** | BigInt | PK, AI | **주문 옵션 상세 ID** |
| order_detail_id | BigInt | FK (DETAILS) | 주문 상세 ID |
| option_id | BigInt | FK (OPTIONS) | 옵션 ID |
| price_snapshot | Int | Not Null | 시점 가격 |
| created_at | Timestamp | Not Null | 생성 일시 |

---

## 4. 직원 호출 (Support Domain)

### 4.1 STAFF_CALL_ITEMS
> **Type: [Category/Lookup]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **staff_call_item_id** | BigInt | PK, AI | **호출 항목 ID** |
| store_id | BigInt | FK (STORES) | 매장 ID |
| name | Varchar | Not Null | 항목명 |
| icon_code | Varchar | - | 아이콘 코드 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 4.2 STAFF_CALLS
> **Type: [Entity (Transaction)]**

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **staff_call_id** | BigInt | PK, AI | **호출 내역 ID** |
| table_id | BigInt | FK (TABLES) | 테이블 ID |
| staff_call_item_id | BigInt | FK (ITEMS) | 호출 항목 ID |
| is_completed | Boolean | Default False | 완료 여부 |
| created_at | Timestamp | Not Null | 생성 일시 |