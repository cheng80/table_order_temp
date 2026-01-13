# [설계] 데이터베이스 상세 명세서 (v6.1)

- **문서 번호:** 07_DB_상세_명세_V06(full)
- **작성 일자:** 2026.01.13
- **버전:** v6.1 (STORE_RESERVATIONS 추가)

> 목표: **이 문서(07)만으로 개념적 ERD(Chen Concept ERD)를 작성**할 수 있어야 한다.

---

## 0. 설계 기준 선언 (중요)

### 0.1 용어 정의 (Chen 기준)

- **Entity(엔티티)**: 독립적으로 존재 의미를 갖는 개체(사각형)
- **Relationship(릴레이션십)**: 엔티티 간 의미적 연결(다이아몬드). 1:1, 1:N, N:M 모두 가능하며 Attribute를 가질 수 있다.
- **Associative Entity(연관 엔티티)**: **오직 N:M 관계 해소 목적**으로만 사용한다.

> **PK/속성의 존재 여부는 연관 엔티티 판단 기준이 아니다.**

### 0.2 구현 원칙

- 본 프로젝트는 **개념 ERD(Chen) 표현과 구현 정합**을 위해, 릴레이션십을 **구현 테이블(Relationship Implementation Table)**로 내려서 관리한다.
- 모든 관계 구현 테이블은 **`created_at`을 가진다**.
- 대기열은 테이블과 **직접 결합하지 않는다**(WAITING_LISTS ↔ STORE_TABLES FK 금지).
- 예약은 STORES와 **관계 테이블(STORE_RESERVATIONS)** 로 연결한다(07 단독 ERD 재작성 가능).
- 결제 확정 시점에 가격/원가 스냅샷을 고정 저장한다.

---

## 1. 테이블 분류 체계 (3단)

### 1.1 Entity Tables

- MEMBERS
- STORES
- STORE_TABLES
- MENU_CATEGORIES
- MENUS
- OPTION_GROUPS
- OPTIONS
- STORE_ORDERS
- PAYMENTS
- KDS_TICKETS
- WAITING_LISTS
- RESERVATIONS
- STAFF_CALL_ITEMS
- DAILY_WEATHER

### 1.2 Relationship Implementation Tables (1:1, 1:N)

- OWN_STORES (MEMBERS ↔ STORES)
- HAS_TABLES (STORES ↔ STORE_TABLES)
- DEFINE_MENU_CATEGORIES (STORES ↔ MENU_CATEGORIES)
- DEFINE_OPTION_GROUPS (STORES ↔ OPTION_GROUPS)
- STORE_DAILY_WEATHER (STORES ↔ DAILY_WEATHER)
- STORE_WAITINGS (STORES ↔ WAITING_LISTS)
- **STORE_RESERVATIONS (STORES ↔ RESERVATIONS)**
- MENU_COST_HISTORY (MENUS ↔ COST)
- OPTION_COST_HISTORY (OPTIONS ↔ COST)

### 1.3 Associative Entity Tables (N:M only)

- MENU_OPTION_MAPPINGS (MENUS ↔ OPTION_GROUPS)
- ORDER_DETAILS (STORE_ORDERS ↔ MENUS)
- ORDER_DETAIL_OPTIONS (ORDER_DETAILS ↔ OPTIONS)
- STAFF_CALL_LOGS (STORE_TABLES ↔ STAFF_CALL_ITEMS)

---

## 2. 공통 컬럼/규칙

- 모든 테이블은 `created_at`(Timestamp)을 기본 포함한다.
- 상태값 컬럼은 가능하면 `VARCHAR(20)` + 허용값(문서 표) 방식으로 통일한다.

---

# 3. 테이블 상세 명세 (All Tables)

> 형식: 컬럼 / 타입 / Null / 설명 / 비고

---

