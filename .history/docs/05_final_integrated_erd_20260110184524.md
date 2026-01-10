# [Design] Final Integrated ERD (v3.1)

> - **File Name:** 05_final_integrated_erd.md
> - **Date:** 2026.01.10
> - **Version:** v3.1 (Final)
> - **Description:** Visual representation of the database structure using Mermaid, including table relationships, keys, and logical groupings.

---

## 1. Visual Diagram (Mermaid ERD)

This diagram represents the logical and physical structure of the **Table Order System** database.

```mermaid
---
config:
  layout: elk
---
erDiagram
    %% ---------------------------------------------------------
    %% 1. Core Domain (Users & Stores)
    %% ---------------------------------------------------------
    USERS {
        BigInt user_id PK "Auto Increment"
        Varchar login_id UK "Email Address"
        Varchar password "BCrypt Hash"
        Varchar access_token "UUID v4 (Session)"
        Timestamp last_login_at
        Timestamp created_at
    }

    STORES {
        BigInt store_id PK
        BigInt user_id FK
        Varchar name "Store Name"
        Boolean is_open "Operation Status"
        Int total_table_count
        Timestamp created_at
    }

    TABLES {
        BigInt table_id PK
        BigInt store_id FK
        Int table_number
        Varchar auth_code "Device PIN"
        Timestamp created_at
    }

    USERS ||--o{ STORES : owns
    STORES ||--o{ TABLES : contains

    %% ---------------------------------------------------------
    %% 2. Product Domain (Menus & Options)
    %% ---------------------------------------------------------
    MENU_CATEGORIES {
        BigInt menu_category_id PK
        BigInt store_id FK
        Varchar name
        Int sort_order
    }

    MENUS {
        BigInt menu_id PK
        BigInt menu_category_id FK
        Varchar name
        Int price
        Varchar image_url
        Boolean is_soldout
        Boolean is_hidden
    }

    OPTION_GROUPS {
        BigInt option_group_id PK
        BigInt store_id FK
        Varchar name
        Boolean is_exclusive "True:Radio / False:Check"
        Int min_select
        Int max_select
    }

    OPTIONS {
        BigInt option_id PK
        BigInt option_group_id FK
        Varchar name
        Int extra_price
    }

    MENU_OPTION_MAPPINGS {
        BigInt mapping_id PK
        BigInt menu_id FK
        BigInt option_group_id FK
    }

    STORES ||--o{ MENU_CATEGORIES : defines
    MENU_CATEGORIES ||--o{ MENUS : categorizes
    STORES ||--o{ OPTION_GROUPS : defines
    OPTION_GROUPS ||--o{ OPTIONS : contains
    MENUS ||--o{ MENU_OPTION_MAPPINGS : has
    OPTION_GROUPS ||--o{ MENU_OPTION_MAPPINGS : applied_to

    %% ---------------------------------------------------------
    %% 3. Transaction Domain (Orders & Payments)
    %% ---------------------------------------------------------
    ORDERS {
        BigInt order_id PK
        Varchar order_uuid UK "Toss Order ID"
        BigInt store_id FK
        BigInt table_id FK
        Int total_price
        Timestamp created_at
    }

    PAYMENTS {
        BigInt payment_id PK
        BigInt order_id FK
        Varchar payment_key "Toss Payment Key"
        Varchar toss_order_id
        Varchar method "Card/EasyPay"
        Int total_amount
        Varchar status "DONE/CANCELED"
        Timestamp approved_at
    }

    ORDER_DETAILS {
        BigInt order_detail_id PK
        BigInt order_id FK
        BigInt menu_id FK
        Int quantity
        Int price_snapshot "Historical Price"
        Varchar cook_status "PENDING/COOKING/DONE"
    }

    ORDER_DETAIL_OPTIONS {
        BigInt order_detail_option_id PK
        BigInt order_detail_id FK
        BigInt option_id FK
        Int price_snapshot "Historical Price"
    }

    TABLES ||--o{ ORDERS : places
    STORES ||--o{ ORDERS : receives
    ORDERS ||--|| PAYMENTS : pays_via
    ORDERS ||--o{ ORDER_DETAILS : consists_of
    ORDER_DETAILS ||--o{ ORDER_DETAIL_OPTIONS : includes
    MENUS ||--o{ ORDER_DETAILS : reference
    OPTIONS ||--o{ ORDER_DETAIL_OPTIONS : reference

    %% ---------------------------------------------------------
    %% 4. Support Domain (Staff Calls)
    %% ---------------------------------------------------------
    STAFF_CALL_ITEMS {
        BigInt staff_call_item_id PK
        BigInt store_id FK
        Varchar name "Item Name"
        Varchar icon_code
    }

    STAFF_CALLS {
        BigInt staff_call_id PK
        BigInt table_id FK
        BigInt staff_call_item_id FK
        Boolean is_completed
        Timestamp created_at
    }

    STORES ||--o{ STAFF_CALL_ITEMS : defines
    STAFF_CALL_ITEMS ||--o{ STAFF_CALLS : type_of
    TABLES ||--o{ STAFF_CALLS : requests