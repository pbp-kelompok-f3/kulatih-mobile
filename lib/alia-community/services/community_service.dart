import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/community.dart';
import '../models/message.dart';

class CommunityService {
  static const String baseUrl = "http://localhost:8000/community";

  // Helper untuk force created_by ke enum valid
  static Map<String, dynamic> normalizeCreator(Map<String, dynamic> json) {
    final allowed = ["admin", "pew"];

    if (!allowed.contains(json["created_by"])) {
      // fallback default -> "admin"
      json["created_by"] = "admin";
    }
    return json;
  }

  // ============================================================
  // GET ALL COMMUNITIES
  // ============================================================
  static Future<List<CommunityEntry>> getAllCommunities(
      CookieRequest request) async {
    final response = await request.get("$baseUrl/json/");

    if (response is List) {
      return response
          .map((json) => CommunityEntry.fromJson(normalizeCreator(json)))
          .toList();
    }
    return [];
  }

  // ============================================================
  // GET COMMUNITY DETAIL
  // ============================================================
  static Future<CommunityEntry?> getCommunityDetail(
      CookieRequest request, int id) async {
    final response = await request.get("$baseUrl/$id/json/");
    return CommunityEntry.fromJson(normalizeCreator(response));
  }

  // ============================================================
  // CREATE COMMUNITY
  // ============================================================
  static Future<bool> createCommunity(
    CookieRequest request,
    String name,
    String shortDescription,
    String fullDescription,
    String? profileImageUrl,
  ) async {
    final response = await request.postJson(
      "$baseUrl/json/create",
      jsonEncode({
        "name": name,
        "short_description": shortDescription,
        "full_description": fullDescription,
        "profile_image_url": profileImageUrl,
      }),
    );

    return response["success"] == true;
  }

  // ============================================================
  // GET MY COMMUNITIES
  // ============================================================
  static Future<List<CommunityEntry>> getMyCommunities(
      CookieRequest request) async {
    final response = await request.get("$baseUrl/my/json/");

    // Django return LIST, bukan { communities: [...] }
    if (response is List) {
      return response
          .map((json) => CommunityEntry.fromJson(normalizeCreator(json)))
          .toList();
    }

    return [];
  }

  // ============================================================
  // JOIN COMMUNITY
  // ============================================================
  static Future<bool> joinCommunity(
      CookieRequest request, int id) async {
    final response =
        await request.postJson("$baseUrl/join/$id/json/", jsonEncode({}));

    return response["success"] == true;
  }

  // ============================================================
  // LEAVE COMMUNITY
  // ============================================================
  static Future<bool> leaveCommunity(
      CookieRequest request, int id) async {
    final response =
        await request.postJson("$baseUrl/leave/$id/json/", jsonEncode({}));

    return response["success"] == true;
  }

  // ============================================================
  // GET GROUP CHAT MESSAGES
  // ============================================================
  static Future<List<Message>> getMessages(
      CookieRequest request, int communityId) async {
    final response =
        await request.get("$baseUrl/my/$communityId/messages/json/");

    if (response["messages"] is List) {
      return (response["messages"] as List)
          .map((json) => Message.fromJson(json))
          .toList();
    }
    return [];
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================
  static Future<bool> sendMessage(
      CookieRequest request, int communityId, String text) async {
    final response = await request.postJson(
      "$baseUrl/my/$communityId/json/send_message/",
      jsonEncode({"text": text}),
    );

    return response["id"] != null;
  }

  // ============================================================
  // EDIT MESSAGE
  // ============================================================
  static Future<bool> editMessage(CookieRequest request, int communityId,
      int msgId, String newText) async {
    final response = await request.postJson(
      "$baseUrl/my/$communityId/json/edit_message/$msgId/",
      jsonEncode({"text": newText}),
    );

    return response["success"] == true;
  }

  // ============================================================
  // DELETE MESSAGE
  // ============================================================
  static Future<bool> deleteMessage(
      CookieRequest request, int communityId, int msgId) async {

    final response = await request.postJson(
      "$baseUrl/my/$communityId/json/delete_message/$msgId/",
      jsonEncode({}),
    );

    return response["success"] == true;
  }
}