## 3.1 MEMBERS (사용자/점주)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **member_id** | BigInt | PK | 사용자 고유 ID | Auto Increment |
| login_id | Varchar(50) | NO | 로그인 아이디 | Unique |
| password | Varchar(255) | NO | 비밀번호 | BCrypt |
| owner_name | Varchar(30) | YES | 점주 성명 | - |
| business_number | Varchar(20) | YES | 사업자 등록번호 | - |
| access_token | Varchar(64) | YES | 자동로그인 토큰 | UUID v4 |
| last_login_at | Timestamp | YES | 마지막 로그인 시각 | 날씨 수집 판단 |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.2 STORES (매장)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **store_id** | BigInt | PK | 매장 ID | Auto Increment |
| name | Varchar(50) | NO | 매장명 | 예: 우마이 카레 |
| avg_eating_time | Int | NO | 평균 식사시간(분) | 운영 설정값 |
| is_open | Boolean | NO | 영업 여부 | - |
| total_table_count | Int | NO | 총 테이블 수 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.3 OWN_STORES (회원-매장 소유 릴레이션십)

- **분류:** Relationship Implementation Table
- **개념 ERD:** MEMBERS —(owns)— STORES

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **own_store_id** | BigInt | PK | 소유 관계 ID | Auto Increment |
| member_id | BigInt | FK | 회원 ID | MEMBERS |
| store_id | BigInt | FK | 매장 ID | STORES |
| created_at | Timestamp | NO | 관계 생성 시각 | - |

---

## 3.4 STORE_TABLES (매장 테이블)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **store_table_id** | BigInt | PK | 테이블 ID | Auto Increment |
| table_number | Int | NO | 테이블 번호 | 1,2,3... |
| auth_code | Varchar(10) | NO | 기기 PIN | 테이블 단말 인증 |
| status | Varchar(20) | NO | 테이블 상태 | AVAILABLE/BUSY |
| capacity | Int | NO | 수용 인원 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.5 HAS_TABLES (매장-테이블 소속 릴레이션십)

- **분류:** Relationship Implementation Table
- **개념 ERD:** STORES —(has)— STORE_TABLES

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **has_table_id** | BigInt | PK | 소속 관계 ID | Auto Increment |
| store_id | BigInt | FK | 매장 ID | STORES |
| store_table_id | BigInt | FK | 테이블 ID | STORE_TABLES |
| created_at | Timestamp | NO | 관계 생성 시각 | - |

---

## 3.6 DAILY_WEATHER (일일 날씨)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **weather_id** | BigInt | PK | 날씨 로그 ID | Auto Increment |
| weather_condition_id | Varchar(10) | NO | 날씨 코드 | 예: OWM id |
| icon_code | Varchar(10) | NO | 아이콘 코드 | - |
| target_date | Date | NO | 대상 날짜 | yyyy-mm-dd |
| created_at | Timestamp | NO | 수집 시각 | - |

---

## 3.7 STORE_DAILY_WEATHER (매장-날씨 릴레이션십)

- **분류:** Relationship Implementation Table
- **개념 ERD:** STORES —(logs)— DAILY_WEATHER

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **store_weather_id** | BigInt | PK | 매장-날씨 관계 ID | Auto Increment |
| store_id | BigInt | FK | 매장 ID | STORES |
| weather_id | BigInt | FK | 날씨 ID | DAILY_WEATHER |
| created_at | Timestamp | NO | 관계 생성 시각 | - |

---

## 3.8 WAITING_LISTS (대기열)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **waiting_id** | BigInt | PK | 대기 ID | Auto Increment |
| waiting_number | Int | NO | 당일 대기번호 | 1부터 증가 |
| customer_name | Varchar(20) | NO | 고객명 | - |
| customer_phone | Varchar(20) | NO | 연락처 | 중복 제한 기준 |
| guest_count | Int | NO | 인원수 | - |
| status | Varchar(20) | NO | 상태 | WAITING/CALLED/ENTERED/NO_SHOW/CANCELED/CLOSED |
| created_at | Timestamp | NO | 등록 시각 | - |

---

## 3.9 STORE_WAITINGS (매장-대기열 릴레이션십)

- **분류:** Relationship Implementation Table
- **개념 ERD:** STORES —(has)— WAITING_LISTS

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **store_waiting_id** | BigInt | PK | 매장-대기 관계 ID | Auto Increment |
| store_id | BigInt | FK | 매장 ID | STORES |
| waiting_id | BigInt | FK | 대기 ID | WAITING_LISTS |
| created_at | Timestamp | NO | 관계 생성 시각 | - |

> 규칙: WAITING_LISTS는 STORE_TABLES와 직접 FK로 연결하지 않는다.

---

