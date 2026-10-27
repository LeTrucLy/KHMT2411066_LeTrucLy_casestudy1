import 'package:flutter/material.dart';
import 'app_ui.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
      child: Column(children: [
        const Spacer(flex: 2),
        Stack(alignment: Alignment.center, children: [
          Container(width: 156, height: 156, decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(40))),
          const Icon(Icons.account_balance_wallet_rounded, size: 110, color: appBlue),
          const Positioned(top: 8, right: 16, child: Icon(Icons.payments_rounded,
            size: 57, color: appGreen)),
        ]),
        const SizedBox(height: 26),
        const Text('Expense Manager', style: TextStyle(fontSize: 26,
          fontWeight: FontWeight.w800, color: appInk)),
        const SizedBox(height: 13),
        const Text('Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF8A97A9), fontSize: 15, height: 1.6)),
        const Spacer(flex: 3),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: appBlue, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen())),
          child: const Text('Bắt đầu', style: TextStyle(fontWeight: FontWeight.w700)),
        )),
        const SizedBox(height: 20),
      ]),
    )),
  );
}
