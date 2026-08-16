import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/balance_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/glass_bottom_nav.dart';
import 'widgets/glass_sidebar.dart';

/// Shell responsif: BottomNav (mobile), NavRail / Sidebar dengan toggle (desktop/tablet)
class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _isSidebarExpanded = true;

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
        HomeScreen(onNavigateTab: _onNavigateTab),
        const BalanceScreen(),
        const TransactionScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Desktop / Tablet (Layar lebar > 600px)
    if (width > 600) {
      return Scaffold(
        body: Row(
          children: [
            GlassSidebar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              isExpanded: _isSidebarExpanded,
              onToggleExpand: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            ),
            Expanded(child: _screens[_currentIndex]),
          ],
        ),
      );
    }

    // Mobile (< 600px): Bottom Navigation Bar
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
