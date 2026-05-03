import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:mycycle/features/pairing/domain/usecases/invite_code_generator.dart';

void main() {
  test('generated code is exactly 6 characters', () {
    final code = InviteCodeGenerator.generate();
    expect(code, hasLength(6));
  });

  test('generated code uses only the unambiguous alphabet', () {
    const allowed = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    for (var i = 0; i < 1000; i++) {
      final code = InviteCodeGenerator.generate();
      for (final ch in code.split('')) {
        expect(allowed, contains(ch));
      }
    }
  });

  test('isValidFormat accepts allowed characters', () {
    expect(InviteCodeGenerator.isValidFormat('ABC234'), isTrue);
    expect(InviteCodeGenerator.isValidFormat('ZZZZZZ'), isTrue);
  });

  test('isValidFormat rejects ambiguous chars and wrong lengths', () {
    expect(InviteCodeGenerator.isValidFormat('ABCDE0'), isFalse); // contains 0
    expect(InviteCodeGenerator.isValidFormat('ABCDEI'), isFalse); // contains I
    expect(InviteCodeGenerator.isValidFormat('ABCDEL'), isFalse); // contains L
    expect(InviteCodeGenerator.isValidFormat('ABC1234'), isFalse); // too long
    expect(InviteCodeGenerator.isValidFormat('ABC23'), isFalse); // too short
    expect(InviteCodeGenerator.isValidFormat('abc234'), isFalse); // lowercase
  });

  test('seeded random produces deterministic output', () {
    final r1 = math.Random(42);
    final r2 = math.Random(42);
    expect(
      InviteCodeGenerator.generate(random: r1),
      InviteCodeGenerator.generate(random: r2),
    );
  });
}
