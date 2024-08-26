import 'ad_hoc_identity.dart';

/// Tries to detect an [AdHocIdentity] from a [TInput].
abstract class AdHocIdentityDetector<TInput> {
  /// Creates a new [AdHocIdentityDetector], which passes the input to
  /// all supplied [detectors].
  ///
  /// If [executeParallel] is set to false, the [detectors] will receive the
  /// [input] one after another, returning after the first
  /// [AdHocIdentityDetector] detects an [AdHocIdentity].
  /// If [executeParallel] is set to false, all [detectors]
  /// are run in parallel, returning once all have finished processing.
  /// When executing in parallel, the results are
  /// evaluated in the same order of the [detectors], returning the first
  /// detected [AdHocIdentity] or an exception if any detector threw one.
  static AdHocIdentityDetector<TInput> fromDelegate<TInput>(
          Future<AdHocIdentity?> Function(TInput input) delegate) =>
      _DelegateAdHocIdentityDetector(delegate);

  /// Creates a new [AdHocIdentityDetector], which passes the input to
  /// all supplied [detectors].
  ///
  /// If [executeParallel] is set to false, the [detectors] will receive the
  /// [input] one after another, returning after the first
  /// [AdHocIdentityDetector] detects an [AdHocIdentity].
  /// If [executeParallel] is set to false, all [detectors]
  /// are run in parallel, returning once all have finished processing.
  /// When executing in parallel, the results are
  /// evaluated in the same order of the [detectors], returning the first
  /// detected [AdHocIdentity] or an exception if any detector threw one.
  static AdHocIdentityDetector<TInput> fromList<TInput>(
          List<AdHocIdentityDetector<TInput>> detectors,
          {bool executeParallel = false}) =>
      executeParallel
          ? _MultiAdHocIdentityDetector.parallel(detectors)
          : _MultiAdHocIdentityDetector.sequential(detectors);

  /// Detects an [AdHocIdentity] from the [input] or returns null.
  ///
  /// When an exception is thrown, a multi-detector such as those created by
  /// [AdHocIdentityDetector.fromList] will stop without checking other
  /// detectors. Therefore any expected incompatibilities should be
  /// handled by returning null. This will allow other detectors to
  /// try processing the [input].
  Future<AdHocIdentity?> detect(TInput input);
}

class _DelegateAdHocIdentityDetector<TInput>
    implements AdHocIdentityDetector<TInput> {
  final Future<AdHocIdentity?> Function(TInput input) delegate;

  _DelegateAdHocIdentityDetector(this.delegate);

  @override
  Future<AdHocIdentity?> detect(TInput input) => delegate(input);
}

class _MultiAdHocIdentityDetector<TInput>
    implements AdHocIdentityDetector<TInput> {
  final List<AdHocIdentityDetector<TInput>> _detectors;
  final bool _workParallel;

  _MultiAdHocIdentityDetector.sequential(
      List<AdHocIdentityDetector<TInput>> detectors)
      : _detectors = detectors,
        _workParallel = false;

  _MultiAdHocIdentityDetector.parallel(
      List<AdHocIdentityDetector<TInput>> detectors)
      : _detectors = detectors,
        _workParallel = true;

  @override
  Future<AdHocIdentity?> detect(nfcTag) async {
    if (_workParallel) {
      return await _detectParallel(nfcTag);
    }
    return await _detectSequential(nfcTag);
  }

  Future<AdHocIdentity?> _detectSequential(TInput input) async {
    for (AdHocIdentityDetector<TInput> detector in _detectors) {
      final result = await detector.detect(input);
      if (result != null) {
        return result;
      }
    }

    return null;
  }

  Future<AdHocIdentity?> _detectParallel(TInput input) async {
    final List<Future<AdHocIdentity?>> work = [];
    for (AdHocIdentityDetector<TInput> detector in _detectors) {
      work.add(detector.detect(input));
    }

    final results = await Future.wait(work, eagerError: true);

    return results.nonNulls.firstOrNull;
  }
}
