import 'package:flutter/material.dart';

import 'review_api.dart';
import 'review_models.dart';
import 'review_card.dart';
import 'review_theme.dart';
import 'reviews_list_page.dart';
import 'review_detail_page.dart';

class CoachReviewsSection extends StatefulWidget {
  final String coachId;
  final String? coachName;

  const CoachReviewsSection({
    super.key,
    required this.coachId,
    this.coachName,
  });

  @override
  State<CoachReviewsSection> createState() => _CoachReviewsSectionState();
}

class _CoachReviewsSectionState extends State<CoachReviewsSection> {
  final _api = ReviewApi();

  late Future<CoachReviewsResponse> _future;

  static const int _previewPageSize = 3;

  @override
  void initState() {
    super.initState();
    _future = _api.getCoachReviews(
      coachId: widget.coachId,
      page: 1,
      pageSize: _previewPageSize,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api.getCoachReviews(
        coachId: widget.coachId,
        page: 1,
        pageSize: _previewPageSize,
      );
    });
  }

  void _openDetail(ReviewItem item) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (_) => ReviewDetailPage(reviewId: int.parse(item.id)),
    ))
        .then((changed) {
      if (changed == true) {
        _reload();
      }
    });
  }

  void _openSeeAll(CoachReviewsResponse initial) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => ReviewsListPage(
          coachId: widget.coachId,
          coachName: widget.coachName ?? initial.coach.username,
        ),
      ),
    )
        .then((_) {
      _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RATING AND FEEDBACK',
              style: TextStyle(
                color: ReviewColors.yellow,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Di mobile: ga ada filter di section ini
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<CoachReviewsResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: ReviewColors.yellow,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Failed to load reviews',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null || data.items.isEmpty) {
              return Container(
                decoration: BoxDecoration(
                  color: ReviewColors.indigoLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF2E2B55)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No reviews',
                      style: TextStyle(
                        color: ReviewColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Be the first to leave a rating & feedback.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }

            final items = data.items;

            return Column(
              children: [
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ReviewCard(
                      review: item,
                      onTapDetail: () => _openDetail(item),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (data.pagination.totalItems > items.length)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _openSeeAll(data),
                      child: const Text(
                        'See all reviews',
                        style: TextStyle(
                          color: ReviewColors.yellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
