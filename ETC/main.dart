import 'package:flutter/material.dart';

void main() {
  runApp(const TableOrderIntegratedApp());
}

class TableOrderIntegratedApp extends StatelessWidget {
  const TableOrderIntegratedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Table Order System v4.0',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainViewer(),
    );
  }
}

// ---------------------------------------------------------------------------
// [Viewer] 통합 뷰어 (Navigation)
// ---------------------------------------------------------------------------
class MainViewer extends StatefulWidget {
  const MainViewer({super.key});

  @override
  State<MainViewer> createState() => _MainViewerState();
}

class _MainViewerState extends State<MainViewer> {
  // DartPad에서 바로 보이도록 'W-02 대기 현황판'을 기본값으로 설정
  int _selectedIndex = 16; 

  final List<Widget> _screens = [
    const ScreenA01Register(),
    const ScreenA02Login(),
    const ScreenO01OwnerMainTablet(),
    const ScreenO02MenuMasterDetail(),
    const ScreenO04Banner(),
    const ScreenO05Table(),
    const ScreenO06Inquiry(),
    const ScreenO07WaitingAdmin(),
    const ScreenO08OptionGroup(),
    const ScreenO09OptionDetail(),
    const ScreenT01ScrollSpy(),
    const ScreenT02Option(),
    const ScreenT03Cart(),
    const ScreenT04StaffCall(),
    const ScreenT05AdminAuth(),
    const ScreenW01WaitingRegister(),
    const ScreenW02WaitingBoard(),
    const ScreenK01KDS(),
  ];

  final List<String> _titles = [
    "A-01 회원가입",
    "A-02 로그인",
    "O-01 점주 대시보드",
    "O-02 메뉴/원가",
    "O-04 배너 관리",
    "O-05 테이블 관리",
    "O-06 문의하기",
    "O-07 대기 관리",
    "O-08 옵션 그룹",
    "O-09 옵션 상세",
    "T-01 테이블 메인",
    "T-02 옵션 선택",
    "T-03 장바구니",
    "T-04 직원 호출",
    "T-05 관리자 인증",
    "W-01 대기 등록",
    "W-02 대기 현황판",
    "K-01 주방 KDS",
  ];

