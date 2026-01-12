# [상세] 비즈니스 로직 및 워크플로우 명세서 (v4.0)

> - **문서 파일명:** 04_business_logic_workflow_detail.md. 
> - **버전:** v4.0 (Full Integration: 모든 다이어그램 및 정밀 로직 포함). 
> - **참조 문서:** 03_full_screen_definition.md (v3.1), 07_database_schema_spec.md (v4.0). 
> - **문서 목적:** 카레 전문점의 유입부터 정산까지 전 과정의 상세 동작 및 데이터 흐름 정의.  

---

## 1. 시스템 진입 및 모드 전환 (System Entry & Mode)

앱 실행 시의 인증과 **날씨 수집 방식 B**, 그리고 운영 모드 전환 로직입니다.

### 1.1 워크플로우 (Flowchart)

```mermaid
flowchart TD
    %% 스타일 정의
    classDef startend fill:#2d2d2d,stroke:#2d2d2d,stroke-width:2px,color:#fff,rx:10,ry:10;
    classDef decision fill:#fff,stroke:#333,stroke-width:1px,shape:diamond;

    Start([앱 실행]):::startend --> CheckLogin{"로그인 여부<br/>(Token Check)"}:::decision
    
    CheckLogin -- No --> LoginView[A-02: 로그인 화면]
    CheckLogin -- Yes --> FetchWeather{"오늘 날씨<br/>DB 존재 여부"}:::decision

    LoginView --> LoginProc[ID/PW 인증] --> FetchWeather
    
    FetchWeather -- "No (당일 최초)" --> APIWeather[OpenWeatherMap API 호출] --> SaveWeather[DAILY_WEATHER 저장] --> OwnerMain[O-01: 점주 대시보드]
    FetchWeather -- Yes --> OwnerMain
    FetchWeather -- API Fail --> LogFail[Null 허용] --> OwnerMain

    OwnerMain --> ModeSelect{"운영 모드 선택"}:::decision
    ModeSelect -- "테이블 주문" --> T_01[T-01: 주문판 모드]
    ModeSelect -- "대기 등록" --> W_01[W-01: 대기 등록 모드]
    ModeSelect -- "대기 현황판" --> W_02[W-02: 현황판 모드]
    ModeSelect -- "주방 KDS" --> K_01[K-01: KDS 모드]
```

---

## 2. 대기열 및 호출 프로세스 (Waiting & Call)

입구 접수부터 매장 내 현황판 호출까지의 실시간 연동 흐름입니다.

### 2.1 대기열 시퀀스 (Sequence Diagram)

```mermaid
sequenceDiagram
    participant Guest as 🙋‍♂️ 고객 (W-01)
    participant Server as ☁️ 서버 (DB/MQTT)
    participant Owner as 🧑‍🍳 점주 (O-07)
    participant Board as 📺 현황판 (W-02)

    Guest->>Server: 대기 등록 (성함, 연락처, 인원)
    Server->>Server: WAITING_LISTS 생성 (status: WAITING)
    Server-->>Guest: 대기번호 및 예상시간 발권
    Server->>Owner: [MQTT] 실시간 대기 명단 업데이트 전파

    Note over Owner: 테이블 공석 확인
    Owner->>Server: 15번 고객 [호출] 클릭
    Server->>Server: 상태 변경 (status: CALLED)
    Server->>Board: [MQTT] 호출 이벤트 전파 (번호: 15)
    Board->>Board: 번호 강조(Blink) 및 안내음(TTS) 발생

    Owner->>Server: 고객 입장 확인
    Server->>Server: 상태 변경 (status: ENTERED) 및 테이블 매칭
```

---

## 3. 주문, 결제 및 KDS 처리 (Order, Pay & KDS)

카레 옵션 검증, **결제 스냅샷(판매가/원가)** 저장 및 주방 전송 흐름입니다.

### 3.1 주문 및 결제 시퀀스 (Sequence Diagram)

```mermaid
sequenceDiagram
    participant Table as 📱 테이블 (T-01~03)
    participant PG as 💳 토스페이먼츠
    participant Server as ☁️ 서버 (API/DB)
    participant KDS as 🧑‍🍳 주방 (K-01)

    Table->>Table: 메뉴 선택 및 맵기(필수) 옵션 검증
    Table->>PG: 결제 요청
    PG-->>Table: 승인 완료 (paymentKey 수신)
    
    Table->>Server: 결제 승인 결과 및 주문 데이터 전송
    
    rect rgb(240, 240, 240)
    Note over Server: [트랜잭션 시작]
    Server->>Server: PAYMENTS 테이블 기록 (승인 정보)
    Server->>Server: STORE_ORDERS 생성 (weather_id 연결)
    Server->>Server: ORDER_DETAILS 생성 (판매가/원가 스냅샷 저장)
    Server->>Server: ORDER_DETAIL_OPTIONS 생성 (추가금/원가 스냅샷 저장)
    Note over Server: [트랜잭션 완료]
    end

    Server->>KDS: [MQTT] 신규 주문 티켓 전파 (메뉴+맵기+토핑)
    KDS->>KDS: [접수] 클릭 -> 조리 시작
    KDS->>Server: cook_status 업데이트 (COOKING)
    Server->>Table: [MQTT] 조리 현황 업데이트 (조리중 표시)
```

---

## 4. 상세 비즈니스 로직 규격

| 구분 | 항목 | 상세 내용 및 조건 |
| :--- | :--- | :--- |
| **날씨 연동** | 수집 데이터 | OpenWeatherMap의 `weather_condition_id`와 `icon_code`만 저장하여 통계 효율성 확보. |
| **수익 분석** | 원가 스냅샷 | 메뉴/옵션의 마스터 가격이 변해도 과거 순이익 계산에 영향이 없도록 주문 상세 테이블에 `cost_snapshot` 필수 저장. |
| **대기 관리** | 예상 시간 | `(WAITING 상태 팀 수 / 총 테이블 수) * avg_eating_time`으로 자동 산출. |
| **직원 호출** | 호출 로직 | 테이블별 고유 ID와 호출 항목(`call_item_id`)을 MQTT 메시지에 담아 주방/점주 앱에 실시간 팝업 노출. |

---

## 5. 정산 및 통계 계산

- **당일 총 매출** = `SUM(STORE_ORDERS.total_price)`
- **당일 총 순이익** = `총 매출` - `(SUM(ORDER_DETAILS.cost_snapshot) + SUM(ORDER_DETAIL_OPTIONS.cost_snapshot))`
- **날씨 통계** = `DAILY_WEATHER`와 `STORE_ORDERS`를 `weather_id`로 조인하여 날씨군별 판매 랭킹 집계.

---

## 6. 예외 및 에러 처리

| 상황 | 에러 코드 | 처리 로직 |
| :--- | :--- | :--- |
| **결제 승인 후 서버 통신 장애** | `PAY_SYNC_ERR` | `store_order_uuid`를 대조하여 PG 승인은 되었으나 주문서가 없는 건을 대조하여 복구. |
| **주문 도중 품절 발생** | `STOCK_OUT` | 결제창 진입 전 최종 재고 체크 수행 후 에러 메시지 노출. |
| **날씨 API 장애** | `WEATHER_FAIL` | 에러 무시 후 `weather_id`를 Null로 처리하여 주문 서비스는 정상 유지. |
