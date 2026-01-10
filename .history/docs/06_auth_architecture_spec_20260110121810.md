# [설계] 인증 시스템 아키텍처 및 구현 가이드 (UUID Stateful Token)

> **문서 번호:** 06_auth_architecture_spec.md
> **작성 일자:** 2025.01.10
> **설계 목적:** 복잡한 JWT 없이, **MySQL DB 기반의 세션 토큰**을 사용하여 직관적이고 강력한(강제 로그아웃 가능) 인증 시스템 구현.
> **전제 조건:** 로컬 DB(SQLite)를 사용하지 않으며, **서버 DB가 유일한 진실 공급원(Single Source of Truth)**이다.

---

## 1. 개요 (Overview)

본 프로젝트는 **Stateful Session** 방식을 채택한다.
사용자가 로그인하면 서버는 **고유한 랜덤 문자열(UUID)**을 생성하여 DB에 저장하고, 클라이언트에게 발급한다. 이후 모든 요청 헤더에 이 토큰을 실어 보내면, 서버는 DB를 조회하여 사용자를 식별한다.

### 1.1 채택 사유
1.  **구현의 단순성:** 암호화 알고리즘이나 서명 검증 로직이 필요 없음.
2.  **확실한 제어권:** 관리자가 특정 사용자의 DB 토큰 값을 지우거나 바꾸면, 해당 사용자는 **즉시 강제 로그아웃** 처리됨.
3.  **단일 DB 의존:** 별도의 Redis나 캐시 서버 없이 MySQL 하나로 처리하여 인프라 비용 절감.

---

## 2. 데이터베이스 설계 (Database Schema)

기존 `USERS` 테이블에 인증 관련 컬럼을 추가한다.

### 2.1 USERS 테이블 변경 스크립트
```sql
ALTER TABLE users ADD COLUMN access_token VARCHAR(64) NULL;
ALTER TABLE users ADD COLUMN last_login_at TIMESTAMP NULL;

-- 성능을 위해 인덱스 추가 권장
CREATE INDEX idx_users_access_token ON users(access_token);