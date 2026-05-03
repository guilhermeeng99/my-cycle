import 'package:equatable/equatable.dart';

enum ConfidenceLevel { low, medium, high }

/// One menstrual cycle — from day 1 of period to day 1 of the next period.
///
/// Date fields ([startDate], [periodEndDate], `predicted*`) are date-only —
/// midnight UTC. Use `core/utils/dates.dart` helpers to construct/serialize.
class Cycle extends Equatable {
  const Cycle({
    required this.id,
    required this.coupleId,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.periodEndDate,
    this.totalLengthDays,
    this.predictedNextStart,
    this.predictedNextStartRangeEnd,
    this.predictedOvulation,
    this.predictionConfidence,
  });

  final String id;
  final String coupleId;
  final DateTime startDate;
  final DateTime? periodEndDate;
  final int? totalLengthDays;
  final DateTime? predictedNextStart;
  final DateTime? predictedNextStartRangeEnd;
  final DateTime? predictedOvulation;
  final ConfidenceLevel? predictionConfidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True while this cycle is the open one (no next cycle has started yet).
  bool get isCurrent => totalLengthDays == null;

  Cycle copyWith({
    String? id,
    String? coupleId,
    DateTime? startDate,
    DateTime? periodEndDate,
    int? totalLengthDays,
    DateTime? predictedNextStart,
    DateTime? predictedNextStartRangeEnd,
    DateTime? predictedOvulation,
    ConfidenceLevel? predictionConfidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cycle(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      startDate: startDate ?? this.startDate,
      periodEndDate: periodEndDate ?? this.periodEndDate,
      totalLengthDays: totalLengthDays ?? this.totalLengthDays,
      predictedNextStart: predictedNextStart ?? this.predictedNextStart,
      predictedNextStartRangeEnd:
          predictedNextStartRangeEnd ?? this.predictedNextStartRangeEnd,
      predictedOvulation: predictedOvulation ?? this.predictedOvulation,
      predictionConfidence: predictionConfidence ?? this.predictionConfidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        coupleId,
        startDate,
        periodEndDate,
        totalLengthDays,
        predictedNextStart,
        predictedNextStartRangeEnd,
        predictedOvulation,
        predictionConfidence,
        createdAt,
        updatedAt,
      ];
}
