# [설계] 테이블오더 시스템 데이터베이스 상세 명세서 (v3.0)

> **문서 번호:** 07_database_schema_spec.md
> **작성 일자:** 2025.01.10
> **기반 ERD:** Integrated ERD v3.0
> **설계 원칙:**
> 1. **네이밍:** PK와 FK 컬럼명을 100% 일치시킴 (Natural Join 친화적).
> 2. **인증:** `USERS` 테이블에 UUID 세션 토큰 포함.
> 3. **결제:** `ORDERS`와 `PAYMENTS`를 분리하여 PG사(Toss) 데이터 독립성 확보.

---

## 1. 계정 및 매장 (Core Domain)
시스템의 접근 권한과 물리적 매장 구조를 정의합니다.

### 1.1 USERS (사용자/점주)
> **Type: [Entity]**
> **설명:** 서비스를 이용하는 사장님(관리자). UUID 기반의 세션 인증을 수행합니다.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **user_id** | BigInt | **PK** | 사용자 고유 ID | Auto Increment |
| login_id | Varchar(50) | NO | 로그인 아이디 | Unique Key (이메일 등) |
| password | Varchar(255) | NO | 비밀번호 | BCrypt 암호화 저장 필수 |
| business_number | Varchar(20) | YES | 사업자 등록번호 | - |
| owner_name | Varchar(20) | YES | 점주 성명 | - |
| **access_token** | Varchar(64) | YES | **자동로그인 토큰** | **UUID v4 (인증 핵심)** |
| last_login_at | Timestamp | YES | 마지막 접속 일시 | 토큰 만료 체크용 |
| created_at | Timestamp | NO | 계정 생성 일시 | Default NOW() |

### 1.2 STORES (매장)
> **Type: [Entity]**
> **설명:** 점주가 소유한 가게 정보.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_id** | BigInt | **PK** | 매장 고유 ID | Auto Increment |
| **user_id** | BigInt | **FK** | 소유 점주 ID | USERS 테이블 참조 |
| name | Varchar(50) | NO | 매장 상호명 | - |
| is_open | Boolean | NO | 영업 중 여부 | Default False |
| total_table_count | Int | NO | 총 보유 테이블 수 | Default 0 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 1.3 TABLES (테이블 기기)
> **Type: [Entity]**
> **설명:** 매장 내 설치된 태블릿 기기 정보.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **table_id** | BigInt | **PK** | 테이블 고유 ID | Auto Increment |
| **store_id** | BigInt | **FK** | 소속 매장 ID | STORES 테이블 참조 |
| table_number | Int | NO | 테이블 번호 | 1, 2, 3... |
| auth_code | Varchar(10) | NO | **기기 인증 코드** | PIN 번호 (오동작 방지) |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2. 상품 구성 (Product Domain)
점주가 구성하는 메뉴판 데이터입니다. 변경이 잦은 카테고리성 데이터는 별도 테이블로 관리합니다.

### 2.1 MENU_CATEGORIES (메뉴 카테고리)
> **Type: [Lookup]**
> **설명:** 메뉴를 묶는 그룹 (예: 파스타, 음료, 주류).

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_category_id** | BigInt | **PK** | 카테고리 ID | Auto Increment |
| **store_id** | BigInt | **FK** | 소속 매장 ID | - |
| name | Varchar(30) | NO | 카테고리명 | - |
| sort_order | Int | NO | 정렬 순서 | Default 0 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 2.2 MENUS (메뉴)
> **Type: [Entity]**
> **설명:** 실제 판매되는 메뉴 아이템.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_id** | BigInt | **PK** | 메뉴 ID | Auto Increment |
| **menu_category_id** | BigInt | **FK** | 카테고리 ID | - |
| name | Varchar(50) | NO | 메뉴명 | - |
| price | Int | NO | 기본 판매가 | - |
| description | Text | YES | 메뉴 설명 | - |
| image_url | Varchar(255) | YES | 이미지 URL | - |
| is_soldout | Boolean | NO | 품절 여부 | Default False |
| is_hidden | Boolean | NO | 숨김 여부 | Default False |
| created_at | Timestamp | NO | 생성 일시 | - |

### 2.3 OPTION_GROUPS (옵션 그룹)
> **Type: [Lookup]**
> **설명:** 옵션의 묶음 및 선택 규칙 (예: 맵기 조절).

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **option_group_id** | BigInt | **PK** | 옵션 그룹 ID | - |
| **store_id** | BigInt | **FK** | 소속 매장 ID | - |
| name | Varchar(30) | NO | 그룹명 | - |
| is_exclusive | Boolean | NO | **선택 방식** | True=라디오, False=체크박스 |
| min_select | Int | NO | 최소 선택 수 | 유효성 검증용 |
| max_select | Int | NO | 최대 선택 수 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

