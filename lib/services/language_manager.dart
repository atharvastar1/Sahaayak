import 'package:flutter/material.dart';

class LanguageManager extends InheritedWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageManager({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    required super.child,
  });

  static LanguageManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LanguageManager>();
  }

  @override
  bool updateShouldNotify(LanguageManager oldWidget) {
    return currentLanguage != oldWidget.currentLanguage;
  }
}
