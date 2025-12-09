// To parse this JSON data, do
//
//     final tournamentEntry = tournamentEntryFromJson(jsonString);

import 'dart:convert';

TournamentEntry tournamentEntryFromJson(String str) => TournamentEntry.fromJson(json.decode(str));

String tournamentEntryToJson(TournamentEntry data) => json.encode(data.toJson());

class TournamentEntry {
    String role;
    List<Tournament> tournaments;
    String namaUser;

    TournamentEntry({
        required this.role,
        required this.tournaments,
        required this.namaUser,
    });

    factory TournamentEntry.fromJson(Map<String, dynamic> json) => TournamentEntry(
        role: json["role"],
        tournaments: List<Tournament>.from(json["tournaments"].map((x) => Tournament.fromJson(x))),
        namaUser: json["namaUser"],
    );

    Map<String, dynamic> toJson() => {
        "role": role,
        "tournaments": List<dynamic>.from(tournaments.map((x) => x.toJson())),
        "namaUser": namaUser,
    };
}

class Tournament {
    String id;
    String nama;
    String tipe;
    DateTime tanggal;
    String lokasi;
    String poster;
    String deskripsi;
    String pembuat;
    String pembuatFoto;
    List<Participant> participants;
    int participantCount;

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

    factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
        id: json["id"],
        nama: json["nama"],
        tipe: json["tipe"],
        tanggal: DateTime.parse(json["tanggal"]),
        lokasi: json["lokasi"],
        poster: json["poster"],
        deskripsi: json["deskripsi"],
        pembuat: json["pembuat"],
        pembuatFoto: json["pembuat_foto"],
        participants: List<Participant>.from(json["participants"].map((x) => Participant.fromJson(x))),
        participantCount: json["participant_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "tipe": tipe,
        "tanggal": "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
        "lokasi": lokasi,
        "poster": poster,
        "deskripsi": deskripsi,
        "pembuat": pembuat,
        "pembuat_foto": pembuatFoto,
        "participants": List<dynamic>.from(participants.map((x) => x.toJson())),
        "participant_count": participantCount,
    };
}

class Participant {
    Member member;

    Participant({
        required this.member,
    });

    factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        member: Member.fromJson(json["member"]),
    );

    Map<String, dynamic> toJson() => {
        "member": member.toJson(),
    };
}

class Member {
    String id;
    String username;
    String city;
    String photo;

    Member({
        required this.id,
        required this.username,
        required this.city,
        required this.photo,
    });

    factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json["id"],
        username: json["username"],
        city: json["city"],
        photo: json["photo"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "city": city,
        "photo": photo,
    };
}
