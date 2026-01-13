# DB 테이블 스펙표 (개념 ERD 기준 · 확정본 v07)

> 본 문서는 **개념적 ERD 기준**에서 도출된 모든 구성요소를 정리한 **단일 기준 문서**이다.
> - 물리 DB(FK, 인덱스, 제약조건)는 본 문서를 기준으로 **파생 설계**한다.
> - 이미지 ERD, 플로우차트, 화면 설계는 본 문서와 **정합성 유지**를 전제로 한다.

---

## 0. 전체 구성요소 요약 (총 26개)

- **ENTITY**: 9
- **RELATIONSHIP**: 13 (개념 관계 / 다이아몬드)
- **ASSOCIATIVE ENTITY**: 4 (N:M 해소용 연관 엔티티)

상태값 정책:
- `cook_status`, `ticket_status` 는 **문자열(varchar)** 로 저장

---

## 1. ENTITY (9)

### 1. members
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| member_id | bigint | PK |
| login_id | varchar | 로그인 ID |
| password | varchar | 비밀번호 |
| owner_name | varchar | 대표자명 |
| business_number | varchar | 사업자번호 |
| access_token | varchar | 인증 토큰 |
| last_login_at | datetime | 마지막 로그인 |
| created_at | datetime | 생성 시각 |

### 2. stores
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| store_id | bigint | PK |
| name | varchar | 매장명 |
| address | varchar | 주소 |
| avg_eating_time | int | 평균 식사 시간(분) |
| is_open | boolean | 영업 여부 |
| total_table_count | int | 테이블 수 |
| created_at | datetime | 생성 시각 |

### 3. store_tables
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| store_table_id | bigint | PK |
| table_number | int | 테이블 번호 |
| auth_code | varchar | 기기 인증 코드 |
| status | varchar | 테이블 상태 |
| capacity | int | 수용 인원 |
| created_at | datetime | 생성 시각 |

### 4. store_orders
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| store_order_id | bigint | PK |
| store_order_uuid | uuid | 주문 UUID |
| total_price | int | 총 주문 금액 |
| created_at | datetime | 주문 시각 |

### 5. menus
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| menu_id | bigint | PK |
| name | varchar | 메뉴명 |
| price | int | 판매가 |
| description | text | 설명 |
| image_url | varchar | 이미지 |
| is_soldout | boolean | 품절 여부 |
| is_hidden | boolean | 노출 여부 |
| created_at | datetime | 생성 시각 |

### 6. option_groups
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| option_group_id | bigint | PK |
| name | varchar | 그룹명 |
| is_exclusive | boolean | 단일 선택 여부 |
| min_select | int | 최소 선택 |
| max_select | int | 최대 선택 |
| created_at | datetime | 생성 시각 |

### 7. options
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| option_id | bigint | PK |
| name | varchar | 옵션명 |
| extra_price | int | 추가 금액 |
| cost | int | 원가 |
| created_at | datetime | 생성 시각 |

### 8. staff_call_items
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| staff_call_item_id | bigint | PK |
| name | varchar | 호출 항목명 |
| created_at | datetime | 생성 시각 |

### 9. daily_weather
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| weather_id | bigint | PK |
| weather_condition_id | varchar | 날씨 코드 |
| icon_code | varchar | 아이콘 코드 |
| target_date | date | 기준 날짜 |
| created_at | datetime | 수집 시각 |

---

## 2. ASSOCIATIVE ENTITY (4)

### 10. order_details
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| order_detail_id | bigint | PK |
| store_order_id | bigint | 주문 FK(개념) |
| menu_id | bigint | 메뉴 FK(개념) |
| quantity | int | 수량 |
| price_snapshot | int | 가격 스냅샷 |
| cost_snapshot | int | 원가 스냅샷 |
| cook_status | varchar | 조리 상태 |
| created_at | datetime | 생성 시각 |

### 11. order_detail_options
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| order_detail_option_id | bigint | PK |
| order_detail_id | bigint | 주문상세 FK |
| option_id | bigint | 옵션 FK |
| price_snapshot | int | 옵션가 스냅샷 |
| cost_snapshot | int | 옵션 원가 |
| created_at | datetime | 생성 시각 |

### 12. menu_option_mappings
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| mapping_id | bigint | PK |
| menu_id | bigint | 메뉴 FK |
| option_group_id | bigint | 옵션그룹 FK |
| created_at | datetime | 생성 시각 |

### 13. staff_call_logs
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| staff_call_id | bigint | PK |
| store_table_id | bigint | 테이블 FK |
| staff_call_item_id | bigint | 호출 항목 FK |
| is_completed | boolean | 처리 여부 |
| created_at | datetime | 생성 시각 |

