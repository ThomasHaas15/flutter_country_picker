## 0.1.0

Initial release.

* `showCountryPicker(context, ...)` returns a `Country` (ISO 3166-1
  alpha-2 code wrapper).
* 205 countries, ISO alpha-2 codes.
* Bundled flag PNGs in two shapes: round and rect.
* Translations: English (`en_US`) and Dutch (`nl_NL`), keyed by ISO code.
* `CountryPickerLocalizations.delegate` for sync access through
  `MaterialApp.localizationsDelegates`. Async self-load fallback when the
  delegate isn't registered.
* Top-level helpers: `countryNameFor(code, {locale})` (async) and
  `countryNameOf(context, code)` (sync).
* Theme-aware colors via `CountryPickerTheme`, with `ThemeData`-backed
  defaults.
