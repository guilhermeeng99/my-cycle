import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/utils/dates.dart';

class CycleModel extends Cycle {
  const CycleModel({
    required super.id,
    required super.coupleId,
    required super.startDate,
    required super.createdAt,
    required super.updatedAt,
    super.periodEndDate,
    super.totalLengthDays,
    super.predictedNextStart,
    super.predictedNextStartRangeEnd,
    super.predictedOvulation,
    super.predictionConfidence,
  });

  factory CycleModel.fromMap(
    Map<String, dynamic> data, {
    required String id,
    required String coupleId,
  }) {
    return CycleModel(
      id: id,
      coupleId: coupleId,
      startDate: parseIsoDate(data['startDate'] as String),
      periodEndDate: _parseDateString(data['periodEndDate']),
      totalLengthDays: data['totalLengthDays'] as int?,
      predictedNextStart: _parseDateString(data['predictedNextStart']),
      predictedNextStartRangeEnd:
          _parseDateString(data['predictedNextStartRangeEnd']),
      predictedOvulation: _parseDateString(data['predictedOvulation']),
      predictionConfidence:
          _parseConfidence(data['predictionConfidence'] as String?),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startDate': formatIsoDate(startDate),
      'periodEndDate':
          periodEndDate == null ? null : formatIsoDate(periodEndDate!),
      'totalLengthDays': totalLengthDays,
      'predictedNextStart': predictedNextStart == null
          ? null
          : formatIsoDate(predictedNextStart!),
      'predictedNextStartRangeEnd': predictedNextStartRangeEnd == null
          ? null
          : formatIsoDate(predictedNextStartRangeEnd!),
      'predictedOvulation': predictedOvulation == null
          ? null
          : formatIsoDate(predictedOvulation!),
      'predictionConfidence': predictionConfidence?.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime? _parseDateString(Object? value) {
    if (value == null) return null;
    return parseIsoDate(value as String);
  }

  static DateTime _parseDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static ConfidenceLevel? _parseConfidence(String? value) {
    if (value == null) return null;
    return ConfidenceLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => ConfidenceLevel.low,
    );
  }
}
