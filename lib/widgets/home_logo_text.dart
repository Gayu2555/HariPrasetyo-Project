import 'package:flutter/material.dart';

class HomeLogoText extends StatelessWidget {
  const HomeLogoText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo bulat dengan gradient
        Container(
          width: 48.0,
          height: 48.0,
          child: Center(
            // Mengganti Text 'S' dengan Image.asset
            child: ClipOval(
              child: Image.asset(
                'assets/logo.jpg',
                width: 36.0,
                height: 36.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                children: [
                  TextSpan(
                    text: 'SHARE',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: 'RE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
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
