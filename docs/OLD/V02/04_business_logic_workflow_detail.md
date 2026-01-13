# [상세] 비즈니스 로직 및 워크플로우 명세서 (v2.2)

> - **문서 파일명:** 04_business_logic_workflow_detail.md
> - **작성 일자:** 2026.01.10
> - **버전:** v2.2 (KDS 시퀀스 다이어그램 및 상세 로직 통합 완료)
> - **참조 문서:** 03_full_screen_definition.md (화면), 05_final_integrated_erd.md (DB)
> - **문서 목적:** 개발자가 구현해야 할 시스템의 상세 동작 조건(Validation), 분기 처리(Branching), 데이터 흐름(Data Flow) 정의

---

## 1. 시스템 진입 및 모드 전환 (System Entry)

앱 실행 시 초기 진입 로직과, 점주 모드/테이블 모드 간의 전환 프로세스를 정의합니다.

### 1.1 워크플로우 (Flowchart)

```mermaid
---
config:
  layout: elk
---
flowchart TD
    %% 스타일 정의
    classDef startend fill:#2d2d2d,stroke:#2d2d2d,stroke-width:2px,color:#fff,rx:10,ry:10;
    classDef proc fill:#fff,stroke:#333,stroke-width:1px;
    classDef decision fill:#fff,stroke:#333,stroke-width:1px,shape:diamond;
    classDef display fill:#f4f4f4,stroke:#333,stroke-width:1px;

    %% 1. 앱 실행 및 인증
    Start([앱 실행]):::startend --> CheckLogin{"로그인 여부<br/>(Token Check)"}:::decision
    
    CheckLogin -- No --> LoginView["A-02: 로그인 화면"]:::display
    CheckLogin -- Yes (Auto) --> OwnerMain["O-01: 점주 대시보드"]:::display

    LoginView --> SignUpView["A-01: 회원가입"]:::display
    SignUpView -- 가입 완료 --> LoginView
    LoginView -- 로그인 성공 --> SaveToken["UUID 세션 저장"]:::proc
    SaveToken --> OwnerMain

    %% 2. 모드 선택
    OwnerMain --> ModeSelect{"모드 선택"}:::decision
    
    ModeSelect -- 메뉴/테이블 관리 --> ManageView["O-02: 메뉴 관리"]:::display
    ModeSelect -- KDS 모드 실행 --> KdsMain["K-01: 주방 KDS"]:::display
    
    ModeSelect -- 테이블 모드 실행 --> TableMain["T-01: 테이블 메인"]:::display

    %% 3. 관리자 복귀 (Hidden)
    TableMain --> HiddenTouch["관리자 히든 버튼<br/>(5회 터치)"]:::proc
    HiddenTouch --> AdminAuth["T-05: 관리자 인증"]:::display
    
    AdminAuth --> CheckPin{"PIN 번호 검사"}:::decision
    CheckPin -- 일치 --> OwnerMain
    CheckPin -- 불일치 --> AdminAuth
    
    %% 스타일 적용
    class LoginView,SignUpView,OwnerMain,ManageView,KdsMain,TableMain,AdminAuth display;
```

### 1.2 상세 처리 로직 (Logic Specs)

**1) 자동 로그인 (Auto Login)**
* **조건:** 앱 실행 시 `SecureStorage` (또는 `SharedPreferences`)에 `access_token` 존재 여부 확인.
* **성공:** 토큰 유효성 API 검증 통과 시 `O-01(점주 메인)`으로 즉시 이동 (Splash 생략 가능).
* **실패:** 토큰 없음 or 만료 시 `A-02(로그인 화면)` 출력 및 내부 저장소 초기화.

**2) 관리자 히든 버튼 (Admin Exit)**
* **목적:** 손님이 임의로 앱을 종료하거나 점주 화면으로 이탈하는 것을 방지.
* **Trigger:** 화면 로고 영역 5회 연속 터치 (또는 우측 상단 3초 롱프레스).
* **검증:** `TABLES.auth_code` 또는 점주 비밀번호와 일치하는지 로컬/서버 검증.

---

## 2. 손님 주문 및 결제 프로세스 (Order & Payment)

테이블 모드에서 손님의 메뉴 선택, 옵션 검증, PG 결제까지의 핵심 트랜잭션 흐름입니다.

### 2.1 워크플로우 (Flowchart)

```mermaid
---
config:
  layout: elk
---
flowchart TD
    %% 스타일 정의
    classDef startend fill:#2d2d2d,stroke:#2d2d2d,stroke-width:2px,color:#fff,rx:10,ry:10;
    classDef proc fill:#fff,stroke:#333,stroke-width:1px;
    classDef decision fill:#fff,stroke:#333,stroke-width:1px,shape:diamond;
    classDef display fill:#f4f4f4,stroke:#333,stroke-width:1px;

    %% 1. 메뉴 선택 및 검증
    TableMain["T-01: 메인 주문판"]:::display --> SelectMenu[메뉴 클릭]:::proc
    SelectMenu --> CheckStock{"품절 여부<br/>확인"}:::decision
    
    CheckStock -- 품절됨 --> ToastMsg@{ shape: doc, label: "알림: 품절된 메뉴입니다" }
    CheckStock -- 판매중 --> OptionPopup["T-02: 옵션 선택 팝업"]:::display
    
    OptionPopup --> SelectOption[옵션 선택 & 담기]:::proc
    SelectOption --> ValidateOption{"유효성 검사<br/>(필수옵션 체크)"}:::decision
    
    ValidateOption -- Fail --> OptionPopup
    ValidateOption -- Pass --> UpdateCart[장바구니 갱신]:::proc
    
    %% 2. 결제 프로세스
    UpdateCart --> ClickOrder[주문하기 버튼]:::proc
    ClickOrder --> PayMethod{"결제 방식 선택"}:::decision
    
    PayMethod -- 일괄 결제 --> PayAll[전체 금액 결제]:::proc
    PayMethod -- 개별 결제 --> PaySplit[체크한 메뉴만 결제]:::proc
    
    PayAll --> CallPG["PG사 결제창 호출"]:::display
    PaySplit --> CallPG
    
    CallPG --> CheckPG{"결제 결과"}:::decision
    
    CheckPG -- 실패/취소 --> OrderCheck["T-03: 주문 및 결제 확인"]:::display
    OrderCheck --> PayMethod
    
    CheckPG -- 성공 --> OrderComplete([주문 완료 & 서버 전송]):::startend
    
    %% 스타일 적용
    class TableMain,OptionPopup,CallPG,OrderCheck display;
```

