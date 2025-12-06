import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kulatih_mobile/salman-tournament/models/tournament_entry.dart'; // pastikan path sesuai

Future<TournamentEntry> fetchTournaments() async {
  final url = Uri.parse("http://localhost:8000/tournament/json/tournaments/"); // endpoint Django
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return tournamentEntryFromJson(
      response.body,
    );
  } else {
    throw Exception("Gagal fetch tournaments");
  }
}
