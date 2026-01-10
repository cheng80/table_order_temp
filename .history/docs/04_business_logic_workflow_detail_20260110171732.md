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
    ValidateToken -- 만료/실패 --> LoginView> "로그인 화면 출력"]:::display

    %% 2. 로그인/가입 분기
    LoginView --> UserAction{"행동 선택"}:::decision
    
    %% [Scenario A] 회원가입
    UserAction -- 회원가입 --> TermsView> "약관 동의 화면"]:::display
    TermsView --> CheckTerms{"필수 약관<br/>동의 완료?"}:::decision
    CheckTerms -- 미동의 --> AlertTerms> "알림: 필수 약관에<br/>동의해야 합니다"]:::display
    AlertTerms --> TermsView
    
    CheckTerms -- 동의 --> InputInfo[/"정보 입력:<br/>ID, PW, 사업자번호"/]:::input
    InputInfo --> ValidateInfo{"1. 빈칸 체크<br/>2. PW 복잡도<br/>3. 사업자번호 형식"}:::decision
    
    ValidateInfo -- 부적합 --> AlertValid> "알림: 입력 정보를<br/>확인해주세요"]:::display
    AlertValid --> InputInfo
    
    ValidateInfo -- 적합 --> ApiJoin["API: 회원가입 요청"]:::proc
    ApiJoin --> CheckDup{"ID 중복 여부<br/>(서버 리턴)"}:::decision
    
    CheckDup -- 중복됨 --> AlertDup> "알림: 이미 사용 중인<br/>아이디입니다"]:::display
    AlertDup --> InputInfo
    
    CheckDup -- 가입성공 --> SuccessJoin> "가입 완료 팝업"]:::display
    SuccessJoin --> LoginView

    %% [Scenario B] 로그인
    UserAction -- 로그인 --> InputLogin[/"ID / PW 입력"/]:::input
    InputLogin --> ApiLogin["API: 로그인 요청"]:::proc
    ApiLogin --> AuthCheck{"계정 일치 여부"}:::decision
    
    AuthCheck -- 불일치 --> AlertAuth> "알림: 아이디 또는<br/>비밀번호 오류"]:::display
    AlertAuth --> InputLogin
    
    AuthCheck -- 일치 --> GenToken["UUID 토큰 생성 및<br/>DB/로컬 저장"]:::proc
    GenToken --> MainDashboard

    %% 3. 메뉴 등록 (초기 세팅)
    MainDashboard --> GoMenu[/"메뉴 관리 진입"/]:::input
    GoMenu --> MenuForm> "메뉴 등록 폼"]:::display
    
    MenuForm --> InputMenuData[/"이미지, 이름, 가격,<br/>카테고리 입력"/]:::input
    InputMenuData --> ValidateMenu{"데이터 검증:<br/>가격 > 0<br/>이름 !Null"}:::decision
    
    ValidateMenu -- 오류 --> AlertMenu> "알림: 필수 입력값을<br/>확인하세요"]:::display
    AlertMenu --> InputMenuData
    
    ValidateMenu -- 통과 --> SaveMenu["API: 메뉴 저장"]:::proc
    SaveMenu --> RefreshList> "메뉴 리스트 갱신"]:::display
    RefreshList --> EndSetup([준비 완료]):::startend