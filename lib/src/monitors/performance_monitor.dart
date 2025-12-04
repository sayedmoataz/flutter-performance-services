import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:performance_monitor/src/models/timing_result.dart';

/// Performance monitoring with detailed timing reports
/// Single Responsibility: Timing & profiling only
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = <String, Stopwatch>{};
  static final Map<String, int> _timings = <String, int>{};
  static final List<String> _timingOrder = <String>[];

  /// Start timing an operation
  static void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
    if (!_timingOrder.contains(operation)) {
      _timingOrder.add(operation);
    }
  }

  /// End timing and log result
  static void endTimer(String operation) {
    final timer = _timers.remove(operation);
    if (timer == null) return;

    timer.stop();
    final duration = timer.elapsedMilliseconds;
    _timings[operation] = duration;

    if (kDebugMode) {
      log('⏱️ $operation: ${duration}ms', name: 'PerformanceMonitor');
    }
  }

  /// Measure async operation (RAII pattern)
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() task,
  ) async {
    startTimer(operation);
    try {
      return await task();
    } finally {
      endTimer(operation);
    }
  }

  /// Detailed timing report with percentages
  static void printTimingReport() {
    if (_timings.isEmpty) {
      log('No timing data', name: 'PerformanceMonitor');
      return;
    }

    final results = getTimingResults();
    final totalTime = results.fold<int>(0, (sum, r) => sum + r.duration);

    log('📊 PERFORMANCE REPORT', name: 'PerformanceMonitor');
    log('='.padRight(50, '='), name: 'PerformanceMonitor');

    for (final result in results) {
      final pct = totalTime > 0
          ? (result.duration / totalTime * 100).toStringAsFixed(1)
          : '0.0';
      log(
        '${result.operation.padRight(30)}: ${result.duration.toString().padLeft(4)}ms '
        '${pct.padLeft(5)}%',
        name: 'PerformanceMonitor',
      );
    }

    log('='.padRight(50, '='), name: 'PerformanceMonitor');
    log(
      'TOTAL: ${totalTime.toString().padLeft(4)}ms',
      name: 'PerformanceMonitor',
    );
  }

  /// Get timing results as immutable list (Open for extension)
  static List<TimingResult> getTimingResults() {
    return _timingOrder
        .map((op) => TimingResult(op, _timings[op] ?? 0))
        .toList();
  }

  /// Get slowest operation
  static String? getSlowestOperation([int thresholdMs = 100]) {
    final slowOnes = getSlowOperations(thresholdMs);
    return slowOnes.isNotEmpty ? slowOnes.first : null;
  }

  /// Operations slower than threshold
  static List<String> getSlowOperations(int thresholdMs) {
    return _timings.entries
        .where((e) => e.value > thresholdMs)
        .map((e) => e.key)
        .toList();
  }

  /// Clear all timing data
  static void clear() {
    _timers.clear();
    _timings.clear();
    _timingOrder.clear();
  }
}
