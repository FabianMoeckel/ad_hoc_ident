import 'dart:async';

import 'ad_hoc_identity.dart';

/// Used to encrypt an existing [AdHocIdentity].
abstract class AdHocIdentityEncrypter {
  /// Creates an [AdHocIdentityDetector] that applies the [encrypt] function.
  ///
  /// The [encrypt] function is applied to the [AdHocIdentity.identifier].
  /// The [AdHocIdentity.type] remains unchanged.
  static AdHocIdentityEncrypter fromDelegate(
      Future<AdHocIdentity> Function(AdHocIdentity identity) encrypt) {
    return _DelegateAdHocIdentityEncrypter(encrypt);
  }

  /// Encrypts the [AdHocIdentity], protecting its [AdHocIdentity.identifier].
  ///
  /// Does not change the [AdHocIdentity.type].
  FutureOr<AdHocIdentity> encrypt(AdHocIdentity identity);
}

/// Extension methods to create utility wrappers for an [AdHocIdentityEncrypter].
extension FunctionalityWrappers on AdHocIdentityEncrypter {
  /// Appends the [pepper] to the [AdHocIdentity.identifier] before encrypting.
  ///
  /// This can improve security, by changing the calculated encrypted value
  /// from the one without the pepper. This is e.g. relevant when using hashing
  /// for encryption and improves security against rainbow table attacks.
  /// For this protection to be effective, the pepper needs to be kept secret.
  AdHocIdentityEncrypter withPepper(String pepper) {
    return AdHocIdentityEncrypter.fromDelegate(
      (identity) async => this.encrypt(
        AdHocIdentity(
            type: identity.type, identifier: identity.identifier + pepper),
      ),
    );
  }

  /// Appends the [AdHocIdentity.type] to the [AdHocIdentity.identifier] before
  /// encrypting.
  ///
  /// This can improve security, by hiding which kind of hardware token was
  /// used for authentication.
  AdHocIdentityEncrypter secureType() {
    return AdHocIdentityEncrypter.fromDelegate(
      (identity) async => this.encrypt(
        AdHocIdentity(
            type: "secure", identifier: identity.identifier + identity.type),
      ),
    );
  }
}

class _DelegateAdHocIdentityEncrypter implements AdHocIdentityEncrypter {
  final Future<AdHocIdentity> Function(AdHocIdentity identity) _encrypt;

  _DelegateAdHocIdentityEncrypter(
      Future<AdHocIdentity> Function(AdHocIdentity identity) encrypt)
      : _encrypt = encrypt;

  @override
  Future<AdHocIdentity> encrypt(AdHocIdentity identity) async {
    final encryptedIdentity = await _encrypt(identity);
    return encryptedIdentity;
  }
}