## 3.10 MENU_CATEGORIES (메뉴 카테고리)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **menu_category_id** | BigInt | PK | 카테고리 ID | Auto Increment |
| name | Varchar(30) | NO | 카테고리명 | - |
| sort_order | Int | NO | 정렬 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.11 DEFINE_MENU_CATEGORIES (매장-카테고리 정의 릴레이션십)

- **분류:** Relationship Implementation Table
- **개념 ERD:** STORES —(defines)— MENU_CATEGORIES

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **define_menu_category_id** | BigInt | PK | 정의 관계 ID | Auto Increment |
| store_id | BigInt | FK | 매장 ID | STORES |
| menu_category_id | BigInt | FK | 카테고리 ID | MENU_CATEGORIES |
| created_at | Timestamp | NO | 관계 생성 시각 | - |

---

## 3.12 MENUS (메뉴)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **menu_id** | BigInt | PK | 메뉴 ID | Auto Increment |
| name | Varchar(50) | NO | 메뉴명 | - |
| price | Int | NO | 판매가 | - |
| description | Text | YES | 설명 | - |
| image_url | Varchar(255) | YES | 이미지 URL | - |
| is_soldout | Boolean | NO | 품절 | - |
| is_hidden | Boolean | NO | 숨김 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.13 OPTION_GROUPS (옵션 그룹)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **option_group_id** | BigInt | PK | 그룹 ID | Auto Increment |
| name | Varchar(30) | NO | 그룹명 | 예: 맵기 |
| is_exclusive | Boolean | NO | 선택 방식 | 라디오/체크 |
| min_select | Int | NO | 최소 선택 | 필수 옵션 표현 |
| max_select | Int | NO | 최대 선택 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.14 DEFINE_OPTION_GROUPS (매장-옵션그룹 정의 릴레이션십)

- **분류:** Relationship Implementation Table
- **개념 ERD:** STORES —(defines)— OPTION_GROUPS

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **define_option_group_id** | BigInt | PK | 정의 관계 ID | Auto Increment |
| store_id | BigInt | FK | 매장 ID | STORES |
| option_group_id | BigInt | FK | 옵션그룹 ID | OPTION_GROUPS |
| created_at | Timestamp | NO | 관계 생성 시각 | - |

---

## 3.15 OPTIONS (옵션)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **option_id** | BigInt | PK | 옵션 ID | Auto Increment |
| name | Varchar(30) | NO | 옵션명 | - |
| extra_price | Int | NO | 추가금 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.16 MENU_OPTION_MAPPINGS (메뉴-옵션그룹 N:M 해소)

- **분류:** Associative Entity Table (N:M)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **mapping_id** | BigInt | PK | 매핑 ID | Auto Increment |
| menu_id | BigInt | FK | 메뉴 ID | MENUS |
| option_group_id | BigInt | FK | 옵션그룹 ID | OPTION_GROUPS |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.17 MENU_COST_HISTORY (메뉴-원가 릴레이션십)

- **분류:** Relationship Implementation Table (1:N)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **menu_cost_id** | BigInt | PK | 메뉴 원가 관계 ID | Auto Increment |
| menu_id | BigInt | FK | 메뉴 ID | MENUS |
| cost_amount | Int | NO | 원가 | - |
| effective_date | Date | YES | 적용 기준일 | 선택 |
| created_at | Timestamp | NO | 기록 시각 | - |

---

## 3.18 OPTION_COST_HISTORY (옵션-원가 릴레이션십)

- **분류:** Relationship Implementation Table (1:N)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **option_cost_id** | BigInt | PK | 옵션 원가 관계 ID | Auto Increment |
| option_id | BigInt | FK | 옵션 ID | OPTIONS |
| cost_amount | Int | NO | 원가 | - |
| effective_date | Date | YES | 적용 기준일 | 선택 |
| created_at | Timestamp | NO | 기록 시각 | - |

---

## 3.19 STORE_ORDERS (주문 헤더)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **store_order_id** | BigInt | PK | 주문 ID | Auto Increment |
| store_order_uuid | Varchar(64) | NO | UUID | 결제 연동 |
| total_price | Int | NO | 총액 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.20 ORDER_DETAILS (주문-메뉴 N:M 해소)

