import 'package:flutter/material.dart';

class HomeLogoText extends StatelessWidget {
  const HomeLogoText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                children: [
                  const TextSpan(
                    text: 'SHARE',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  const TextSpan(
                    text: 'RE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const TextSpan(
                    text: 'CIPE',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              'Discover your next meal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12.0,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
