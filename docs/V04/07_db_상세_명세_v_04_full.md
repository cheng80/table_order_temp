# [설계] 데이터베이스 상세 명세서 (v4.0)

- **문서 번호:** 07_DB_상세_명세_V04
- **작성 일자:** 2026.01.13
- **버전:** v4.0 (Curry + Waiting + Weather + Cost)

> 목표: **이 문서(07)만으로 개념적 ERD(Conceptual ERD)를 작성**할 수 있어야 한다.

---

## ERD 타입 범례 (Conceptual ERD)

- **[Strong Entity]** : 독립적으로 존재하는 핵심 엔티티
- **[Weak Entity]** : 상위 엔티티에 종속되는 엔티티
- **[Associative Entity]** : N:M 관계를 해소하기 위한 연관 엔티티

---

## 0. 공통 명세 규칙

- 모든 테이블은 `created_at`(Timestamp)을 기본 포함한다.
- 상태 기반 운영을 위해 `status` 또는 이에 준하는 상태 컬럼을 둔다.
- 분석 목적의 스냅샷은 **주문 확정 시점에 고정 저장**한다.
- 대기열은 테이블과 **직접 연결하지 않는다**(느슨한 결합).

---

# 1. 개념적 ERD 작성용 요약 (07 단독 작성 핵심)

## 1.1 엔티티 타입 목록

### Strong Entity
- **MEMBERS**

### Weak Entity
- **STORES** (Parent: MEMBERS)
- **DAILY_WEATHER** (Parent: STORES)
- **STORE_TABLES** (Parent: STORES)
- **WAITING_LISTS** (Parent: STORES)

- **MENU_CATEGORIES** (Parent: STORES)
- **MENUS** (Parent: MENU_CATEGORIES)
- **OPTION_GROUPS** (Parent: STORES)
- **OPTIONS** (Parent: OPTION_GROUPS)

- **STORE_ORDERS** (Parent: STORES)
- **PAYMENTS** (Parent: STORE_ORDERS)

- **STAFF_CALL_ITEMS** (Parent: STORES)
- **RESERVATIONS** (Parent: STORES)

- **KDS_TICKETS** (Parent: STORE_ORDERS)
- **COST_SNAPSHOTS** (Parent: STORES)

### Associative Entity
- **MENU_OPTION_MAPPINGS** (MENUS ↔ OPTION_GROUPS)
- **ORDER_DETAILS** (STORE_ORDERS ↔ MENUS)
- **ORDER_DETAIL_OPTIONS** (ORDER_DETAILS ↔ OPTIONS)
- **STAFF_CALL_LOGS** (STORE_TABLES ↔ STAFF_CALL_ITEMS)

---

## 1.2 관계 정의 (카디널리티 · FK 방향)

표기: **A (1) ── (N) B** 는 **B가 A의 PK를 FK로 가짐**

### 계정/매장
- MEMBERS (1) ── (N) STORES

### 운영/날씨/대기
- STORES (1) ── (N) DAILY_WEATHER
- STORES (1) ── (N) STORE_TABLES
- STORES (1) ── (N) WAITING_LISTS

### 메뉴/옵션
- STORES (1) ── (N) MENU_CATEGORIES
- MENU_CATEGORIES (1) ── (N) MENUS
- STORES (1) ── (N) OPTION_GROUPS
- OPTION_GROUPS (1) ── (N) OPTIONS
- MENUS (N) ── (M) OPTION_GROUPS *(MENU_OPTION_MAPPINGS로 해소)*
- MENUS (1) ── (N) MENU_OPTION_MAPPINGS
- OPTION_GROUPS (1) ── (N) MENU_OPTION_MAPPINGS

### 주문/결제
- STORES (1) ── (N) STORE_ORDERS
- STORE_TABLES (1) ── (N) STORE_ORDERS
- DAILY_WEATHER (1) ── (N) STORE_ORDERS *(STORE_ORDERS.weather_id는 정책에 따라 Nullable 가능)*

- STORE_ORDERS (1) ── (N) ORDER_DETAILS
- MENUS (1) ── (N) ORDER_DETAILS

- ORDER_DETAILS (1) ── (N) ORDER_DETAIL_OPTIONS
- OPTIONS (1) ── (N) ORDER_DETAIL_OPTIONS

