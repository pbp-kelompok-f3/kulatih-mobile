import 'dart:convert';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

import '../models/review_models.dart';

class ReviewApi {
  ReviewApi()
      : _client = BrowserClient()..withCredentials = true;

  final http.Client _client;

  static const String baseUrl = 'http://localhost:8000';

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse(baseUrl).replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query,
    );
  }

  Map<String, String> _headers({bool jsonBody = false}) {
    return {
      'Accept': 'application/json',
      if (jsonBody) 'Content-Type': 'application/json',
    };
  }

  // ===================== COACH REVIEWS (LIST) =====================
  Future<CoachReviewsResponse> getCoachReviews({
    required String coachId,
    int? rating,
    int page = 1,
    int pageSize = 10,
  }) async {
    final query = <String, dynamic>{
      'page': '$page',
      'page_size': '$pageSize',
    };
    if (rating != null) query['rating'] = '$rating';

    final uri = _uri('/reviews/coach/$coachId/', query);
    final res = await _client.get(uri, headers: _headers());

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    return CoachReviewsResponse.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)),
    );
  }

  // ===================== REVIEW DETAIL =====================
  Future<ReviewDetail> getReviewDetail(int reviewId) async {
    final uri = _uri('/reviews/detail/$reviewId/');
    final res = await _client.get(uri, headers: _headers());

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    return ReviewDetail.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)),
    );
  }

  // ===================== CREATE =====================
  Future<void> createReview({
    required String coachId,
    required int rating,
    String? comment,
  }) async {
    final uri = _uri('/reviews/coach/$coachId/create/');
    final res = await _client.post(
      uri,
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'rating': rating,
        'comment': comment ?? '',
      }),
    );

    if (res.statusCode != 201) {
      throw Exception(res.body);
    }
  }

  // ===================== UPDATE =====================
  Future<void> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
  }) async {
    final uri = _uri('/reviews/update/$reviewId/');
    final payload = <String, dynamic>{};
    if (rating != null) payload['rating'] = rating;
    if (comment != null) payload['comment'] = comment;

    final res = await _client.post(
      uri,
      headers: _headers(jsonBody: true),
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }

  // ===================== DELETE =====================
  Future<void> deleteReview({
    required int reviewId,
  }) async {
    final uri = _uri('/reviews/delete/$reviewId/');
    final res = await _client.post(uri, headers: _headers());

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }

  // ===================== FIND MY REVIEW ID =====================
  Future<int?> getMyReviewIdForCoach({
    required String coachId,
    int pageSize = 50,
  }) async {
    int page = 1;

    while (true) {
      final res = await getCoachReviews(
        coachId: coachId,
        page: page,
        pageSize: pageSize,
      );

      final mine = res.items.where((it) => it.isOwner).toList();
      if (mine.isNotEmpty) {
        return int.tryParse(mine.first.id);
      }

      if (!res.pagination.hasNext) return null;
      page++;
    }
  }
}
