// lib/alia-community/services/community_service.dart

import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community.dart';
import '../models/message.dart';

class CommunityService {
  static const String baseUrl = "http://localhost:8000/community/api";

  // GET all communities
  static Future<List<Community>> getAllCommunities() async {
    try {
      final response = await CookieRequest().get("$baseUrl/list/");

      return (response as List)
          .map((json) => Community.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // GET communities user has joined
  static Future<List<Community>> getJoinedCommunities() async {
    try {
      final response =
          await CookieRequest().get("$baseUrl/my-communities/");

      return (response as List)
          .map((json) => Community.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // POST create community
  static Future<bool> createCommunity(
      BuildContext context,
      String name,
      String shortDesc,
      String longDesc,
      ) async {
    final request = context.read<CookieRequest>();

    final response = await request.post(
      "$baseUrl/create/",
      {
        "name": name,
        "short_description": shortDesc,
        "long_description": longDesc,
      },
    );

    return response["status"] == "success";
  }

  // POST join
  static Future<bool> joinCommunity(BuildContext context, int id) async {
    final request = context.read<CookieRequest>();

    final response = await request.post(
      "$baseUrl/join/$id/",
      {},
    );

    return response["status"] == "success";
  }

  // POST leave
  static Future<void> leaveCommunity(int id) async {
    await CookieRequest().post("$baseUrl/leave/$id/", {});
  }

  // GET messages for community
  static Future<List<Message>> getMessages(int communityId) async {
    try {
      final response =
          await CookieRequest().get("$baseUrl/messages/$communityId/");

      return (response as List)
          .map((json) => Message.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // POST send message
  static Future<bool> sendMessage(
      BuildContext context,
      int communityId,
      String message,
      ) async {
    final request = context.read<CookieRequest>();

    final response = await request.post(
      "$baseUrl/send/$communityId/",
      {"content": message},
    );

    return response["status"] == "success";
  }
}