- STORE_ORDERS (1) ── (N) PAYMENTS *(정책에 따라 1:1로 제한 가능)*

### 호출/예약
- STORES (1) ── (N) STAFF_CALL_ITEMS
- STORE_TABLES (1) ── (N) STAFF_CALL_LOGS
- STAFF_CALL_ITEMS (1) ── (N) STAFF_CALL_LOGS

- STORES (1) ── (N) RESERVATIONS
- STORE_TABLES (1) ── (N) RESERVATIONS *(store_table_id는 정책에 따라 Nullable 가능)*

### KDS
- STORE_ORDERS (1) ── (N) KDS_TICKETS

### 원가 이력(실제 FK로 “붙이는” 구조)
- STORES (1) ── (N) COST_SNAPSHOTS
- MENUS (1) ── (N) COST_SNAPSHOTS *(menu_id Nullable)*
- OPTIONS (1) ── (N) COST_SNAPSHOTS *(option_id Nullable)*

---

## 1.3 핵심 제약(룰) 요약

- **[Waiting-Table 결합 금지]** WAITING_LISTS는 STORE_TABLES와 직접 FK로 연결하지 않는다.
- **[Waiting 중복 제한]** 활성 상태(예: WAITING/CALLED)에서는 같은 `customer_phone` 중복 등록을 제한할 수 있다.
- **[Weather Snapshot]** STORE_ORDERS는 주문 생성 시점의 `weather_id`를 참조(또는 Nullable)한다.
- **[Price/Cost Snapshot]** 결제 확정 시점에 `ORDER_DETAILS.cost_snapshot`, `ORDER_DETAIL_OPTIONS.cost_snapshot`을 고정 저장한다.
- **[COST_SNAPSHOTS XOR]** `menu_id` 또는 `option_id` 중 **정확히 하나만** 값이 있어야 한다.

---

# 2. 테이블 상세 명세 (All Tables)

> 형식: 컬럼 / 타입 / Null / 설명 / 비고

---

