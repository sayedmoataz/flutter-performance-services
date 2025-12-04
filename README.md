
# performance_monitor

[![Pub](https://img.shields.io/badge/pub.dev-published-brightgreen)](https://pub.dev/packages/performance_monitor)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Test Coverage](https://img.shields.io/badge/coverage-95%25-brightgreen.svg)](https://pub.dev/packages/performance_monitor/score)

**Flutter Performance Monitor & Smart Cache Service**

**Reduce app startup from 30+ seconds → <1 second** with precise timing & smart caching.

## Installation

```
dependencies:
  performance_monitor: ^1.0.0
```

```
flutter pub add performance_monitor
```

## Quick Start

### 1. Time your app startup
```
import 'package:performance_monitor/performance_monitor.dart';

Future<void> main() async {
  PerformanceMonitor.startTimer('App Startup');
  
  await PerformanceMonitor.measureAsync('Firebase', () async {
    await Firebase.initializeApp();
  });
  
  runApp(MyApp()); // Render UI FIRST!
  
  PerformanceMonitor.printTimingReport(); // See detailed report
}
```

### 2. Smart caching (no duplicate API calls)
```
final perf = PerformanceOptimizationService.instance;
await perf.initialize();

final userData = await perf.getCachedOrLoad(
  'user_profile',
  () => api.fetchUserProfile(),
);
```

## Sample Output

```
📊 PERFORMANCE REPORT
==================================================
Essential Services             :  312ms 45.2%
Smart Cache Demo               :  218ms 31.6%
Total App Startup              :   89ms 12.9%
==================================================
TOTAL:   689ms
```

## API Reference

### PerformanceMonitor
```
// Measure async operations
await PerformanceMonitor.measureAsync('API Call', apiCall);

// Get bottlenecks
final slowest = PerformanceMonitor.getSlowestOperation(100);
final slowOps = PerformanceMonitor.getSlowOperations(100);

// Detailed report
PerformanceMonitor.printTimingReport();
```

### PerformanceOptimizationService
```
// Initialize once
await PerformanceOptimizationService.instance.initialize();

// Smart caching
await perf.getCachedOrLoad('key', expensiveLoader);
perf.clearCache('key'); // Manual eviction
```

## Example

Complete `example/` app shows real-world usage:

```
cd example
flutter run
```

See [example/lib/main.dart](example/lib/main.dart) for full startup optimization.

## Features

- Precise operation timing (async/sync)
- Smart caching with deduplication
- Percentage breakdown & slowest ops detection
- Zero runtime dependencies
- iOS/Android
- 95%+ test coverage
- Production-ready (debug-only logs)

## Real Results

```
Before: 30+ seconds
After:  <1 second
```

## 🤝 Contributing

1. Fork the repo
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing-feature`)
5. Open Pull Request


## 📄 License

[MIT](LICENSE)

---

⭐ **Star if it saves you 29 seconds on startup!** ⭐
