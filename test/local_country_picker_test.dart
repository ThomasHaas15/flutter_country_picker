import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_country_picker/local_country_picker.dart';

void main() {
  group('Country', () {
    test('value equality on alpha2', () {
      const a = Country(alpha2: 'NL');
      const b = Country(alpha2: 'NL');
      const c = Country(alpha2: 'BE');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString surfaces the code', () {
      expect(const Country(alpha2: 'NL').toString(), 'Country(NL)');
    });
  });

  group('CountryPickerLocalizations', () {
    testWidgets('exposes ISO codes from data file', (tester) async {
      expect(CountryPickerLocalizations.allCodes, contains('NL'));
      expect(CountryPickerLocalizations.allCodes, contains('US'));
      expect(CountryPickerLocalizations.allCodes, isNot(contains('EN')));
    });

    testWidgets('loads English ARB and translates known codes', (tester) async {
      final loc = await CountryPickerLocalizations.load(
        const Locale('en', 'US'),
      );
      expect(loc.localeKey, 'en_US');
      expect(loc.defaultTitle, 'Country');
      expect(loc.defaultSearchHint, 'Search country…');
      expect(loc.nameFor('NL'), 'Netherlands');
      expect(loc.nameFor('US'), 'United States');
    });

    testWidgets('loads Dutch ARB', (tester) async {
      final loc = await CountryPickerLocalizations.load(
        const Locale('nl', 'NL'),
      );
      expect(loc.localeKey, 'nl_NL');
      expect(loc.defaultTitle, 'Land');
      expect(loc.defaultSearchHint, 'Zoek land…');
      expect(loc.nameFor('NL'), 'Nederland');
      expect(loc.nameFor('US'), 'Verenigde Staten');
    });

    testWidgets('resolves bare languageCode to a country variant', (
      tester,
    ) async {
      final loc = await CountryPickerLocalizations.load(const Locale('nl'));
      expect(loc.localeKey, 'nl_NL');
    });

    testWidgets('falls back to en_US for unsupported locales', (tester) async {
      final loc = await CountryPickerLocalizations.load(const Locale('fr'));
      expect(loc.localeKey, 'en_US');
    });
  });

  group('countryNameFor', () {
    testWidgets('returns English name when locale is omitted', (tester) async {
      expect(await countryNameFor('NL'), 'Netherlands');
      expect(await countryNameFor('US'), 'United States');
    });

    testWidgets('returns localized name for supported locale', (tester) async {
      expect(
        await countryNameFor('US', locale: const Locale('nl', 'NL')),
        'Verenigde Staten',
      );
    });

    testWidgets('falls back to code for unknown ISO code', (tester) async {
      expect(await countryNameFor('ZZ'), 'ZZ');
    });
  });

  group('LocalizationsDelegate', () {
    testWidgets('delegate.isSupported recognizes en/nl, rejects fr', (
      tester,
    ) async {
      const delegate = CountryPickerLocalizations.delegate;
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('en', 'US')), isTrue);
      expect(delegate.isSupported(const Locale('nl', 'NL')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });

    testWidgets('of(context) returns loaded localizations and powers '
        'countryNameOf', (tester) async {
      String? captured;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('nl', 'NL'),
          supportedLocales: CountryPickerLocalizations.supportedLocales,
          localizationsDelegates: const [
            CountryPickerLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              captured = countryNameOf(context, 'US');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(captured, 'Verenigde Staten');
    });
  });
}
