import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../services/review_api.dart';
import '../models/review_models.dart';
import '../widgets/review_card.dart';
import '../widgets/review_theme.dart';
import 'review_detail_page.dart';

class ReviewsListPage extends StatefulWidget {
  final String coachId;
  final String? coachName;

  const ReviewsListPage({
    super.key,
    required this.coachId,
    this.coachName,
  });

  @override
  State<ReviewsListPage> createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage> {
  ReviewApi? _api;

  int? _ratingFilter;
  int _page = 1;
  static const int _pageSize = 10;

  late Future<CoachReviewsResponse> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // init sekali
    _api ??= ReviewApi(context.read<CookieRequest>());
    _future = _load();
  }

  Future<CoachReviewsResponse> _load() {
    return _api!.getCoachReviews(
      coachId: widget.coachId,
      rating: _ratingFilter,
      page: _page,
      pageSize: _pageSize,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  void _changeRating(int? rating) {
    setState(() {
      _ratingFilter = rating;
      _page = 1;
      _future = _load();
    });
  }

  void _changePage(int newPage) {
    if (newPage < 1) return;
    setState(() {
      _page = newPage;
      _future = _load();
    });
  }

  void _openDetail(ReviewItem item) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ReviewDetailPage(reviewId: int.parse(item.id)),
          ),
        )
        .then((changed) {
      if (changed == true) {
        _reload();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReviewColors.indigoDark,
      appBar: AppBar(
        backgroundColor: ReviewColors.indigoDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: ReviewColors.white),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // ===== HEADER + FILTER (SEJAJAR) =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RATING AND FEEDBACK',
                    style: TextStyle(
                      color: ReviewColors.yellow,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                          color: ReviewColors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ReviewColors.indigoDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2E2B55)),
                        ),
                        child: DropdownButton<int?>(
                          value: _ratingFilter,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: ReviewColors.indigoDark,
                          underline: const SizedBox.shrink(),
                          iconEnabledColor: ReviewColors.white,
                          style: const TextStyle(
                            color: ReviewColors.white,
                            fontSize: 13,
                          ),
                          items: const [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 5,
                              child: Text('5★'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 4,
                              child: Text('4★'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 3,
                              child: Text('3★'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 2,
                              child: Text('2★'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 1,
                              child: Text('1★'),
                            ),
                          ],
                          onChanged: _changeRating,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ===== LIST + PAGINATION =====
              Expanded(
                child: FutureBuilder<CoachReviewsResponse>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ReviewColors.yellow,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Failed to load reviews',
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data;
                    if (data == null || data.items.isEmpty) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: ReviewColors.indigoLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF2E2B55)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'NO REVIEWS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ReviewColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Be the first to leave a rating & feedback.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final items = data.items;

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ReviewCard(
                                review: item,
                                onTapDetail: () => _openDetail(item),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (data.pagination.hasPrevious)
                              TextButton(
                                onPressed: () =>
                                    _changePage(data.pagination.page - 1),
                                child: const Text(
                                  'Prev',
                                  style: TextStyle(
                                    color: ReviewColors.white,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 64),
                            Text(
                              data.pagination.totalPages > 1
                                  ? 'Page ${data.pagination.page} / ${data.pagination.totalPages}'
                                  : '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            if (data.pagination.hasNext)
                              TextButton(
                                onPressed: () =>
                                    _changePage(data.pagination.page + 1),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    color: ReviewColors.white,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 64),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