  @override
  Widget build(BuildContext context) {
    // DartPad 화면이 좁을 수 있으므로 레이아웃을 유연하게 조정
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Row(
        children: [
          // [Left] Navigation List
          Container(
            width: 200, // 너비를 줄임
            color: const Color(0xFF2D2D2D),
            child: Column(
              children: [
                Container(
                  height: 60,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: const Text("VIEWER v4.0", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _titles.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedIndex == index;
                      String prefix = _titles[index].split(" ")[0];
                      Color iconColor = Colors.grey;
                      if (prefix.startsWith("A")) iconColor = Colors.blue;
                      if (prefix.startsWith("O")) iconColor = Colors.orange;
                      if (prefix.startsWith("T")) iconColor = Colors.green;
                      if (prefix.startsWith("W")) iconColor = Colors.purple;
                      if (prefix.startsWith("K")) iconColor = Colors.red;

                      return Container(
                        color: isSelected ? Colors.white.withOpacity(0.1) : null,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            _titles[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60, 
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: Icon(Icons.circle, size: 8, color: iconColor),
                          onTap: () => setState(() => _selectedIndex = index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // [Right] Screen Preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _screens[_selectedIndex < _screens.length ? _selectedIndex : 0],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// [Screens] 각 화면 구현체
// ---------------------------------------------------------------------------

class ScreenA01Register extends StatelessWidget {
  const ScreenA01Register({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("회원가입", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const TextField(decoration: InputDecoration(labelText: "사업자번호", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(labelText: "아이디", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(labelText: "비밀번호", border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text("가입"))),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreenA02Login extends StatelessWidget {
  const ScreenA02Login({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, size: 50, color: Colors.teal),
            const SizedBox(height: 20),
            const Text("사장님 로그인", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: "아이디", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: "비밀번호", border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text("로그인"))),
          ],
        ),
      ),
    );
  }
}

class ScreenO01OwnerMainTablet extends StatelessWidget {
  const ScreenO01OwnerMainTablet({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("대시보드"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("오늘의 현황", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _statCard("매출", "124만원", Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _statCard("순이익", "42만원", Colors.green)),
              ],
            ),
            const SizedBox(height: 20),
            const Text("바로가기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _actionBtn("주문판", Icons.tablet),
                _actionBtn("KDS", Icons.kitchen),
                _actionBtn("대기등록", Icons.people),
                _actionBtn("현황판", Icons.tv),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title, style: const TextStyle(color: Colors.grey)), Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon) {
    return Chip(label: Text(label), avatar: Icon(icon, size: 18));
  }
}

class ScreenO02MenuMasterDetail extends StatelessWidget {
  const ScreenO02MenuMasterDetail({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("메뉴/원가 관리")),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (_,__) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(title: Text("메뉴 ${i+1}"), subtitle: Text("12,000원"), selected: i==0),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  TextField(decoration: InputDecoration(labelText: "메뉴명", border: OutlineInputBorder())),
                  SizedBox(height: 10),
                  TextField(decoration: InputDecoration(labelText: "판매가", border: OutlineInputBorder())),
                  SizedBox(height: 10),
                  TextField(decoration: InputDecoration(labelText: "원가 (Cost)", border: OutlineInputBorder())),
                  SizedBox(height: 20),
                  Text("옵션 그룹 연결", style: TextStyle(fontWeight: FontWeight.bold)),
                  CheckboxListTile(value: true, onChanged: null, title: Text("맵기 조절")),
                  CheckboxListTile(value: true, onChanged: null, title: Text("토핑 추가")),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ScreenO07WaitingAdmin extends StatelessWidget {
  const ScreenO07WaitingAdmin({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("대기 관리")),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(child: Text("${i+1}")),
          title: Text("대기번호 ${100+i}"),
          trailing: ElevatedButton(onPressed: (){}, child: const Text("호출")),
        ),
      ),
    );
  }
}

// 나머지 빈 화면들
class ScreenO04Banner extends StatelessWidget { const ScreenO04Banner({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("배너 관리")); }
class ScreenO05Table extends StatelessWidget { const ScreenO05Table({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("테이블 관리")); }
class ScreenO06Inquiry extends StatelessWidget { const ScreenO06Inquiry({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("문의하기")); }
class ScreenO08OptionGroup extends StatelessWidget { const ScreenO08OptionGroup({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("옵션 그룹 관리")); }
class ScreenO09OptionDetail extends StatelessWidget { const ScreenO09OptionDetail({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("옵션 상세 관리")); }

class ScreenT01ScrollSpy extends StatelessWidget { const ScreenT01ScrollSpy({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("T-01 메인 화면")); }

class ScreenT02Option extends StatelessWidget {
  const ScreenT02Option({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("옵션 선택")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("비프 카레", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Divider(),
            const Text("맵기 (필수)", style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(value: 1, groupValue: 1, onChanged: (v){}, title: const Text("1단계")),
            RadioListTile(value: 2, groupValue: 1, onChanged: (v){}, title: const Text("2단계")),
            const SizedBox(height: 10),
            const Text("토핑 (선택)", style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(value: true, onChanged: (v){}, title: const Text("돈카츠 (+3500원)")),
            CheckboxListTile(value: false, onChanged: (v){}, title: const Text("치즈 (+1500원)")),
            const Spacer(),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: (){}, child: const Text("담기")))
          ],
        ),
      ),
    );
  }
}

class ScreenT03Cart extends StatelessWidget { const ScreenT03Cart({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("장바구니")); }
class ScreenT04StaffCall extends StatelessWidget { const ScreenT04StaffCall({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("직원 호출")); }
class ScreenT05AdminAuth extends StatelessWidget { const ScreenT05AdminAuth({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("관리자 인증")); }

class ScreenW01WaitingRegister extends StatelessWidget {
  const ScreenW01WaitingRegister({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, size: 60, color: Colors.teal),
          const SizedBox(height: 20),
          const Text("대기 등록", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: (){}, child: const Text("터치하여 시작"))
        ],
      ),
    );
  }
}

class ScreenW02WaitingBoard extends StatelessWidget {
  const ScreenW02WaitingBoard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("호출 번호", style: TextStyle(color: Colors.white, fontSize: 24)),
            SizedBox(height: 20),
            Text("105", style: TextStyle(color: Colors.yellow, fontSize: 100, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            Text("대기인원 5팀", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class ScreenK01KDS extends StatelessWidget {
  const ScreenK01KDS({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text("KDS"), backgroundColor: Colors.black),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, i) => Container(
          width: 200,
          margin: const EdgeInsets.only(right: 10),
          color: Colors.grey[800],
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(10), color: Colors.black54, child: Text("주문 ${i+1}", style: const TextStyle(color: Colors.white))),
              const Expanded(child: Center(child: Text("카레...", style: TextStyle(color: Colors.white)))),
              ElevatedButton(onPressed: (){}, child: const Text("완료"))
            ],
          ),
        ),
      ),
    );
  }
}