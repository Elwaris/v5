// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'theme.dart';
import 'screens/journal_screen.dart';
import 'screens/by_pair_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/checklist_editor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(
    ChangeNotifierProvider.value(value: state, child: const ICTJournalApp()),
  );
}

class ICTJournalApp extends StatelessWidget {
  const ICTJournalApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ICT Journal',
        theme: appTheme(),
        home: const HomeShell(),
        debugShowCheckedModeBanner: false,
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  final _screens = const [
    JournalScreen(),
    ByPairScreen(),
    StatsScreen(),
    ChecklistEditorScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _idx, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Journal'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'By Pair'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Checklist'),
          ],
        ),
      );
}
