/// Date-only utilities.
///
/// Cycle dates are stored as date-only (`YYYY-MM-DD` strings on the wire).
/// In-memory we use [DateTime] normalized to midnight UTC. Always convert via
/// these helpers — never construct DateTime values with time components for
/// date fields.
library;

/// Returns a [DateTime] at midnight UTC for [input]'s year/month/day.
DateTime normalizeDate(DateTime input) {
  return DateTime.utc(input.year, input.month, input.day);
}

/// `YYYY-MM-DD` ISO formatting suitable for Firestore document IDs and
/// human-readable storage of date fields.
String formatIsoDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Parses `YYYY-MM-DD` into a midnight-UTC [DateTime]. Throws [FormatException]
/// on bad input (caller's responsibility to validate before storage).
DateTime parseIsoDate(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) {
    throw FormatException('Expected YYYY-MM-DD, got "$iso"');
  }
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// Inclusive day count between two dates.
int daysBetween(DateTime from, DateTime to) {
  final f = normalizeDate(from);
  final t = normalizeDate(to);
  return t.difference(f).inDays;
}
