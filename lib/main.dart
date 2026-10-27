import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'welcome_screen.dart';
import 'app_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.ensureCategories();
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Expense Manager',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: appBlue),
      scaffoldBackgroundColor: appBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white,
        foregroundColor: appInk, surfaceTintColor: Colors.white),
    ),
    home: const WelcomeScreen(),
  );
}