- **분류:** Associative Entity Table (N:M)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **order_detail_id** | BigInt | PK | 상세 ID | Auto Increment |
| store_order_id | BigInt | FK | 주문 ID | STORE_ORDERS |
| menu_id | BigInt | FK | 메뉴 ID | MENUS |
| quantity | Int | NO | 수량 | - |
| price_snapshot | Int | NO | 판매가 스냅샷 | 결제 확정 기준 |
| cost_snapshot | Int | NO | 원가 스냅샷 | 순이익 계산 |
| cook_status | Varchar(20) | NO | 조리 상태 | PENDING/COOKING/DONE/CANCELED |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.21 ORDER_DETAIL_OPTIONS (상세-옵션 N:M 해소)

- **분류:** Associative Entity Table (N:M)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **order_detail_option_id** | BigInt | PK | 옵션상세 ID | Auto Increment |
| order_detail_id | BigInt | FK | 주문상세 ID | ORDER_DETAILS |
| option_id | BigInt | FK | 옵션 ID | OPTIONS |
| price_snapshot | Int | NO | 옵션가 스냅샷 | - |
| cost_snapshot | Int | NO | 옵션 원가 스냅샷 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.22 PAYMENTS (결제)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **payment_id** | BigInt | PK | 결제 ID | Auto Increment |
| payment_key | Varchar(100) | NO | 승인 키 | - |
| method | Varchar(20) | NO | 결제 수단 | - |
| status | Varchar(20) | NO | 결제 상태 | DONE/CANCELED |
| total_amount | Int | NO | 승인 금액 | - |
| approved_at | Timestamp | YES | 승인 시각 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.23 KDS_TICKETS (KDS 티켓)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **kds_ticket_id** | BigInt | PK | 티켓 ID | Auto Increment |
| ticket_status | Varchar(20) | NO | 티켓 상태 | PENDING/DISPLAYED/DONE |
| printed_at | Timestamp | YES | 생성/표시 시각 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.24 STAFF_CALL_ITEMS (호출 항목)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **staff_call_item_id** | BigInt | PK | 항목 ID | Auto Increment |
| name | Varchar(30) | NO | 항목명 | - |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.25 STAFF_CALL_LOGS (테이블-호출항목 N:M 해소)

- **분류:** Associative Entity Table (N:M)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **staff_call_id** | BigInt | PK | 로그 ID | Auto Increment |
| store_table_id | BigInt | FK | 테이블 ID | STORE_TABLES |
| staff_call_item_id | BigInt | FK | 항목 ID | STAFF_CALL_ITEMS |
| is_completed | Boolean | NO | 처리 여부 | - |
| created_at | Timestamp | NO | 호출 시각 | - |

---

## 3.26 RESERVATIONS (예약)

- **분류:** Entity Table

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **reservation_id** | BigInt | PK | 예약 ID | Auto Increment |
| customer_name | Varchar(30) | NO | 예약자명 | - |
| customer_phone | Varchar(20) | NO | 연락처 | - |
| guest_count | Int | NO | 인원수 | - |
| reserve_date | Date | NO | 예약 날짜 | - |
| reserve_time | Time | NO | 예약 시간 | - |
| status | Varchar(20) | NO | 상태 | CONFIRMED/CANCELED |
| created_at | Timestamp | NO | 생성 시각 | - |

---

## 3.27 STORE_RESERVATIONS (매장-예약 릴레이션십)

- **분류:** Relationship Implementation Table
- **개념 ERD:** STORES —(has)— RESERVATIONS

| 컬럼명 | 타입 | Null | 설명 | 비고 |
|---|---|---:|---|---|
| **store_reservation_id** | BigInt | PK | 매장-예약 관계 ID | Auto Increment |
| store_id | BigInt | FK | 매장 ID | STORES |
| reservation_id | BigInt | FK | 예약 ID | RESERVATIONS |
| created_at | Timestamp | NO | 관계 생성 시각 | - |

---

# 4. 정합 메모 (요약)

- 모든 관계 구현 테이블(1:1, 1:N)은 `created_at` 포함
- 연관 엔티티는 N:M 해소 전용
- 대기열은 테이블과 직접 FK로 연결하지 않음
- 예약은 `STORE_RESERVATIONS`로 매장과 연결(07 단독 ERD 재작성 가능)

