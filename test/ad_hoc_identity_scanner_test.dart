import 'dart:async';

import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:test/test.dart';

void main() {
  test('successfully process elements', () async {
    int counter = 0;
    const timeout = Duration(milliseconds: 300);
    Future<AdHocIdentity?> detect(int val) async {
      counter++;
      await Future.delayed(timeout);
      return AdHocIdentity(type: "int.test", identifier: val.toString());
    }

    final completer = Completer<AdHocIdentity?>();
    final detector = AdHocIdentityDetector.fromDelegate<int>(detect);
    final encrypter =
        AdHocIdentityEncrypter.fromDelegate((identity) async => AdHocIdentity(
              type: "encrypted.${identity.type}",
              identifier: identity.identifier,
            ));
    final stream = Stream.fromIterable(Iterable<int>.generate(10));
    final scanner = AdHocIdentityScanner(
        inputStream: stream, detector: detector, encrypter: encrypter);
    scanner.stream.listen(completer.complete);

    final result = await completer.future.timeout(Duration(seconds: 1));

    expect(counter, 1);
    expect(result, isNotNull);
    expect(result!.type, "encrypted.int.test");
    expect(result.identifier, "0");
  });
}
