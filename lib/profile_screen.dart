import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_ui.dart';
import 'database/database_helper.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const ProfileScreen({super.key, required this.onChanged});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = DatabaseHelper.instance;
  String _name = 'Người dùng';
  String _budget = '';
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final name = await db.getSetting('profile_name') ?? 'Người dùng';
    final budget = await db.getSetting('monthly_budget') ?? '';
    if (mounted) setState(() { _name = name; _budget = budget; });
  }
  Future<void> _editSetting({required String title, required String key,
    required String initial, bool numeric = false}) async {
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(hintText: title)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Lưu')),
      ],
    ));
    controller.dispose();
    if (value == null || !mounted) return;
    if (numeric && (int.tryParse(value) == null || int.parse(value) < 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập ngân sách hợp lệ')));
      return;
    }
    await db.setSetting(key, value);
    await _load();
    widget.onChanged();
  }
  Future<void> _categories() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagerScreen()));
    widget.onChanged();
  }
  Future<void> _backup() async {
    try {
      final json = await db.exportBackupJson();
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã sao chép bản sao lưu JSON. Hãy dán và lưu vào tệp an toàn.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi sao lưu: $e')));
    }
  }
  Widget _menu(IconData icon, String title, String subtitle, VoidCallback onTap,
      {Color color = appInk}) => ListTile(
    leading: Icon(icon, color: color),
    title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    trailing: const Icon(Icons.chevron_right, size: 20),
    onTap: onTap,
  );
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100), children: [
      const CircleAvatar(radius: 40, backgroundColor: Color(0xFFDDE9FF),
        child: Icon(Icons.person, size: 47, color: appBlue)),
      const SizedBox(height: 12),
      Center(child: Text(_name, style: const TextStyle(fontSize: 19,
        fontWeight: FontWeight.w800, color: appInk))),
      const Center(child: Text('Tài khoản sử dụng trên thiết bị',
        style: TextStyle(color: Color(0xFF8B99AC), fontSize: 12))),
      const SizedBox(height: 27),
      Container(decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(15)), child: Column(children: [
        _menu(Icons.person_outline, 'Thông tin cá nhân', 'Đổi tên hiển thị', () =>
          _editSetting(title: 'Tên hiển thị', key: 'profile_name', initial: _name)),
        const Divider(height: 1, indent: 58),
        _menu(Icons.account_balance_wallet_outlined, 'Cài đặt ngân sách',
          _budget.isEmpty ? 'Chưa đặt ngân sách tháng' : 'Ngân sách: ${money(int.tryParse(_budget) ?? 0)}',
          () => _editSetting(title: 'Ngân sách tháng (đ)', key: 'monthly_budget',
            initial: _budget, numeric: true)),
        const Divider(height: 1, indent: 58),
        _menu(Icons.category_outlined, 'Danh mục chi tiêu', 'Xem và thêm danh mục', _categories),
        const Divider(height: 1, indent: 58),
        _menu(Icons.backup_outlined, 'Sao lưu dữ liệu', 'Sao chép dữ liệu JSON', _backup),
        const Divider(height: 1, indent: 58),
        _menu(Icons.info_outline, 'Giới thiệu', 'Expense Manager · Lưu dữ liệu cục bộ', () =>
          showAboutDialog(context: context, applicationName: 'Expense Manager',
            applicationVersion: '1.0', children: [const Text('Ứng dụng quản lý thu chi bằng Flutter và SQLite.')])),
      ])),
      const SizedBox(height: 18),
      TextButton.icon(onPressed: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false),
        icon: const Icon(Icons.logout, color: appRed),
        label: const Text('Về màn hình chào', style: TextStyle(color: appRed))),
    ],
  );
}

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});
  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}
class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  final db = DatabaseHelper.instance;
  String _type = 'Chi tiêu';
  List<Map<String, Object?>> _items = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final items = await db.getCategories(_type);
    if (mounted) setState(() => _items = items);
  }
  Future<void> _add() async {
    final c = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Thêm danh mục'),
      content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Tên danh mục')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        TextButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Thêm'))],
    ));
    c.dispose();
    if (name == null || name.isEmpty) return;
    try { await db.addCategory(name, _type); await _load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }
  Future<void> _delete(int id) async {
    try { await db.deleteCategory(id); await _load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quản lý danh mục')),
    floatingActionButton: FloatingActionButton(onPressed: _add,
      backgroundColor: appBlue, foregroundColor: Colors.white, child: const Icon(Icons.add)),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: SegmentedButton<String>(
        segments: const [ButtonSegment(value: 'Chi tiêu', label: Text('Chi tiêu')),
          ButtonSegment(value: 'Thu nhập', label: Text('Thu nhập'))],
        selected: {_type}, onSelectionChanged: (s) { setState(() => _type = s.first); _load(); })),
      Expanded(child: ListView(children: [for (final c in _items)
        ListTile(leading: Icon(categoryIcon(c['name'] as String), color: appBlue),
          title: Text(c['name'] as String),
          trailing: IconButton(tooltip: 'Xóa', icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete((c['id'] as num).toInt())))])),
    ]),
  );
}
