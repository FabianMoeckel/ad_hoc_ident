import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:test/test.dart';

void main() {
  test('successfully process elements by delegate', () async {
    const protectedValue = "protected";
    const testIdentity =
        AdHocIdentity(type: "notProtected", identifier: "notProtected");
    Future<AdHocIdentity> detect(AdHocIdentity identity) async {
      return AdHocIdentity(type: protectedValue, identifier: protectedValue);
    }

    final encrypter = AdHocIdentityEncrypter.fromDelegate(detect);

    final result = await encrypter.encrypt(testIdentity);

    expect(result.type, protectedValue);
    expect(result.identifier, protectedValue);
  });
}
