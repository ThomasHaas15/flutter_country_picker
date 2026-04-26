import 'package:flutter/material.dart';

/// Visual customization for [showCountryPicker].
///
/// Any field left `null` falls back to a sensible default derived from the
/// ambient [ThemeData] / [ColorScheme] at the moment the picker is opened.
@immutable
class CountryPickerTheme {
  /// Page background.
  /// Default: [ThemeData.scaffoldBackgroundColor].
  final Color? backgroundColor;

  /// Card / list container color.
  /// Default: [ColorScheme.surface].
  final Color? surfaceColor;

  /// Color for the selected row's text and trailing checkmark.
  /// Default: [ColorScheme.primary].
  final Color? selectedColor;

  /// Color for unselected row text and the search-field text.
  /// Default: [ColorScheme.onSurface].
  final Color? onSurfaceColor;

  /// Color for the close (back) icon in the header.
  /// Default: [ColorScheme.onSurface].
  final Color? iconColor;

  /// Search field fill color.
  /// Default: [ColorScheme.surface] tinted slightly toward onSurface.
  final Color? searchFieldFillColor;

  /// Hint text color in the search field.
  /// Default: [ColorScheme.onSurface] at 50% opacity.
  final Color? hintColor;

  /// Font family for all text in the picker.
  ///
  /// `null` (default) inherits from the ambient theme. Pass `'SFProText'`
  /// to use the SF Pro Text family bundled with this package.
  final String? fontFamily;

  /// Optional package the [fontFamily] lives in. Set to
  /// `'flutter_country_picker'` together with `fontFamily: 'SFProText'`
  /// to use this package's bundled SF Pro Text.
  final String? fontFamilyPackage;

  /// Header title text. Defaults to the localized "Country".
  final String? title;

  /// Search field placeholder. Defaults to the localized "Search country…".
  final String? searchHint;

  const CountryPickerTheme({
    this.backgroundColor,
    this.surfaceColor,
    this.selectedColor,
    this.onSurfaceColor,
    this.iconColor,
    this.searchFieldFillColor,
    this.hintColor,
    this.fontFamily,
    this.fontFamilyPackage,
    this.title,
    this.searchHint,
  });

  CountryPickerTheme _resolveAgainst(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return CountryPickerTheme(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      surfaceColor: surfaceColor ?? scheme.surface,
      selectedColor: selectedColor ?? scheme.primary,
      onSurfaceColor: onSurfaceColor ?? scheme.onSurface,
      iconColor: iconColor ?? scheme.onSurface,
      searchFieldFillColor: searchFieldFillColor ??
          Color.alphaBlend(
            scheme.onSurface.withValues(alpha: 0.04),
            scheme.surface,
          ),
      hintColor: hintColor ?? scheme.onSurface.withValues(alpha: 0.5),
      fontFamily: fontFamily,
      fontFamilyPackage: fontFamilyPackage,
      title: title,
      searchHint: searchHint,
    );
  }
}

/// Internal helper: applies [CountryPickerTheme]'s defaults given a context.
extension CountryPickerThemeResolve on CountryPickerTheme {
  CountryPickerTheme resolve(BuildContext context) => _resolveAgainst(context);
}
