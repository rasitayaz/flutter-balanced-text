library balanced_text;

import 'package:flutter/widgets.dart';

class BalancedText extends StatelessWidget {
  const BalancedText(
    this.text, {
    super.key,
    required this.style,
    this.maxLines,
  });

  final String? text;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Text(
          _getBalancedText(constraints.maxWidth)!,
          style: style,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
        );
      },
    );
  }

  String? _getBalancedText(double width) {
    List<String> words = text!.split(' ');
    if (words.length < 3 || _getTextWidth(text) < width) return text;

    List<String> balancedStrings = [];

    double lastDifference = double.infinity;
    for (int i = 1; i <= words.length; i++) {
      List<String> leadingWords = words.sublist(0, i);
      String leading = leadingWords.join(' ');
      double leadingWidth = _getTextWidth(leading);

      List<String> remainingWords = words.sublist(i, words.length);
      String remaining = remainingWords.join(' ');
      double remainingWidth = _getTextWidth(remaining);

      double widthDifference = (leadingWidth - remainingWidth).abs();

      if (widthDifference > lastDifference) {
        leading = words.sublist(0, i - 1).join(' ');
        remaining = words.sublist(i - 1, words.length).join(' ');
        balancedStrings.addAll([leading, '\n', remaining]);
        break;
      }

      if (leadingWidth > width) return text;
      lastDifference = widthDifference;
    }

    return balancedStrings.join();
  }

  double _getTextWidth(String? text) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size.width;
  }
}
