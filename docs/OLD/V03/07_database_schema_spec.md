
# [설계] 데이터베이스 상세 명세서 (v4.0)

> - **문서 번호:** 07_database_schema_spec.md
> - **작성 일자:** 2026.01.12
> - **버전:** v4.0 (Full Integration: Curry + Waiting + Weather + Cost)
> - **변경 사항:** 
>   1. 기존 v3.8의 모든 테이블(PAYMENTS, STAFF_CALL, RESERVATIONS 등) 복구.
>   2. 신규 기능(대기열, 날씨 정보) 테이블 2종 추가.
>   3. 정산 및 통계를 위한 컬럼(원가, 날씨 ID) 모든 연관 테이블에 추가 완료.

---

## 1. 계정 및 매장 (Core Domain)

### 1.1 MEMBERS (사용자/점주)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **member_id** | BigInt | PK | 사용자 고유 ID | Auto Increment |
| login_id | Varchar(50) | NO | 로그인 아이디 | Unique |
| password | Varchar(255) | NO | 비밀번호 | BCrypt |
| owner_name | Varchar(20) | YES | 점주 성명 | - |
| business_number | Varchar(20) | YES | 사업자 등록번호 | - |
| **access_token** | Varchar(64) | YES | 자동로그인용 토큰 | UUID v4 |
| last_login_at | Timestamp | YES | 마지막 접속 일시 | 날씨 수집 판단 기준 |
| created_at | Timestamp | NO | 가입 일시 | - |

### 1.2 STORES (매장)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_id** | BigInt | PK | 매장 고유 ID | - |
| member_id | BigInt | FK | 소유 점주 ID | MEMBERS 참조 |
| name | Varchar(50) | NO | 매장 상호명 | - |
| **avg_eating_time** | Int | NO | 평균 식사 시간 | 대기 계산용 (분 단위) |
| is_open | Boolean | NO | 영업 상태 | - |
| total_table_count | Int | NO | 총 보유 테이블 수 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

### 1.3 DAILY_WEATHER (일일 날씨 정보 - 신규)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **weather_id** | BigInt | PK | 날씨 로그 ID | - |
| store_id | BigInt | FK | 매장 ID | STORES 참조 |
| weather_condition_id | Varchar(10) | NO | OWM 날씨 상태 코드 | 예: 800(맑음) |
| icon_code | Varchar(10) | NO | OWM 아이콘 코드 | 예: 01d |
| target_date | Date | NO | 날씨 적용 날짜 | 2026-01-12 |
| created_at | Timestamp | NO | 수집 일시 | - |

---

## 2. 매장 운영 및 대기열 (Operations & Waiting)

### 2.1 STORE_TABLES (테이블 기기)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_table_id** | BigInt | PK | 테이블 고유 ID | - |
| store_id | BigInt | FK | 소속 매장 ID | - |
| table_number | Int | NO | 테이블 번호 | 1, 2, 3... |
| auth_code | Varchar(10) | NO | 기기 인증 PIN | 복귀용 암호 |
| status | Varchar(20) | NO | 운영 상태 | AVAILABLE, BUSY 등 |
| capacity | Int | NO | 수용 인원 | 예약 시 체크 |
| created_at | Timestamp | NO | 등록 일시 | - |

### 2.2 WAITING_LISTS (대기열 관리 - 신규)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **waiting_id** | BigInt | PK | 대기 고유 ID | - |
| store_id | BigInt | FK | 매장 ID | - |
| waiting_number | Int | NO | 당일 대기 번호 | 1번부터 순차 증가 |
| customer_name | Varchar(20) | NO | 고객 성함 | - |
| customer_phone | Varchar(20) | NO | 연락처 | - |
| guest_count | Int | NO | 방문 인원 수 | - |
| status | Varchar(20) | NO | 진행 상태 | WAITING, CALLED, ENTERED |
| created_at | Timestamp | NO | 접수 시각 | - |

---

## 3. 상품 구성 및 원가 (Product & Cost)

### 3.1 MENU_CATEGORIES (메뉴 카테고리)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_category_id** | BigInt | PK | 카테고리 ID | - |
| store_id | BigInt | FK | 소속 매장 ID | - |
| name | Varchar(30) | NO | 카테고리명 | 예: 메인 카레 |
| sort_order | Int | NO | 정렬 순서 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

### 3.2 MENUS (메뉴)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **menu_id** | BigInt | PK | 메뉴 ID | - |
| menu_category_id | BigInt | FK | 카테고리 ID | - |
| name | Varchar(50) | NO | 메뉴명 | - |
| price | Int | NO | 판매가 | 고객 지불가 |
| **cost** | Int | NO | **재료 원가** | 순이익 계산용 |
| description | Text | YES | 메뉴 설명 | - |
| image_url | Varchar(255) | YES | 이미지 URL | - |
| is_soldout | Boolean | NO | 품절 여부 | - |
| is_hidden | Boolean | NO | 숨김 여부 | - |
| created_at | Timestamp | NO | 등록 일시 | - |

