import 'dart:async';

/// Smart caching service that prevents duplicate async calls by
/// caching the underlying Future.
///
/// Note: Caching completed futures increases memory usage and can
/// affect performance characteristics. Use consciously.
class CacheService {
  CacheService._internal();
  static final CacheService instance = CacheService._internal();

  /// Stores Futures keyed by string.
  /// Once a Future completes, its value is cached inside the Future itself.
  final Map<String, Future<dynamic>> _futures = {};

  /// Get cached data or load it if not cached.
  ///
  /// The [loader] will be invoked at most once per [key].
  Future<T> getCachedOrLoad<T>(
    String key,
    Future<T> Function() loader, {
    Duration? expiryAfter,
  }) {
    final existing = _futures[key];
    if (existing != null) {
      // The existing future already has the correct type,
      // we just need to cast the resolved value
      return existing.then((value) => value as T);
    }

    // Create and store the new future
    final future = loader();
    _futures[key] = future;

    if (expiryAfter != null) {
      _scheduleExpiry(key, expiryAfter);
    }

    return future;
  }

  void _scheduleExpiry(String key, Duration duration) {
    Timer(duration, () => clearCache(key));
  }

  void clearCache(String key) {
    _futures.remove(key);
  }

  void clearAllCache() {
    _futures.clear();
  }

  int get cacheSize => _futures.length;

  Iterable<String> get cacheKeys => _futures.keys;
}
