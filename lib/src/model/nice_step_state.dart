/// How a step stands relative to the stepper's current index: before it,
/// at it, or after it. Drawn in three distinct ways so the reader sees at
/// a glance which step they are on, which are done and which are to come.
enum NiceStepState {
  /// Before the current index, or any step once the flow is done.
  completed,

  /// At the current index.
  current,

  /// After the current index.
  upcoming;

  /// The state of the step at [index] when the flow is at [currentIndex];
  /// every step is completed once the flow is [done] (its last step
  /// finished, a submission succeeded).
  static NiceStepState of(int index, int currentIndex, {bool done = false}) =>
      done || index < currentIndex
          ? NiceStepState.completed
          : index == currentIndex
              ? NiceStepState.current
              : NiceStepState.upcoming;
}
