import 'package:flutter/material.dart';
import '../state/github_controller.dart';
import '../state/network_log_controller.dart';
import '../state/weather_controller.dart';
import 'tabs/github_tab.dart';
import 'tabs/weather_tab.dart';
import 'widgets/network_console_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final NetworkLogController _logController;
  late final WeatherController _weatherController;
  late final GitHubController _githubController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _logController = NetworkLogController();
    _weatherController = WeatherController(logController: _logController);
    _githubController = GitHubController(logController: _logController);

    // Initial demo load: Talca weather
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _weatherController.loadTalca();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weatherController.dispose();
    _githubController.dispose();
    _logController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _logController,
      builder: (context, _) {
        final showConsole = _logController.showConsole;
        final logCount = _logController.logs.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('REST API PoC'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.wb_sunny_outlined),
                  text: 'Open-Meteo (No Auth)',
                ),
                Tab(
                  icon: Icon(Icons.code_rounded),
                  text: 'GitHub (Auth / Public)',
                ),
              ],
            ),
            actions: [
              // Toggle Console Button
              Semantics(
                label: showConsole ? 'Hide Network Console' : 'Show Network Console',
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: showConsole ? Colors.green.shade800 : Colors.grey.shade700,
                    backgroundColor: showConsole ? Colors.green.shade50 : Colors.grey.shade200,
                  ),
                  icon: Icon(
                    showConsole ? Icons.terminal_rounded : Icons.terminal_outlined,
                    size: 18,
                  ),
                  label: Row(
                    children: [
                      Text(showConsole ? 'Console: ON' : 'Console: OFF'),
                      if (logCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: showConsole ? Colors.green.shade700 : Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$logCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onPressed: _logController.toggleConsole,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    WeatherTab(controller: _weatherController),
                    GitHubTab(controller: _githubController),
                  ],
                ),
              ),
              // Live Network Console (Collapsible / Toggleable)
              NetworkConsoleSheet(logController: _logController),
            ],
          ),
          // Subtle floating quick-action when console is hidden
          floatingActionButton: !showConsole
              ? FloatingActionButton.extended(
                  onPressed: _logController.toggleConsole,
                  icon: const Icon(Icons.terminal_rounded),
                  label: Text('Open Console ($logCount)'),
                  tooltip: 'Show HTTP Network Console',
                )
              : null,
        );
      },
    );
  }
}
