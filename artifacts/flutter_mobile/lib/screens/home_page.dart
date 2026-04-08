import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../store/app_store.dart';
import 'dashboard_tab.dart';
import 'timetable_tab.dart';
import 'assignments_tab.dart';
import 'exams_tab.dart';
import 'ai_agent_tab.dart';
import 'settings_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store});

  final AppStore store;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final today = AppStore.days[DateTime.now().weekday - 1];
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/images/icon.svg', 
              width: 24, 
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary, 
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            // Don't show text on smaller screens if we are on dashboard where we have a big header anyway
            const Text('CampusPulse', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsTab(store: store)),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: [
            DashboardTab(store: store, today: today),
            TimetableTab(store: store),
            AssignmentsTab(store: store),
            ExamsTab(store: store),
            AIAgentTab(store: store),  // New AI tab instead of Settings
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule_rounded), label: 'Classes'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school_rounded), label: 'Exams'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Pulse AI'),
        ],
      ),
    );
  }
}
