import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:flutter/widgets.dart';

class AdHocIdentityDisplay extends StatelessWidget {
  final AdHocIdentity? _identity;
  final String? _nullMessage;
  final String? _waitingMessage;
  final Stream<AdHocIdentity?>? _stream;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const AdHocIdentityDisplay(
      {super.key, required AdHocIdentity identity, this.errorBuilder})
      : _identity = identity,
        _nullMessage = null,
        _waitingMessage = null,
        _stream = null;

  const AdHocIdentityDisplay.optional(
      {super.key,
      required AdHocIdentity? identity,
      required String nullMessage,
      this.errorBuilder})
      : _identity = identity,
        _nullMessage = nullMessage,
        _waitingMessage = null,
        _stream = null;

  const AdHocIdentityDisplay.fromStream(
      {super.key,
      required Stream<AdHocIdentity?> stream,
      required String nullMessage,
      required String waitingMessage,
      this.errorBuilder})
      : _identity = null,
        _nullMessage = nullMessage,
        _waitingMessage = waitingMessage,
        _stream = stream;

  @override
  Widget build(BuildContext context) {
    if (_stream != null) {
      return StreamBuilder(
        stream: _stream,
        initialData: null,
        builder: (context, snapshot) => snapshot.connectionState !=
                    ConnectionState.active &&
                snapshot.connectionState != ConnectionState.done
            ? Text(_waitingMessage!)
            : snapshot.hasData
                ? Text(_toDisplayString(snapshot.data!))
                : snapshot.hasError
                    ? errorBuilder != null
                        ? errorBuilder!(snapshot.error!, snapshot.stackTrace)
                        : Text('${snapshot.error!} \r\n'
                            'stacktrace: ${snapshot.stackTrace?.toString() ?? ''}')
                    : Text(_nullMessage!),
      );
    }

    return _identity != null
        ? Text(_toDisplayString(_identity))
        : Text(_nullMessage!);
  }

  String _toDisplayString(AdHocIdentity identity) {
    return 'identity type: ${identity.type}\r\n'
        'identity value: ${identity.identifier}';
  }
}
