import 'dart:async';

import 'package:ad_hoc_ident/src/debounced.dart';
import 'package:test/test.dart';

void main() {
  test('debounced delegate is not executed while still running', () async {
    int counter = 0;
    int setVal = -123;
    const timeout = Duration(milliseconds: 300);
    delegate(int val) async {
      counter++;
      setVal = val;
      await Future.delayed(timeout);
    }

    final debouncedDelegate = debounced(delegate);
    final List<Future> futures = [];
    for (var i = 0; i < 10; i++) {
      futures.add(debouncedDelegate(i));
    }
    await Future.wait(futures);

    expect(counter, 1);
    expect(setVal, 0);
  });

  test('debounced stream events are ignored while still running', () async {
    int counter = 0;
    int setVal = -123;
    const timeout = Duration(milliseconds: 300);
    delegate(int val) async {
      counter++;
      setVal = val;
      await Future.delayed(timeout);
    }

    final debouncedDelegate = debounced(delegate);
    final completer = Completer();
    Stream.fromIterable(Iterable<int>.generate(10))
        .listen(debouncedDelegate, onDone: completer.complete);

    await completer.future.timeout(Duration(seconds: 1));

    expect(counter, 1);
    expect(setVal, 0);
  });
}
