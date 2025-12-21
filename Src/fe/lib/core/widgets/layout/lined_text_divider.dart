import 'package:flutter/material.dart';
import 'package:movie_fe/core/extension/lined_text_divider_theme_extensions.dart';

class LinedTextDivider extends StatelessWidget {
  const LinedTextDivider({
    super.key,
    this.text,
  });

  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = LinedTextDividerTheme.of(context);

    if (text == null || text!.isEmpty) {
      return Padding(
        padding: theme.padding,
        child: Divider(
          color: theme.lineColor,
          thickness: theme.thickness,
          height: theme.thickness,
        ),
      );
    }

    return Padding(
      padding: theme.padding,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.lineColor,
              thickness: theme.thickness,
              height: theme.thickness,
            ),
          ),
          SizedBox(width: theme.spacing),
          Text(text!, style: theme.textStyle),
          SizedBox(width: theme.spacing),
          Expanded(
            child: Divider(
              color: theme.lineColor,
              thickness: theme.thickness,
              height: theme.thickness,
            ),
          ),
        ],
      ),
    );
  }
}
