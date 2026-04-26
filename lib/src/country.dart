/// A country selected from the picker.
///
/// `code` is the ISO 3166-1 alpha-2 code (e.g. `NL`, `US`).
/// `name` is the country's display name in the active locale.
class Country {
  final String code;
  final String name;

  const Country({required this.code, required this.name});

  @override
  bool operator ==(Object other) =>
      other is Country && other.code == code && other.name == name;

  @override
  int get hashCode => Object.hash(code, name);

  @override
  String toString() => 'Country($code, $name)';
}
