/// Types of faults that can be reported for a bike.
enum FaultType {
  /// Flat tire or damaged wheel.
  flatTire,

  /// Broken chain.
  brokenChain,

  /// Faulty brakes.
  faultyBrakes,

  /// Damaged frame or structure.
  damagedFrame,

  /// Broken or missing bell.
  brokenBell,

  /// Damaged or missing lights.
  damagedLights,

  /// Other issue not categorized above.
  other,
}

/// Extension to provide Polish labels and descriptions for fault types.
extension FaultTypeExtension on FaultType {
  /// Returns the Polish display name for this fault type.
  String get displayName {
    return switch (this) {
      FaultType.flatTire => 'Przebita opona',
      FaultType.brokenChain => 'Zerwany łańcuch',
      FaultType.faultyBrakes => 'Uszkodzone hamulce',
      FaultType.damagedFrame => 'Uszkodzona rama',
      FaultType.brokenBell => 'Zepsuty dzwonek',
      FaultType.damagedLights => 'Uszkodzone światła',
      FaultType.other => 'Inne',
    };
  }

  /// Returns the API value for this fault type.
  String get apiValue {
    return switch (this) {
      FaultType.flatTire => 'PRZEBITA_OPONA',
      FaultType.brokenChain => 'ZERWANY_LANCUCH',
      FaultType.faultyBrakes => 'USZKODZONE_HAMULCE',
      FaultType.damagedFrame => 'USZKODZONA_RAMA',
      FaultType.brokenBell => 'ZEPSUTY_DZWONEK',
      FaultType.damagedLights => 'USZKODZONE_SWIATLA',
      FaultType.other => 'INNE',
    };
  }

  /// Returns whether this fault type requires a description.
  bool get requiresDescription => this == FaultType.other;

  /// Creates a FaultType from an API value.
  static FaultType fromApiValue(String value) {
    return switch (value.toUpperCase()) {
      'PRZEBITA_OPONA' || 'FLAT_TIRE' => FaultType.flatTire,
      'ZERWANY_LANCUCH' || 'BROKEN_CHAIN' => FaultType.brokenChain,
      'USZKODZONE_HAMULCE' || 'FAULTY_BRAKES' => FaultType.faultyBrakes,
      'USZKODZONA_RAMA' || 'DAMAGED_FRAME' => FaultType.damagedFrame,
      'ZEPSUTY_DZWONEK' || 'BROKEN_BELL' => FaultType.brokenBell,
      'USZKODZONE_SWIATLA' || 'DAMAGED_LIGHTS' => FaultType.damagedLights,
      _ => FaultType.other,
    };
  }
}
