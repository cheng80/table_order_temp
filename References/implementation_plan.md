# 미니슬랙 백엔드 데이터베이스 설계안

본 설계안은 기획서 V2를 바탕으로 서버 측 영속 데이터 저장소(MySQL)와 클라이언트 측 로컬 저장소(SQLite)의 스키마를 정의합니다.

## 제안 사항

### 1. MySQL (서버측 영속 저장소)

서버는 모든 데이터의 최종 기준이 됩니다.

#### `users` 테이블
사용자 정보를 관리하며, 등급(grade)에 따라 채널 생성 권한이 제어됩니다.
- `id`: PK (UUID 또는 Auto Increment)
- `email`: 사용자 이메일 (Unique)
- `nickname`: 사용자 닉네임
- `grade`: 사용자 등급 (FREE, PLUS, PRO)
- `created_at`: 생성 일시

#### `otps` 테이블
로그인을 위한 OTP 정보를 임시 보관합니다.
- `id`: PK
- `email`: 대상 이메일
- `otp_code`: 6자리 숫자 등
- `expires_at`: 만료 시간

#### `sessions` 테이블
사용자 세션을 관리합니다.
- `session_id`: PK (Random Token)
- `user_id`: FK (users.id)
- `expires_at`: 만료 시간

#### `channels` 테이블
채널 정보를 관리합니다.
- `id`: PK
- `name`: 채널 이름
- `type`: 채널 유형 (DEFAULT, PRIVATE, PASSWORD)
- `password_hash`: 비밀번호 채널용 해시 (나머지는 NULL)
- `owner_id`: 생성자 (FK users.id, DEFAULT 채널은 NULL)
- `created_at`: 생성 일시

#### `messages` 테이블
모든 채팅 메시지를 저장합니다.
- `id`: PK (서버 생성 messageId)
- `channel_id`: FK (channels.id)
- `sender_id`: FK (users.id)
- `content`: 메시지 내용 (Text)
- `client_msg_id`: 클라이언트에서 중복 방지를 위해 보낸 고유 ID
- `created_at`: 서버 저장 일시 (정렬 기준)

---

### 2. SQLite (클라이언트 로컬 저장소)

클라이언트는 사용자 경험 안정성을 위해 전송 큐와 캐시를 운영합니다.

#### `local_messages` 테이블
메시지 전송 큐 및 최근 메시지 캐시 역할을 합니다.
- `local_id`: PK (클라이언트 생성)
- `channel_id`: 채널 ID
- `sender_id`: 발신자 ID
- `content`: 메시지 내용
- `status`: 전송 상태 (PENDING, SENDING, SENT, FAILED)
- `server_msg_id`: 서버로부터 받은 최종 messageId (Nullable)
- `created_at`: 생성 시간

#### `channels_cache` 테이블
빠른 UI 렌더링을 위한 채널 리스트 캐시입니다.
- `id`: PK (서버의 channel_id)
- `name`: 채널 이름
- `type`: 채널 유형

---

## 검증 계획

### 수동 검증
- 설계된 ERD가 기획서의 모든 요구사항(인증 흐름, 등급별 채널, 메시지 중복 방지 등)을 충족하는지 검토합니다.
- 이후 FastAPI 구현 단계에서 각 테이블에 대응하는 SQLAlchemy 모델을 생성하여 연동 테스트를 진행합니다.
