import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle heading(double size, {Color color = Colors.white}) {
  return GoogleFonts.bebasNeue(
    fontSize: size,
    color: color,
    letterSpacing: 1.2,
  );
}

TextStyle body(double size, {Color color = Colors.white}) {
  return GoogleFonts.beVietnamPro(
    fontSize: size,
    color: color,
    height: 1.4,
  );
}
