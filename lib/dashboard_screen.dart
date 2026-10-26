import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'transaction_screen.dart';
import 'statistics_screen.dart';

const _blue = Color(0xFF1762E8);
const _green = Color(0xFF2FB54B);
const _red = Color(0xFFFF4256);
const _ink = Color(0xFF1D2638);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseHelper.instance;
  int _selectedTab = 0;
  int _income = 0;
  int _expense = 0;
  bool _loading = true;
  String? _error;
  List<Map<String, Object?>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final summary = await _db.getSummary();
      final transactions = await _db.getTransactions();
      if (!mounted) return;
      setState(() {
        _income = summary['income'] ?? 0;
        _expense = summary['expense'] ?? 0;
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _openTransaction([int? id]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TransactionScreen(transactionId: id)),
    );
    if (changed == true) await _load();
  }

  String _money(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.',
    );
    return '${negative ? '-' : ''}$digits đ';
  }

  String _displayDate(Object? raw) {
    final date = DateTime.tryParse(raw?.toString() ?? '');
    if (date == null) return raw?.toString() ?? '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  IconData _categoryIcon(String name, bool income) {
    switch (name) {
      case 'Ăn uống': return Icons.restaurant;
      case 'Di chuyển': return Icons.directions_car;
      case 'Mua sắm': return Icons.shopping_cart;
      case 'Học phí': return Icons.school;
      case 'Giải trí': return Icons.movie;
      case 'Lương': return Icons.monetization_on;
      case 'Thưởng': return Icons.workspace_premium;
      default: return income ? Icons.savings : Icons.receipt_long;
    }
  }

  Color _categoryColor(String name, bool income) {
    switch (name) {
      case 'Ăn uống': return const Color(0xFFFF792C);
      case 'Di chuyển': return const Color(0xFF258FF3);
      case 'Mua sắm': return const Color(0xFFAA4AEE);
      case 'Học phí': return const Color(0xFF009A93);
      default: return income ? const Color(0xFF23A53C) : const Color(0xFF6B7C98);
    }
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      height: 156,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF4689FA), Color(0xFF0752D8)],
        ),
        boxShadow: const [BoxShadow(color: Color(0x1B1762E8), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Stack(children: [
        Positioned(right: 20, bottom: 19, child: Icon(
          Icons.account_balance_wallet_rounded, size: 94,
          color: Colors.white.withOpacity(0.27),
        )),
        Positioned(right: 53, top: 26, child: Transform.rotate(
          angle: -0.2,
          child: Icon(Icons.payments_rounded, size: 53, color: const Color(0xFF8FE3A0).withOpacity(0.90)),
        )),
        Center(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('SỐ DƯ HIỆN TẠI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              SizedBox(width: 7), Icon(Icons.visibility_outlined, color: Colors.white, size: 16),
            ]),
            const SizedBox(height: 11),
            FittedBox(fit: BoxFit.scaleDown, child: Text(
              _money(_income - _expense),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
            )),
          ]),
        )),
        Positioned(bottom: 9, left: 0, right: 0, child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 14, height: 5, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 4),
            for (int i = 0; i < 3; i++) Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(radius: 2.5, backgroundColor: Colors.white.withOpacity(0.4)),
            ),
          ],
        )),
      ]),
    );
  }

  Widget _summaryCard({required bool income}) {
    final color = income ? _green : _red;
    return Expanded(child: Container(
      height: 83,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: income ? const Color(0xFFEAF7ED) : const Color(0xFFFFECEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        CircleAvatar(radius: 19, backgroundColor: color.withOpacity(0.20),
          child: CircleAvatar(radius: 14, backgroundColor: color,
            child: Icon(income ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white, size: 19))),
        const SizedBox(width: 8),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text(income ? 'TỔNG THU NHẬP' : 'TỔNG CHI TIÊU',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF78828C)))),
            const SizedBox(height: 5),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text(_money(income ? _income : _expense),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color))),
          ],
        )),
      ]),
    ));
  }

  Widget _transactionTile(Map<String, Object?> item) {
    final income = item['type'] == 'Thu nhập';
    final category = (item['category_name'] as String?) ?? 'Khác';
    final note = (item['note'] as String?)?.trim() ?? '';
    final amount = (item['amount'] as num).toInt();
    final id = (item['id'] as num).toInt();
    final iconColor = _categoryColor(category, income);
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _openTransaction(id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(children: [
            CircleAvatar(radius: 21, backgroundColor: iconColor,
              child: Icon(_categoryIcon(category, income), color: Colors.white, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(note.isEmpty ? category : note, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, color: _ink, fontSize: 14)),
              const SizedBox(height: 5),
              Row(children: [
                Flexible(child: Text(category, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8792A2)))),
                const SizedBox(width: 8),
                Text(_displayDate(item['date']),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8792A2))),
              ]),
            ])),
            const SizedBox(width: 6),
            FittedBox(fit: BoxFit.scaleDown, child: Text(
              '${income ? '+' : '-'}${_money(amount)}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                color: income ? _green : _red),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _transactionsList({required bool all}) {
    final visible = all ? _transactions : _transactions.take(5).toList();
    if (visible.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 18),
        alignment: Alignment.center,
        child: Column(children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFF9EADC1)),
          const SizedBox(height: 10),
          const Text('Chưa có giao dịch nào', style: TextStyle(color: Color(0xFF66758B))),
          const SizedBox(height: 8),
          TextButton(onPressed: () => _openTransaction(), child: const Text('Thêm giao dịch đầu tiên')),
        ]),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Column(children: [
        for (var i = 0; i < visible.length; i++) ...[
          _transactionTile(visible[i]),
          if (i != visible.length - 1) const Divider(height: 1, indent: 60, color: Color(0xFFECEFF4)),
        ],
      ]),
    );
  }

  Widget _homeTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
      children: [
        _balanceCard(),
        const SizedBox(height: 13),
        Row(children: [
          _summaryCard(income: true),
          const SizedBox(width: 9),
          _summaryCard(income: false),
        ]),
        const SizedBox(height: 21),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Giao dịch gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
          TextButton(onPressed: () => setState(() => _selectedTab = 1),
            child: const Text('Xem tất cả', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 4),
        _transactionsList(all: false),
      ],
    );
  }

  Widget _allTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text('Tất cả giao dịch (${_transactions.length})',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 12),
        _transactionsList(all: true),
      ],
    );
  }

  Widget _statRow(String label, int amount, Color color) {
    final total = _income + _expense;
    final ratio = total == 0 ? 0.0 : amount / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(_money(amount), style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 9),
        LinearProgressIndicator(value: ratio, minHeight: 12,
          borderRadius: BorderRadius.circular(12), color: color,
          backgroundColor: const Color(0xFFEBEFF6)),
      ]),
    );
  }

  Widget _statisticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Thống kê thu chi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 16),
        _balanceCard(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            _statRow('Thu nhập', _income, _green),
            _statRow('Chi tiêu', _expense, _red),
            Text('Số giao dịch: ${_transactions.length}',
              style: const TextStyle(color: Color(0xFF66758B))),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        leading: Builder(builder: (ctx) => IconButton(
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          icon: const Icon(Icons.menu, color: _ink),
        )),
        title: const Text('Quản lý thu chi',
          style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Thông báo',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chưa có thông báo mới'))),
            icon: const Icon(Icons.notifications_none_rounded, color: _ink),
          ),
        ],
      ),
      drawer: Drawer(child: SafeArea(child: ListView(children: [
        const DrawerHeader(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.account_balance_wallet_rounded, color: _blue, size: 38),
          SizedBox(height: 12), Text('Quản lý thu chi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ])),
        ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Trang chủ'),
          onTap: () { Navigator.pop(context); setState(() => _selectedTab = 0); }),
        ListTile(leading: const Icon(Icons.receipt_long_outlined), title: const Text('Giao dịch'),
          onTap: () { Navigator.pop(context); setState(() => _selectedTab = 1); }),
        ListTile(leading: const Icon(Icons.pie_chart_outline), title: const Text('Thống kê'),
          onTap: () { Navigator.pop(context); setState(() => _selectedTab = 2); }),
      ]))),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Lỗi đọc SQLite: $_error', textAlign: TextAlign.center),
                TextButton(onPressed: _load, child: const Text('Thử lại')),
              ])))
          : RefreshIndicator(
              onRefresh: _load,
              child: _selectedTab == 0 ? _homeTab()
                  : _selectedTab == 1 ? _allTab() : _statisticsTab(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTransaction(),
        backgroundColor: _blue, foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8F0FF),
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StatisticsScreen(),
              ),
            );
          } else {
            setState(() {
              _selectedTab = index;
            });
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: _blue), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: _blue), label: 'Giao dịch'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart, color: _blue), label: 'Thống kê'),
        ],
      ),
    );
  }
}
