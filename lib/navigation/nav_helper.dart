import 'package:flutter/material.dart';

import 'package:kulatih_mobile/izzati-forum/pages/forum_main.dart';

void handleNavTap(BuildContext context, int index) {
  Widget target;

  switch (index) {
    case 3:
      target = const ForumMainPage();
      break;

    default:
      // Untuk halaman lain yang belum kamu buat, jangan panggil apa-apa
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Halaman belum tersedia")),
      );
      return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => target),
  );
}
