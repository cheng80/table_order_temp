# [상세] 비즈니스 로직 및 워크플로우 명세서 (v2.0)

> **문서 번호:** 04_business_logic_workflow_detail.md
> **작성 일자:** 2025.01.10
> **개정 내용:** 실무 레벨의 예외 처리(Exception Handling), 데이터 검증(Validation), 시스템 피드백(UI Alert)을 포함한 상세 로직 정의.
> **표기법 범례:**
> * `(Start/End)`: 흐름의 시작과 끝
> * `[Process]`: 내부 연산, API 호출, DB 저장
> * `{Decision}`: 조건 분기 (Yes/No, 성공/실패)
> * `[/Input/Output/]`: 사용자의 입력 행위
> * `>Document]`: 사용자에게 보여지는 화면, 팝업, 알림(Toast)

---

## 1. 계정 인증 및 매장 초기화 (Account & Setup Flow)
앱 실행 시 자동 로그인부터, 신규 점주의 가입, 그리고 매장 영업 준비(메뉴 등록)까지의 과정입니다.

### 🔍 주요 체크 포인트
* **자동 로그인:** UUID 토큰이 만료되었거나 변조되었는지 API로 확인합니다.
* **유효성 검사:** 사업자 번호 형식, 비밀번호 복잡도, 필수 약관 동의 등을 클라이언트/서버 양쪽에서 검증합니다.
* **데이터 무결성:** 메뉴 등록 시 가격이 음수이거나 필수 옵션이 누락되었는지 확인합니다.

```mermaid
flowchart TD
    %% 스타일 정의 (Clean Grayscale)
    classDef startend fill:#333,stroke:#333,stroke-width:2px,color:#fff,rx:20,ry:20;
    classDef proc fill:#fff,stroke:#333,stroke-width:1px;
    classDef decision fill:#fff,stroke:#333,stroke-width:1px,shape:diamond;
    classDef input fill:#fff,stroke:#333,stroke-width:1px,shape:parallelogram;
    classDef display fill:#f4f4f4,stroke:#333,stroke-width:1px,shape:rect;

    %% 1. 앱 진입
    Start([앱 실행]):::startend --> CheckToken{"로컬 스토리지<br/>토큰 존재?"}:::decision
    
    CheckToken -- Yes --> ValidateToken{"API: 토큰 유효성<br/>& 만료 체크"}:::decision
    ValidateToken -- 유효 --> MainDashboard["점주 대시보드 진입"]:::proc
    
    CheckToken -- No --> LoginView
    ValidateToken -- 만료/실패 --> LoginView["로그인 화면 출력"]:::display

    %% 2. 로그인/가입 분기
    LoginView --> UserAction{"행동 선택"}:::decision
    
    %% [Scenario A] 회원가입
    UserAction -- 회원가입 --> TermsView["약관 동의 화면"]:::display
    TermsView --> CheckTerms{"필수 약관<br/>동의 완료?"}:::decision
    CheckTerms -- 미동의 --> AlertTerms[>"알림: 필수 약관에<br/>동의해야 합니다"]:::display
    AlertTerms --> TermsView
    
    CheckTerms -- 동의 --> InputInfo[/"정보 입력:<br/>ID, PW, 사업자번호"/]:::input
    InputInfo --> ValidateInfo{"1. 빈칸 체크<br/>2. PW 복잡도<br/>3. 사업자번호 형식"}:::decision
    
    ValidateInfo -- 부적합 --> AlertValid[>"알림: 입력 정보를<br/>확인해주세요"]:::display
    AlertValid --> InputInfo
    
    ValidateInfo -- 적합 --> ApiJoin["API: 회원가입 요청"]:::proc
    ApiJoin --> CheckDup{"ID 중복 여부<br/>(서버 리턴)"}:::decision
    
    CheckDup -- 중복됨 --> AlertDup[>"알림: 이미 사용 중인<br/>아이디입니다"]:::display
    AlertDup --> InputInfo
    
    CheckDup -- 가입성공 --> SuccessJoin[>"가입 완료 팝업"]:::display
    SuccessJoin --> LoginView

    %% [Scenario B] 로그인
    UserAction -- 로그인 --> InputLogin[/"ID / PW 입력"/]:::input
    InputLogin --> ApiLogin["API: 로그인 요청"]:::proc
    ApiLogin --> AuthCheck{"계정 일치 여부"}:::decision
    
    AuthCheck -- 불일치 --> AlertAuth[>"알림: 아이디 또는<br/>비밀번호 오류"]:::display
    AlertAuth --> InputLogin
    
    AuthCheck -- 일치 --> GenToken["UUID 토큰 생성 및<br/>DB/로컬 저장"]:::proc
    GenToken --> MainDashboard

    %% 3. 메뉴 등록 (초기 세팅)
    MainDashboard --> GoMenu[/"메뉴 관리 진입"/]:::input
    GoMenu --> MenuForm["메뉴 등록 폼"]:::display
    
    MenuForm --> InputMenuData[/"이미지, 이름, 가격,<br/>카테고리 입력"/]:::input
    InputMenuData --> ValidateMenu{"데이터 검증:<br/>가격 > 0<br/>이름 !Null"}:::decision
    
    ValidateMenu -- 오류 --> AlertMenu[>"알림: 필수 입력값을<br/>확인하세요"]:::display
    AlertMenu --> InputMenuData
    
    ValidateMenu -- 통과 --> SaveMenu["API: 메뉴 저장"]:::proc
    SaveMenu --> RefreshList[>"메뉴 리스트 갱신"]:::display
    RefreshList --> EndSetup([준비 완료]):::startend
```

