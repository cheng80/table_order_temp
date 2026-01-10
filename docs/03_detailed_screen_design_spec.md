# [기획] 테이블오더 시스템 상세 화면 설계서 (v1.0)

> **문서 제목:** 03_detailed_screen_design_spec.md
> **작성 일자:** 2024.05.20
> **작성 목적:** 테이블오더 포트폴리오의 UI/UX 구조 확정 및 기능 명세 정의
> **참고 자료:** 넥스트페이, 하이오더, 메뉴몬 매뉴얼 분석 기반

---

## 1. 기획 의도 및 설계 원칙

본 프로젝트는 상용 테이블오더 서비스의 핵심 로직(주문-접수-조리-서빙)을 완벽하게 재현하는 것을 목표로 한다.
1인 개발 및 포트폴리오 환경을 고려하여 **'하드웨어 제어는 최소화'**하되, **'소프트웨어적 실시간성(MQTT)'**과 **'사용자 경험(UX)'**을 극대화하는 방향으로 설계한다.

### 핵심 설계 원칙
1.  **3-Pane Layout (Customer):** 메뉴 탐색과 주문 내역 확인을 한 화면에서 처리하여 주문 이탈률 감소.
2.  **Real-time Sync (System):** 품절 처리 및 주문 상태 변경 시 새로고침 없이 즉시 반영 (MQTT).
3.  **One-App Multi-Role:** 하나의 앱 패키지에서 로그인 계정/모드에 따라 [점주/주방/손님] 화면으로 분기.

---

## 2. 기능 구현 범위 (Scope)

상용 제품 분석을 통해 포트폴리오에 필수적인 기능(MVP)과 제외할 기능을 명확히 정의한다.

| 구분 | 구현 (Must Have) | 제외 (Out of Scope) | 사유 |
| :--- | :--- | :--- | :--- |
| **주문** | 테이블별 장바구니, 옵션(필수/선택) | 더치페이, 포장 주문 | 결제 및 옵션 로직의 본질에 집중 |
| **결제** | PG 연동 (토스 페이먼츠 샌드박스) | 포인트 적립, 쿠폰, 현금결제 | 결제 승인/실패 프로세스 구현이 핵심 |
| **관리** | **원터치 품절(Toggle)**, 메뉴 수정 | 재고 수량 카운팅, 바코드 연동 | UX적으로 '품절 토글'이 더 임팩트 있음 |
| **알림** | 직원 호출(프리셋), 조리 상태 알림 | 로봇 서빙 연동, 카톡 알림톡 | 하드웨어 의존성 제거 |
| **주방** | KDS (주문 티켓 시스템), 타이머 | 주방 프린터 출력 | 태블릿 화면(KDS)으로 프린터 대체 |

---

## 3. 화면 상세 설계 (UI Wireframe & Logic)

### 3-1. [손님] 메인 주문 화면 (Table Home)
**컨셉:** 넥스트페이, 메뉴몬 스타일의 **3단 분할 레이아웃**. 화면 이동 최소화.

**[Layout Structure]**
- **Left (Category):** NavigationRail 위젯 사용. 세로형 탭.
- **Center (Menu Grid):** GridView 위젯. 메뉴 카드 나열. 품절 시 오버레이 처리.
- **Right (Cart):** Column 위젯. 상단 리스트(ListView) + 하단 고정 버튼(Container).

**[Data Flow]**
- **초기 로딩:** `GET /menus?storeId={id}`
- **실시간 품절 반영:** MQTT Topic `store/{id}/menu_update` 수신 시 로컬 상태(Provider) 즉시 갱신.
- **직원 호출:** 버튼 클릭 시 MQTT `store/{id}/staff_call` 발행.

### 3-2. [손님] 옵션 선택 팝업 (Option Modal)
**컨셉:** 하이오더 스타일. **필수(Radio)**와 **선택(Checkbox)**의 명확한 구분.

**[UI Components]**
- **Header:** 메뉴 이미지, 이름, 기본 가격.
- **Body (Scrollable):**
    - Section 1: 필수 옵션 (예: 맵기). RadioGroup 사용. 선택 전까지 담기 버튼 Disabled.
    - Section 2: 선택 옵션 (예: 토핑). CheckboxGroup 사용.
- **Footer:** 수량 조절(Counter) 및 [금액 합산 담기] 버튼.

### 3-3. [점주] 메뉴 및 품절 관리 (Quick Menu Mgmt)
**컨셉:** 바쁜 매장 상황을 고려하여 **'스위치 한 번으로 품절 처리'**에 집중.

**[UI Components]**
- **List Item:** 메뉴 썸네일(Leading) - 이름/가격(Title/Subtitle) - **Switch(Trailing)**.
- **Action:** Switch 토글 시 Debounce 없이 즉시 API `PATCH /menus/{id}/soldout` 호출.

### 3-4. [주방] KDS (Kitchen Display System)
**컨셉:** 종이 영수증을 대체하는 화면. 시간 경과 확인 및 터치로 상태 변경.

**[UI Components]**
- **Horizontal ListView:** 주문 티켓(Card)을 가로로 나열.
- **Timer Widget:** 주문 접수 시간(`created_at`) 기준 경과 시간 실시간 갱신 (Ticker).
- **Status Button:** [접수대기(Color: Red)] -> [조리중(Color: Blue)] -> [완료(Gone)].

---

## 4. 사용자 흐름도 (User Flow)

1. **앱 실행 & 로그인** (점주 계정)
2. **모드 선택:**
   - [관리자 모드] -> 매출 확인, 메뉴 품절 관리
   - [테이블 모드] -> 손님용 UI 실행 (태블릿 거치용)
   - [주방 모드] -> KDS UI 실행 (주방 거치용)
3. **손님 주문:**
   - 테이블 모드에서 메뉴 선택 -> 장바구니 -> 결제(PG) -> 서버 주문 생성.
4. **주문 전파 (Real-time):**
   - 서버 -> MQTT -> 주방 모드(KDS)에 신규 주문 티켓 생성.
5. **조리 및 서빙:**
   - 주방에서 [접수] -> [완료] 터치.
   - 상태 변경 시 MQTT -> 테이블 모드에 알림(Toast/Badge) 전송.