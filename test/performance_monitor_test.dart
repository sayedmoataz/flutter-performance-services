import 'package:flutter_test/flutter_test.dart';
import 'package:performance_monitor/performance_monitor.dart';

void main() {
  group('PerformanceOptimizationService', () {
    late PerformanceOptimizationService service;

    setUp(() {
      service = PerformanceOptimizationService.instance;
    });

    test('initialize completes successfully', () async {
      await service.initialize();
      expect(service.isInitialized, true);
    });

    test('initialize is idempotent', () async {
      await service.initialize();
      await service.initialize(); // Call twice
      expect(service.isInitialized, true);
    });
  });

  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService.instance;
      cacheService.clearAllCache();
    });

    test('getCachedOrLoad caches data and prevents duplicate calls', () async {
      int callCount = 0;
      Future<String> loader() async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return 'cached_data';
      }

      // First call - loads data
      final result1 = await cacheService.getCachedOrLoad('test_key', loader);
      expect(result1, 'cached_data');
      expect(callCount, 1);
      expect(cacheService.cacheSize, 1);

      // Second call - returns cached data
      final result2 = await cacheService.getCachedOrLoad('test_key', loader);
      expect(result2, 'cached_data');
      expect(callCount, 1); // No additional calls!
      expect(cacheService.cacheSize, 1);
    });

    test('getCachedOrLoad handles concurrent requests', () async {
      int callCount = 0;
      Future<String> loader() async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return 'concurrent_data';
      }

      // Multiple concurrent requests
      final futures = List.generate(
          3, (i) => cacheService.getCachedOrLoad('concurrent_key_$i', loader));

      final results = await Future.wait(futures);
      expect(results.every((r) => r == 'concurrent_data'), true);
      expect(callCount, 3); // Each key called once
      expect(cacheService.cacheSize, 3);
    });

    test('getCachedOrLoad propagates errors', () => throwsA(isA<Exception>()));
    test('clearCache removes specific key', () async {
      await cacheService.getCachedOrLoad('to_clear', () async => 'data');
      cacheService.clearCache('to_clear');
      expect(cacheService.cacheSize, 0);
    });

    test('clearAllCache clears everything', () async {
      await cacheService.getCachedOrLoad('key1', () async => 'data1');
      await cacheService.getCachedOrLoad('key2', () async => 'data2');
      cacheService.clearAllCache();
      expect(cacheService.cacheSize, 0);
    });
  });

  group('PerformanceMonitor', () {
    setUp(PerformanceMonitor.clear);

    test('measureAsync times operations correctly', () async {
      final stopwatch = Stopwatch()..start();
      await PerformanceMonitor.measureAsync('test_op', () async {
        await Future.delayed(const Duration(milliseconds: 30));
      });
      stopwatch.stop();

      final timings = PerformanceMonitor.getTimingResults();
      expect(timings.length, 1);
      expect(timings.first.operation, 'test_op');
      expect(timings.first.duration, greaterThan(20));
      expect(timings.first.duration, lessThan(50));
    });

    test('startTimer/endTimer works manually', () {
      PerformanceMonitor.startTimer('manual');
      Future.delayed(const Duration(milliseconds: 20));
      PerformanceMonitor.endTimer('manual');

      final timings = PerformanceMonitor.getTimingResults();
      expect(timings.length, 1);
      expect(timings.first.operation, 'manual');
      expect(timings.first.duration, greaterThan(15));
    });

    test('getSlowOperations finds slow ops', () async {
      await PerformanceMonitor.measureAsync('fast', () async {});
      await PerformanceMonitor.measureAsync('slow', () async {
        await Future.delayed(const Duration(milliseconds: 120));
      });

      final slowOps = PerformanceMonitor.getSlowOperations(100);
      expect(slowOps, contains('slow'));
      expect(slowOps, isNot(contains('fast')));
    });

    test('getSlowestOperation returns slowest', () async {
      await PerformanceMonitor.measureAsync('medium', () async {
        await Future.delayed(const Duration(milliseconds: 80));
      });
      await PerformanceMonitor.measureAsync('slowest', () async {
        await Future.delayed(const Duration(milliseconds: 150));
      });

      final slowest = PerformanceMonitor.getSlowestOperation(50);
      expect(slowest, 'slowest');
    });

    test('printTimingReport handles empty timings gracefully', () {
      PerformanceMonitor.clear();
      expect(PerformanceMonitor.printTimingReport, returnsNormally);
    });

    test('TimingResult equality works', () {
      const result1 = TimingResult('op1', 100);
      const result2 = TimingResult('op1', 100);
      const result3 = TimingResult('op2', 100);

      expect(result1, equals(result2));
      expect(result1, isNot(equals(result3)));
    });
  });

  group('Integration Tests', () {
    test('Full startup flow works', () async {
      final service = PerformanceOptimizationService.instance;

      // Initialize service
      await service.initialize();

      // Cache some data with timing
      await PerformanceMonitor.measureAsync('cached_api', () async {
        await service.getCachedOrLoad('api_data', () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'api_response';
        });
      });

      // Verify everything
      expect(service.isInitialized, true);
      final timings = PerformanceMonitor.getTimingResults();
      expect(timings.isNotEmpty, true);
    });
  });
}
