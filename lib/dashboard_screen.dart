import 'package:flutter/material.dart';
import 'app_ui.dart';
import 'database/database_helper.dart';
import 'transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  final db = DatabaseHelper.instance;
  int _tab = 0;
  int _income = 0;
  int _expense = 0;
  int _budget = 0;
  String _name = 'bạn';
  bool _loading = true;
  String? _error;
  List<Map<String, Object?>> _transactions = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final summary = await db.getSummary();
      final items = await db.getTransactions();
      final budget = await db.getSetting('monthly_budget');
      final name = await db.getSetting('profile_name');
      if (!mounted) return;
      setState(() {
        _income = summary['income'] ?? 0;
        _expense = summary['expense'] ?? 0;
        _transactions = items;
        _budget = int.tryParse(budget ?? '') ?? 0;
        _name = (name?.isNotEmpty ?? false) ? name! : 'bạn';
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }
  Future<void> _edit([int? id]) async {
    final changed = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => TransactionScreen(transactionId: id)));
    if (changed == true) await _load();
  }
  Widget _balanceCard() => Container(
    height: 155, width: double.infinity,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(colors: [Color(0xFF4688F9), Color(0xFF0D54DD)])),
    child: Stack(children: [
      Positioned(right: 18, top: 24, child: Icon(Icons.account_balance_wallet_rounded,
        color: Colors.white.withOpacity(.25), size: 103)),
      Positioned(right: 51, top: 17, child: Transform.rotate(angle: -.2,
        child: const Icon(Icons.payments_rounded, color: Color(0xFF8FE1A4), size: 55))),
      Positioned.fill(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SỐ DƯ HIỆN TẠI  ◉', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 13),
          FittedBox(child: Text(money(_income - _expense), style: const TextStyle(
            color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900))),
        ]))),
      Positioned(bottom: 9, left: 0, right: 0, child: Row(
        mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 15, height: 5, decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8))),
          for (var i = 0; i < 3; i++) Padding(padding: const EdgeInsets.only(left: 5),
            child: CircleAvatar(radius: 2.5, backgroundColor: Colors.white.withOpacity(.4))),
        ])),
    ]),
  );
  Widget _summaryCard(bool income) => Expanded(child: Container(
    height: 85, padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: income ? const Color(0xFFEAF8EE) : const Color(0xFFFFEBEF),
      borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      CircleAvatar(radius: 18, backgroundColor: income ? const Color(0xFFB7EAC5) : const Color(0xFFFFBAC4),
        child: Icon(income ? Icons.arrow_circle_down : Icons.arrow_circle_up,
          color: income ? appGreen : appRed, size: 30)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, children: [
        FittedBox(child: Text(income ? 'TỔNG THU NHẬP' : 'TỔNG CHI TIÊU',
          style: const TextStyle(fontSize: 10, color: Color(0xFF8793A2)))),
        const SizedBox(height: 5),
        FittedBox(child: Text(money(income ? _income : _expense), style: TextStyle(
          fontWeight: FontWeight.w800, fontSize: 15, color: income ? appGreen : appRed))),
      ])),
    ]),
  ));
  Widget _home() => ListView(padding: const EdgeInsets.fromLTRB(16, 15, 16, 100), children: [
    Text('Xin chào, $_name! 👋', style: const TextStyle(fontSize: 19,
      fontWeight: FontWeight.w800, color: appInk)),
    const Text('Hôm nay là một ngày tuyệt vời để quản lý tài chính',
      style: TextStyle(fontSize: 11, color: Color(0xFF8995A7))),
    const SizedBox(height: 15),
    _balanceCard(),
    const SizedBox(height: 12),
    Row(children: [_summaryCard(true), const SizedBox(width: 9), _summaryCard(false)]),
    if (_budget > 0) ...[
      const SizedBox(height: 12),
      Builder(builder: (_) {
        final now = DateTime.now();
        final monthExpense = _transactions.where((t) {
          final d = DateTime.tryParse('${t['date']}');
          return t['type'] == 'Chi tiêu' && d != null &&
            d.year == now.year && d.month == now.month;
        }).fold<int>(0, (sum, t) => sum + (t['amount'] as num).toInt());
        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ngân sách tháng: ${money(monthExpense)} / ${money(_budget)}',
              style: const TextStyle(fontSize: 12, color: appInk)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (monthExpense / _budget).clamp(0.0, 1.0),
              color: monthExpense > _budget ? appRed : appBlue,
              backgroundColor: const Color(0xFFE5ECF8), minHeight: 7),
          ]));
      }),
    ],
    const SizedBox(height: 19),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Giao dịch gần đây', style: TextStyle(fontSize: 16,
        fontWeight: FontWeight.w800, color: appInk)),
      TextButton(onPressed: () => setState(() => _tab = 1),
        child: const Text('Xem tất cả', style: TextStyle(fontSize: 12))),
    ]),
    if (_transactions.isEmpty) emptyTransactions() else
      ClipRRect(borderRadius: BorderRadius.circular(14), child: Column(children: [
        for (var i = 0; i < _transactions.take(5).length; i++) ...[
          TransactionTile(item: _transactions[i],
            onTap: () => _edit((_transactions[i]['id'] as num).toInt())),
          if (i < _transactions.take(5).length - 1)
            const Divider(height: 1, indent: 60),
        ],
      ])),
  ]);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: _tab == 0 ? Builder(builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()))
        : IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _tab = 0)),
      title: Text(['Quản lý thu chi', 'Giao dịch', 'Thống kê', 'Cá nhân'][_tab],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      centerTitle: _tab != 0,
      actions: _tab == 0 ? [IconButton(icon: const Icon(Icons.notifications_none),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có thông báo mới'))))] : null,
    ),
    drawer: Drawer(child: SafeArea(child: ListView(children: [
      const DrawerHeader(child: Center(child: Text('Expense Manager',
        style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: appBlue)))),
      for (var i = 0; i < 4; i++) ListTile(
        leading: Icon([Icons.home, Icons.receipt_long, Icons.pie_chart, Icons.person][i]),
        title: Text(['Trang chủ', 'Giao dịch', 'Thống kê', 'Cá nhân'][i]),
        onTap: () { Navigator.pop(context); setState(() => _tab = i); },
      ),
    ]))),
    body: _loading ? const Center(child: CircularProgressIndicator()) :
      _error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Lỗi SQLite: $_error', textAlign: TextAlign.center),
        TextButton(onPressed: _load, child: const Text('Thử lại')),
      ])) : RefreshIndicator(onRefresh: _load, child: switch (_tab) {
        0 => _home(),
        1 => TransactionListScreen(transactions: _transactions,
          onEdit: (id) => _edit(id)),
        2 => StatisticsScreen(transactions: _transactions),
        _ => ProfileScreen(onChanged: () { _load(); }),
      }),
    floatingActionButton: _tab <= 1 ? FloatingActionButton(
      backgroundColor: appBlue, foregroundColor: Colors.white,
      shape: const CircleBorder(), onPressed: () => _edit(),
      child: const Icon(Icons.add, size: 30)) : null,
    bottomNavigationBar: NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE4EEFF),
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: appBlue), label: 'Trang chủ'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long, color: appBlue), label: 'Giao dịch'),
        NavigationDestination(icon: Icon(Icons.pie_chart_outline),
          selectedIcon: Icon(Icons.pie_chart, color: appBlue), label: 'Thống kê'),
        NavigationDestination(icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: appBlue), label: 'Cá nhân'),
      ],
    ),
  );
}