---




# 07 부록: 관계 구현 테이블 ↔ 엔티티 FK 매핑 완전표 (v6.1)

> 목적
> - **07_DB_상세_명세_V06(full)** 하단에 그대로 붙여 넣을 수 있는 **부록용 표**
> - 05(ERD) 재작성/검증 시 **관계 테이블이 무엇을 연결하는지** 한 번에 확인
> - 본 프로젝트 원칙: **관계(Relationship)는 구현 테이블로 내려 관리**하며, **모든 관계 테이블은 `created_at`을 가진다**

---

## 1) Relationship Implementation Tables (1:1 / 1:N) — FK 매핑

> 표 읽는 법
> - **관계 테이블** = 07에서 “다이아몬드(관계)”에 해당
> - **카디널리티**는 개념 기준(일반적인 기대치)이며, 실제 제약은 **UNIQUE 인덱스**로 강제 가능

| 관계 테이블 | 관계 의미(개념) | FK 컬럼 → 참조(부모) | 카디널리티(개념) | 무결성/제약 추천 |
|---|---|---|---|---|
| **OWN_STORES** | MEMBERS가 STORES를 소유 | `member_id` → MEMBERS<br/>`store_id` → STORES | MEMBERS 1 : N STORES *(복수 매장 소유 가능)* | `UNIQUE(store_id)` *(매장은 1명의 소유자만)* 또는 정책에 따라 미적용 |
| **HAS_TABLES** | STORES가 STORE_TABLES를 보유 | `store_id` → STORES<br/>`store_table_id` → STORE_TABLES | STORES 1 : N TABLES | `UNIQUE(store_table_id)` *(테이블은 한 매장에만 소속)* |
| **DEFINE_MENU_CATEGORIES** | STORES가 MENU_CATEGORIES를 정의 | `store_id` → STORES<br/>`menu_category_id` → MENU_CATEGORIES | STORES 1 : N CATEGORIES | `UNIQUE(menu_category_id)` *(카테고리는 한 매장 전용)* 또는 공유 정책이면 미적용 |
| **DEFINE_OPTION_GROUPS** | STORES가 OPTION_GROUPS를 정의 | `store_id` → STORES<br/>`option_group_id` → OPTION_GROUPS | STORES 1 : N OPTION_GROUPS | `UNIQUE(option_group_id)` *(옵션그룹은 한 매장 전용)* 또는 공유 정책이면 미적용 |
| **STORE_DAILY_WEATHER** | STORES가 DAILY_WEATHER를 로깅 | `store_id` → STORES<br/>`weather_id` → DAILY_WEATHER | STORES 1 : N WEATHER_LOG | `UNIQUE(store_id, weather_id)`<br/>`INDEX(store_id, created_at)` |
| **STORE_WAITINGS** | STORES가 WAITING_LISTS를 가짐 | `store_id` → STORES<br/>`waiting_id` → WAITING_LISTS | STORES 1 : N WAITINGS | `UNIQUE(waiting_id)` *(대기 1건은 한 매장에만)*<br/>`INDEX(store_id, created_at)` |
| **STORE_RESERVATIONS** | STORES가 RESERVATIONS를 가짐 | `store_id` → STORES<br/>`reservation_id` → RESERVATIONS | STORES 1 : N RESERVATIONS | `UNIQUE(reservation_id)` *(예약 1건은 한 매장에만)*<br/>`INDEX(store_id, reserve_date)` *(조회 최적화)* |
| **MENU_COST_HISTORY** | MENUS의 원가 이력 | `menu_id` → MENUS | MENUS 1 : N COST_HISTORY | `INDEX(menu_id, created_at)`<br/>`INDEX(menu_id, effective_date)` |
| **OPTION_COST_HISTORY** | OPTIONS의 원가 이력 | `option_id` → OPTIONS | OPTIONS 1 : N COST_HISTORY | `INDEX(option_id, created_at)`<br/>`INDEX(option_id, effective_date)` |

---

## 2) Associative Entity Tables (N:M 해소) — FK 매핑

> 표 읽는 법
> - **연관 엔티티(Associative Entity)** = 오직 **N:M 관계 해소**용
> - 기본 추천 제약: `UNIQUE(좌FK, 우FK)`

