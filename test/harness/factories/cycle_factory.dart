import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/utils/dates.dart';

import 'user_factory.dart';

abstract final class CycleFactory {
  static Cycle make({
    String id = 'cycle-1',
    String coupleId = 'couple-1',
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
      id: id,
      coupleId: coupleId,
      startDate: normalizeDate(startDate ?? defaultTestNow),
      periodEndDate: periodEndDate,
      totalLengthDays: totalLengthDays,
      predictedNextStart: predictedNextStart,
      predictedNextStartRangeEnd: predictedNextStartRangeEnd,
      predictedOvulation: predictedOvulation,
      predictionConfidence: predictionConfidence,
      createdAt: createdAt ?? defaultTestNow,
      updatedAt: updatedAt ?? defaultTestNow,
    );
  }

  /// First-cycle scenario: just started, no closure data, no predictions yet.
  static Cycle firstEver({DateTime? startDate}) => make(startDate: startDate);
}
