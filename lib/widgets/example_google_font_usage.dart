// title=lib/widgets/example_google_font_usage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExampleGoogleFontUsage extends StatelessWidget {
  const ExampleGoogleFontUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Mariatu Ngum',
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}
