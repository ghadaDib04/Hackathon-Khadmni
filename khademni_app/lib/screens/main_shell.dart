import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'task/post_task_screen.dart';
import 'task/my_tasks_screen.dart';
import 'wallet/wallet_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Index 0 : Accueil (Feed)
    const PostTaskScreen(), // Index 1 : Poster une mission
    const MyTasksScreen(), // Index 2 : Mes Missions (onglets Postées/Prises)
    const WalletScreen(), // Index 3 : Portefeuille
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'ACCUEIL'),
                _buildNavItem(
                  1,
                  Icons.add_circle_outline,
                  Icons.add_circle,
                  'POSTER',
                ),
                _buildNavItem(
                  2,
                  Icons.assignment_outlined,
                  Icons.assignment,
                  'MISSIONS',
                ),
                _buildNavItem(
                  3,
                  Icons.account_balance_wallet_outlined,
                  Icons.account_balance_wallet,
                  'PORTEFEUILLE',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData iconOutlined,
    IconData iconFilled,
    String label,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.burntOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? iconFilled : iconOutlined,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.burntOrange
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