---

## 2. 테이블 모드 전환 및 보안 설정 (Device Provisioning)
점주용 태블릿을 손님용 주문 기기(Kiosk)로 전환하는 과정입니다. 손님이 앱을 종료하지 못하도록 하는 보안 절차가 포함됩니다.

### 🔍 주요 체크 포인트
* **관리자 PIN:** 손님이 실수로 관리자 모드에 진입하지 못하도록 4자리 이상의 비밀번호를 강제합니다.
* **앱 고정(App Pinning):** 안드로이드/iOS의 '앱 고정' 기능을 활성화하거나 네비게이션 바를 숨겨 이탈을 방지합니다.
* **데이터 프리페칭(Prefetch):** 손님이 사용할 메뉴 데이터를 미리 서버에서 받아와 로컬 메모리에 캐싱합니다.

```mermaid
flowchart TD
    classDef startend fill:#333,stroke:#333,stroke-width:2px,color:#fff,rx:20,ry:20;
    classDef proc fill:#fff,stroke:#333,stroke-width:1px;
    classDef decision fill:#fff,stroke:#333,stroke-width:1px,shape:diamond;
    classDef input fill:#fff,stroke:#333,stroke-width:1px,shape:parallelogram;
    classDef display fill:#f4f4f4,stroke:#333,stroke-width:1px,shape:rect;

    Start([대시보드]):::startend --> ClickMode[/"'테이블 모드'<br/>버튼 터치"/]:::input
    ClickMode --> SetupPopup[>"설정 팝업 출력"]:::display
    
    SetupPopup --> InputTableNo[/"1. 테이블 번호 입력"/]:::input
    InputTableNo --> InputAdminPin[/"2. 관리자 PIN 설정<br/>(4자리 숫자)"/]:::input
    
    InputAdminPin --> ValidatePin{"PIN 형식 확인"}:::decision
    ValidatePin -- 미달 --> AlertPin[>"알림: 4자리 숫자로<br/>설정해주세요"]:::display
    AlertPin --> InputAdminPin
    
    ValidatePin -- 적합 --> ConfirmMsg[>"경고: 모드 전환 시<br/>앱이 고정됩니다"]:::display
    ConfirmMsg --> UserConfirm{"진행 확인"}:::decision
    
    UserConfirm -- 취소 --> Start
    UserConfirm -- 확인 --> LockSystem["시스템 UI 잠금<br/>(Immersive Mode)"]:::proc
    
    LockSystem --> ApiFetch["API: 전체 메뉴/옵션<br/>데이터 로드"]:::proc
    ApiFetch --> CheckLoad{"데이터 수신"}:::decision
    
    CheckLoad -- 실패 --> AlertNet[>"오류: 네트워크 확인<br/>재시도 버튼"]:::display
    AlertNet --> ApiFetch
    
    CheckLoad -- 성공 --> RenderUI["손님용 UI 렌더링"]:::proc
    RenderUI --> ConnectSocket["KDS 소켓 연결 대기"]:::proc
    ConnectSocket --> CustomerMode([손님 화면 대기]):::startend
```

