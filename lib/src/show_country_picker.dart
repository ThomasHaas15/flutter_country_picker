import 'package:flutter/material.dart';

import 'country_flag_shape.dart';
import 'country_picker_localizations.dart';
import 'country_picker_theme.dart';
import 'data/countries.dart';

/// Opens a fullscreen country picker and returns the chosen ISO alpha-2
/// code, or `null` if dismissed.
///
/// Use [countryNameFor] (async) or [countryNameOf] (sync, in widget code
/// with the delegate registered) to translate the returned code for
/// display.
///
/// - [selectedCode]: ISO code currently selected, highlighted in the list.
/// - [shape]: round (default) or rectangular flag images.
/// - [theme]: visual overrides; any unset field falls back to [Theme.of].
/// - [locale]: forces a specific locale, ignoring the registered
///   delegate. When omitted, uses
///   [CountryPickerLocalizations.maybeOf] if available, otherwise loads
///   on demand from [Localizations.maybeLocaleOf] of the calling context
///   (English/en_US if no locale is available).
Future<String?> showCountryPicker(
  BuildContext context, {
  String? selectedCode,
  CountryFlagShape shape = CountryFlagShape.round,
  CountryPickerTheme? theme,
  Locale? locale,
}) {
  return Navigator.of(context).push<String>(
    PageRouteBuilder<String>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _CountryPickerScreen(
        selectedCode: selectedCode,
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
    required this.selectedCode,
    required this.shape,
    required this.theme,
    required this.locale,
  });

  final String? selectedCode;
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
    final ctxLocale =
        widget.locale ?? Localizations.maybeLocaleOf(context);
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
      entries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? entries
        : entries.where((e) =>
            e.name.toLowerCase().contains(query) ||
            e.code.toLowerCase().contains(query)).toList();

    final titleStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                            final isSelected = entry.code == widget.selectedCode;
                            return _CountryRow(
                              code: entry.code,
                              name: entry.name,
                              shape: widget.shape,
                              isSelected: isSelected,
                              theme: theme,
                              onTap: () =>
                                  Navigator.of(context).pop(entry.code),
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
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 20),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
          Text(title, style: titleStyle),
        ],
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
      fontSize: 15,
      color: textColor,
      fontFamily: fontFamily,
      package: fontFamilyPackage,
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: textStyle,
      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textStyle.copyWith(color: hintColor),
        prefixIcon: Icon(Icons.search, color: hintColor, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: Icon(Icons.clear, color: hintColor, size: 18),
            );
          },
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
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
                  package: 'flutter_country_picker',
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
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
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
