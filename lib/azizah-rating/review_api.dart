import 'dart:convert';
import 'package:http/http.dart' as http;

import 'review_models.dart';

class ReviewApi {
  ReviewApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Ganti ke base URL deploy / lokal kalian
  static const String baseUrl =
      'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id';

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse(baseUrl).replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters:
          query?.map((k, v) => MapEntry(k, v?.toString() ?? '')) ?? {},
    );
    return uri;
  }

  Map<String, String> _headers({
    bool jsonBody = false,
    String? cookie,
    String? csrfToken,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (cookie != null && cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    if (csrfToken != null && csrfToken.isNotEmpty) {
      headers['X-CSRFToken'] = csrfToken;
    }
    return headers;
  }

  Future<CoachReviewsResponse> getCoachReviews({
    required String coachId,
    int? rating,
    int page = 1,
    int pageSize = 10,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (rating != null) {
      query['rating'] = rating;
    }

    final uri = _uri('/reviews/coach/$coachId/', query);
    final res = await _client.get(uri, headers: _headers());
    if (res.statusCode != 200) {
      throw Exception(
          'Failed to load reviews (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes))
        as Map<String, dynamic>;
    return CoachReviewsResponse.fromJson(data);
  }

  Future<ReviewDetail> getReviewDetail(int reviewId) async {
    final uri = _uri('/reviews/detail/$reviewId/');
    final res = await _client.get(uri, headers: _headers());
    if (res.statusCode != 200) {
      throw Exception(
          'Failed to load review detail (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes))
        as Map<String, dynamic>;
    return ReviewDetail.fromJson(data);
  }

  Future<ReviewDetail> createReview({
    required String coachId,
    required int rating,
    String? comment,
    String? cookie,
    String? csrfToken,
  }) async {
    final uri = _uri('/reviews/coach/$coachId/create/');
    final body = jsonEncode({
      'rating': rating,
      'comment': comment ?? '',
    });

    final res = await _client.post(
      uri,
      headers: _headers(jsonBody: true, cookie: cookie, csrfToken: csrfToken),
      body: body,
    );

    if (res.statusCode != 201) {
      throw Exception(
          'Failed to create review (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes))
        as Map<String, dynamic>;

    // Response create_review_json tidak ada nested coach/reviewer,
    // jadi kita ambil detail lagi supaya konsisten dengan ReviewDetail.
    final newId = int.tryParse(data['id']?.toString() ?? '');
    if (newId == null) {
      throw Exception('Invalid review id in create response');
    }
    return getReviewDetail(newId);
  }

  Future<ReviewDetail> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
    String? cookie,
    String? csrfToken,
  }) async {
    final uri = _uri('/reviews/update/$reviewId/');
    final payload = <String, dynamic>{};
    if (rating != null) payload['rating'] = rating;
    if (comment != null) payload['comment'] = comment;

    final res = await _client.post(
      uri,
      headers: _headers(jsonBody: true, cookie: cookie, csrfToken: csrfToken),
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception(
          'Failed to update review (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes))
        as Map<String, dynamic>;
    // data sederhana, tapi supaya konsisten ambil detail lagi
    return getReviewDetail(reviewId);
  }

  Future<void> deleteReview({
    required int reviewId,
    String? cookie,
    String? csrfToken,
  }) async {
    final uri = _uri('/reviews/delete/$reviewId/');
    final res = await _client.post(
      uri,
      headers: _headers(cookie: cookie, csrfToken: csrfToken),
    );
    if (res.statusCode != 200) {
      throw Exception(
          'Failed to delete review (${res.statusCode}): ${res.body}');
    }
  }
}
