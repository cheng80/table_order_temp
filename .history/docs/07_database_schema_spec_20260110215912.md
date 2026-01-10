# [설계] 테이블오더 시스템 데이터베이스 상세 명세서 (v3.3)

> - **문서 번호:** 07_database_schema_spec.md
> - **작성 일자:** 2026.01.10
> - **버전:** v3.3 (SQL 예약어 리네이밍 + 예약 도메인 추가 + ERD 타입 명시)
> - **설계 원칙:**
>   1. **Keyword Safe:** SQL 예약어(Order, Table, User 등) 사용 금지.
>   2. **ERD Type Defined:** 강한/약한/연관 개체를 명시하여 모델링 가이드 제공.

---

## 📌 ERD 타입 범례 (Legend)
* **[Strong Entity]:** 부모 없이 독립적으로 존재하는 **강한 개체** (일반 사각형).
* **[Weak Entity]:** 부모(FK)가 있어야만 존재하는 **약한 개체** (일반 사각형 + 부모 쪽 필수 관계).
* **[Associative Entity]:** 두 개체 간의 M:N 관계를 해소하는 **연관(교차) 개체** (보통 주문 상세, 매핑 테이블).

---

## 1. 계정 및 매장 (Core Domain)

### 1.1 MEMBERS (사용자/점주)
> **ERD Type: [Strong Entity]**
> **변경:** `USERS` → `MEMBERS` (SQL `USER` 예약어 회피)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **member_id** | BigInt | **PK** | 사용자 고유 ID | Auto Increment |
| login_email | Varchar(50) | NO | 로그인 이메일 | `login_id` → 의미 명확화 |
| login_pw | Varchar(255) | NO | 비밀번호 | `password` 예약어 회피 |
| owner_name | Varchar(20) | YES | 점주 성명 | - |
| business_no | Varchar(20) | YES | 사업자 등록번호 | - |
| **access_token** | Varchar(64) | YES | 자동로그인 토큰 | UUID v4 |
| last_login_at | Timestamp | YES | 마지막 접속 일시 | - |
| created_at | Timestamp | NO | 가입 일시 | - |

