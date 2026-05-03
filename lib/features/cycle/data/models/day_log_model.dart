import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/utils/dates.dart';

class DayLogModel extends DayLog {
  const DayLogModel({
    required super.coupleId,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    super.flow,
    super.symptoms,
    super.mood,
    super.ownerNote,
    super.partnerNote,
  });

  factory DayLogModel.fromMap(
    Map<String, dynamic> data, {
    required String coupleId,
    required DateTime date,
  }) {
    final symptomsRaw = (data['symptoms'] as List<dynamic>?) ?? const [];
    return DayLogModel(
      coupleId: coupleId,
      date: date,
      flow: _parseFlow(data['flow'] as String?),
      symptoms: symptomsRaw
          .map((dynamic s) => _parseSymptom(s as String?))
          .whereType<SymptomType>()
          .toSet(),
      mood: _parseMood(data['mood'] as String?),
      ownerNote: data['ownerNote'] as String?,
      partnerNote: data['partnerNote'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'flow': flow?.name,
      'symptoms': symptoms.map((s) => s.name).toList()..sort(),
      'mood': mood?.name,
      'ownerNote': ownerNote,
      'partnerNote': partnerNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static FlowLevel? _parseFlow(String? value) {
    if (value == null) return null;
    return FlowLevel.values.firstWhere(
      (f) => f.name == value,
      orElse: () => FlowLevel.light,
    );
  }

  static SymptomType? _parseSymptom(String? value) {
    if (value == null) return null;
    for (final s in SymptomType.values) {
      if (s.name == value) return s;
    }
    return null;
  }

  static MoodType? _parseMood(String? value) {
    if (value == null) return null;
    return MoodType.values.firstWhere(
      (m) => m.name == value,
      orElse: () => MoodType.calm,
    );
  }

  static DateTime _parseDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// Doc-id form of [date] used by Firestore.
  static String docIdForDate(DateTime date) => formatIsoDate(date);
}
