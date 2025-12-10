import 'package:flutter/material.dart';
import 'package:performance_monitor/performance_monitor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start total startup timing
  PerformanceMonitor.startTimer('Total App Startup');

  // Essential services (before runApp) – measurement only
  await PerformanceMonitor.measureAsync('Essential Services', () async {
    // Simulate some essential startup work
    await Future.delayed(const Duration(milliseconds: 300));
  });

  // Optional: warm up cache layer
  final perf = PerformanceOptimizationService.instance;
  await perf.initialize();

  // Simulate an expensive call that will be cached
  await PerformanceMonitor.measureAsync('Smart Cache Demo', () async {
    await perf.getCachedOrLoad('user_profile', () async {
      await Future.delayed(const Duration(milliseconds: 200));
      return {'name': 'Demo User', 'id': 123};
    });
  });

  // Render UI
  runApp(const PerformanceMonitorExampleApp());

  // Finish total startup timing and print report
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

  Future<void> _runCacheDemo() async {
    final perf = PerformanceOptimizationService.instance;

    // First call triggers the loader
    await PerformanceMonitor.measureAsync('Cache Demo - first call', () async {
      await perf.getCachedOrLoad('demo_cache', () async {
        await Future.delayed(const Duration(milliseconds: 500));
        return 'heavy_result';
      });
    });

    // Second call returns instantly from cache
    await PerformanceMonitor.measureAsync('Cache Demo - second call', () async {
      await perf.getCachedOrLoad<String>('demo_cache', () async {
        throw Exception('This should not be called if cache works!');
      });
    });

    PerformanceMonitor.printTimingReport();
  }

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
                  'Check console for performance report\n'
                  '⏱ Measures startup & manual operations\n'
                  'Optional smart caching demo included',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const ElevatedButton(
              onPressed: PerformanceMonitor.printTimingReport,
              child: Text('Refresh Report'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await PerformanceMonitor.measureAsync('Manual Test', () async {
                  await Future.delayed(const Duration(seconds: 1));
                });
                PerformanceMonitor.printTimingReport();
              },
              child: const Text('Run Manual Timing Test'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _runCacheDemo,
              child: const Text('Run Cache Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