### 1.2 STORES (매장)
> **ERD Type: [Weak Entity]** (Parent: MEMBERS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_id** | BigInt | **PK** | 매장 고유 ID | - |
| **member_id** | BigInt | **FK** | 점주 ID | - |
| store_name | Varchar(50) | NO | 매장 상호명 | `name` → `store_name` |
| store_status | Varchar(20) | NO | 영업 상태 | OPEN, CLOSED |
| max_table_cnt | Int | NO | 총 보유 테이블 수 | 설정값 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 1.3 STORE_TABLES (테이블 기기)
> **ERD Type: [Weak Entity]** (Parent: STORES)
> **변경:** `TABLES` → `STORE_TABLES` (SQL `TABLE` 예약어 회피)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_table_id** | BigInt | **PK** | 테이블 고유 ID | `table_id`에서 변경 |
| **store_id** | BigInt | **FK** | 소속 매장 ID | - |
| table_no | Int | NO | 테이블 번호 | 1, 2, 3... |
| auth_pin | Varchar(10) | NO | 기기 인증 PIN | `auth_code`보다 명확함 |
| **table_status** | Varchar(20) | NO | **운영 상태** | AVAILABLE, OCCUPIED, RESERVED, DISABLED |
| **guest_capacity** | Int | NO | **수용 인원** | 예약 정원 체크 (Default 4) |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2. 상품 구성 (Product Domain)

### 2.1 MENU_CATEGORIES (메뉴 카테고리)
> **ERD Type: [Weak Entity]** (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **category_id** | BigInt | **PK** | 카테고리 ID | `menu_category_id` 단축 |
| **store_id** | BigInt | **FK** | 소속 매장 ID | - |
| category_name | Varchar(30) | NO | 카테고리명 | `name` → `category_name` |
| sort_sequence | Int | NO | 정렬 순서 | `order` 예약어 회피 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 2.2 MENUS (메뉴)
> **ERD Type: [Weak Entity]** (Parent: MENU_CATEGORIES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_id** | BigInt | **PK** | 메뉴 ID | - |
| **category_id** | BigInt | **FK** | 카테고리 ID | - |
| menu_name | Varchar(50) | NO | 메뉴명 | `name` → `menu_name` |
| unit_price | Int | NO | 기본 판매가 | `price`보다 명확함 |
| description | Text | YES | 메뉴 설명 | - |
| img_url | Varchar(255) | YES | 이미지 URL | - |
| is_soldout | Boolean | NO | 품절 여부 | - |
| is_hidden | Boolean | NO | 숨김 여부 | - |

### 2.3 OPTION_GROUPS (옵션 그룹)
> **ERD Type: [Weak Entity]** (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **opt_group_id** | BigInt | **PK** | 옵션 그룹 ID | `option_group_id` 약어 |
| **store_id** | BigInt | **FK** | 소속 매장 ID | - |
| group_name | Varchar(30) | NO | 그룹명 | `name` → `group_name` |
| is_exclusive | Boolean | NO | 선택 방식 | True(라디오), False(체크) |
| min_qty | Int | NO | 최소 선택 수 | `select` 예약어 회피 |
| max_qty | Int | NO | 최대 선택 수 | - |

### 2.4 MENU_OPTIONS (옵션 상세)
> **ERD Type: [Weak Entity]** (Parent: OPTION_GROUPS)
> **변경:** `OPTIONS` → `MENU_OPTIONS` (SQL `OPTION` 예약어 회피)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_opt_id** | BigInt | **PK** | 옵션 ID | `option_id`에서 변경 |
| **opt_group_id** | BigInt | **FK** | 소속 그룹 ID | - |
| option_name | Varchar(30) | NO | 옵션명 | - |
| extra_price | Int | NO | 추가 금액 | - |

### 2.5 MENU_OPT_MAPPINGS (메뉴-옵션 연결)
> **ERD Type: [Associative Entity]** (MENUS <-> OPTION_GROUPS)
> **설명:** 다대다(M:N) 관계를 해소하기 위한 교차 테이블.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **mapping_id** | BigInt | **PK** | 매핑 ID | - |
| **menu_id** | BigInt | **FK** | 메뉴 ID | - |
| **opt_group_id** | BigInt | **FK** | 옵션 그룹 ID | - |

---

## 3. 주문 및 결제 (Transaction Domain)

### 3.1 SALES_ORDERS (주문 헤더)
> **ERD Type: [Weak Entity]** (Parent: STORE_TABLES)
> **변경:** `ORDERS` → `SALES_ORDERS` (SQL `ORDER` 예약어 회피)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **sales_order_id** | BigInt | **PK** | 주문 ID | `order_id`에서 변경 |
| **order_uuid** | Varchar(64) | NO | 주문 고유 UUID | Toss 연동용 |
| **store_id** | BigInt | **FK** | 매장 ID | 조회 최적화용 |
| **store_table_id** | BigInt | **FK** | 테이블 ID | `table_id`에서 변경 |
| total_amount | Int | NO | 주문 총 금액 | - |
| created_at | Timestamp | NO | 주문 생성 일시 | - |

### 3.2 PAYMENTS (결제 정보)
> **ERD Type: [Weak Entity]** (Parent: SALES_ORDERS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **payment_id** | BigInt | **PK** | 결제 ID | - |
| **sales_order_id** | BigInt | **FK** | 주문 ID | `order_id`에서 변경 |
| payment_key | Varchar(100) | NO | Toss Payment Key | - |
| pay_method | Varchar(20) | NO | 결제 수단 | `method` 예약어 회피 |
| pay_amount | Int | NO | 승인 금액 | - |
| pay_status | Varchar(20) | NO | 결제 상태 | `status` 예약어 회피 |
| approved_at | Timestamp | YES | 승인 일시 | - |

### 3.3 ORDER_LINE_ITEMS (주문 상세)
> **ERD Type: [Associative Entity]** (SALES_ORDERS <-> MENUS)
> **변경:** `ORDER_DETAILS` → `ORDER_LINE_ITEMS` (일반적인 커머스 용어)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **line_item_id** | BigInt | **PK** | 상세 ID | `order_detail_id` 변경 |
| **sales_order_id** | BigInt | **FK** | 주문 ID | - |
| **menu_id** | BigInt | **FK** | 메뉴 ID | - |
| quantity | Int | NO | 수량 | - |
| unit_price_snap | Int | NO | 시점 단가 | - |
| cook_status | Varchar(20) | NO | 조리 상태 | PENDING, COOKING, DONE |

### 3.4 LINE_ITEM_OPTIONS (주문 옵션 상세)
> **ERD Type: [Associative Entity]** (ORDER_LINE_ITEMS <-> MENU_OPTIONS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **item_opt_id** | BigInt | **PK** | 옵션 상세 ID | - |
| **line_item_id** | BigInt | **FK** | 주문 상세 ID | - |
| **menu_opt_id** | BigInt | **FK** | 옵션 ID | - |
| price_snap | Int | NO | 시점 추가금 | - |

---

## 4. 지원 및 예약 (Support & Reservation)

### 4.1 STAFF_CALL_ITEMS (호출 항목)
> **ERD Type: [Weak Entity]** (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **call_item_id** | BigInt | **PK** | 항목 ID | - |
| **store_id** | BigInt | **FK** | 매장 ID | - |
| item_name | Varchar(30) | NO | 항목명 | - |

### 4.2 STAFF_CALL_LOGS (호출 로그)
> **ERD Type: [Associative Entity]** (STORE_TABLES <-> STAFF_CALL_ITEMS)
> **변경:** `STAFF_CALLS` → `STAFF_CALL_LOGS`

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **call_log_id** | BigInt | **PK** | 로그 ID | - |
| **store_table_id** | BigInt | **FK** | 테이블 ID | - |
| **call_item_id** | BigInt | **FK** | 항목 ID | - |
| is_completed | Boolean | NO | 처리 여부 | - |

### 4.3 RESERVATIONS (예약)
> **ERD Type: [Weak Entity]** (Parent: STORE_TABLES)
> **설명:** 테이블의 시간 점유를 관리하는 예약 정보.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **reservation_id** | BigInt | **PK** | 예약 ID | Auto Increment |
| **store_id** | BigInt | **FK** | 매장 ID | 조회 최적화 |
| **store_table_id** | BigInt | **FK** | 테이블 ID | STORE_TABLES 참조 |
| guest_name | Varchar(30) | NO | 예약자명 | - |
| guest_phone | Varchar(20) | NO | 연락처 | - |
| guest_count | Int | NO | 인원수 | capacity 체크용 |
| reserve_date | Date | NO | 예약 날짜 | 2026-01-10 |
| reserve_time | Time | NO | 예약 시간 | 18:00 |
| status | Varchar(20) | NO | 예약 상태 | CONFIRMED, CANCELED |
| created_at | Timestamp | NO | 생성 일시 | - |