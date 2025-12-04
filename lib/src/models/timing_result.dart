/// Immutable timing result model
class TimingResult {
  final String operation;
  final int duration;

  const TimingResult(this.operation, this.duration);

  @override
  String toString() => '$operation: ${duration}ms';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimingResult &&
          runtimeType == other.runtimeType &&
          operation == other.operation &&
          duration == other.duration;

  @override
  int get hashCode => operation.hashCode ^ duration.hashCode;
}
