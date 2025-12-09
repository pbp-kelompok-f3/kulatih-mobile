import 'package:flutter/material.dart';

/// ====== LIST / COACH REVIEWS ======

class CoachSummary {
  final String id;
  final String username;

  CoachSummary({required this.id, required this.username});

  factory CoachSummary.fromJson(Map<String, dynamic> json) {
    return CoachSummary(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}

class ReviewFilterState {
  final int? rating;

  ReviewFilterState({this.rating});

  factory ReviewFilterState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ReviewFilterState(rating: null);
    final r = json['rating'];
    if (r == null) return ReviewFilterState(rating: null);
    final parsed = int.tryParse(r.toString());
    return ReviewFilterState(rating: parsed);
  }
}

class Pagination {
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;
  final bool hasNext;
  final bool hasPrevious;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    int _i(dynamic v, [int d = 0]) => int.tryParse(v?.toString() ?? '') ?? d;
    return Pagination(
      page: _i(json['page'], 1),
      pageSize: _i(json['page_size'], 10),
      totalPages: _i(json['total_pages'], 1),
      totalItems: _i(json['total_items'], 0),
      hasNext: json['has_next'] == true,
      hasPrevious: json['has_previous'] == true,
    );
  }
}

class ReviewItem {
  final String id;
  final String reviewerId;
  final String reviewerUsername;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final bool isOwner;

  ReviewItem({
    required this.id,
    required this.reviewerId,
    required this.reviewerUsername,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isOwner,
  });

  String get initial =>
      (reviewerUsername.isNotEmpty ? reviewerUsername[0] : '?').toUpperCase();

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    int _parseInt(dynamic v, [int d = 0]) =>
        int.tryParse(v?.toString() ?? '') ?? d;

    return ReviewItem(
      id: json['id']?.toString() ?? '',
      reviewerId: json['reviewer_id']?.toString() ?? '',
      reviewerUsername: json['reviewer_username']?.toString() ?? '',
      rating: _parseInt(json['rating'], 0),
      comment: json['comment']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      isOwner: json['is_owner'] == true,
    );
  }
}

class CoachReviewsResponse {
  final CoachSummary coach;
  final ReviewFilterState filter;
  final Pagination pagination;
  final List<ReviewItem> items;

  CoachReviewsResponse({
    required this.coach,
    required this.filter,
    required this.pagination,
    required this.items,
  });

  factory CoachReviewsResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return CoachReviewsResponse(
      coach: CoachSummary.fromJson(
          (json['coach'] as Map<String, dynamic>? ?? {})),
      filter:
          ReviewFilterState.fromJson(json['filter'] as Map<String, dynamic>?),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
      items: itemsJson.map(ReviewItem.fromJson).toList(),
    );
  }
}

/// ====== DETAIL REVIEW ======

class ReviewerSummary {
  final String id;
  final String username;

  ReviewerSummary({required this.id, required this.username});

  factory ReviewerSummary.fromJson(Map<String, dynamic> json) {
    return ReviewerSummary(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}

class ReviewDetail {
  final String id;
  final CoachSummary coach;
  final ReviewerSummary reviewer;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final bool isOwner;

  ReviewDetail({
    required this.id,
    required this.coach,
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isOwner,
  });

  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    int _parseInt(dynamic v, [int d = 0]) =>
        int.tryParse(v?.toString() ?? '') ?? d;

    final coachJson =
        (json['coach'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final reviewerJson =
        (json['reviewer'] as Map<String, dynamic>? ?? <String, dynamic>{});

    return ReviewDetail(
      id: json['id']?.toString() ?? '',
      coach: CoachSummary.fromJson(coachJson),
      reviewer: ReviewerSummary(
        id: reviewerJson['id']?.toString() ?? '',
        username: reviewerJson['username']?.toString() ?? '',
      ),
      rating: _parseInt(json['rating'], 0),
      comment: json['comment']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      isOwner: json['is_owner'] == true,
    );
  }
}
