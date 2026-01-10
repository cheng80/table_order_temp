---
config:
  layout: elk
---
flowchart TD
    %% ---------------------------------------------------------
    %% 1. 스타일 정의 (Conceptual Notation)
    %% ---------------------------------------------------------
    classDef strong fill:#fff,stroke:#333,stroke-width:2px;
    classDef weak fill:#fff,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5;
    classDef assoc fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,shape:hexagon; 
    classDef rel fill:#fff,stroke:#333,stroke-width:1px,shape:diamond;

    %% ---------------------------------------------------------
    %% 2. 엔티티 (Entities) - Final Naming (v3.7)
    %% ---------------------------------------------------------
    
    %% [Core]
    Member[MEMBERS]:::strong
    Store[STORES]:::weak
    Table[STORE_TABLES]:::weak
    
    %% [Product]
    Category[MENU_CATEGORIES]:::weak
    Menu[MENUS]:::weak
    Group[OPTION_GROUPS]:::weak
    Option[OPTIONS]:::weak
    
    %% [Transaction] - Renaming Applied!
    Order[STORE_ORDERS]:::weak
    Payment[PAYMENTS]:::weak
    
    %% [Support]
    CallItem[STAFF_CALL_ITEMS]:::weak
    Reserv[RESERVATIONS]:::weak

    %% ---------------------------------------------------------
    %% 3. 연관 엔티티 (Associative Entities)
    %% ---------------------------------------------------------
    MapMenuOpt{{MENU_OPTION_MAPPINGS}}:::assoc
    OrderDetail{{ORDER_DETAILS}}:::assoc
    OrderDetailOpt{{ORDER_DETAIL_OPTIONS}}:::assoc
    CallLog{{STAFF_CALL_LOGS}}:::assoc

    %% ---------------------------------------------------------
    %% 4. 관계 (Relationships)
    %% ---------------------------------------------------------
    R_Owns{소유}:::rel
    R_Has{구성}:::rel
    R_Define{정의}:::rel
    R_Classify{분류}:::rel
    R_Pay{결제}:::rel
    R_Book{예약}:::rel

    %% ---------------------------------------------------------
    %% 5. 연결 (Connections)
    %% ---------------------------------------------------------
    
    %% 회원 -> 매장 -> 테이블
    Member ---|1:N| R_Owns --- Store
    Store ---|1:N| R_Has --- Table

    %% 매장 -> 메뉴 및 옵션 구조
    Store ---|1:N| R_Define --- Category
    Category ---|1:N| R_Classify --- Menu
    
    Store ---|1:N| R_Define --- Group
    Group ---|1:N| R_Has --- Option

    %% 메뉴 <-> 옵션그룹 매핑
    Menu --- MapMenuOpt --- Group

    %% 테이블 -> 주문(STORE_ORDERS) -> 결제
    Table ---|1:N| R_Has --- Order
    Order ---|1:1| R_Pay --- Payment

    %% 주문 <-> 메뉴 (상세)
    Order --- OrderDetail --- Menu

    %% 주문상세 <-> 옵션
    OrderDetail --- OrderDetailOpt --- Option

    %% 직원 호출
    Store ---|1:N| R_Define --- CallItem
    Table --- CallLog --- CallItem

    %% 예약
    Table ---|1:N| R_Book --- Reserv