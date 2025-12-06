import 'package:equatable/equatable.dart';

class LanguageSettings extends Equatable {
  const LanguageSettings({
    required this.selected,
  });

  final String selected;

  factory LanguageSettings.fromJson(Map<String, dynamic> json) {
    return LanguageSettings(
      selected: json['selected'] as String? ?? 'en_us',
    );
  }

  Map<String, dynamic> toJson() => {'selected': selected};

  LanguageSettings copyWith({String? selected}) {
    return LanguageSettings(selected: selected ?? this.selected);
  }

  static const defaults = LanguageSettings(selected: 'en_us');

  @override
  List<Object?> get props => [selected];
}


