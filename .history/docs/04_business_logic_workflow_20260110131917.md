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