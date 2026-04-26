import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'country.dart';
import 'country_flag_shape.dart';
import 'country_picker_localizations.dart';
import 'country_picker_theme.dart';
import 'data/countries.dart';

/// Opens a fullscreen country picker and returns the chosen [Country], or
/// `null` if dismissed.
///
/// The returned [Country] carries only the ISO alpha-2 code. Use
/// [countryNameFor] (async) or [countryNameOf] (sync, in widget code with
/// the delegate registered) to translate it for display.
///
/// - [selected]: country currently selected, highlighted in the list.
/// - [shape]: round (default) or rectangular flag images.
/// - [theme]: visual overrides; any unset field falls back to [Theme.of].
/// - [locale]: forces a specific locale, ignoring the registered
///   delegate. When omitted, uses
///   [CountryPickerLocalizations.maybeOf] if available, otherwise loads
///   on demand from [Localizations.maybeLocaleOf] of the calling context
///   (English/en_US if no locale is available).
Future<Country?> showCountryPicker(
  BuildContext context, {
  Country? selected,
  CountryFlagShape shape = CountryFlagShape.round,
  CountryPickerTheme? theme,
  Locale? locale,
}) {
  return Navigator.of(context).push<Country>(
    PageRouteBuilder<Country>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _CountryPickerScreen(
        selected: selected,
        shape: shape,
        theme: theme ?? const CountryPickerTheme(),
        locale: locale,
      ),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  );
}

class _CountryPickerScreen extends StatefulWidget {
  const _CountryPickerScreen({
    required this.selected,
    required this.shape,
    required this.theme,
    required this.locale,
  });

  final Country? selected;
  final CountryFlagShape shape;
  final CountryPickerTheme theme;
  final Locale? locale;

  @override
  State<_CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends State<_CountryPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  CountryPickerLocalizations? _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_l10n != null) return;
    if (widget.locale == null) {
      final registered = CountryPickerLocalizations.maybeOf(context);
      if (registered != null) {
        _l10n = registered;
        return;
      }
    }
    _loadLocalizations();
  }

  Future<void> _loadLocalizations() async {
    final ctxLocale = widget.locale ?? Localizations.maybeLocaleOf(context);
    final loc = await CountryPickerLocalizations.load(ctxLocale);
    if (!mounted) return;
    setState(() => _l10n = loc);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _defaultTitle() => _l10n?.defaultTitle ?? 'Country';
  String _defaultSearchHint() => _l10n?.defaultSearchHint ?? 'Search country…';

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme.resolve(context);
    final l10n = _l10n;

    final entries = <_DisplayEntry>[];
    if (l10n != null) {
      for (final code in kCountryCodes) {
        entries.add(_DisplayEntry(code: code, name: l10n.nameFor(code)));
      }
      entries.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }

    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? entries
        : entries
              .where(
                (e) =>
                    e.name.toLowerCase().contains(query) ||
                    e.code.toLowerCase().contains(query),
              )
              .toList();

    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: theme.onSurfaceColor,
      fontFamily: theme.fontFamily,
      package: theme.fontFamilyPackage,
    );

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: theme.title ?? _defaultTitle(),
              titleStyle: titleStyle,
              iconColor: theme.iconColor!,
              onBack: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _SearchField(
                controller: _searchController,
                hint: theme.searchHint ?? _defaultSearchHint(),
                fillColor: theme.searchFieldFillColor!,
                textColor: theme.onSurfaceColor!,
                hintColor: theme.hintColor!,
                fontFamily: theme.fontFamily,
                fontFamilyPackage: theme.fontFamilyPackage,
                onChanged: (q) => setState(() => _query = q),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).padding.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: l10n == null
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            final isSelected =
                                entry.code == widget.selected?.alpha2;
                            return _CountryRow(
                              code: entry.code,
                              name: entry.name,
                              shape: widget.shape,
                              isSelected: isSelected,
                              theme: theme,
                              onTap: () => Navigator.of(
                                context,
                              ).pop(Country(alpha2: entry.code)),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisplayEntry {
  final String code;
  final String name;
  _DisplayEntry({required this.code, required this.name});
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.titleStyle,
    required this.iconColor,
    required this.onBack,
  });

  final String title;
  final TextStyle titleStyle;
  final Color iconColor;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      'assets/icons/chevron_left.svg',
                      package: 'local_country_picker',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ),
            Text(title, style: titleStyle),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.fillColor,
    required this.textColor,
    required this.hintColor,
    required this.onChanged,
    required this.fontFamily,
    required this.fontFamilyPackage,
  });

  final TextEditingController controller;
  final String hint;
  final Color fillColor;
  final Color textColor;
  final Color hintColor;
  final ValueChanged<String> onChanged;
  final String? fontFamily;
  final String? fontFamilyPackage;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      color: textColor,
      fontFamily: fontFamily,
      package: fontFamilyPackage,
    );
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: hintColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: textStyle,
              cursorColor: textColor,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: textStyle.copyWith(color: hintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                  child: Icon(Icons.close, size: 18, color: hintColor),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.code,
    required this.name,
    required this.shape,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  final String code;
  final String name;
  final CountryFlagShape shape;
  final bool isSelected;
  final CountryPickerTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shapeDir = shape == CountryFlagShape.round ? 'round' : 'rect';
    final assetPath = 'assets/flags/$shapeDir/$code.png';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  shape == CountryFlagShape.round ? 12 : 4,
                ),
                child: Image.asset(
                  assetPath,
                  package: 'local_country_picker',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 24, height: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? theme.selectedColor
                        : theme.onSurfaceColor,
                    fontFamily: theme.fontFamily,
                    package: theme.fontFamilyPackage,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, size: 18, color: theme.selectedColor),
            ],
          ),
        ),
      ),
    );
  }
}
