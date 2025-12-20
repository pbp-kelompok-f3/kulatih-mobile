// To parse this JSON data, do
//
//     final bookingResponse = bookingResponseFromJson(jsonString);

import 'dart:convert';

BookingResponse bookingResponseFromJson(String str) => BookingResponse.fromJson(json.decode(str));

String bookingResponseToJson(BookingResponse data) => json.encode(data.toJson());

class BookingResponse {
    List<Booking> bookings;

    BookingResponse({
        required this.bookings,
    });

    factory BookingResponse.fromJson(Map<String, dynamic> json) => BookingResponse(
        bookings: List<Booking>.from(json["bookings"].map((x) => Booking.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "bookings": List<dynamic>.from(bookings.map((x) => x.toJson())),
    };
}

class Booking {
    int id;
    String coachName;
    String memberName;
    String sport;
    String location;
    DateTime date;
    String startTime;
    String endTime;
    String status;

    Booking({
        required this.id,
        required this.coachName,
        required this.memberName,
        required this.sport,
        required this.location,
        required this.date,
        required this.startTime,
        required this.endTime,
        required this.status,
    });

    factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"],
        coachName: json["coach_name"],
        memberName: json["member_name"],
        sport: json["sport"],
        location: json["location"],
        date: DateTime.parse(json["date"]),
        startTime: json["start_time"],
        endTime: json["end_time"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "coach_name": coachName,
        "member_name": memberName,
        "sport": sport,
        "location": location,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "start_time": startTime,
        "end_time": endTime,
        "status": status,
    };
}