### 2.2 상세 처리 로직 (Logic Specs)

**1) 품절 체크 (Stock Check)**
* **시점:** 메뉴 클릭 시점(1차), 주문하기 버튼 클릭 시점(2차).
* **동작:** 서버의 최신 상태와 동기화된 로컬 캐시 확인. 품절 시 Toast 알림 출력 후 진입 차단.

**2) 옵션 유효성 검사 (Option Validation)**
* **필수(Mandatory):** `min_select > 0`인 옵션 그룹에서 선택 개수가 부족하면 "담기" 버튼 비활성화.
* **최대(Limit):** `max_select` 개수를 초과하여 선택 시도 시 시각적 피드백(진동/알림) 후 선택 막음.

**3) PG 결제 연동 (Payment)**
* **Toss Payments:**
    * `order_uuid` 생성: `ORDERS` 테이블에 INSERT 전 미리 UUID 생성.
    * `successUrl`: 결제 성공 시 호출될 클라이언트 딥링크 또는 콜백 함수.
* **트랜잭션:** 결제 승인(Payment Key 수신)과 동시에 `ORDERS` 상태를 PAID로 업데이트하고 `ORDER_DETAILS` 생성.

---

## 3. 주방 KDS 주문 처리 (Real-time Order Processing)

주방(KDS) 화면과 서버 간의 API 호출 및 실시간 동기화(MQTT) 흐름입니다.

### 3.1 시퀀스 다이어그램 (Sequence Diagram)

```mermaid
sequenceDiagram
    participant Customer as 🙋‍♂️ 손님 (Table T-01)
    participant Server as ☁️ 서버 (API/DB)
    participant KDS as 🧑‍🍳 주방 (KDS K-01)

    Note over Customer, Server: 주문 발생 시점
    Customer->>Server: POST /orders (주문 데이터)
    Server->>Server: DB 저장 & 상태 'PENDING' 설정
    
    par 실시간 전파 (MQTT)
        Server->>KDS: Topic: store/{id}/orders (신규주문)
        Server-->>Customer: (주문 접수됨 알림)
    end

    Note over KDS: 화면에 주문 티켓 생성 (깜빡임 효과)
    
    KDS->>KDS: [접수] 버튼 클릭
    KDS->>Server: PATCH /orders/{id}/status (COOKING)
    
    par 상태 동기화
        Server->>Customer: Topic: store/{id}/table/{no}
        Note right of Customer: 주문내역 상태가<br/>'조리중'으로 변경됨
    end

    Note over KDS: 조리 완료 후
    KDS->>KDS: [완료] 버튼 클릭
    KDS->>Server: PATCH /orders/{id}/status (SERVED)
    
    par 서빙 알림
        Server->>Customer: "음식이 준비되었습니다!" 알림
        Note right of Customer: 주문내역 상태가<br/>'서빙완료'로 변경
    end
```

### 3.2 처리 단계 및 동기화

* **신규(Pending):** `ORDERS` 생성 직후 상태. KDS에서 알림음 발생.
* **조리중(Cooking):** 주방 직원이 [접수] 버튼 터치 시 변경.
* **완료(Done):** 조리 완료 후 [호출/완료] 버튼 터치 시 변경. 서빙 직원(또는 손님 태블릿)에게 알림 전송.
* **기술 스택:** WebSocket 또는 MQTT를 사용하여 테이블과 주방 간의 상태를 Delay < 500ms 이내로 동기화.

---

## 4. 예외 및 에러 처리 (Exception Handling)

| 상황 (Context) | 에러 코드 | 사용자 메시지 (UI) | 처리 로직 |
| :--- | :--- | :--- | :--- |
| **네트워크 끊김** | `NET_ERR` | "네트워크 연결이 불안정합니다. 잠시 후 다시 시도해주세요." | 요청 큐(Queue)에 저장 후 재연결 시 자동 재전송 (Retry Policy) |
| **결제 실패** | `PG_FAIL` | "카드 승인이 거절되었습니다. 잔액을 확인해주세요." | 결제창 닫고 장바구니 화면 유지 (재결제 유도) |
| **동시성 문제** | `STOCK_ERR` | "주문 도중 품절된 메뉴가 있습니다." | 품절된 메뉴만 장바구니에서 자동 삭제 후 알림 |
| **인증 만료** | `AUTH_EXP` | "로그인 세션이 만료되었습니다." | 로그인 화면(A-02)으로 강제 이동 및 토큰 삭제 |

---