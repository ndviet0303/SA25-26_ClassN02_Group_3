import 'package:flutter/material.dart';

class TextUtils {
  const TextUtils._();

  static List<TextSpan> buildDescriptionSpans(String raw, ThemeData theme, Color textColor) {
    var text = raw
        .replaceAll(RegExp(r'</?p[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .trim();

    final spans = <TextSpan>[];
    final regex = RegExp(r'(<strong[^>]*>)(.*?)(</strong>)', caseSensitive: false, dotAll: true);
    int lastIndex = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      final boldText = match.group(2) ?? '';
      spans.add(TextSpan(
        text: boldText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ));
      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }
    return spans;
  }
}


