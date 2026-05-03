/// Injectable wall clock for testability.
///
/// Domain code MUST NOT call `DateTime.now()` directly. Inject a [Clock]
/// instead — tests pin time via a fake to keep date-sensitive logic
/// deterministic.
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
