import 'dart:convert';

TournamentEntry tournamentEntryFromJson(String str) =>
    TournamentEntry.fromJson(json.decode(str));

String tournamentEntryToJson(TournamentEntry data) =>
    json.encode(data.toJson());

class TournamentEntry {
  final String role;
  final List<Tournament> tournaments;
  final String namaUser;

  TournamentEntry({
    required this.role,
    required this.tournaments,
    required this.namaUser,
  });

  factory TournamentEntry.fromJson(Map<String, dynamic> json) {
    return TournamentEntry(
      role: json['role']?.toString() ?? 'unknown',
      namaUser: json['username']?.toString() ??
          json['namaUser']?.toString() ??
          '',
      tournaments: (json['tournaments'] as List? ?? [])
          .map((e) => Tournament.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'username': namaUser,
        'tournaments': tournaments.map((e) => e.toJson()).toList(),
      };
}

class Tournament {
  final String id;
  final String nama;
  final String tipe;
  final DateTime tanggal;
  final String lokasi;
  final String poster;
  final String deskripsi;
  final String pembuat;
  final String pembuatFoto;
  final List<Participant> participants;
  final int participantCount;

  Tournament({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.tanggal,
    required this.lokasi,
    required this.poster,
    required this.deskripsi,
    required this.pembuat,
    required this.pembuatFoto,
    required this.participants,
    required this.participantCount,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      tipe: json['tipe']?.toString() ?? '',
      tanggal: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal'].toString()) ??
              DateTime(1970)
          : DateTime(1970),
      lokasi: json['lokasi']?.toString() ?? '',
      poster: json['poster']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      pembuat: json['pembuat']?.toString() ?? '',
      pembuatFoto: json['pembuat_foto']?.toString() ?? '',
      participants: (json['participants'] as List? ?? [])
          .map((e) => Participant.fromJson(e))
          .toList(),
      participantCount: json['participant_count'] is int
          ? json['participant_count']
          : int.tryParse(json['participant_count']?.toString() ?? '0') ??
              0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'tipe': tipe,
        'tanggal': tanggal.toIso8601String(),
        'lokasi': lokasi,
        'poster': poster,
        'deskripsi': deskripsi,
        'pembuat': pembuat,
        'pembuat_foto': pembuatFoto,
        'participants': participants.map((e) => e.toJson()).toList(),
        'participant_count': participantCount,
      };
}

class Participant {
  final Member member;

  Participant({required this.member});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      member: Member.fromJson(json['member'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'member': member.toJson(),
      };
}

class Member {
  final String id;
  final String username;
  final String city;
  final String photo;

  Member({
    required this.id,
    required this.username,
    required this.city,
    required this.photo,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'city': city,
        'photo': photo,
      };
}
