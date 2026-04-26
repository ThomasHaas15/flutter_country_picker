import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'data/countries.dart';

/// Localized strings used by the country picker.
///
/// Register this in your app's `MaterialApp` to load translations once at
/// startup and access them synchronously inside widgets:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: const [
///     CountryPickerLocalizations.delegate,
///     GlobalMaterialLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///     GlobalCupertinoLocalizations.delegate,
///   ],
///   supportedLocales: CountryPickerLocalizations.supportedLocales,
/// )
/// ```
///
/// When the delegate isn't registered, `showCountryPicker` falls back to
/// loading translations on demand from the bundled
/// `assets/l10n/<locale>.arb` files, and the [countryNameFor] helper
/// remains available for non-widget callers.
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

  static const _supportedLocaleKeys = <String>{'en_US', 'nl_NL'};
  static const _fallbackLocale = 'en_US';
  static const _packageName = 'flutter_country_picker';

  /// Locales for which translations ship with this package.
  ///
  /// Use as the `supportedLocales` argument of `MaterialApp` if the picker
  /// is the only thing driving locale selection in your app.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', 'US'),
    Locale('nl', 'NL'),
  ];

  /// Delegate to register in `MaterialApp.localizationsDelegates`.
  static const LocalizationsDelegate<CountryPickerLocalizations> delegate =
      _CountryPickerLocalizationsDelegate();

  /// Returns the registered [CountryPickerLocalizations] from [context],
  /// or throws if the delegate isn't registered.
  static CountryPickerLocalizations of(BuildContext context) {
    final loc = maybeOf(context);
    assert(
      loc != null,
      'No CountryPickerLocalizations found. Add '
      'CountryPickerLocalizations.delegate to your MaterialApp\'s '
      'localizationsDelegates.',
    );
    return loc!;
  }

  /// Returns the registered [CountryPickerLocalizations] from [context],
  /// or `null` when the delegate isn't registered.
  static CountryPickerLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<CountryPickerLocalizations>(
      context,
      CountryPickerLocalizations,
    );
  }

  static final Map<String, CountryPickerLocalizations> _cache = {};

  /// Loads translations for [locale]. Unsupported locales fall back to
  /// English (en_US). Subsequent calls for the same resolved locale are
  /// served from an in-memory cache.
  static Future<CountryPickerLocalizations> load(Locale? locale) async {
    final key = _resolveLocale(locale);
    final cached = _cache[key];
    if (cached != null) return cached;

    final assetPath = 'packages/$_packageName/assets/l10n/$key.arb';
    final raw = await rootBundle.loadString(assetPath);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final names = <String, String>{};
    decoded.forEach((k, value) {
      if (value is! String) return;
      if (k.length == 2 && k == k.toUpperCase()) names[k] = value;
    });
    final loc = CountryPickerLocalizations._(
      key,
      defaultTitle: decoded['defaultTitle'] as String? ?? 'Country',
      defaultSearchHint:
          decoded['defaultSearchHint'] as String? ?? 'Search country…',
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
      if (_supportedLocaleKeys.contains(exact)) return exact;
    }
    for (final supported in _supportedLocaleKeys) {
      if (supported.startsWith('${lang}_')) return supported;
    }
    return _fallbackLocale;
  }

  /// All known ISO codes, in package-defined order.
  static List<String> get allCodes => kCountryCodes;
}

class _CountryPickerLocalizationsDelegate
    extends LocalizationsDelegate<CountryPickerLocalizations> {
  const _CountryPickerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final lang = locale.languageCode.toLowerCase();
    return CountryPickerLocalizations._supportedLocaleKeys
        .any((key) => key.startsWith('${lang}_'));
  }

  @override
  Future<CountryPickerLocalizations> load(Locale locale) =>
      CountryPickerLocalizations.load(locale);

  @override
  bool shouldReload(_CountryPickerLocalizationsDelegate old) => false;
}

/// Returns the country name for ISO alpha-2 [code] localized to [locale].
///
/// Async because it loads the bundled ARB on first access. Subsequent
/// calls for the same locale are served from the in-memory cache.
/// For widget code where you've registered
/// [CountryPickerLocalizations.delegate], prefer [countryNameOf] which is
/// synchronous.
///
/// Unsupported [locale]s fall back to English (en_US); unknown [code]s
/// fall back to the code itself.
Future<String> countryNameFor(String code, {Locale? locale}) async {
  final loc = await CountryPickerLocalizations.load(locale);
  return loc.nameFor(code);
}

/// Synchronous lookup of the country name for ISO alpha-2 [code], using
/// the [CountryPickerLocalizations] registered on [context].
///
/// Requires [CountryPickerLocalizations.delegate] to be present in your
/// `MaterialApp.localizationsDelegates`. Throws in debug if it isn't.
String countryNameOf(BuildContext context, String code) {
  return CountryPickerLocalizations.of(context).nameFor(code);
}
