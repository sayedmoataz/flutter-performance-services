import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:performance_monitor/src/services/cache_service.dart';

/// Performance optimization service with pre-warming capabilities
class PerformanceOptimizationService {
  PerformanceOptimizationService._();
  static final PerformanceOptimizationService instance =
      PerformanceOptimizationService._();

  final CacheService _cacheService = CacheService.instance;
  bool _isInitialized = false;

  /// Initialize performance optimizations
  ///
  /// Call this in main() before runApp()
  /// ```
  /// await PerformanceOptimizationService.instance.initialize();
  /// ```
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _preWarmCaches();
      _isInitialized = true;
      if (kDebugMode) {
        log('✅ Performance service initialized', name: 'PerfService');
      }
    } catch (e) {
      log('❌ Perf service init failed: $e', name: 'PerfService');
    }
  }

  Future<void> _preWarmCaches() async {
    // Override in subclasses or add common caches here
  }

  /// Cached data access (delegates to CacheService - Dependency Inversion)
  Future<T> getCachedOrLoad<T>(
    String key,
    Future<T> Function() loader, {
    Duration? expiryAfter,
  }) =>
      _cacheService.getCachedOrLoad(key, loader, expiryAfter: expiryAfter);

  bool get isInitialized => _isInitialized;
  int get cacheSize => _cacheService.cacheSize;
  void clearCache(String key) => _cacheService.clearCache(key);
  void clearAllCache() => _cacheService.clearAllCache();
}