### 2.4 OPTIONS (옵션 상세)
> **Type: [Entity]**
> **설명:** 실제 선택 가능한 옵션 항목 (예: 아주 매운맛).

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **option_id** | BigInt | **PK** | 옵션 ID | - |
| **option_group_id** | BigInt | **FK** | 소속 그룹 ID | - |
| name | Varchar(30) | NO | 옵션명 | - |
| extra_price | Int | NO | 추가 금액 | Default 0 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 2.5 MENU_OPTION_MAPPINGS (메뉴-옵션 연결)
> **Type: [Relationship]**
> **설명:** 어떤 메뉴에 어떤 옵션 그룹이 노출될지 정의 (M:N 해소).

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **mapping_id** | BigInt | **PK** | 매핑 ID | - |
| **menu_id** | BigInt | **FK** | 메뉴 ID | - |
| **option_group_id** | BigInt | **FK** | 옵션 그룹 ID | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 3. 주문 및 결제 (Transaction Domain)
돈과 메뉴가 오가는 핵심 트랜잭션 영역입니다. **Toss Payments 연동을 위해 PAYMENTS 테이블을 분리**했습니다.

### 3.1 ORDERS (주문 헤더)
> **Type: [Transaction]**
> **설명:** 테이블에서 발생한 주문의 기본 정보. (결제 정보는 포함하지 않음)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_id** | BigInt | **PK** | 내부 주문 ID | Auto Increment |
| **order_uuid** | Varchar(64) | NO | **주문 고유 UUID** | **Toss로 보낼 주문번호** |
| **store_id** | BigInt | **FK** | 매장 ID | - |
| **table_id** | BigInt | **FK** | 테이블 ID | - |
| total_price | Int | NO | 주문 총 금액 | - |
| created_at | Timestamp | NO | 주문 생성 일시 | - |

### 3.2 PAYMENTS (결제 정보 - Toss)
> **Type: [Transaction]**
> **설명:** PG사(Toss) 승인 결과 및 영수증 정보 저장.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **payment_id** | BigInt | **PK** | 결제 ID | - |
| **order_id** | BigInt | **FK** | 관련 주문 ID | 1:1 관계 |
| payment_key | Varchar(100) | NO | **Toss Payment Key** | 환불 시 필수값 |
| toss_order_id | Varchar(64) | NO | Toss에 보낸 UUID | orders.order_uuid와 동일 |
| method | Varchar(20) | NO | 결제 수단 | 카드, 간편결제 등 |
| total_amount | Int | NO | 실제 승인 금액 | - |
| status | Varchar(20) | NO | **결제 상태** | DONE, CANCELED, ABORTED |
| requested_at | Timestamp | NO | 결제 요청 일시 | - |
| approved_at | Timestamp | YES | **최종 승인 일시** | 실제 매출 발생 시점 |
| receipt_url | Varchar(255) | YES | 영수증 URL | Toss 제공 |
| cancel_reason | Varchar(100) | YES | 취소 사유 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

### 3.3 ORDER_DETAILS (주문 상세)
> **Type: [Detail]**
> **설명:** 주문에 포함된 메뉴 리스트. KDS(주방)에서 보는 주 데이터.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_detail_id** | BigInt | **PK** | 상세 ID | - |
| **order_id** | BigInt | **FK** | 주문 ID | - |
| **menu_id** | BigInt | **FK** | 메뉴 ID | - |
| quantity | Int | NO | 수량 | - |
| price_snapshot | Int | NO | **시점 단가** | 메뉴 가격 변경 대비 |
| cook_status | Varchar(20) | NO | **조리 상태** | PENDING, COOKING, DONE |
| created_at | Timestamp | NO | 생성 일시 | - |

### 3.4 ORDER_DETAIL_OPTIONS (주문 옵션 상세)
> **Type: [Detail]**
> **설명:** 상세 메뉴에 딸린 옵션 선택 내역.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_detail_option_id** | BigInt | **PK** | 옵션 상세 ID | - |
| **order_detail_id** | BigInt | **FK** | 주문 상세 ID | - |
| **option_id** | BigInt | **FK** | 옵션 ID | - |
| price_snapshot | Int | NO | **시점 추가금** | 옵션 가격 변경 대비 |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 4. 운영 지원 (Support Domain)
고객 요청 처리를 위한 데이터입니다.

### 4.1 STAFF_CALL_ITEMS (호출 항목 정의)
> **Type: [Lookup]**
> **설명:** 점주가 설정한 호출 버튼 종류 (물, 앞치마 등).

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **staff_call_item_id** | BigInt | **PK** | 항목 ID | - |
| **store_id** | BigInt | **FK** | 매장 ID | - |
| name | Varchar(30) | NO | 항목명 | - |
| icon_code | Varchar(50) | YES | 아이콘 코드 | 클라이언트 매핑용 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 4.2 STAFF_CALLS (호출 로그)
> **Type: [Transaction]**
> **설명:** 실제 발생한 호출 내역.

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **staff_call_id** | BigInt | **PK** | 호출 ID | - |
| **table_id** | BigInt | **FK** | 요청 테이블 ID | - |
| **staff_call_item_id** | BigInt | **FK** | 요청 항목 ID | - |
| is_completed | Boolean | NO | 처리 완료 여부 | Default False |
| created_at | Timestamp | NO | 요청 일시 | - |