---

## 3. 손님 주문 및 결제 트랜잭션 (Customer Transaction)
가장 중요한 수익 발생 구간입니다. 옵션 선택부터 PG사 결제, 그리고 서버의 최종 검증까지의 흐름입니다.

### 🔍 주요 체크 포인트
* **재고/품절 동시성:** 메뉴를 고르는 사이에 품절될 경우를 대비해 장바구니 담기 시점에 한 번 더 체크합니다.
* **장바구니 병합:** 이미 담긴 메뉴와 옵션이 완벽히 동일하면 항목을 추가하지 않고 수량만 늘립니다.
* **PG 결제 검증:** 클라이언트 위조를 방지하기 위해, 결제 완료 후 `PaymentKey`를 서버로 보내 실제 승인 요청을 수행합니다.

```mermaid
flowchart TD
    classDef startend fill:#333,stroke:#333,stroke-width:2px,color:#fff,rx:20,ry:20;
    classDef proc fill:#fff,stroke:#333,stroke-width:1px;
    classDef decision fill:#fff,stroke:#333,stroke-width:1px,shape:diamond;
    classDef input fill:#fff,stroke:#333,stroke-width:1px,shape:parallelogram;
    classDef display fill:#f4f4f4,stroke:#333,stroke-width:1px,shape:rect;

    Start([대기 화면]):::startend --> TouchItem[/"메뉴 선택"/]:::input
    
    %% 옵션 선택 로직
    TouchItem --> CheckStatus{"상태 체크:<br/>품절/숨김"}:::decision
    CheckStatus -- 불가 --> ToastFail[>"품절된 메뉴입니다"]:::display
    ToastFail --> Start
    
    CheckStatus -- 가능 --> OpenOption[>"옵션 선택 팝업"]:::display
    OpenOption --> SelectOpts[/"옵션 선택"/]:::input
    
    SelectOpts --> ValidOpts{"필수 옵션<br/>충족 여부"}:::decision
    ValidOpts -- 미충족 --> ToastOpt[>"필수 옵션을<br/>선택해주세요"]:::display
    ToastOpt --> SelectOpts
    
    ValidOpts -- 충족 --> CheckCart{"장바구니 중복<br/>(메뉴+옵션 동일)"}:::decision
    CheckCart -- Yes --> MergeCart["기존 항목 수량 +1"]:::proc
    CheckCart -- No --> NewCart["새 항목 추가"]:::proc
    
    MergeCart & NewCart --> UpdateCartUI[>"장바구니 UI 갱신"]:::display

    %% 결제 로직
    UpdateCartUI --> ClickOrder[/"'주문하기' 버튼"/]:::input
    ClickOrder --> SelectPayMethod[/"결제 수단 선택<br/>(카드/간편결제)"/]:::input
    
    SelectPayMethod --> InitToss["Toss Payments<br/>SDK 호출"]:::proc
    InitToss --> PGFlow{{"사용자 결제 수행"}}:::proc
    
    PGFlow -- 취소/잔액부족 --> AlertPayFail[>"결제 실패 알림<br/>(사유 표시)"]:::display
    AlertPayFail --> ClickOrder
    
    PGFlow -- 인증성공 --> ClientSuccess["PaymentKey 수신"]:::proc
    ClientSuccess --> ApiConfirm["API: 서버로<br/>최종 승인 요청"]:::proc
    
    ApiConfirm --> ServerValidate{"서버 검증<br/>(금액/재고)"}:::decision
    
    ServerValidate -- 불일치 --> AutoRefund["자동 환불 처리"]:::proc
    AutoRefund --> AlertSystemError[>"시스템 오류:<br/>결제가 취소되었습니다"]:::display
    AlertSystemError --> ClickOrder
    
    ServerValidate -- 승인완료 --> SaveDB["DB Transaction:<br/>주문/결제 저장"]:::proc
    SaveDB --> EmitSocket["Socket: 주방(KDS)<br/>주문 전송"]:::proc
    
    EmitSocket --> OrderSuccessScreen[>"주문 완료 화면<br/>(주문번호 호출)"]:::display
    OrderSuccessScreen --> EndTrans([초기화]):::startend
```

