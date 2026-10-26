import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'database/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseHelper.instance.database;

  final columns = await db.rawQuery(
    'PRAGMA table_info(categories)',
  );

  debugPrint('Cấu trúc bảng categories: $columns');

  final indexes = await db.rawQuery(
    'PRAGMA index_list(categories)',
  );

  debugPrint('Danh sách index: $indexes');

  try {
    await DatabaseHelper.instance.ensureCategories();
    debugPrint('Khởi tạo danh mục thành công!');

    final categories =
    await DatabaseHelper.instance.getCategories('Chi tiêu');

    debugPrint('DANH MỤC CHI TIÊU: $categories');
    
  } catch (e) {
    debugPrint('LỖI SQLITE: $e');
  }

  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý thu chi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1760E8)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}
