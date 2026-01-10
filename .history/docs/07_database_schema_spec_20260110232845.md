# [설계] 테이블오더 시스템 데이터베이스 상세 명세서 (v3.7)

> - **문서 번호:** 07_database_schema_spec.md  
> - **작성 일자:** 2026.01.10  
> - **버전:** v3.7 (Final Polished)  
> - **설계 원칙:**
>   1. **Reserved Word Safe:** `MEMBERS`, `STORE_TABLES`, `STORE_ORDERS` 사용으로 SQL 충돌 원천 차단.  
>   2. **Consistency:** 부모 PK와 자식 FK 컬럼명을 100% 일치시킴.  

---

## 📌 ERD 타입 범례 (Legend)
* **[Strong Entity]:** 독립적으로 존재하는 강한 개체 (일반 사각형).  
* **[Weak Entity]:** 부모가 있어야만 존재하는 약한 개체 (점선 사각형).  
* **[Associative Entity]:** M:N 관계를 해소하는 연관 개체 (육각형 권장).  

---

## 1. 계정 및 매장 (Core Domain)

### 1.1 MEMBERS (사용자/점주)  
> **ERD Type: [Strong Entity]**  

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **member_id** | BigInt | **PK** | 사용자 고유 ID | Auto Increment |
| login_id | Varchar(50) | NO | 로그인 아이디 | 이메일 등 |
| password | Varchar(255) | NO | 비밀번호 | BCrypt |
| owner_name | Varchar(20) | YES | 점주 성명 | - |
| business_number | Varchar(20) | YES | 사업자 등록번호 | - |
| **access_token** | Varchar(64) | YES | 자동로그인 토큰 | UUID v4 |
| last_login_at | Timestamp | YES | 마지막 접속 일시 | - |
| created_at | Timestamp | NO | 가입 일시 | - |

