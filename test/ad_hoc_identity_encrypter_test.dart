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

  test('successfully add pepper', () async {
    const pepper = ".pepper";
    const testIdentity =
        AdHocIdentity(type: "notProtected", identifier: "notProtected");

    final noOpEncrypter = AdHocIdentityEncrypter.fromDelegate(
        (AdHocIdentity identity) async => identity);

    final result = await noOpEncrypter.withPepper(pepper).encrypt(testIdentity);

    expect(result.type, testIdentity.type);
    expect(result.identifier, endsWith(pepper));
  });

  test('successfully add salt', () async {
    const mockSaltValue = ".salt";
    createMockSalt(AdHocIdentity _) => mockSaltValue;
    const testIdentity =
        AdHocIdentity(type: "notProtected", identifier: "notProtected");

    final noOpEncrypter = AdHocIdentityEncrypter.fromDelegate(
        (AdHocIdentity identity) async => identity);

    final result =
        await noOpEncrypter.withSalt(createMockSalt).encrypt(testIdentity);

    expect(result.type, testIdentity.type);
    expect(result.identifier, endsWith(mockSaltValue));
  });
}
