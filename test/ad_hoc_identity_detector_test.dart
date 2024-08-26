import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:test/test.dart';

void main() {
  test('successfully process elements by delegate', () async {
    const testIdentityType = "int.test";
    const testIdentityIdentifier = 1;
    Future<AdHocIdentity?> detect(int val) async {
      return AdHocIdentity(type: testIdentityType, identifier: val.toString());
    }

    final detector = AdHocIdentityDetector.fromDelegate<int>(detect);

    final result = await detector.detect(testIdentityIdentifier);

    expect(result, isNotNull);
    expect(result!.type, testIdentityType);
    expect(result.identifier, testIdentityIdentifier.toString());
  });

  test('successfully process elements sequential, returning first result',
      () async {
    const testIdentityType = "int.test";
    const testIdentityIdentifier1 = "1";
    const testIdentityIdentifier2 = "2";
    int detectorsExecuted = 0;
    Future<AdHocIdentity?> detect1(int val) async {
      detectorsExecuted++;
      return AdHocIdentity(
          type: testIdentityType, identifier: testIdentityIdentifier1);
    }

    Future<AdHocIdentity?> detect2(int val) async {
      detectorsExecuted++;
      return AdHocIdentity(
          type: testIdentityType, identifier: testIdentityIdentifier2);
    }

    final detector1 = AdHocIdentityDetector.fromDelegate<int>(detect1);
    final detector2 = AdHocIdentityDetector.fromDelegate<int>(detect2);
    final sequentialDetector =
        AdHocIdentityDetector.fromList([detector1, detector2]);

    final result = await sequentialDetector.detect(1234);

    expect(detectorsExecuted, 1);
    expect(result, isNotNull);
    expect(result!.type, testIdentityType);
    expect(result.identifier, testIdentityIdentifier1);
  });

  test('successfully process elements sequential, returning second result',
      () async {
    const testIdentityType = "int.test";
    const testIdentityIdentifier2 = "2";
    int detectorsExecuted = 0;
    Future<AdHocIdentity?> detect1(int val) async {
      detectorsExecuted++;
      return null;
    }

    Future<AdHocIdentity?> detect2(int val) async {
      detectorsExecuted++;
      return AdHocIdentity(
          type: testIdentityType, identifier: testIdentityIdentifier2);
    }

    final detector1 = AdHocIdentityDetector.fromDelegate<int>(detect1);
    final detector2 = AdHocIdentityDetector.fromDelegate<int>(detect2);
    final sequentialDetector =
        AdHocIdentityDetector.fromList([detector1, detector2]);

    final result = await sequentialDetector.detect(1234);

    expect(detectorsExecuted, 2);
    expect(result, isNotNull);
    expect(result!.type, testIdentityType);
    expect(result.identifier, testIdentityIdentifier2);
  });

  test('successfully process elements parallel, returning first result',
      () async {
    const testIdentityType = "int.test";
    const testIdentityIdentifier1 = "1";
    const testIdentityIdentifier2 = "2";
    int detectorsExecuted = 0;
    Future<AdHocIdentity?> detect1(int val) async {
      detectorsExecuted++;
      return AdHocIdentity(
          type: testIdentityType, identifier: testIdentityIdentifier1);
    }

    Future<AdHocIdentity?> detect2(int val) async {
      detectorsExecuted++;
      return AdHocIdentity(
          type: testIdentityType, identifier: testIdentityIdentifier2);
    }

    final detector1 = AdHocIdentityDetector.fromDelegate<int>(detect1);
    final detector2 = AdHocIdentityDetector.fromDelegate<int>(detect2);
    final sequentialDetector = AdHocIdentityDetector.fromList(
        [detector1, detector2],
        executeParallel: true);

    final result = await sequentialDetector.detect(1234);

    expect(detectorsExecuted, 2);
    expect(result, isNotNull);
    expect(result!.type, testIdentityType);
    expect(result.identifier, testIdentityIdentifier1);
  });

  test('successfully process elements parallel, returning second result',
      () async {
    const testIdentityType = "int.test";
    const testIdentityIdentifier2 = "2";
    int detectorsExecuted = 0;
    Future<AdHocIdentity?> detect1(int val) async {
      detectorsExecuted++;
      return null;
    }

    Future<AdHocIdentity?> detect2(int val) async {
      detectorsExecuted++;
      return AdHocIdentity(
          type: testIdentityType, identifier: testIdentityIdentifier2);
    }

    final detector1 = AdHocIdentityDetector.fromDelegate<int>(detect1);
    final detector2 = AdHocIdentityDetector.fromDelegate<int>(detect2);
    final sequentialDetector = AdHocIdentityDetector.fromList(
        [detector1, detector2],
        executeParallel: true);

    final result = await sequentialDetector.detect(1234);

    expect(detectorsExecuted, 2);
    expect(result, isNotNull);
    expect(result!.type, testIdentityType);
    expect(result.identifier, testIdentityIdentifier2);
  });
}
