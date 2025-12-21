import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TournamentAssigner {
  static Future<void> assignToTournament(
    BuildContext context,
    String tournamentId,
    String tournamentName,
  ) async {
    final request = context.read<CookieRequest>();

    final String url = "https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/tournament/json/$tournamentId/assign/";

    try {

      final response = await request.post(url, {}); 
      if (response["message"] == "Anda sudah terdaftar dalam turnamen ini.") {
        if (context.mounted) {
          _showPopup(
            context,
            title: "Sudah Terdaftar",
            message: "Anda sudah terdaftar di $tournamentName.",
          );
        }
        return;
      }
      if (response["status"] == "success") {
        if (context.mounted) {
          _showPopup(
            context,
            title: "Pendaftaran Berhasil",
            message: "Anda telah berhasil daftar ke turnamen $tournamentName!",
          );
        }
        return;
      }
      if (context.mounted) {
        _showPopup(
          context,
          title: "Gagal Mendaftar",
          message: response["error"] ?? "Terjadi kesalahan pada server.",
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showPopup(
          context,
          title: "Error",
          message: "Tidak dapat terhubung ke server atau terjadi kesalahan: $e",
        );
      }
    }
  }

  static void _showPopup(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}