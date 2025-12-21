import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/review_models.dart';

class ReviewApi {
  ReviewApi(this.request);

  final CookieRequest request;

  static const String baseUrl = 'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id';

  String _url(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse(baseUrl).replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query,
    );
    return uri.toString();
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

    final res = await request.get(_url('/reviews/coach/$coachId/', query));

    // CookieRequest biasanya sudah decode JSON jadi Map/List
    final jsonMap = (res is String) ? jsonDecode(res) : res;
    return CoachReviewsResponse.fromJson(jsonMap);
  }

  // ===================== REVIEW DETAIL =====================
  Future<ReviewDetail> getReviewDetail(int reviewId) async {
    final res = await request.get(_url('/reviews/detail/$reviewId/'));
    final jsonMap = (res is String) ? jsonDecode(res) : res;
    return ReviewDetail.fromJson(jsonMap);
  }

  // ===================== CREATE =====================
  Future<void> createReview({
    required String coachId,
    required int rating,
    String? comment,
  }) async {
    final res = await request.postJson(
      _url('/reviews/coach/$coachId/create/'),
      jsonEncode({
        'rating': rating,
        'comment': comment ?? '',
      }),
    );

    // Kalau backend kamu balikin error info sebagai Map
    if (res is Map && (res['status'] == 'error' || res['success'] == false)) {
      throw Exception(res['message'] ?? 'Failed to create review');
    }
  }

  // ===================== UPDATE =====================
  Future<void> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
  }) async {
    final payload = <String, dynamic>{};
    if (rating != null) payload['rating'] = rating;
    if (comment != null) payload['comment'] = comment;

    final res = await request.postJson(
      _url('/reviews/update/$reviewId/'),
      jsonEncode(payload),
    );

    if (res is Map && (res['status'] == 'error' || res['success'] == false)) {
      throw Exception(res['message'] ?? 'Failed to update review');
    }
  }

  // ===================== DELETE =====================
  Future<void> deleteReview({
    required int reviewId,
  }) async {
    final res = await request.post(
      _url('/reviews/delete/$reviewId/'),
      {},
    );

    if (res is Map && (res['status'] == 'error' || res['success'] == false)) {
      throw Exception(res['message'] ?? 'Failed to delete review');
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
