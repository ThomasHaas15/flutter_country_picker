# flutter_country_picker

A self-contained country picker for Flutter. 205 countries, all flag images
bundled (rounded **and** rectangular), translations for English and Dutch,
and theme-aware colors that fall back to your `ThemeData`. **No network
calls** — everything is local.

## Install

```yaml
dependencies:
  flutter_country_picker:
    git:
      url: https://github.com/ThomasHaas15/flutter_country_picker
      ref: main
```

## Usage

```dart
import 'package:flutter_country_picker/flutter_country_picker.dart';

final country = await showCountryPicker(
  context,
  selectedCode: 'NL',
  shape: CountryFlagShape.round,
);

if (country != null) {
  print('${country.code} — ${country.name}');
  // e.g. "NL — Netherlands"  (or "NL — Nederland" if locale is nl)
}
```

### Returned object

```dart
class Country {
  final String code; // ISO 3166-1 alpha-2 ('NL', 'US', ...)
  final String name; // already translated to the active locale
}
```

### Flag shape

```dart
CountryFlagShape.round  // default — circular flags (24×24)
CountryFlagShape.rect   // rectangular flags
```

### Theme

Every color and the font family are taken from `Theme.of(context)` by default.
Override any subset:

```dart
showCountryPicker(
  context,
  theme: const CountryPickerTheme(
    selectedColor: Color(0xFFFF4500),
    fontFamily: 'SFProText',
    fontFamilyPackage: 'flutter_country_picker', // use bundled SF Pro Text
  ),
);
```

| Field                  | Default                                          |
| ---------------------- | ------------------------------------------------ |
| `backgroundColor`      | `theme.scaffoldBackgroundColor`                  |
| `surfaceColor`         | `colorScheme.surface`                            |
| `selectedColor`        | `colorScheme.primary`                            |
| `onSurfaceColor`       | `colorScheme.onSurface`                          |
| `iconColor`            | `colorScheme.onSurface`                          |
| `searchFieldFillColor` | `surface` tinted slightly toward `onSurface`     |
| `hintColor`            | `colorScheme.onSurface` @ 50%                    |

### Locale

Translations follow the ambient `Localizations` by default. Pass `locale:`
to force one:

```dart
showCountryPicker(context, locale: const Locale('nl'));
```

Supported out of the box: `en`, `nl`. Unsupported locales fall back to
English.

### Translating individual codes

Useful for showing a saved country name elsewhere in your app:

```dart
final loc = await CountryPickerLocalizations.load(const Locale('nl'));
loc.nameFor('US'); // "Verenigde Staten"
```

## Bundled fonts

The package ships **SF Pro Text** under
`assets/fonts/SF-Pro-Text-*.otf`. Reference it from your own widgets with:

```dart
TextStyle(fontFamily: 'SFProText', package: 'flutter_country_picker')
```
