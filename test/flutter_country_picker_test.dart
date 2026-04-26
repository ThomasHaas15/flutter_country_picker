import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_country_picker/flutter_country_picker.dart';

void main() {
  group('Country', () {
    test('value equality on code + name', () {
      const a = Country(code: 'NL', name: 'Netherlands');
      const b = Country(code: 'NL', name: 'Netherlands');
      const c = Country(code: 'NL', name: 'Nederland');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('CountryPickerLocalizations', () {
    testWidgets('exposes ISO codes from generated data', (tester) async {
      expect(CountryPickerLocalizations.allCodes, contains('NL'));
      expect(CountryPickerLocalizations.allCodes, contains('US'));
      expect(CountryPickerLocalizations.allCodes, isNot(contains('EN')));
    });

    testWidgets('loads English ARB and translates known codes',
        (tester) async {
      final loc =
          await CountryPickerLocalizations.load(const Locale('en', 'US'));
      expect(loc.localeKey, 'en_US');
      expect(loc.defaultTitle, 'Country');
      expect(loc.defaultSearchHint, 'Search country…');
      expect(loc.nameFor('NL'), 'Netherlands');
      expect(loc.nameFor('US'), 'United States');
    });

    testWidgets('loads Dutch ARB', (tester) async {
      final loc =
          await CountryPickerLocalizations.load(const Locale('nl', 'NL'));
      expect(loc.localeKey, 'nl_NL');
      expect(loc.defaultTitle, 'Land');
      expect(loc.defaultSearchHint, 'Zoek land…');
      expect(loc.nameFor('NL'), 'Nederland');
      expect(loc.nameFor('US'), 'Verenigde Staten');
    });

    testWidgets('resolves bare languageCode to a country variant',
        (tester) async {
      final loc = await CountryPickerLocalizations.load(const Locale('nl'));
      expect(loc.localeKey, 'nl_NL');
    });

    testWidgets('falls back to en_US for unsupported locales',
        (tester) async {
      final loc = await CountryPickerLocalizations.load(const Locale('fr'));
      expect(loc.localeKey, 'en_US');
    });
  });

  group('countryNameFor', () {
    testWidgets('returns English name when locale is omitted',
        (tester) async {
      expect(await countryNameFor('NL'), 'Netherlands');
      expect(await countryNameFor('US'), 'United States');
    });

    testWidgets('returns localized name for supported locale',
        (tester) async {
      expect(
        await countryNameFor('US', locale: const Locale('nl', 'NL')),
        'Verenigde Staten',
      );
    });

    testWidgets('falls back to code for unknown ISO code', (tester) async {
      expect(await countryNameFor('ZZ'), 'ZZ');
    });
  });
}
