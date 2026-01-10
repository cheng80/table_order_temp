# [설계] 테이블오더 시스템 데이터베이스 명세서 (v2.5)

> **문서 번호:** 05_database_design_spec.md
> **작성 일자:** 2025.01.10
> **설계 원칙:** 실용적 정규화 (Pragmatic Normalization)
> **공통 규칙:**
> * 모든 테이블은 `bigint id` (PK, Auto Increment)를 가진다.
> * 모든 테이블은 `timestamp created_at` (생성일시)를 가진다.
> * 외래키(FK) 컬럼명은 `대상테이블단수명_id` 형식을 따른다.

---

## 1. 계정 및 매장 (Core Domain)
시스템의 근간이 되는 핵심 마스터 데이터입니다.

### 1.1 USERS
> **Type: [Entity]**
> **설명:** 서비스를 사용하는 점주(관리자) 정보.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| login_id | Varchar | UK, Not Null | 로그인 아이디 (이메일 등) |
| password | Varchar | Not Null | 암호화된 비밀번호 |
| business_number | Varchar | - | 사업자 등록번호 |
| owner_name | Varchar | - | 점주 성명 |
| created_at | Timestamp | Not Null | 가입 일시 |

### 1.2 STORES
> **Type: [Entity]**
> **설명:** 점주가 소유한 매장 정보. (1명의 점주가 여러 매장 소유 가능)

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| owner_id | BigInt | FK (USERS) | 소유 점주 ID |
| name | Varchar | Not Null | 매장명 |
| is_open | Boolean | Default False | 영업 상태 (On/Off) |
| total_table_count | Int | Default 0 | 총 보유 테이블 수 |
| created_at | Timestamp | Not Null | 매장 생성 일시 |

### 1.3 TABLES
> **Type: [Entity]**
> **설명:** 매장 내 개별 테이블 정보. 태블릿 기기와 1:1 매핑되는 기준.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| store_id | BigInt | FK (STORES) | 소속 매장 ID |
| table_number | Int | Not Null | 테이블 번호 (1, 2, 3...) |
| auth_code | Varchar | Not Null | 기기 인증용 PIN/QR 코드 (오동작 방지) |
| created_at | Timestamp | Not Null | 생성 일시 |

---

## 2. 메뉴 및 옵션 구성 (Product Domain)
점주가 구성하는 상품 정보이며, **카테고리형 데이터**가 포함됩니다.

### 2.1 MENU_CATEGORIES
> **Type: [Category/Lookup]**
> **설명:** 메뉴를 그룹화하는 카테고리. 점주가 생성/수정 가능.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| store_id | BigInt | FK (STORES) | 소속 매장 ID |
| name | Varchar | Not Null | 카테고리명 (예: 파스타, 음료) |
| sort_order | Int | Default 0 | 정렬 순서 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 2.2 MENUS
> **Type: [Entity]**
> **설명:** 판매되는 개별 메뉴 아이템.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| category_id | BigInt | FK (MENU_CATEGORIES) | 소속 카테고리 |
| name | Varchar | Not Null | 메뉴명 |
| price | Int | Not Null | 기본 판매가 |
| description | Text | - | 메뉴 설명 |
| image_url | Varchar | - | 메뉴 이미지 경로 |
| is_soldout | Boolean | Default False | 품절 여부 (Toggle) |
| is_hidden | Boolean | Default False | 숨김 여부 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 2.3 OPTION_GROUPS
> **Type: [Category/Lookup]**
> **설명:** 옵션들의 묶음 및 선택 규칙 정의.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| store_id | BigInt | FK (STORES) | 소속 매장 ID |
| name | Varchar | Not Null | 그룹명 (예: 맵기 조절, 토핑 추가) |
| is_exclusive | Boolean | Not Null | True=필수단일(Radio), False=다중선택(Check) |
| min_select | Int | Default 0 | 최소 선택 개수 (유효성 검증용) |
| max_select | Int | Default 1 | 최대 선택 개수 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 2.4 OPTIONS
> **Type: [Entity]**
> **설명:** 그룹에 속한 개별 선택지.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| group_id | BigInt | FK (OPTION_GROUPS) | 소속 옵션 그룹 |
| name | Varchar | Not Null | 옵션명 (예: 아주 매운맛, 치즈) |
| extra_price | Int | Default 0 | 추가 금액 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 2.5 MENU_OPTION_MAPPINGS
> **Type: [Relationship]**
> **설명:** 메뉴와 옵션 그룹 간의 M:N 관계를 해소하는 매핑 테이블.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| menu_id | BigInt | FK (MENUS) | 대상 메뉴 |
| option_group_id | BigInt | FK (OPTION_GROUPS) | 연결할 옵션 그룹 |
| created_at | Timestamp | Not Null | 연결 일시 |

