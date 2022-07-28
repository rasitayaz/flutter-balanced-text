library balanced_text;

import 'package:flutter/widgets.dart';

class BalancedText extends StatelessWidget {
  const BalancedText(
    this.data, {
    Key? key,
    this.style,
    this.textAlign,
    this.softWrap,
    this.overflow,
    this.maxLines,
  }) : super(key: key);

  /// The text to display.
  final String data;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's "inherit" property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool? softWrap;

  /// How visual overflow should be handled.
  ///
  /// If this is null [TextStyle.overflow] will be used, otherwise the value
  /// from the nearest [DefaultTextStyle] ancestor will be used.
  final TextOverflow? overflow;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient [DefaultTextStyle] that specifies
  /// an explicit number for its [DefaultTextStyle.maxLines], then the
  /// [DefaultTextStyle] value will take precedence. You can use a [RichText]
  /// widget directly to entirely override the [DefaultTextStyle].
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Text(
          _getBalanced(constraints.maxWidth),
          style: style,
          textAlign: textAlign,
          softWrap: softWrap,
          overflow: overflow,
          maxLines: maxLines,
        );
      },
    );
  }

  String _getBalanced(double width) {
    List<String> words = data.split(' ');
    if (words.length < 3 || _getWidth(data) < width) return data;

    List<String> balancedStrings = [];

    double lastDifference = double.infinity;
    for (int i = 1; i <= words.length; i++) {
      List<String> leadingWords = words.sublist(0, i);
      String leading = leadingWords.join(' ');
      double leadingWidth = _getWidth(leading);

      List<String> remainingWords = words.sublist(i, words.length);
      String remaining = remainingWords.join(' ');
      double remainingWidth = _getWidth(remaining);

      double widthDifference = (leadingWidth - remainingWidth).abs();

      if (widthDifference > lastDifference) {
        leading = words.sublist(0, i - 1).join(' ');
        remaining = words.sublist(i - 1, words.length).join(' ');
        balancedStrings.addAll([leading, '\n', remaining]);
        break;
      }

      if (leadingWidth > width) return data;
      lastDifference = widthDifference;
    }

    return balancedStrings.join();
  }

  double _getWidth(String? string) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: string, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size.width;
  }
}
