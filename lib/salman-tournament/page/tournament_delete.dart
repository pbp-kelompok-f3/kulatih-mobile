import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TournamentDeleteService {
  // Ubah return type jadi Future<bool>
  static Future<bool> deleteTournament({
    required BuildContext context,
    required String tournamentId,
  }) async {
    final request = context.read<CookieRequest>();
    final url = "http://localhost:8000/tournament/json/tournaments/$tournamentId/delete/"; 

    // 1. Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await request.postJson(url, jsonEncode({}));

      // 2. Tutup Loading dulu (Apapun hasilnya)
      if (context.mounted) {
        Navigator.of(context).pop(); 
      }

      if (context.mounted) {
        if (response['message'] != null) {
          // Sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message']), backgroundColor: Colors.green),
          );
          return true; // <--- KEMBALIKAN TRUE
        } else {
          // Gagal dari Backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? "Gagal menghapus."), backgroundColor: Colors.red),
          );
          return false; // <--- KEMBALIKAN FALSE
        }
      }
      return false;
    } catch (e) {
      // Error Koneksi
      if (context.mounted) {
        // Tutup loading jika masih kebuka (safety)
        // Navigator.of(context).pop(); // Opsional, biasanya sudah tertutup di blok try
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
      }
      return false; // <--- KEMBALIKAN FALSE
    }
  }
}