import 'package:flutter/material.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const _DemoApp());
}

class _DemoApp extends StatefulWidget {
  const _DemoApp();

  @override
  State<_DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<_DemoApp> {
  Locale _locale = const Locale('en', 'US');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Picker Demo',
      locale: _locale,
      supportedLocales: CountryPickerLocalizations.supportedLocales,
      localizationsDelegates: const [
        CountryPickerLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF4500)),
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
        useMaterial3: true,
      ),
      home: _DemoHome(
        locale: _locale,
        onLocaleChange: (l) => setState(() => _locale = l),
      ),
    );
  }
}

class _DemoHome extends StatefulWidget {
  const _DemoHome({required this.locale, required this.onLocaleChange});

  final Locale locale;
  final ValueChanged<Locale> onLocaleChange;

  @override
  State<_DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<_DemoHome> {
  String? _selectedCode;
  CountryFlagShape _shape = CountryFlagShape.round;

  Future<void> _open() async {
    final code = await showCountryPicker(
      context,
      selectedCode: _selectedCode,
      shape: _shape,
    );
    if (code != null) setState(() => _selectedCode = code);
  }

  @override
  Widget build(BuildContext context) {
    final selectedName = _selectedCode == null
        ? null
        : countryNameOf(context, _selectedCode!);
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_country_picker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedCode == null
                    ? 'No country selected'
                    : '$_selectedCode — $selectedName',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              SegmentedButton<CountryFlagShape>(
                segments: const [
                  ButtonSegment(
                    value: CountryFlagShape.round,
                    label: Text('Round'),
                  ),
                  ButtonSegment(
                    value: CountryFlagShape.rect,
                    label: Text('Rect'),
                  ),
                ],
                selected: {_shape},
                onSelectionChanged: (s) => setState(() => _shape = s.first),
              ),
              const SizedBox(height: 12),
              SegmentedButton<Locale>(
                segments: const [
                  ButtonSegment(
                    value: Locale('en', 'US'),
                    label: Text('English'),
                  ),
                  ButtonSegment(
                    value: Locale('nl', 'NL'),
                    label: Text('Nederlands'),
                  ),
                ],
                selected: {widget.locale},
                onSelectionChanged: (s) => widget.onLocaleChange(s.first),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _open,
                child: const Text('Pick a country'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
