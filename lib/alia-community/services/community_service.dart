import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/community.dart';
import '../models/message.dart';

class CommunityService {
  static const String baseUrl = "http://localhost:8000/community";

<<<<<<< HEAD
=======
  /// Convert external image URL to proxied URL
  static String getProxiedImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    // If it's already a proxied URL, return as is
    if (imageUrl.contains('/proxy-image/')) {
      return imageUrl;
    }
    
    // Encode the image URL
    final encodedUrl = Uri.encodeComponent(imageUrl);
    
    // Return proxied URL
    return '$baseUrl/proxy-image/?url=$encodedUrl';
  }

>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
  /// Safely handle unknown creator usernames
  static Map<String, dynamic> normalizeCreator(Map<String, dynamic> json) {
    final newJson = Map<String, dynamic>.from(json);

    final allowed = ["admin", "pew"];
    if (!allowed.contains(newJson["created_by"])) {
      newJson["created_by"] = "admin";
    }

    return newJson;
  }

  // Get All Communities
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

  // Get Community Detail
  static Future<Map<String, dynamic>?> getCommunityDetail(
      CookieRequest request, int id) async {
    final response = await request.get("$baseUrl/$id/json/");

    if (response is Map<String, dynamic>) {
      return normalizeCreator(response);
    }
    return null;
  }

  // Create Community
  static Future<CommunityEntry?> createCommunity(
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

    if (response["id"] != null) {
      return CommunityEntry.fromJson(normalizeCreator(response));
    }
    return null;
  }

  //Get My Communities
  static Future<List<CommunityEntry>> getMyCommunities(
      CookieRequest request) async {
    final response = await request.get("$baseUrl/my/json/");

    if (response is List) {
      return response
          .map((json) => CommunityEntry.fromJson(normalizeCreator(json)))
          .toList();
    }
    return [];
  }

 // Join Community
static Future<CommunityEntry?> joinCommunity(
    CookieRequest request, int id) async {
  try {
    final response =
        await request.postJson("$baseUrl/join/$id/json/", jsonEncode({}));

    print('🔵 Join response: $response'); // DEBUG

    // Cek apakah berhasil (joined baru atau already member)
    if (response["success"] == true || response["community"] != null) {
      // Return community data
      if (response["community"] != null) {
        return CommunityEntry.fromJson(
          normalizeCreator(response["community"]),
        );
      }
      
      // Kalau already member tapi tetap success, return dummy object
      // Supaya UI tahu join "berhasil" (walaupun udah member)
      return CommunityEntry(
        id: id,
        name: '',
        shortDescription: '',
        fullDescription: '',
        profileImageUrl: null,
        membersCount: 0,
        createdAt: DateTime.now(),
        createdBy: CreatedBy.ADMIN,
      );
    }
    
    return null;
  } catch (e) {
    print('🔴 Error joining community: $e');
    return null;
  }
}

// Leave Community
static Future<bool> leaveCommunity(
    CookieRequest request, int id) async {
  try {
    final response =
        await request.postJson("$baseUrl/leave/$id/json/", jsonEncode({}));

    print('🔵 Leave response: $response'); 

    // Cek apakah berhasil
    if (response["success"] == true) {
      return true;
    }
    
    return false;
  } catch (e) {
    print('🔴 Error leaving community: $e');
    return false;
  }
}

  // Get Messages
  static Future<List<Message>> getMessages(
      CookieRequest request, int communityId) async {
    final response =
        await request.get("$baseUrl/my/$communityId/messages/json/");

    if (response is Map && response["messages"] is List) {
      return (response["messages"] as List)
          .map((json) => Message.fromJson(json))
          .toList();
    }

    return [];
  }

  // Send Message
  static Future<Message?> sendMessage(
      CookieRequest request, int communityId, String text) async {
    final response = await request.postJson(
      "$baseUrl/my/$communityId/json/send_message/",
      jsonEncode({"text": text}),
    );

    if (response["data"] != null) {
      return Message.fromJson(response["data"]);
    }
    return null;
  }

  // Edit Message
  static Future<bool> editMessage(
      CookieRequest request, int communityId, int msgId, String newText) async {
    final response = await request.postJson(
      "$baseUrl/my/$communityId/json/edit_message/$msgId/",
      jsonEncode({"text": newText}),
    );

    return response["success"] == true;
  }

  // Delete Message
  static Future<bool> deleteMessage(
      CookieRequest request, int communityId, int msgId) async {
    final response = await request.postJson(
      "$baseUrl/my/$communityId/json/delete_message/$msgId/",
      jsonEncode({}),
    );

    return response["success"] == true;
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
