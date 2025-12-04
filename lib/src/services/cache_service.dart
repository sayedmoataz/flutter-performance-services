import 'dart:async';

/// Smart caching service that prevents duplicate API calls
/// Follows Single Responsibility Principle (SRP)
class CacheService {
  CacheService._internal();
  static final CacheService instance = CacheService._internal();

  final Map<String, dynamic> _cache = <String, dynamic>{};
  final Map<String, Completer<dynamic>> _loadingTasks =
      <String, Completer<dynamic>>{};

  /// Get cached data or load it if not cached
  ///
  /// ```
  /// final data = await CacheService.instance.getCachedOrLoad(
  ///   'user_profile',
  ///   () => api.fetchUser()
  /// );
  /// ```
  Future<T> getCachedOrLoad<T>(
    String key,
    Future<T> Function() loader, {
    Duration? expiryAfter,
  }) async {
    // Dependency Inversion: External loader strategy
    if (_loadingTasks.containsKey(key)) {
      return await _loadingTasks[key]!.future as T;
    }

    final cached = _cache[key];
    if (cached != null) {
      return cached as T;
    }

    final completer = Completer<T>();
    _loadingTasks[key] = completer;

    try {
      final result = await loader();
      _cache[key] = result;
      completer.complete(result);

      // Optional expiry (Open/Closed Principle)
      if (expiryAfter != null) {
        _scheduleExpiry(key, expiryAfter);
      }

      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _loadingTasks.remove(key);
    }
  }

  void _scheduleExpiry(String key, Duration duration) {
    Timer(duration, () => clearCache(key));
  }

  /// Clear cache for specific key
  void clearCache(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  void clearAllCache() {
    _cache.clear();
  }

  /// Cache size getter (Open for extension)
  int get cacheSize => _cache.length;

  /// Cache keys (Interface Segregation)
  Iterable<String> get cacheKeys => _cache.keys;
}