## 2.1 MEMBERS (사용자/점주)
- **ERD Type:** [Strong Entity]

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **member_id** | BigInt | PK | 사용자 고유 ID | Auto Increment |
| login_id | Varchar(50) | NO | 로그인 아이디 | Unique |
| password | Varchar(255) | NO | 비밀번호 | BCrypt |
| owner_name | Varchar(20) | YES | 점주 성명 | - |
| business_number | Varchar(20) | YES | 사업자 등록번호 | - |
| access_token | Varchar(64) | YES | 자동로그인 토큰 | UUID v4 |
| last_login_at | Timestamp | YES | 마지막 로그인 | 날씨 수집 판단 |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.2 STORES (매장)
- **ERD Type:** [Weak Entity] (Parent: MEMBERS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_id** | BigInt | PK | 매장 ID | - |
| member_id | BigInt | FK | 소유자 ID | MEMBERS |
| name | Varchar(50) | NO | 매장명 | - |
| avg_eating_time | Int | NO | 평균 식사시간(분) | 대기 산식 |
| is_open | Boolean | NO | 영업 여부 | - |
| total_table_count | Int | NO | 총 테이블 수 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.3 DAILY_WEATHER (일일 날씨)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **weather_id** | BigInt | PK | 날씨 로그 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES |
| weather_condition_id | Varchar(10) | NO | 날씨 코드 | OWM |
| icon_code | Varchar(10) | NO | 아이콘 코드 | OWM |
| target_date | Date | NO | 대상 날짜 | yyyy-mm-dd |
| created_at | Timestamp | NO | 수집 시각 | - |

---

## 2.4 STORE_TABLES (테이블)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_table_id** | BigInt | PK | 테이블 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES |
| table_number | Int | NO | 테이블 번호 | - |
| auth_code | Varchar(10) | NO | 기기 PIN | 보안 |
| status | Varchar(20) | NO | 상태 | AVAILABLE, BUSY |
| capacity | Int | NO | 수용 인원 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.5 WAITING_LISTS (대기열)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **waiting_id** | BigInt | PK | 대기 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES |
| waiting_number | Int | NO | 당일 대기번호 | 1부터 증가 |
| customer_name | Varchar(20) | NO | 고객명 | - |
| customer_phone | Varchar(20) | NO | 연락처 | 중복 제한 기준 |
| guest_count | Int | NO | 인원수 | - |
| status | Varchar(20) | NO | 상태 | WAITING/CALLED/ENTERED/NO_SHOW/CANCELED/CLOSED |
| created_at | Timestamp | NO | 등록 시각 | - |

---

## 2.6 MENU_CATEGORIES (메뉴 카테고리)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_category_id** | BigInt | PK | 카테고리 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES |
| name | Varchar(30) | NO | 카테고리명 | - |
| sort_order | Int | NO | 정렬 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.7 MENUS (메뉴)
- **ERD Type:** [Weak Entity] (Parent: MENU_CATEGORIES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_id** | BigInt | PK | 메뉴 ID | - |
| menu_category_id | BigInt | FK | 카테고리 ID | MENU_CATEGORIES |
| name | Varchar(50) | NO | 메뉴명 | - |
| price | Int | NO | 판매가 | - |
| cost | Int | NO | 현재 원가 | 스냅샷 별도 |
| description | Text | YES | 설명 | - |
| image_url | Varchar(255) | YES | 이미지 | - |
| is_soldout | Boolean | NO | 품절 | - |
| is_hidden | Boolean | NO | 숨김 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.8 OPTION_GROUPS (옵션 그룹)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **option_group_id** | BigInt | PK | 그룹 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES |
| name | Varchar(30) | NO | 그룹명 | 예: 맵기 |
| is_exclusive | Boolean | NO | 선택 방식 | 라디오/체크 |
| min_select | Int | NO | 최소 선택 | 필수 옵션 표현 |
| max_select | Int | NO | 최대 선택 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.9 OPTIONS (옵션)
- **ERD Type:** [Weak Entity] (Parent: OPTION_GROUPS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **option_id** | BigInt | PK | 옵션 ID | - |
| option_group_id | BigInt | FK | 그룹 ID | OPTION_GROUPS |
| name | Varchar(30) | NO | 옵션명 | - |
| extra_price | Int | NO | 추가금 | - |
| cost | Int | NO | 현재 원가 | 스냅샷 별도 |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.10 MENU_OPTION_MAPPINGS (메뉴-옵션그룹 매핑)
- **ERD Type:** [Associative Entity]

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **mapping_id** | BigInt | PK | 매핑 ID | - |
| menu_id | BigInt | FK | 메뉴 ID | MENUS |
| option_group_id | BigInt | FK | 옵션그룹 ID | OPTION_GROUPS |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.11 STORE_ORDERS (주문 헤더)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_order_id** | BigInt | PK | 주문 ID | - |
| store_order_uuid | Varchar(64) | NO | UUID | 결제 연동 |
| store_id | BigInt | FK | 매장 ID | STORES |
| store_table_id | BigInt | FK | 테이블 ID | STORE_TABLES |
| weather_id | BigInt | FK | 날씨 ID | DAILY_WEATHER *(Nullable 정책 가능)* |
| total_price | Int | NO | 총액 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.12 ORDER_DETAILS (주문 상세)
- **ERD Type:** [Associative Entity]

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_detail_id** | BigInt | PK | 상세 ID | - |
| store_order_id | BigInt | FK | 주문 ID | STORE_ORDERS |
| menu_id | BigInt | FK | 메뉴 ID | MENUS |
| quantity | Int | NO | 수량 | - |
| price_snapshot | Int | NO | 판매가 스냅샷 | 결제 확정 기준 |
| cost_snapshot | Int | NO | 원가 스냅샷 | 순이익 |
| cook_status | Varchar(20) | NO | 조리 상태 | PENDING/COOKING/DONE |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.13 ORDER_DETAIL_OPTIONS (주문 옵션 상세)
- **ERD Type:** [Associative Entity]

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_detail_option_id** | BigInt | PK | 옵션상세 ID | - |
| order_detail_id | BigInt | FK | 주문상세 ID | ORDER_DETAILS |
| option_id | BigInt | FK | 옵션 ID | OPTIONS |
| price_snapshot | Int | NO | 옵션가 스냅샷 | - |
| cost_snapshot | Int | NO | 옵션 원가 스냅샷 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.14 PAYMENTS (결제)
- **ERD Type:** [Weak Entity] (Parent: STORE_ORDERS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **payment_id** | BigInt | PK | 결제 ID | - |
| store_order_id | BigInt | FK | 주문 ID | STORE_ORDERS |
| payment_key | Varchar(100) | NO | 승인 키 | - |
| method | Varchar(20) | NO | 결제 수단 | - |
| status | Varchar(20) | NO | 결제 상태 | DONE/CANCELED |
| total_amount | Int | NO | 승인 금액 | - |
| approved_at | Timestamp | YES | 승인 시각 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.15 STAFF_CALL_ITEMS (호출 항목)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **staff_call_item_id** | BigInt | PK | 항목 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES |
| name | Varchar(30) | NO | 항목명 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.16 STAFF_CALL_LOGS (호출 로그)
- **ERD Type:** [Associative Entity]

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **staff_call_id** | BigInt | PK | 로그 ID | - |
| store_table_id | BigInt | FK | 테이블 ID | STORE_TABLES |
| staff_call_item_id | BigInt | FK | 항목 ID | STAFF_CALL_ITEMS |
| is_completed | Boolean | NO | 처리 여부 | - |
| created_at | Timestamp | NO | 호출 시각 | - |

---

## 2.17 RESERVATIONS (예약)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **reservation_id** | BigInt | PK | 예약 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES |
| store_table_id | BigInt | FK | 테이블 ID | STORE_TABLES *(Nullable 정책 가능)* |
| customer_name | Varchar(30) | NO | 예약자명 | - |
| customer_phone | Varchar(20) | NO | 연락처 | - |
| guest_count | Int | NO | 인원수 | - |
| reserve_date | Date | NO | 예약 날짜 | - |
| reserve_time | Time | NO | 예약 시간 | - |
| status | Varchar(20) | NO | 상태 | CONFIRMED/CANCELED |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 2.18 KDS_TICKETS (KDS 티켓)
- **ERD Type:** [Weak Entity] (Parent: STORE_ORDERS)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **kds_ticket_id** | BigInt | PK | 티켓 ID | - |
| store_order_id | BigInt | FK | 주문 ID | STORE_ORDERS |
| ticket_status | Varchar(20) | NO | 티켓 상태 | PENDING/DISPLAYED/DONE |
| printed_at | Timestamp | YES | 생성/표시 시각 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

> 구현에서는 `ORDER_DETAILS.cook_status`로도 조리 상태 추적이 가능하나,
> 티켓 단위 이력/재전송/확장성을 위해 KDS_TICKETS를 별도 엔티티로 유지한다.

---

## 2.19 COST_SNAPSHOTS (원가 변경 이력)
- **ERD Type:** [Weak Entity] (Parent: STORES)

| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **cost_snapshot_id** | BigInt | PK | 스냅샷 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES |
| menu_id | BigInt | YES | 메뉴 ID | MENUS (XOR) |
| option_id | BigInt | YES | 옵션 ID | OPTIONS (XOR) |
| cost_amount | Int | NO | 원가 | - |
| effective_date | Date | YES | 적용 기준일 | - |
| created_at | Timestamp | NO | 기록 시각 | - |

**XOR 규칙:** `menu_id` 또는 `option_id` 중 **정확히 하나만** 값이 있어야 한다.

---

# 3. ERD 정합 체크리스트

- [ ] 1장(개념 ERD 작성용 요약)만 보고 엔티티/관계를 그릴 수 있다.
- [ ] WAITING_LISTS는 STORE_TABLES와 직접 FK로 연결하지 않는다.
- [ ] STORE_ORDERS.weather_id는 정책에 따라 Nullable 가능(로그인 시점 날씨 수집 방식 반영).
- [ ] 결제 확정 시점에 price/cost 스냅샷이 ORDER_DETAILS/ORDER_DETAIL_OPTIONS에 고정된다.
- [ ] COST_SNAPSHOTS는 menu_id/option_id XOR 제약을 가진다.
- [ ] KDS_TICKETS는 STORE_ORDERS를 부모로 가진다.

