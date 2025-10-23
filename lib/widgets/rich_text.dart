import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<TextSpan> children;

  const CustomRichText({
    Key? key,
    required this.text,
    this.style,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: style ?? Theme.of(context).textTheme.bodyMedium,
        children: children,
      ),
    );
  }
}
