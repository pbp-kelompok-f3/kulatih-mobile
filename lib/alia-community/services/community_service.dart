// lib/alia-community/services/community_service.dart

import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/community.dart';
import '../models/message.dart';

class CommunityService {
  // Ganti baseUrl sesuai environment kamu:
  // - emulator Android: 10.0.2.2
  // - browser/web: localhost
  static const String baseUrl = "http://10.0.2.2:8000";

  // =======================
  //  COMMUNITY BASIC
  // =======================

  // GET semua community
  static Future<List<Community>> getAllCommunities(
      CookieRequest request) async {
    try {
      final response =
          await request.get("$baseUrl/community/api/communities/");

      if (response is List) {
        return response
            .map<Community>((json) => Community.fromJson(json))
            .toList();
      } else if (response is Map && response["communities"] is List) {
        return (response["communities"] as List)
            .map<Community>((json) => Community.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print("ERROR getAllCommunities: $e");
      return [];
    }
  }

  // GET community yang sudah di-join user
  static Future<List<Community>> getJoinedCommunities(
      CookieRequest request) async {
    try {
      final response =
          await request.get("$baseUrl/community/api/my-communities/");

      if (response is List) {
        return response
            .map<Community>((json) => Community.fromJson(json))
            .toList();
      } else if (response is Map && response["communities"] is List) {
        return (response["communities"] as List)
            .map<Community>((json) => Community.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print("ERROR getJoinedCommunities: $e");
      return [];
    }
  }

  // POST create community
  static Future<bool> createCommunity(
    CookieRequest request,
    String name,
    String shortDescription,
    String fullDescription,
  ) async {
    try {
      final response = await request.postJson(
        "$baseUrl/community/api/create/",
        jsonEncode({
          "name": name,
          "short_description": shortDescription,
          "full_description": fullDescription,
        }),
      );

      return response["success"] == true || response["status"] == "success";
    } catch (e) {
      print("ERROR createCommunity: $e");
      return false;
    }
  }

  // POST join community
  static Future<bool> joinCommunity(
      CookieRequest request, int communityId) async {
    try {
      final response = await request.postJson(
        "$baseUrl/community/api/$communityId/join/",
        jsonEncode({}),
      );
      return response["success"] == true || response["status"] == "success";
    } catch (e) {
      print("ERROR joinCommunity: $e");
      return false;
    }
  }

  // POST leave community
  static Future<bool> leaveCommunity(
      CookieRequest request, int communityId) async {
    try {
      final response = await request.postJson(
        "$baseUrl/community/api/$communityId/leave/",
        jsonEncode({}),
      );
      return response["success"] == true || response["status"] == "success";
    } catch (e) {
      print("ERROR leaveCommunity: $e");
      return false;
    }
  }

  // =======================
  //  GROUP CHAT
  // =======================

  // GET semua message untuk suatu community
  static Future<List<Message>> getMessages(
      CookieRequest request, int communityId) async {
    try {
      final response = await request
          .get("$baseUrl/community/api/$communityId/messages/");

      // Bisa berupa List langsung atau dibungkus {"messages": [...]}
      if (response is List) {
        return response
            .map<Message>((json) => Message.fromJson(json))
            .toList();
      } else if (response is Map && response["messages"] is List) {
        return (response["messages"] as List)
            .map<Message>((json) => Message.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print("ERROR getMessages: $e");
      return [];
    }
  }

  // POST kirim message ke community
  static Future<bool> sendMessage(
    CookieRequest request,
    int communityId,
    String text,
  ) async {
    try {
      final response = await request.postJson(
        "$baseUrl/community/api/$communityId/messages/send/",
        jsonEncode({
          "text": text,
        }),
      );

      return response["success"] == true || response["status"] == "success";
    } catch (e) {
      print("ERROR sendMessage: $e");
      return false;
    }
  }
}