---

## 3. 주문 및 트랜잭션 (Transaction Domain)
실제 서비스 운영 중 발생하는 데이터입니다.

### 3.1 ORDERS
> **Type: [Entity (Transaction)]**
> **설명:** 테이블에서 발생한 1회의 주문 건 (Header).

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 주문번호 |
| store_id | BigInt | FK (STORES) | 매장 ID |
| table_id | BigInt | FK (TABLES) | 주문한 테이블 ID |
| payment_type | Varchar | **Enum** | 결제수단 ('CARD', 'CASH', 'TOSS') |
| payment_status | Varchar | **Enum** | 결제상태 ('PENDING', 'PAID', 'CANCELED') |
| total_price | Int | Not Null | 총 결제 금액 |
| created_at | Timestamp | Not Null | 주문 생성 일시 |

### 3.2 ORDER_DETAILS
> **Type: [Entity (Detail)]**
> **설명:** 주문에 포함된 메뉴 상세 내역. KDS 표시의 기준 단위.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| order_id | BigInt | FK (ORDERS) | 소속 주문 |
| menu_id | BigInt | FK (MENUS) | 주문한 메뉴 |
| quantity | Int | Not Null | 수량 |
| price_snapshot | Int | Not Null | 주문 시점의 메뉴 단가 (가격변동 대비) |
| cook_status | Varchar | **Enum** | 조리상태 ('PENDING', 'COOKING', 'DONE') |
| created_at | Timestamp | Not Null | 생성 일시 |

### 3.3 ORDER_DETAIL_OPTIONS
> **Type: [Entity (Detail)]**
> **설명:** 주문 상세 메뉴에 딸린 선택된 옵션 내역.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| order_detail_id | BigInt | FK (ORDER_DETAILS) | 소속 주문 상세 |
| option_id | BigInt | FK (OPTIONS) | 선택한 옵션 |
| price_snapshot | Int | Not Null | 주문 시점의 옵션 가격 |
| created_at | Timestamp | Not Null | 생성 일시 |

---

## 4. 부가 기능 (Support Domain)

### 4.1 STAFF_CALL_ITEMS
> **Type: [Category/Lookup]**
> **설명:** 직원 호출 시 선택 가능한 항목 정의. 점주가 커스텀 가능.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| store_id | BigInt | FK (STORES) | 소속 매장 ID |
| name | Varchar | Not Null | 항목명 (예: 물, 앞치마) |
| icon_code | Varchar | - | 클라이언트 아이콘 매핑 코드 |
| created_at | Timestamp | Not Null | 생성 일시 |

### 4.2 STAFF_CALLS
> **Type: [Entity (Transaction)]**
> **설명:** 실제 발생한 직원 호출 요청 로그.

| 컬럼명 | 타입 | 제약조건 | 설명 |
| :--- | :--- | :--- | :--- |
| **id** | BigInt | PK, AI | 고유 ID |
| table_id | BigInt | FK (TABLES) | 요청한 테이블 |
| item_id | BigInt | FK (STAFF_CALL_ITEMS) | 요청한 항목 (오동작 방지) |
| is_completed | Boolean | Default False | 직원 확인/처리 여부 |
| created_at | Timestamp | Not Null | 요청 일시 |

---

## 5. ER Diagram (Visualization)

```mermaid
erDiagram
    USERS ||--|{ STORES : owns
    STORES ||--|{ TABLES : has
    
    STORES ||--|{ MENU_CATEGORIES : manages
    MENU_CATEGORIES ||--|{ MENUS : contains
    
    STORES ||--|{ OPTION_GROUPS : defines
    OPTION_GROUPS ||--|{ OPTIONS : includes
    
    MENUS ||--|{ MENU_OPTION_MAPPINGS : uses
    OPTION_GROUPS ||--|{ MENU_OPTION_MAPPINGS : applied_to

    STORES ||--|{ ORDERS : receives
    TABLES ||--|{ ORDERS : places
    
    ORDERS ||--|{ ORDER_DETAILS : consists_of
    ORDER_DETAILS ||--|{ ORDER_DETAIL_OPTIONS : has
    
    STORES ||--|{ STAFF_CALL_ITEMS : configures
    STAFF_CALL_ITEMS ||--|{ STAFF_CALLS : defines_type
    TABLES ||--|{ STAFF_CALLS : requests