---

## 4. 주방 주문 처리 시스템 (KDS Fulfillment)
주방 디스플레이(KDS)에서 주문을 실시간으로 수신하고, 조리 상태를 관리하는 로직입니다.

### 🔍 주요 체크 포인트
* **실시간성:** Polling(주기적 조회) 방식이 아닌 Socket/Push 알림을 통해 즉각적으로 티켓을 띄웁니다.
* **상태 동기화:** 주방에서 '조리중', '완료'를 누를 때마다 서버를 통해 손님 태블릿에도 상태가 반영되어야 합니다.
* **재시도 로직:** 주방 인터넷이 불안정하여 API 호출 실패 시, 자동으로 재시도하거나 오류 메시지를 띄워 누락을 방지합니다.

```mermaid
flowchart TD
    classDef startend fill:#333,stroke:#333,stroke-width:2px,color:#fff,rx:20,ry:20;
    classDef proc fill:#fff,stroke:#333,stroke-width:1px;
    classDef decision fill:#fff,stroke:#333,stroke-width:1px,shape:diamond;
    classDef input fill:#fff,stroke:#333,stroke-width:1px,shape:parallelogram;
    classDef display fill:#f4f4f4,stroke:#333,stroke-width:1px,shape:rect;

    Start([KDS 모니터링]):::startend --> ListenSocket{"소켓 수신 대기"}:::decision
    
    ListenSocket -- Heartbeat --> KeepAlive["연결 유지"]:::proc
    ListenSocket -- NewOrder --> ReceiveData["주문 데이터 수신"]:::proc
    
    ReceiveData --> AlertKDS[>"1. 알림음 재생<br/>2. 화면 깜빡임 효과"]:::display
    AlertKDS --> RenderTicket["주문 티켓 생성<br/>(상태: 접수대기)"]:::display
    
    %% 조리 시작 단계
    RenderTicket --> ActionCook[/"'조리 시작' 터치"/]:::input
    ActionCook --> ApiStatus1["API: 상태 변경<br/>(PENDING -> COOKING)"]:::proc
    
    ApiStatus1 --> CheckNet1{"통신 성공?"}:::decision
    CheckNet1 -- 실패 --> RetryMsg1[>"통신 오류:<br/>다시 시도해주세요"]:::display
    RetryMsg1 --> ActionCook
    
    CheckNet1 -- 성공 --> UpdateTicket1["UI: 티켓 색상 변경<br/>(조리중)"]:::display
    UpdateTicket1 --> NotifyCustomer1["Push: 손님 태블릿<br/>'메뉴 준비중' 표시"]:::proc
    
    %% 조리 완료 단계
    UpdateTicket1 --> RealCook[".. 조리 수행 .."]:::proc
    RealCook --> ActionDone[/"'조리 완료' 터치"/]:::input
    ActionDone --> ApiStatus2["API: 상태 변경<br/>(COOKING -> DONE)"]:::proc
    
    ApiStatus2 --> CheckNet2{"통신 성공?"}:::decision
    CheckNet2 -- 실패 --> RetryMsg2[>"통신 오류"]:::display
    RetryMsg2 --> ActionDone
    
    CheckNet2 -- 성공 --> RemoveTicket["UI: 티켓 목록에서<br/>삭제/블러 처리"]:::proc
    RemoveTicket --> NotifyCustomer2["Push: 손님 태블릿<br/>'음식이 나왔습니다'"]:::proc
    
    NotifyCustomer2 --> EndKDS([대기 모드]):::startend
```