### 3.3 OPTION_GROUPS (옵션 그룹)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **option_group_id** | BigInt | PK | 옵션 그룹 ID | - |
| store_id | BigInt | FK | 소속 매장 ID | - |
| name | Varchar(30) | NO | 그룹명 | 예: 맵기 조절 |
| is_exclusive | Boolean | NO | 선택 방식 | True(라디오), False(체크) |
| min_select | Int | NO | 최소 선택 수 | - |
| max_select | Int | NO | 최대 선택 수 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

### 3.4 OPTIONS (옵션 상세)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **option_id** | BigInt | PK | 옵션 ID | - |
| option_group_id | BigInt | FK | 소속 그룹 ID | - |
| name | Varchar(30) | NO | 옵션명 | 예: 2단계 매운맛 |
| extra_price | Int | NO | 추가 금액 | - |
| **cost** | Int | NO | **옵션 원가** | 순이익 계산 반영 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 3.5 MENU_OPTION_MAPPINGS (메뉴-옵션 연결)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **mapping_id** | BigInt | PK | 매핑 ID | - |
| menu_id | BigInt | FK | 메뉴 ID | - |
| option_group_id | BigInt | FK | 옵션 그룹 ID | - |
| created_at | Timestamp | NO | 매핑 일시 | - |

---

## 4. 주문 및 결제 (Transaction Domain)

### 4.1 STORE_ORDERS (주문 헤더)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **store_order_id** | BigInt | PK | 주문 고유 ID | - |
| store_order_uuid | Varchar(64) | NO | 주문 고유 UUID | Toss 연동용 |
| store_id | BigInt | FK | 매장 ID | - |
| store_table_id | BigInt | FK | 테이블 ID | - |
| **weather_id** | BigInt | FK | **주문 시점 날씨** | DAILY_WEATHER 참조 |
| total_price | Int | NO | 주문 총 금액 | - |
| created_at | Timestamp | NO | 주문 생성 일시 | - |

### 4.2 PAYMENTS (결제 정보)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **payment_id** | BigInt | PK | 결제 고유 ID | - |
| store_order_id | BigInt | FK | 주문 ID | STORE_ORDERS 참조 |
| payment_key | Varchar(100) | NO | Toss Payment Key | 승인 식별자 |
| method | Varchar(20) | NO | 결제 수단 | CARD, EASY_PAY 등 |
| status | Varchar(20) | NO | 결제 상태 | DONE, CANCELED |
| total_amount | Int | NO | 승인 금액 | - |
| approved_at | Timestamp | YES | 승인 일시 | - |
| created_at | Timestamp | NO | 생성 일시 | - |

### 4.3 ORDER_DETAILS (주문 상세)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_detail_id** | BigInt | PK | 상세 항목 ID | - |
| store_order_id | BigInt | FK | 주문 ID | - |
| menu_id | BigInt | FK | 메뉴 ID | - |
| quantity | Int | NO | 수량 | - |
| price_snapshot | Int | NO | 주문 시점 판매가 | - |
| **cost_snapshot** | Int | NO | **주문 시점 원가** | 수익 계산 기준 |
| cook_status | Varchar(20) | NO | 조리 상태 | PENDING, COOKING, DONE |
| created_at | Timestamp | NO | 생성 일시 | - |

### 4.4 ORDER_DETAIL_OPTIONS (주문 옵션 상세)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **order_detail_option_id** | BigInt | PK | 옵션 상세 ID | - |
| order_detail_id | BigInt | FK | 메뉴 상세 ID | - |
| option_id | BigInt | FK | 옵션 ID | - |
| price_snapshot | Int | NO | 주문 시점 옵션가 | - |
| **cost_snapshot** | Int | NO | **주문 시점 옵션 원가** | - |
| created_at | Timestamp | NO | 생성 일시 | - |

---

## 5. 서비스 및 예약 (Service & Reservation)

### 5.1 STAFF_CALL_ITEMS (호출 항목)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **staff_call_item_id** | BigInt | PK | 항목 ID | - |
| store_id | BigInt | FK | 매장 ID | - |
| name | Varchar(30) | NO | 항목명 | 예: 물, 깍두기 |
| created_at | Timestamp | NO | 생성 일시 | - |

### 5.2 STAFF_CALL_LOGS (호출 로그)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **staff_call_id** | BigInt | PK | 로그 ID | - |
| store_table_id | BigInt | FK | 테이블 ID | 호출 위치 |
| staff_call_item_id | BigInt | FK | 항목 ID | 호출 내용 |
| is_completed | Boolean | NO | 처리 여부 | - |
| created_at | Timestamp | NO | 호출 일시 | - |

### 5.3 RESERVATIONS (예약)
| 컬럼명 | 타입 | Null | 설명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **reservation_id** | BigInt | PK | 예약 ID | - |
| store_id | BigInt | FK | 매장 ID | - |
| store_table_id | BigInt | FK | 테이블 ID | 좌석 선배정 가능 |
| customer_name | Varchar(30) | NO | 예약자명 | - |
| customer_phone | Varchar(20) | NO | 연락처 | - |
| guest_count | Int | NO | 인원수 | - |
| reserve_date | Date | NO | 예약 날짜 | - |
| reserve_time | Time | NO | 예약 시간 | - |
| status | Varchar(20) | NO | 예약 상태 | CONFIRMED, CANCELED |
| created_at | Timestamp | NO | 생성 일시 | - |

---
