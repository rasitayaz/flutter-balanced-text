library balanced_text;

import 'package:flutter/widgets.dart';

class BalancedText extends StatelessWidget {
  /// Creates a balanced text widget.
  ///
  /// If the [style] argument is null, the text will use the style from the
  /// closest enclosing [DefaultTextStyle].
  ///
  /// The [data] parameter must not be null.
  ///
  /// The [overflow] property's behavior is affected by the [softWrap] argument.
  /// If the [softWrap] is true or null, the glyph causing overflow, and those that follow,
  /// will not be rendered. Otherwise, it will be shown with the given overflow option.
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
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);

    return LayoutBuilder(
      builder: (context, constraints) {
        /// Generates a balanced string by splitting the text into words.
        String getBalancedText() {
          final maxWidth = constraints.maxWidth;

          if (data.contains('\n')) {
            return data;
          }

          /// Calculates the width of the given text.
          double getWidth(String? text) {
            final textPainter = TextPainter(
              text: TextSpan(
                text: text,
                style: effectiveStyle,
              ),
              textDirection: TextDirection.ltr,
            )..layout();

            print('$text: ${textPainter.width}');

            return textPainter.size.width;
          }

          final words = data.split(' ');

          if (words.length < 3 || getWidth(data) < maxWidth) {
            return data;
          }

          var lastDifference = double.infinity;

          for (int i = 1; i <= words.length; i++) {
            final leading = words.sublist(0, i).join(' ');
            final leadingWidth = getWidth(leading);

            final remaining = words.sublist(i, words.length).join(' ');
            final remainingWidth = getWidth(remaining);

            if (leadingWidth > maxWidth) {
              return data;
            }

            final widthDifference = (leadingWidth - remainingWidth).abs();

            if (widthDifference > lastDifference) {
              return [
                words.sublist(0, i - 1).join(' '),
                '\n',
                words.sublist(i - 1, words.length).join(' '),
              ].join();
            }

            lastDifference = widthDifference;
          }

          return data;
        }

        return Text(
          getBalancedText(),
          style: effectiveStyle,
          textAlign: textAlign,
          softWrap: softWrap,
          overflow: overflow,
          maxLines: maxLines,
        );
      },
    );
  }
}
