네, 대화가 길어지면 놓칠 수 있죠! 흐름상 **05번**이 데이터베이스 명세서였으므로, 그 바로 앞단계인 **04번 문서**는 화면의 흐름과 로직을 정의했던 **[비즈니스 로직 및 워크플로우 명세서]**입니다.

아까 Mermaid로 작성해 드렸던 **3가지 핵심 흐름도(진입, 주문, 주방)**를 문서화하여 정리해 드립니다.

이 내용을 **`04_business_logic_workflow.md`** 파일로 저장하시면 됩니다.

---

```markdown
# [기획] 비즈니스 로직 및 워크플로우 명세서

> **문서 번호:** 04_business_logic_workflow.md
> **작성 일자:** 2025.01.10
> **내용:** 사용자(점주/손님/주방)의 행동 흐름과 시스템의 분기 처리 로직 정의.
> **도구:** Mermaid Flowchart & Sequence Diagram

---

## 1. 전체 시스템 진입 및 모드 전환 (System Entry)
점주가 로그인 후, 해당 태블릿을 **어떤 용도(테이블용, 주방용, 관리용)**로 쓸지 결정하는 흐름입니다.

```mermaid
flowchart TD
    %% 스타일 정의
    classDef screen fill:#e1f5fe,stroke:#01579b,stroke-width:2px,rx:5,ry:5;
    classDef action fill:#fff9c4,stroke:#fbc02d,stroke-width:1px,rx:5,ry:5;
    classDef system fill:#f3e5f5,stroke:#7b1fa2,stroke-width:1px,stroke-dasharray: 5 5;

    %% 시작점
    Start((앱 실행)) --> CheckLogin{"로그인 여부 확인<br/>(UUID 토큰)"}:::system

    %% A 그룹: 계정
    CheckLogin -- No --> A02["A-02: 로그인 화면"]:::screen
    A02 -- "회원가입 클릭" --> A01["A-01: 회원가입"]:::screen
    A01 -- "가입 완료" --> A02
    A02 -- "로그인 성공" --> O01["O-01: 점주 대시보드"]:::screen
    CheckLogin -- "Yes (Auto Login)" --> O01

    %% O 그룹: 모드 분기
    subgraph OwnerMode [점주 관리 모드]
        O01 --> ActionSelect{"모드 선택"}:::action
        ActionSelect -- "메뉴/테이블 관리" --> O02["O-02: 메뉴 관리"]:::screen
        ActionSelect -- "테이블 모드 실행" --> T01["T-01: 테이블 메인"]:::screen
        ActionSelect -- "KDS 모드 실행" --> K01["K-01: 주방 KDS"]:::screen
    end

    %% T 그룹: 보안 탈출
    subgraph TableMode [손님용 테이블 모드]
        T01 -- "관리자 히든 버튼 (5회 터치)" --> T05["T-05: 관리자 인증"]:::screen
        T05 -- "PIN 번호 일치" --> O01
        T05 -- "불일치" --> T01
    end

```

---

## 2. 손님 주문 및 결제 프로세스 (Customer Order)

손님이 메뉴를 고르고, 옵션을 선택하여 결제까지 완료하는 핵심 수익 발생 흐름입니다.

```mermaid
flowchart TD
    %% 스타일 정의
    classDef screen fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,rx:5,ry:5;
    classDef popup fill:#fff3e0,stroke:#ef6c00,stroke-width:2px,rx:5,ry:5;
    classDef process fill:#f3e5f5,stroke:#7b1fa2,stroke-width:1px;

    %% 메인 흐름
    T01["T-01: 메인 주문판<br/>(ScrollSpy)"]:::screen -->|메뉴 클릭| CheckSoldOut{"품절 여부"}:::process
    
    CheckSoldOut -- "판매중" --> T02["T-02: 옵션 선택 팝업"]:::popup
    CheckSoldOut -- "품절됨" --> Toast1("토스트 알림:<br/>품절된 메뉴입니다"):::process

    %% 옵션 선택
    T02 -->|"옵션 선택 & 담기"| CartLogic{"유효성 검사<br/>(필수옵션 체크)"}:::process
    CartLogic -- "Pass" --> T01_Update["장바구니 갱신"]:::screen
    CartLogic -- "Fail" --> T02
    
    %% 장바구니 및 결제
    T01_Update -->|"주문하기 버튼"| T03["T-03: 주문 및 결제 확인"]:::screen
    
    subgraph Payment [결제 로직 (Toss Payments)]
        T03 --> PayType{"결제 방식 선택<br/>(Toggle)"}:::process
        PayType -- "일괄 결제" --> PayAll["전체 금액 결제"]:::process
        PayType -- "개별 결제" --> PaySplit["체크한 메뉴만 결제"]:::process
        
        PayAll & PaySplit --> PG["PG사 결제창 호출"]:::process
    end

    PG -- "결제 승인" --> OrderComplete(("주문 완료<br/>서버 전송"))
    PG -- "실패/취소" --> T03

```

---

## 3. 주방 주문 접수 및 동기화 (Kitchen Fulfillment)

주문이 들어왔을 때 서버를 거쳐 주방(KDS)에 표시되고, 조리 상태가 손님 화면과 동기화되는 과정입니다.

```mermaid
sequenceDiagram
    participant Customer as 🙋‍♂️ 손님 (Table T-01)
    participant Server as ☁️ 서버 (API/DB)
    participant KDS as 🧑‍🍳 주방 (KDS K-01)

    Note over Customer, Server: 주문 발생 (결제 완료)
    Customer->>Server: POST /orders (주문 데이터)
    Server->>Server: DB 저장 & 상태 'PENDING'
    
    par 실시간 전파 (Polling/Socket)
        Server->>KDS: 신규 주문 알림
        Server-->>Customer: (주문 접수됨 알림)
    end

    Note over KDS: 화면에 주문 티켓 생성 (깜빡임)
    
    KDS->>KDS: [접수] 버튼 클릭
    KDS->>Server: PATCH /orders/{id}/status (COOKING)
    
    par 상태 동기화
        Server->>Customer: 주문내역 갱신
        Note right of Customer: 상태: '조리중'
    end

    Note over KDS: 조리 완료 후
    KDS->>KDS: [완료] 버튼 클릭
    KDS->>Server: PATCH /orders/{id}/status (DONE)
    
    par 서빙 알림
        Server->>Customer: "음식이 준비되었습니다!" 알림
        Note right of Customer: 상태: '서빙완료'
    end

```

```

```