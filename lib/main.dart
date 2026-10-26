
import 'package:flutter/material.dart';
import 'transaction_screen.dart';
import 'dashboard_screen.dart';
import 'database/database_helper.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseHelper.instance.database;

  debugPrint('SQLite kết nối thành công!');

  final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'"
  );

  debugPrint('Danh sách bảng: $tables');

  runApp(const ExpenseManagerApp());
}


class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void openTransaction(BuildContext context, bool isEdit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionScreen(
          isEdit: isEdit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Column(
            children: [
              const Spacer(flex: 4),

              const WalletLogo(),

              const SizedBox(height: 24),

              const Text(
                'Expense Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172842),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Quản lý chi tiêu cá nhân\n'
                    'đơn giản và hiệu quả',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF8B9AB0),
                ),
              ),

              const Spacer(flex: 5),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1967C3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    openTransaction(context, true);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1967C3),
                    side: const BorderSide(
                      color: Color(0xFF1967C3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Sửa giao dịch',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletLogo extends StatelessWidget {
  const WalletLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 115,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 43,
            child: Container(
              width: 71,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF81C784),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 34,
            child: Container(
              width: 69,
              height: 59,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 12,
            child: Container(
              width: 108,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            top: 49,
            right: 0,
            child: Container(
              width: 47,
              height: 29,
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
