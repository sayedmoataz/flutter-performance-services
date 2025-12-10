# performance_monitor

[![Pub](https://img.shields.io/badge/pub.dev-published-brightgreen)](https://pub.dev/packages/performance_monitor)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Test Coverage](https://img.shields.io/badge/coverage-95%25-brightgreen.svg)](https://pub.dev/packages/performance_monitor/score)
Flutter Performance Monitor with Optional Smart Cache

Lightweight timing utilities for measuring startup and async operations, plus an optional cache layer to deduplicate expensive calls.

## Installation

Install the package from pub.dev or add it to your project:

- pubspec.yaml
```
  dependencies:
    performance_monitor: ^1.1.0
```
- CLI

  ```flutter pub add performance_monitor```

## Quick Start

### 1) Time your app startup (Timing-only)

```dart
import 'package:performance_monitor/performance_monitor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start total startup timing
  PerformanceMonitor.startTimer('App Startup');

  // Measure essential startup services
  await PerformanceMonitor.measureAsync('Essential Services', () async {
    // Replace with actual startup tasks, e.g. Firebase.initializeApp(), config loading, etc.
    await Future.delayed(const Duration(milliseconds: 300));
  });

  // Optional: render UI after timing measurements begin
  runApp(const MyApp());

  // End startup timing and print report
  PerformanceMonitor.endTimer('App Startup');
  PerformanceMonitor.printTimingReport();
}
```

### 2) Smart caching (optional, deduplicates API calls)

- Initialize the cache service (wrapper is optional but recommended)
```dart
final perf = PerformanceOptimizationService.instance;
await perf.initialize();
```

- Use the cache to load data with deduplication
```dart
final userData = await perf.getCachedOrLoad(
  'user_profile',
  () => fetchUserProfile(), // your loader returning Future<T>
);
```

Notes:
- The caching layer is optional. PerformanceMonitor remains focused on timing; the cache layer provides deduplication for expensive calls when needed.
- The sample demonstrates that the first call incurs latency, while subsequent calls reuse the cached result.

## Sample Output

```
📊 PERFORMANCE REPORT
==================================================
App Startup                  :  350ms 28.1%
Essential Services           :  300ms 24.0%
Smart Cache Demo             :  218ms 17.4%
Total App Startup            :  868ms 100.0%
==================================================
TOTAL: 868ms
```

## API Reference

### PerformanceMonitor

- measureAsync: Measure async operations
  await PerformanceMonitor.measureAsync('API Call', apiCall);

- startTimer / endTimer: Manual timing blocks
  PerformanceMonitor.startTimer('Long Task');
  // ...
  PerformanceMonitor.endTimer('Long Task');

- getSlowestOperation(thresholdMs)```final slowest = PerformanceMonitor.getSlowestOperation(100);```

- getSlowOperations(thresholdMs)
    ```final slowOps = PerformanceMonitor.getSlowOperations(100);```

- printTimingReport: Print detailed timing report (percentages)

### PerformanceOptimizationService

- initialize: Initialize the caching layer (call once, typically at startup)
    ```await PerformanceOptimizationService.instance.initialize();```

- getCachedOrLoad(key, loader, { expiryAfter })
    ```final data = await perf.getCachedOrLoad('key', expensiveLoader);```

- clearCache(key), clearAllCache: Manual eviction controls
    ```
    perf.clearCache('key');
    perf.clearAllCache();
    ```

## Example

Complete example usage is demonstrated in the [example/lib/main.dart](example/lib/main.dart). The app shows:

- Measuring total startup time
- Timing essential async startup operations
- Optional smart caching demo with a first slow call followed by cached reuse

Build and Run

- Navigate to the example project:
  ```cd example```
- Get dependencies and run:
  ```
  flutter pub get
  flutter run
  ```

Migration Notes

- Version 1.1.0 introduces a simplified, Future-based cache layer that prevents duplicate API calls by caching the underlying Future. Timing functionality remains the core feature of PerformanceMonitor.
- The pubspec version should be bumped to 1.1.0 to reflect the new API and behavior.
- Documentation emphasizes the optional nature of the caching layer and provides clear Quick Start usage for both timing and caching scenarios.


## 🤝 Contributing

1. Fork the repo
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing-feature`)
5. Open Pull Request


## 📄 License

[MIT](LICENSE)

