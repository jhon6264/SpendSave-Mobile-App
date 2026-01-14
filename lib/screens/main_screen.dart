import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'dashboard_screen.dart';
import 'spending_screen.dart';
import 'calendar_screen.dart';
import 'savings_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Screens corresponding to bottom nav items
  static final List<Widget> _screens = [
    const DashboardScreen(),
    SpendingScreen(),
    const CalendarScreen(),
    const SavingsScreen(),
    const SettingsScreen(),
  ];

  // Bottom navigation items
  static final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.house, size: 20),
      activeIcon: FaIcon(FontAwesomeIcons.house, size: 22),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.moneyBillWave, size: 20),
      activeIcon: FaIcon(FontAwesomeIcons.moneyBillWave, size: 22),
      label: 'Spending',
    ),
    BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.calendarDays, size: 20),
      activeIcon: FaIcon(FontAwesomeIcons.calendarDays, size: 22),
      label: 'Calendar',
    ),
    BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.piggyBank, size: 20),
      activeIcon: FaIcon(FontAwesomeIcons.piggyBank, size: 22),
      label: 'Savings',
    ),
    BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.sliders, size: 20),
      activeIcon: FaIcon(FontAwesomeIcons.sliders, size: 22),
      label: 'Settings',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar - we'll handle headers in each screen
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          border: Border(
            top: BorderSide(
              color: AppTheme.glassBorderColor,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}