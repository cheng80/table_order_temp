//화면 프리뷰용 다트파일

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const TableOrderTabletApp());
}

class TableOrderTabletApp extends StatelessWidget {
  const TableOrderTabletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tablet Order Mockup',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
        scaffoldBackgroundColor: Colors.grey[50],
        // cardTheme 설정 제거 (기본 Material 3 스타일 사용)
      ),
      home: const TabletMainViewer(),
    );
  }
}

class TabletMainViewer extends StatefulWidget {
  const TabletMainViewer({super.key});

  @override
  State<TabletMainViewer> createState() => _TabletMainViewerState();
}

class _TabletMainViewerState extends State<TabletMainViewer> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ScreenA01Register(),
    const ScreenA02Login(),
    const ScreenO01OwnerMainTablet(),
    const ScreenO02MenuMasterDetail(),
    const ScreenO04Banner(),
    const ScreenO05Table(),
    const ScreenO06Inquiry(),
    const ScreenT01ScrollSpy(), 
    const ScreenT02Option(),
    const ScreenT03Cart(), 
    const ScreenT04StaffCall(),
    const ScreenT05AdminAuth(),
    const ScreenK01KDS(),
  ];

  final List<String> _titles = [
    "A-01 회원가입",
    "A-02 로그인",
    "O-01 점주 대시보드",
    "O-02/03 메뉴 관리 (Split)",
    "O-04 배너 관리",
    "O-05 테이블 관리",
    "O-06 문의하기",
    "T-01 테이블 메인 (ScrollSpy)",
    "T-02 옵션 팝업",
    "T-03 장바구니/결제 (New)",
    "T-04 직원 호출",
    "T-05 관리자 인증",
    "K-01 주방 KDS",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 250,
              color: const Color(0xFF2D2D2D),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Text("📱 SCREEN LIST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _titles.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedIndex == index;
                        return ListTile(
                          title: Text(
                            _titles[index],
                            style: TextStyle(color: isSelected ? Colors.tealAccent : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          ),
                          selected: isSelected,
                          selectedTileColor: Colors.teal.withOpacity(0.2),
                          onTap: () => setState(() => _selectedIndex = index),
                          leading: Icon(Icons.circle, size: 8, color: isSelected ? Colors.tealAccent : Colors.white24),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, spreadRadius: 5)],
                ),
                child: _screens[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// [Group A] 계정 (Auth)
// ---------------------------------------------------------------------------

class ScreenA01Register extends StatelessWidget {
  const ScreenA01Register({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("서비스 가입", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            const TextField(decoration: InputDecoration(labelText: "사업자등록번호 (10자리)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.business))),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: "아이디 (이메일)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: "비밀번호", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 56, child: FilledButton(onPressed: () {}, child: const Text("가입하기"))),
          ],
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
        width: 500,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, size: 100, color: Colors.teal),
            const SizedBox(height: 24),
            const Text("사장님 로그인", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const TextField(decoration: InputDecoration(labelText: "아이디", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: "비밀번호", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 56, child: FilledButton(onPressed: () {}, child: const Text("로그인"))),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// [Group O] 점주 (Owner)
// ---------------------------------------------------------------------------

class ScreenO01OwnerMainTablet extends StatelessWidget {
  const ScreenO01OwnerMainTablet({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (v) {},
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text("대시보드")),
              NavigationRailDestination(icon: Icon(Icons.restaurant_menu), label: Text("메뉴관리")),
              NavigationRailDestination(icon: Icon(Icons.table_bar), label: Text("테이블")),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text("설정")),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Text("내 매장 대시보드", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Text("영업 상태: ", style: TextStyle(fontSize: 16)),
                      Switch(value: true, onChanged: (v) {}, activeColor: Colors.teal),
                      const SizedBox(width: 16),
                      const CircleAvatar(child: Icon(Icons.person)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard("오늘 매출", "1,240,000원", Icons.monetization_on, Colors.teal),
                        _buildStatCard("주문 건수", "42건", Icons.receipt_long, Colors.blue),
                        _buildActionCard(Icons.restaurant_menu, "메뉴 관리", "품절/수정", Colors.orange),
                        _buildActionCard(Icons.table_bar, "테이블 설정", "QR/좌석", Colors.indigo),
                        _buildActionCard(Icons.tablet_mac, "테이블 모드", "손님 화면 실행", Colors.green),
                        _buildActionCard(Icons.kitchen, "KDS 모드", "주방 화면 실행", Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(title, style: TextStyle(color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, Color color) {
    return Card(
      color: color.withOpacity(0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.2))),
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 30, child: Icon(icon, size: 32, color: color)),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class ScreenO02MenuMasterDetail extends StatelessWidget {
  const ScreenO02MenuMasterDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("메뉴 통합 관리"), elevation: 1),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(decoration: InputDecoration(hintText: "메뉴 검색", prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), contentPadding: EdgeInsets.zero)),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: 8,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        bool isSelected = index == 0;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: Colors.teal.withOpacity(0.1),
                          leading: Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.fastfood)),
                          title: Text("메뉴 이름 ${index + 1}"),
                          subtitle: const Text("12,000원"),
                          trailing: isSelected ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal) : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(32),
              child: Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("메뉴 수정", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          const Text("품절 처리 ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Switch(value: false, onChanged: (v) {}, activeColor: Colors.red),
                        ],
                      ),
                      const Divider(height: 40),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 200, height: 200,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 50, color: Colors.grey), SizedBox(height: 8), Text("이미지 변경")]),
                          ),
                          const SizedBox(width: 32),
                          const Expanded(
                            child: Column(
                              children: [
                                TextField(decoration: InputDecoration(labelText: "메뉴명", border: OutlineInputBorder())),
                                SizedBox(height: 20),
                                TextField(decoration: InputDecoration(labelText: "가격", border: OutlineInputBorder(), suffixText: "원")),
                                SizedBox(height: 20),
                                TextField(decoration: InputDecoration(labelText: "카테고리", border: OutlineInputBorder())),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      const TextField(decoration: InputDecoration(labelText: "설명", border: OutlineInputBorder()), maxLines: 3),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(onPressed: () {}, child: const Text("삭제", style: TextStyle(color: Colors.red))),
                          const SizedBox(width: 16),
                          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.save), label: const Text("변경사항 저장")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScreenO04Banner extends StatelessWidget {
  const ScreenO04Banner({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("배너 관리")),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildBannerItem(1, true),
                _buildBannerItem(2, true),
                _buildBannerItem(3, false),
                const SizedBox(height: 24),
                Center(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text("배너 추가하기"))),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.tablet_mac, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("테이블 화면 미리보기"),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBannerItem(int index, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(width: 100, color: Colors.indigo[100], child: const Icon(Icons.image)),
        title: Text("프로모션 배너 $index"),
        subtitle: Text(isActive ? "노출중" : "숨김"),
        trailing: Switch(value: isActive, onChanged: (v) {}),
      ),
    );
  }
}

class ScreenO05Table extends StatelessWidget {
  const ScreenO05Table({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("테이블 관리")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                const Text("총 좌석 수: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                const SizedBox(width: 100, child: TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText: "10"))),
                const SizedBox(width: 16),
                FilledButton(onPressed: () {}, child: const Text("적용")),
              ],
            ),
            const Divider(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.5, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemCount: 15,
                itemBuilder: (context, index) {
                  return Card(
                    color: index < 10 ? Colors.teal[50] : Colors.grey[200],
                    child: Center(child: Text("Table ${index+1}\n(ID: ${1000+index})", textAlign: TextAlign.center)),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ScreenO06Inquiry extends StatelessWidget {
  const ScreenO06Inquiry({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("문의하기", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const TextField(decoration: InputDecoration(hintText: "제목", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: "내용을 자세히 적어주세요.", border: OutlineInputBorder()), maxLines: 5),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.send), label: const Text("보내기"))),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// [Group T] 테이블 (Table)
// ---------------------------------------------------------------------------

// T-01: 스크롤 연동형 메뉴판 (ScrollSpy)
class ScreenT01ScrollSpy extends StatefulWidget {
  const ScreenT01ScrollSpy({super.key});

  @override
  State<ScreenT01ScrollSpy> createState() => _ScreenT01ScrollSpyState();
}

class _ScreenT01ScrollSpyState extends State<ScreenT01ScrollSpy> {
  final List<String> _categories = ["🔥 인기 메뉴", "🍝 파스타", "🍕 피자", "🥗 샐러드", "🍺 음료/주류"];
  final Map<String, int> _itemCounts = {
    "🔥 인기 메뉴": 3,
    "🍝 파스타": 6,
    "🍕 피자": 4,
    "🥗 샐러드": 3,
    "🍺 음료/주류": 5,
  };

  final ScrollController _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;
  bool _isTapScrolling = false;
  final List<double> _offsets = [];

  @override
  void initState() {
    super.initState();
    _calculateOffsets();
    _scrollController.addListener(_onScroll);
  }

  void _calculateOffsets() {
    double currentOffset = 0;
    _offsets.add(0);
    currentOffset += 180; 
    for (int i = 0; i < _categories.length; i++) {
      String cat = _categories[i];
      int count = _itemCounts[cat]!;
      int rows = (count / 3).ceil();
      double sectionHeight = 60.0 + (rows * 240.0) + (rows * 16.0);
      
      if (i < _categories.length - 1) {
        currentOffset += sectionHeight;
        _offsets.add(currentOffset);
      }
    }
  }

  void _onScroll() {
    if (_isTapScrolling) return;
    double offset = _scrollController.offset;
    for (int i = _categories.length - 1; i >= 0; i--) {
      if (offset >= _offsets[i] - 100) {
        if (_selectedCategoryIndex != i) {
          setState(() => _selectedCategoryIndex = i);
        }
        break;
      }
    }
  }

  void _scrollToCategory(int index) async {
    setState(() {
      _selectedCategoryIndex = index;
      _isTapScrolling = true;
    });
    await _scrollController.animateTo(
      _offsets[index],
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _isTapScrolling = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("1번 테이블 (맛있는 파스타)", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.notifications_active), label: const Text("직원호출")),
          const SizedBox(width: 12),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.receipt), label: const Text("주문내역")),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 100,
            child: NavigationRail(
              selectedIndex: _selectedCategoryIndex,
              onDestinationSelected: _scrollToCategory,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.9,
              destinations: _categories.map((cat) {
                IconData icon = Icons.circle;
                if (cat.contains("인기")) icon = Icons.local_fire_department;
                else if (cat.contains("파스타")) icon = Icons.lunch_dining;
                else if (cat.contains("피자")) icon = Icons.local_pizza;
                else if (cat.contains("샐러드")) icon = Icons.grass;
                else if (cat.contains("음료")) icon = Icons.local_drink;

                return NavigationRailDestination(
                  icon: Icon(icon),
                  selectedIcon: Icon(icon, color: Colors.teal),
                  label: Text(cat.split(" ")[1], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 150,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text("📢 배너 슬라이드 (가로 꽉 참)")),
                  ),
                ),
                for (int i = 0; i < _categories.length; i++) ...[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverHeaderDelegate(title: _categories[i], color: Colors.white),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 40, color: Colors.grey))),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${_categories[i].split(" ")[1]} ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("${12000 + index * 500}원", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        childCount: _itemCounts[_categories[i]]!,
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.teal,
                    width: double.infinity,
                    child: const Text("장바구니", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView(
                      children: const [
                        ListTile(title: Text("파스타 1"), subtitle: Text("1개"), trailing: Text("12,000")),
                        ListTile(title: Text("콜라"), subtitle: Text("2개"), trailing: Text("4,000")),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
                    child: Column(
                      children: [
                        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("합계"), Text("16,000원", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 16),
                        SizedBox(width: double.infinity, height: 56, child: FilledButton(onPressed: () {}, child: const Text("주문하기"))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final Color color;
  _SliverHeaderDelegate({required this.title, required this.color});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
  @override double get maxExtent => 60.0;
  @override double get minExtent => 60.0;
  @override bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) => oldDelegate.title != title;
}

class ScreenT02Option extends StatelessWidget {
  const ScreenT02Option({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600, height: 500,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)]),
        child: Row(
          children: [
            Expanded(child: Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 100, color: Colors.grey))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("해물 파스타", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text("12,000원", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const Divider(height: 32),
                    const Text("옵션 선택", style: TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile(value: 1, groupValue: 1, onChanged: (v) {}, title: const Text("매운맛")),
                    RadioListTile(value: 2, groupValue: 1, onChanged: (v) {}, title: const Text("순한맛")),
                    const Spacer(),
                    SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: () {}, child: const Text("담기")))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// T-03: 장바구니/결제 (일괄/개별 결제 옵션 포함)
class ScreenT03Cart extends StatefulWidget {
  const ScreenT03Cart({super.key});
  @override
  State<ScreenT03Cart> createState() => _ScreenT03CartState();
}

class _ScreenT03CartState extends State<ScreenT03Cart> {
  int _paymentMode = 0; // 0: 일괄, 1: 개별
  final List<Map<String, dynamic>> _items = [
    {"name": "해물 파스타", "price": 12000, "qty": 1},
    {"name": "제로 콜라", "price": 2000, "qty": 1},
    {"name": "마르게리타 피자", "price": 18000, "qty": 1},
  ];
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _selectAll();
  }

  void _selectAll() {
    _selectedIndices.clear();
    for (int i = 0; i < _items.length; i++) _selectedIndices.add(i);
  }

  @override
  Widget build(BuildContext context) {
    int grandTotal = 0;
    for (var item in _items) grandTotal += (item["price"] as int) * (item["qty"] as int);

    int selectedTotal = 0;
    if (_paymentMode == 0) {
      selectedTotal = grandTotal;
    } else {
      for (int i in _selectedIndices) selectedTotal += (_items[i]["price"] as int) * (_items[i]["qty"] as int);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("주문 및 결제 확인")),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("주문 내역", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        bool isSelected = _paymentMode == 0 ? true : _selectedIndices.contains(index);
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.teal : Colors.grey[300]!, width: isSelected ? 2 : 1)),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: _paymentMode == 0 ? null : (v) => setState(() => v! ? _selectedIndices.add(index) : _selectedIndices.remove(index)),
                            activeColor: Colors.teal,
                            title: Text(item["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${item["price"]}원 x ${item["qty"]}개"),
                            secondary: Text("${item["price"] * item["qty"]}원", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Container(
            width: 380,
            color: Colors.white,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("결제 방식 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  height: 50,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _paymentMode = 0; _selectAll(); }),
                          child: Container(
                            decoration: BoxDecoration(color: _paymentMode == 0 ? Colors.teal : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: Text("일괄 결제", style: TextStyle(color: _paymentMode == 0 ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _paymentMode = 1; _selectedIndices.clear(); }),
                          child: Container(
                            decoration: BoxDecoration(color: _paymentMode == 1 ? Colors.teal : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: Text("개별 결제", style: TextStyle(color: _paymentMode == 1 ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_paymentMode == 1) const Padding(padding: EdgeInsets.only(top: 12), child: Text("* 리스트에서 결제할 메뉴를 선택해주세요.", style: TextStyle(color: Colors.orange, fontSize: 13))),
                const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("총 주문 금액", style: TextStyle(color: Colors.grey)), Text("$grandTotal원", style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough))]),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("결제할 금액", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("$selectedTotal원", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal))]),
                const SizedBox(height: 32),
                SizedBox(height: 60, child: FilledButton(onPressed: selectedTotal > 0 ? () {} : null, child: Text(_paymentMode == 0 ? "$selectedTotal원 결제하기" : "선택 금액($selectedTotal원) 결제", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScreenT04StaffCall extends StatelessWidget {
  const ScreenT04StaffCall({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500, height: 400,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: GridView.count(crossAxisCount: 3, padding: const EdgeInsets.all(24), mainAxisSpacing: 16, crossAxisSpacing: 16, children: List.generate(6, (index) => Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey)), child: const Center(child: Icon(Icons.notifications))))),
      ),
    );
  }
}

class ScreenT05AdminAuth extends StatelessWidget {
  const ScreenT05AdminAuth({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350, padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red)),
        child: Column(children: const [Icon(Icons.lock, size: 48, color: Colors.red), SizedBox(height: 16), Text("관리자 PIN 입력"), SizedBox(height: 16), TextField(obscureText: true, decoration: InputDecoration(border: OutlineInputBorder()))]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// [Group K] 주방 (Kitchen)
// ---------------------------------------------------------------------------

class ScreenK01KDS extends StatelessWidget {
  const ScreenK01KDS({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      appBar: AppBar(title: const Text("KDS SYSTEM"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              color: index == 0 ? Colors.red[900] : Colors.grey[800],
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black26,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("T-${index+1}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), const Text("05:00", style: TextStyle(color: Colors.white))]),
                  ),
                  Expanded(child: Center(child: Text("주문 상세 내용...", style: TextStyle(color: Colors.white70)))),
                  SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: () {}, child: const Text("조리 완료")))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}