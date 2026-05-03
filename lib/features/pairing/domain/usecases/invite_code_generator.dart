import 'dart:math' as math;

/// Pure invite-code generator.
///
/// Codes are 6 uppercase characters from a 31-char alphabet that excludes
/// visually-ambiguous letters/digits: `O`, `0`, `I`, `1`, `L`.
abstract final class InviteCodeGenerator {
  static const String _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int _length = 6;

  static String generate({math.Random? random}) {
    final r = random ?? math.Random.secure();
    return String.fromCharCodes(
      List<int>.generate(
        _length,
        (_) => _alphabet.codeUnitAt(r.nextInt(_alphabet.length)),
      ),
    );
  }

  /// True if [code] matches the canonical format (length 6, uppercase from
  /// the unambiguous alphabet).
  static bool isValidFormat(String code) {
    if (code.length != _length) return false;
    for (var i = 0; i < code.length; i++) {
      if (!_alphabet.contains(code[i])) return false;
    }
    return true;
  }
}
