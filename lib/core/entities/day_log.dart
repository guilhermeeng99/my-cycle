import 'package:equatable/equatable.dart';

enum FlowLevel { spotting, light, medium, heavy }

enum SymptomType {
  cramps,
  headache,
  bloating,
  fatigue,
  tenderBreasts,
  acne,
  backPain,
  nausea,
}

enum MoodType { happy, calm, irritable, sad, anxious }

/// One day's log within a couple. Identified in Firestore by the date in
/// `YYYY-MM-DD` format (the doc id at `couples/{coupleId}/days/{date}`).
///
/// All fields except [coupleId] and [date] can be null/empty. An empty log
/// (all data fields null/empty) should be deleted, not stored — see
/// `DayLogRepository.upsertDayLog`.
class DayLog extends Equatable {
  const DayLog({
    required this.coupleId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.flow,
    this.symptoms = const <SymptomType>{},
    this.mood,
    this.ownerNote,
    this.partnerNote,
  });

  final String coupleId;
  final DateTime date;
  final FlowLevel? flow;
  final Set<SymptomType> symptoms;
  final MoodType? mood;
  final String? ownerNote;
  final String? partnerNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True when nothing has been logged. Repositories should delete an empty
  /// log instead of writing an empty document.
  bool get isEmpty =>
      flow == null &&
      symptoms.isEmpty &&
      mood == null &&
      (ownerNote == null || ownerNote!.isEmpty) &&
      (partnerNote == null || partnerNote!.isEmpty);

  DayLog copyWith({
    String? coupleId,
    DateTime? date,
    FlowLevel? flow,
    Set<SymptomType>? symptoms,
    MoodType? mood,
    String? ownerNote,
    String? partnerNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DayLog(
      coupleId: coupleId ?? this.coupleId,
      date: date ?? this.date,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      ownerNote: ownerNote ?? this.ownerNote,
      partnerNote: partnerNote ?? this.partnerNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        coupleId,
        date,
        flow,
        symptoms,
        mood,
        ownerNote,
        partnerNote,
        createdAt,
        updatedAt,
      ];
}