| 연관 테이블 | 해소하는 N:M 관계 | FK 컬럼 → 참조(부모) | 카디널리티(개념) | 무결성/제약 추천 |
|---|---|---|---|---|
| **MENU_OPTION_MAPPINGS** | MENUS ↔ OPTION_GROUPS | `menu_id` → MENUS<br/>`option_group_id` → OPTION_GROUPS | MENUS N : M OPTION_GROUPS | `UNIQUE(menu_id, option_group_id)`<br/>`INDEX(menu_id)` / `INDEX(option_group_id)` |
| **ORDER_DETAILS** | STORE_ORDERS ↔ MENUS | `store_order_id` → STORE_ORDERS<br/>`menu_id` → MENUS | ORDERS 1 : N DETAILS, MENUS 1 : N DETAILS | `INDEX(store_order_id)`<br/>`INDEX(menu_id)` |
| **ORDER_DETAIL_OPTIONS** | ORDER_DETAILS ↔ OPTIONS | `order_detail_id` → ORDER_DETAILS<br/>`option_id` → OPTIONS | DETAILS N : M OPTIONS *(선택 조합)* | `INDEX(order_detail_id)`<br/>`INDEX(option_id)` |
| **STAFF_CALL_LOGS** | STORE_TABLES ↔ STAFF_CALL_ITEMS | `store_table_id` → STORE_TABLES<br/>`staff_call_item_id` → STAFF_CALL_ITEMS | TABLES N : M CALL_ITEMS | `INDEX(store_table_id, created_at)`<br/>`INDEX(staff_call_item_id)` |

---

## 3) “엔티티 내부 FK” 정책 메모 (중요)

본 설계는 Chen 정합을 위해 **소속/정의/로깅** 같은 관계를 “관계 테이블”로 내리는 것을 우선한다.
다만 아래는 **엔티티 내부 FK로 두어도 무방한 영역**이며, 현재 07에서는 “개념 연결”로만 기술되어 있을 수 있다.

| 영역 | 현재(개념 연결) | 엔티티 FK로 둘 경우 | 관계 테이블로 내릴 경우 |
|---|---|---|---|
| MENU_CATEGORIES ↔ MENUS | 05에서 `HAS_MENUS`로 표기 | MENUS에 `menu_category_id` | 별도 `CATEGORY_MENUS` 같은 관계 테이블 필요(비추천) |
| OPTION_GROUPS ↔ OPTIONS | 05에서 `HAS_OPTIONS`로 표기 | OPTIONS에 `option_group_id` | 별도 `GROUP_OPTIONS` 관계 테이블 필요(비추천) |
| STORES ↔ STORE_ORDERS | 05에서 개념 연결 | STORE_ORDERS에 `store_id` | `STORE_ORDERS_OF_STORE` 같은 관계 테이블(일관성 ↑, 테이블 수 ↑) |
| STORE_ORDERS ↔ PAYMENTS | 05에서 개념 연결 | PAYMENTS에 `store_order_id` | 관계 테이블(일관성 ↑, 테이블 수 ↑) |
| STORE_ORDERS ↔ KDS_TICKETS | 05에서 개념 연결 | KDS_TICKETS에 `store_order_id` | 관계 테이블(일관성 ↑, 테이블 수 ↑) |

> 위 5개는 **팀 내부 정책 선택지**다.
> - “관계는 전부 테이블로”를 끝까지 밀면: 관계 테이블 추가가 필요
> - “도메인 핵심 관계는 엔티티 FK로”를 허용하면: 테이블 수를 줄이면서도 설명 가능

---

## 4) ERD/요약본 작성용 최소 체크리스트

- [ ] 관계 테이블마다 **좌/우 FK가 정확히 어떤 엔티티를 참조하는지** 1줄로 설명 가능
- [ ] `UNIQUE(단일 FK)` 또는 `UNIQUE(복합 FK)`로 **카디널리티를 의도대로 강제**했는지 확인
- [ ] 대기열은 **테이블(STORE_TABLES)과 직접 FK 연결 금지**
- [ ] 예약은 **STORE_RESERVATIONS로 매장 소속이 보장**

---

> 삽입 위치 추천: 07 하단의 TODO 섹션 대신, 본 부록 전체를 붙여 넣기