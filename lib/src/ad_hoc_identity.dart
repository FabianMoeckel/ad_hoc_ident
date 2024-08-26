/// The immutable core class of the ad_hoc_ident framework.
class AdHocIdentity {
  /// The type of identification process used to derive this identity.
  ///
  /// Used to discern the source of an identity. Each detector should
  /// apply their own [type] value unique in the context of the application.
  /// Following a naming convention is recommended, such as combining the
  /// input type with the detector type, e.g.: "nfc.uid", "nfc.emv", "ocr.mrz".
  final String type;

  /// The identity value of the derived identity.
  final String identifier;

  /// Creates a new [AdHocIdentity] by its [identifier]
  /// value which was derived by the [type] of detector.
  const AdHocIdentity({required this.type, required this.identifier});

  @override
  bool operator ==(Object other) {
    return other is AdHocIdentity &&
        other.type == type &&
        other.identifier == identifier;
  }

  @override
  int get hashCode => Object.hash(type, identifier);
}
