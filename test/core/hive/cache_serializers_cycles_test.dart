import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/hive/cache_serializers.dart';

import '../../harness/factories/cycle_factory.dart';
import '../../harness/factories/user_factory.dart';

List<Cycle> _roundTrip(List<Cycle> cycles) {
  final encoded = jsonEncode(CacheSerializers.cyclesListToJson(cycles));
  return CacheSerializers.cyclesListFromJson(jsonDecode(encoded) as Object);
}

void main() {
  group('CacheSerializers.cycles', () {
    test('round-trips an empty list', () {
      expect(_roundTrip(<Cycle>[]), isEmpty);
    });

    test('round-trips a list with mixed open and closed cycles', () {
      final cycles = <Cycle>[
        CycleFactory.make(
          id: 'open',
          startDate: defaultTestNow.subtract(const Duration(days: 5)),
          predictedNextStart: defaultTestNow.add(const Duration(days: 23)),
          predictedNextStartRangeEnd: defaultTestNow.add(
            const Duration(days: 25),
          ),
          predictedOvulation: defaultTestNow.add(const Duration(days: 10)),
          predictionConfidence: ConfidenceLevel.medium,
        ),
        CycleFactory.make(
          id: 'closed',
          startDate: defaultTestNow.subtract(const Duration(days: 33)),
          periodEndDate: defaultTestNow.subtract(const Duration(days: 28)),
          totalLengthDays: 28,
        ),
      ];

      final restored = _roundTrip(cycles);

      expect(restored, hasLength(2));
      expect(restored[0].id, 'open');
      expect(restored[0].periodEndDate, isNull);
      expect(restored[0].predictionConfidence, ConfidenceLevel.medium);
      expect(restored[0].predictedOvulation, isNotNull);

      expect(restored[1].id, 'closed');
      expect(restored[1].totalLengthDays, 28);
      expect(restored[1].periodEndDate, isNotNull);
    });

    test('preserves date precision down to the day', () {
      final start = DateTime.utc(2026, 1, 31);
      final cycles = <Cycle>[
        CycleFactory.make(id: 'a', startDate: start, totalLengthDays: 28),
      ];
      expect(_roundTrip(cycles).single.startDate, start);
    });
  });
}
