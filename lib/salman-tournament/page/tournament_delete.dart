import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TournamentDeleteService {
  static Future<bool> deleteTournament({
    required BuildContext context,
    required String tournamentId,
  }) async {
    final request = context.read<CookieRequest>();
    final url =
        "https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/tournament/json/tournaments/$tournamentId/delete/";

    // 1. Loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await request.postJson(url, jsonEncode({}));

      // 2. Tutup dialog (AMAN, navbar tetap ada)
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!context.mounted) return false;

      if (response['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? "Gagal menghapus."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      // Tutup dialog kalau error
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
