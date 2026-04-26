import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'data/countries.dart';

/// In-memory translations for the picker, keyed by locale.
///
/// Loaded once per locale from the bundled `assets/l10n/<locale>.arb` file.
/// Country names fall back to the entry's English name when a key is missing.
class CountryPickerLocalizations {
  final String localeKey;
  final String defaultTitle;
  final String defaultSearchHint;
  final Map<String, String> _names;

  const CountryPickerLocalizations._(
    this.localeKey, {
    required this.defaultTitle,
    required this.defaultSearchHint,
    required Map<String, String> names,
  }) : _names = names;

  static const _supportedLocales = <String>{'en_US', 'nl_NL'};
  static const _fallbackLocale = 'en_US';
  static const _packageName = 'flutter_country_picker';

  static final Map<String, CountryPickerLocalizations> _cache = {};

  /// Loads translations for [locale]. If the language is not supported,
  /// falls back to English (en_US).
  static Future<CountryPickerLocalizations> load(Locale? locale) async {
    final key = _resolveLocale(locale);
    final cached = _cache[key];
    if (cached != null) return cached;

    final assetPath = 'packages/$_packageName/assets/l10n/$key.arb';
    final raw = await rootBundle.loadString(assetPath);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final names = <String, String>{};
    decoded.forEach((k, value) {
      if (k.startsWith('@') || k.startsWith('_')) return;
      if (value is String) names[k] = value;
    });
    final loc = CountryPickerLocalizations._(
      key,
      defaultTitle: decoded['_defaultTitle'] as String? ?? 'Country',
      defaultSearchHint:
          decoded['_defaultSearchHint'] as String? ?? 'Search country…',
      names: names,
    );
    _cache[key] = loc;
    return loc;
  }

  /// Returns the localized country name for [code], falling back to [code]
  /// itself if no translation is available for the active locale.
  String nameFor(String code) => _names[code] ?? code;

  static String _resolveLocale(Locale? locale) {
    if (locale == null) return _fallbackLocale;
    final lang = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toUpperCase();
    if (country != null) {
      final exact = '${lang}_$country';
      if (_supportedLocales.contains(exact)) return exact;
    }
    for (final supported in _supportedLocales) {
      if (supported.startsWith('${lang}_')) return supported;
    }
    return _fallbackLocale;
  }

  /// All known ISO codes, in package-defined order.
  static List<String> get allCodes => kCountryCodes;
}

/// Returns the country name for the ISO alpha-2 [code] in the given [locale].
///
/// Pass `Localizations.localeOf(context)` (or `Localizations.maybeLocaleOf`)
/// to follow the host app's locale; omit [locale] to get the English (en_US)
/// name. Unsupported locales fall back to en_US, and unknown [code]s fall
/// back to the code itself.
///
/// ```dart
/// final name = await countryNameFor('NL', locale: const Locale('nl', 'NL'));
/// // → 'Nederland'
/// ```
Future<String> countryNameFor(String code, {Locale? locale}) async {
  final loc = await CountryPickerLocalizations.load(locale);
  return loc.nameFor(code);
}
