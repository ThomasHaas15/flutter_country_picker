## 1.1.0

* Header redesign: 40h × (16h, 8v outer) padding, 16pt bold title, bundled
  SVG back-chevron rendered via `flutter_svg` and tinted by `iconColor`.
* Search field redesign: fixed 48px height, 12px radius, 1px border at 10%
  of `onSurfaceColor`, 14pt text/hint, manual icon spacing for tight
  contentPadding.
* Fix: swapped contents of `assets/flags/round/` and `assets/flags/rect/` —
  the `round` directory previously held rectangular images and vice versa,
  making `CountryFlagShape.round` render as rectangles. This is a visual
  break for any caller relying on the previous (incorrect) behavior.
* Add `flutter_svg ^2.0.0` dependency.

## 1.0.0

Stable release. No functional changes from 0.1.0; the API surface is
considered stable and future breaking changes will require a major
version bump.

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
