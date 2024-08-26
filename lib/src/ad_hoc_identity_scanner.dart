import 'dart:async';

import 'ad_hoc_identity.dart';
import 'ad_hoc_identity_detector.dart';
import 'ad_hoc_identity_encrypter.dart';
import 'debounced.dart';

/// Processes [TInput] values by detecting and encrypting their [AdHocIdentity].
class AdHocIdentityScanner<TInput> {
  /// A [Stream] providing [TInput] values for the [detector].
  final Stream<TInput> _inputStream;

  /// The [StreamSubscription] to the [_inputStream] during the
  /// scanner's lifetime.
  late final StreamSubscription<TInput> _inputSubscription;

  /// The [StreamController] managing the [stream] output.
  final StreamController<AdHocIdentity?> _outController =
      StreamController.broadcast();

  /// The [AdHocIdentityDetector] used to detect values received
  /// on the [_inputStream].
  AdHocIdentityDetector<TInput> detector;

  /// The [AdHocIdentityEncrypter] used to encrypt detected identities.
  AdHocIdentityEncrypter encrypter;

  /// Broadcast [Stream] containing any detected [AdHocIdentity].
  ///
  /// Unhandled exceptions in the processing pipeline are propagated to the
  /// [Stream] as errors. If no [AdHocIdentity] could be detected from an input
  /// value, null is returned.
  Stream<AdHocIdentity?> get stream => _outController.stream;

  /// Passes the [TInput] to the [detector] and [encrypter],
  /// publishing the result to the [_outController].
  Future<void> _detect(TInput input) async {
    try {
      final plainIdentity = await detector.detect(input);
      if (_outController.isClosed) {
        return;
      }
      if (plainIdentity == null) {
        _outController.add(null);
        return;
      }
      final encryptedIdentity = await encrypter.encrypt(plainIdentity);
      _outController.add(encryptedIdentity);
    } catch (error) {
      if (_outController.isClosed) {
        return;
      }
      _outController.addError(error);
    }
  }

  /// Creates an [AdHocIdentityScanner] that processes the [inputStream].
  ///
  /// Values from the [inputStream] are passed to the [detector], before
  /// encrypting the detected [AdHocIdentity] using the [encrypter].
  /// The results are added to the output [AdHocIdentityScanner.stream].
  /// If [debounce] is set to true, any events on the [inputStream] are
  /// discarded, while another value is still being processed.
  /// This can help save system resources and avoid concurrency issues,
  /// but might discard relevant events based on the implemented use-case.
  AdHocIdentityScanner(
      {required Stream<TInput> inputStream,
      required this.detector,
      required this.encrypter,
      bool debounce = true})
      : _inputStream = inputStream {
    final debouncedClosure = debounced(_detect);
    _inputSubscription = _inputStream.listen(debouncedClosure);
  }

  /// Closes the [AdHocIdentityScanner] and releases its resources.
  void close() {
    _inputSubscription.cancel();
    _outController.close();
  }
}
