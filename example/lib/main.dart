import 'package:flutter/material.dart';
import 'package:performance_monitor/performance_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PerformanceMonitor.startTimer('Total App Startup');

  await PerformanceMonitor.measureAsync('Essential Services', () async {
    await Future.delayed(const Duration(milliseconds: 300));
  });

  final perf = PerformanceOptimizationService.instance;
  await perf.initialize();

  await PerformanceMonitor.measureAsync('Smart Cache Demo', () async {
    await perf.getCachedOrLoad('user_profile', () async {
      await Future.delayed(const Duration(milliseconds: 200));
      return {'name': 'Demo User', 'id': 123};
    });
  });

  runApp(const PerformanceMonitorExampleApp());

  PerformanceMonitor.endTimer('Total App Startup');
  PerformanceMonitor.printTimingReport();
}

class PerformanceMonitorExampleApp extends StatelessWidget {
  const PerformanceMonitorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Monitor Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitor'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Check console for performance report!\nSmart caching working\n⏱All operations timed',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const ElevatedButton(
              onPressed: PerformanceMonitor.printTimingReport,
              child: Text('Refresh Report'),
            ),
            ElevatedButton(
              onPressed: () async {
                await PerformanceMonitor.measureAsync('Manual Test', () async {
                  await Future.delayed(const Duration(seconds: 1));
                });
                PerformanceMonitor.printTimingReport();
              },
              child: const Text('Run Manual Test'),
            ),
          ],
        ),
      ),
    );
  }
}