---

## 3. RELATIONSHIP (13) 상세 스펙

> 요구사항 반영: RELATIONSHIP도 **PK/FK/속성**을 명시한다.  
> 본 섹션의 테이블들은 “개념 ERD의 관계(다이아몬드)”를 **저장 가능한 형태로 구현**한 스펙이다.  
> 공통 규칙: 모든 RELATIONSHIP 테이블은 `created_at`을 가진다.

### 3-1. own_stores
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| own_store_id | bigint | PK |
| member_id | bigint | FK → members.member_id |
| store_id | bigint | FK → stores.store_id |
| created_at | datetime | 생성 시각 |

### 3-2. has_tables
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| has_table_id | bigint | PK |
| store_id | bigint | FK → stores.store_id |
| store_table_id | bigint | FK → store_tables.store_table_id |
| created_at | datetime | 생성 시각 |

### 3-3. waiting_lists
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| waiting_id | bigint | PK |
| store_id | bigint | FK → stores.store_id |
| customer_name | varchar | 고객명 |
| customer_phone | varchar | 전화번호 |
| guest_count | int | 인원 수 |
| waiting_number | int | 대기 번호 |
| status | varchar | 대기 상태 |
| created_at | datetime | 생성 시각 |

### 3-4. reservation
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| reservation_id | bigint | PK |
| store_id | bigint | FK → stores.store_id |
| store_table_id | bigint | FK → store_tables.store_table_id |
| customer_name | varchar | 고객명 |
| customer_phone | varchar | 전화번호 |
| guest_count | int | 인원 수 |
| reserve_date | date | 예약일 |
| reserve_time | time | 예약 시간 |
| status | varchar | 예약 상태 |
| created_at | datetime | 생성 시각 |

### 3-5. menu_categories
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| menu_category_id | bigint | PK |
| store_id | bigint | FK → stores.store_id |
| name | varchar | 카테고리명 |
| sort_order | int | 정렬 순서 |
| created_at | datetime | 생성 시각 |

### 3-6. define_option_groups
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| define_option_group_id | bigint | PK |
| store_id | bigint | FK → stores.store_id |
| option_group_id | bigint | FK → option_groups.option_group_id |
| created_at | datetime | 생성 시각 |

### 3-7. has_options
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| has_option_id | bigint | PK |
| option_group_id | bigint | FK → option_groups.option_group_id |
| option_id | bigint | FK → options.option_id |
| created_at | datetime | 생성 시각 |

### 3-8. has_store_orders
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| has_store_order_id | bigint | PK |
| store_id | bigint | FK → stores.store_id |
| store_order_id | bigint | FK → store_orders.store_order_id |
| created_at | datetime | 생성 시각 |

### 3-9. pay
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| pay_id | bigint | PK |
| store_order_id | bigint | FK → store_orders.store_order_id |
| payment_key | varchar | 결제 키(식별자) |
| method | varchar | 결제 수단 |
| total_amount | int | 결제 금액 |
| status | varchar | 결제 상태 |
| approved_at | datetime | 승인 시각 |
| created_at | datetime | 생성 시각 |

### 3-10. kds_tickets
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| kds_ticket_id | bigint | PK |
| store_order_id | bigint | FK → store_orders.store_order_id |
| ticket_status | varchar | 티켓 상태(문자열) |
| printed_at | datetime | 출력/전송 시각 |
| created_at | datetime | 생성 시각 |

### 3-11. store_daily_weather
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| store_weather_id | bigint | PK |
| store_id | bigint | FK → stores.store_id |
| weather_id | bigint | FK → daily_weather.weather_id |
| created_at | datetime | 생성 시각 |

### 3-12. menu_cost_history
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| menu_cost_id | bigint | PK |
| menu_id | bigint | FK → menus.menu_id |
| cost_amount | int | 원가 |
| effective_date | date | 적용일 |
| created_at | datetime | 생성 시각 |

### 3-13. option_cost_history
| 컬럼 | 타입 | 설명 |
| --- | --- | --- |
| option_cost_id | bigint | PK |
| option_id | bigint | FK → options.option_id |
| cost_amount | int | 원가 |
| effective_date | date | 적용일 |
| created_at | datetime | 생성 시각 |

---

## 4. 확정 규칙 요약

| ID | 규칙 |
| --- | --- |
| R1 | `store_orders`는 `menus`와 직접 연결하지 않는다 |
| R2 | 주문-메뉴 연결은 `order_details`로만 표현한다 |
| R3 | 상태값은 문자열로 관리한다 |
| R4 | 본 문서는 개념 ERD 기준 최상위 문서이다 |