### 1.2 STORES (매장)
> **ERD Type: [Weak Entity]** (Parent: MEMBERS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_id** | BigInt | **PK** | 매장 고유 ID | - |
| **member_id** | BigInt | **FK** | 점주 ID | - |
| name | Varchar(50) | NO | 매장 상호명 | - |
| is_open | Boolean | NO | 영업 상태 | True(영업중), False(마감) |
| total_table_count | Int | NO | 총 보유 테이블 수 | 설정값 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 1.3 STORE_TABLES (테이블 기기)
> **ERD Type: [Weak Entity]** (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_table_id** | BigInt | **PK** | 테이블 고유 ID | - |
| **store_id** | BigInt | **FK** | 소속 매장 ID | - |
| table_number | Int | NO | 테이블 번호 | 1, 2, 3... |
| auth_code | Varchar(10) | NO | 기기 인증 PIN | - |
| **status** | Varchar(20) | NO | **운영 상태** | AVAILABLE, RESERVED, DISABLED |
| **capacity** | Int | NO | **수용 인원** | 예약 정원 체크 (Default 4) |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2. 상품 구성 (Product Domain)

### 2.1 MENU_CATEGORIES (메뉴 카테고리)
> **ERD Type: [Weak Entity]** (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_category_id** | BigInt | **PK** | 카테고리 ID | - |
| **store_id** | BigInt | **FK** | 소속 매장 ID | - |
| name | Varchar(30) | NO | 카테고리명 | - |
| sort_order | Int | NO | 정렬 순서 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

### 2.2 MENUS (메뉴)
> **ERD Type: [Weak Entity]** (Parent: MENU_CATEGORIES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_id** | BigInt | **PK** | 메뉴 ID | - |
| **menu_category_id** | BigInt | **FK** | 카테고리 ID | - |
| name | Varchar(50) | NO | 메뉴명 | - |
| price | Int | NO | 기본 판매가 | - |
| description | Text | YES | 메뉴 설명 | - |
| image_url | Varchar(255) | YES | 이미지 URL | - |
| is_soldout | Boolean | NO | 품절 여부 | - |
| is_hidden | Boolean | NO | 숨김 여부 | - |

### 2.3 OPTION_GROUPS (옵션 그룹)
> **ERD Type: [Weak Entity]** (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **option_group_id** | BigInt | **PK** | 옵션 그룹 ID | - |
| **store_id** | BigInt | **FK** | 소속 매장 ID | - |
| name | Varchar(30) | NO | 그룹명 | - |
| is_exclusive | Boolean | NO | 선택 방식 | True(라디오), False(체크) |
| min_select | Int | NO | 최소 선택 수 | - |
| max_select | Int | NO | 최대 선택 수 | - |

### 2.4 OPTIONS (옵션 상세)
> **ERD Type: [Weak Entity]** (Parent: OPTION_GROUPS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **option_id** | BigInt | **PK** | 옵션 ID | - |
| **option_group_id** | BigInt | **FK** | 소속 그룹 ID | - |
| name | Varchar(30) | NO | 옵션명 | - |
| extra_price | Int | NO | 추가 금액 | - |

### 2.5 MENU_OPTION_MAPPINGS (메뉴-옵션 연결)
> **ERD Type: [Associative Entity]** (MENUS <-> OPTION_GROUPS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **mapping_id** | BigInt | **PK** | 매핑 ID | - |
| **menu_id** | BigInt | **FK** | 메뉴 ID | - |
| **option_group_id** | BigInt | **FK** | 옵션 그룹 ID | - |

---

## 3. 주문 및 결제 (Transaction Domain)

### 3.1 STORE_ORDERS (주문 헤더)
> **ERD Type: [Weak Entity]** (Parent: STORE_TABLES)
> **변경:** `ORDERS` → `STORE_ORDERS` (예약어 회피)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_order_id** | BigInt | **PK** | 주문 ID | - |
| **store_order_uuid** | Varchar(64) | NO | 주문 고유 UUID | Toss 연동용 |
| **store_id** | BigInt | **FK** | 매장 ID | - |
| **store_table_id** | BigInt | **FK** | 테이블 ID | `STORE_TABLES` 참조 |
| total_price | Int | NO | 주문 총 금액 | - |
| created_at | Timestamp | NO | 주문 생성 일시 | - |

### 3.2 PAYMENTS (결제 정보)
> **ERD Type: [Weak Entity]** (Parent: STORE_ORDERS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **payment_id** | BigInt | **PK** | 결제 ID | - |
| **store_order_id** | BigInt | **FK** | 주문 ID | `STORE_ORDERS` 참조 |
| payment_key | Varchar(100) | NO | Toss Payment Key | - |
| method | Varchar(20) | NO | 결제 수단 | CARD, EASY_PAY |
| total_amount | Int | NO | 승인 금액 | - |
| status | Varchar(20) | NO | 결제 상태 | DONE, CANCELED |
| approved_at | Timestamp | YES | 승인 일시 | - |

### 3.3 ORDER_DETAILS (주문 상세)
> **ERD Type: [Associative Entity]** (STORE_ORDERS <-> MENUS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_detail_id** | BigInt | **PK** | 상세 ID | - |
| **store_order_id** | BigInt | **FK** | 주문 ID | `STORE_ORDERS` 참조 |
| **menu_id** | BigInt | **FK** | 메뉴 ID | - |
| quantity | Int | NO | 수량 | - |
| price_snapshot | Int | NO | 시점 단가 | - |
| cook_status | Varchar(20) | NO | 조리 상태 | PENDING, COOKING, DONE |

### 3.4 ORDER_DETAIL_OPTIONS (주문 옵션 상세)
> **ERD Type: [Associative Entity]** (ORDER_DETAILS <-> OPTIONS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_detail_option_id** | BigInt | **PK** | 옵션 상세 ID | - |
| **order_detail_id** | BigInt | **FK** | 주문 상세 ID | - |
| **option_id** | BigInt | **FK** | 옵션 ID | - |
| price_snapshot | Int | NO | 시점 추가금 | - |

---

## 4. 지원 및 예약 (Support & Reservation)

### 4.1 STAFF_CALL_ITEMS (호출 항목)
> **ERD Type: [Weak Entity]** (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **staff_call_item_id** | BigInt | **PK** | 항목 ID | - |
| **store_id** | BigInt | **FK** | 매장 ID | - |
| name | Varchar(30) | NO | 항목명 | - |

### 4.2 STAFF_CALL_LOGS (호출 로그)
> **ERD Type: [Associative Entity]** (STORE_TABLES <-> STAFF_CALL_ITEMS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **staff_call_id** | BigInt | **PK** | 로그 ID | - |
| **store_table_id** | BigInt | **FK** | 테이블 ID | `STORE_TABLES` 참조 |
| **staff_call_item_id** | BigInt | **FK** | 항목 ID | - |
| is_completed | Boolean | NO | 처리 여부 | - |

### 4.3 RESERVATIONS (예약)
> **ERD Type: [Weak Entity]** (Parent: STORE_TABLES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **reservation_id** | BigInt | **PK** | 예약 ID | Auto Increment |
| **store_id** | BigInt | **FK** | 매장 ID | 조회 최적화 |
| **store_table_id** | BigInt | **FK** | 테이블 ID | `STORE_TABLES` 참조 |
| customer_name | Varchar(30) | NO | 예약자명 | - |
| customer_phone | Varchar(20) | NO | 연락처 | - |
| guest_count | Int | NO | 인원수 | capacity 체크용 |
| reserve_date | Date | NO | 예약 날짜 | 2026-01-10 |
| reserve_time | Time | NO | 예약 시간 | 18:00 |
| status | Varchar(20) | NO | 예약 상태 | CONFIRMED, CANCELED |
| created_at | Timestamp | NO | 생성 일시 | - |