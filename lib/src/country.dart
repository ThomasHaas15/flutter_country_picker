import 'package:flutter/foundation.dart';

/// A country, identified by its ISO 3166-1 alpha-2 code (e.g. `NL`, `US`).
///
/// Display names aren't carried on the type — they're locale-specific and
/// resolved at render time via [countryNameOf] or [countryNameFor] from
/// `country_picker_localizations.dart`.
@immutable
class Country {
  /// ISO 3166-1 alpha-2 code, conventionally uppercase (e.g. `'NL'`).
  final String alpha2;

  const Country({required this.alpha2});

  @override
  bool operator ==(Object other) => other is Country && other.alpha2 == alpha2;

  @override
  int get hashCode => alpha2.hashCode;

  @override
  String toString() => 'Country($alpha2)';
}
