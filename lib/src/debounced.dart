/// Returns a new [Function] which executes the [baseCall] only if its
/// last execution has finished.
///
/// Calls to the resulting [Function] are delegated to the [baseCall].
/// If the [baseCall] is still running, the [input] is discarded without any
/// action. This ensures the [baseCall] is ever only executed once at a time.
Future<void> Function(T input) debounced<T>(
    Future<void> Function(T input) baseCall) {
  Future<void>? runningDetection;

  return (T input) async {
    if (runningDetection != null) {
      return;
    }
    runningDetection = baseCall(input);
    try {
      await runningDetection;
    } finally {
      runningDetection = null;
    }
  };
}
