/// Flutter Performance Monitor & Cache Service
///
/// Reduce app startup from 30+ seconds to <1 second!
///
/// ## Quick Start
/// ```
/// final perf = PerformanceOptimizationService.instance;
/// final data = await perf.getCachedOrLoad('user', () => fetchUser());
/// PerformanceMonitor.measureAsync('Firebase', Firebase.initializeApp);
/// ```
library;

export 'src/models/timing_result.dart';
export 'src/monitors/performance_monitor.dart';
export 'src/services/cache_service.dart';
export 'src/services/performance_service.dart';
