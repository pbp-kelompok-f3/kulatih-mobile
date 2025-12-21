import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../services/review_api.dart';
import '../models/review_models.dart';
import '../widgets/review_card.dart';
import 'review_detail_page.dart';

// TODO: sesuaikan path ini jika perlu
import '/theme/app_colors.dart';

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
      if (changed == true) _reload();
    });
  }

  Widget _buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Filter',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.statusGrayIndigo),
          ),
          child: DropdownButton<int?>(
            value: _ratingFilter,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: AppColors.bg,
            underline: const SizedBox.shrink(),
            iconEnabledColor: AppColors.textPrimary,
            style: const TextStyle(
              color: AppColors.textPrimary,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER (JUDUL) =====
              const Text(
                'RATING AND FEEDBACK',
                style: TextStyle(
                  color: AppColors.textHeading,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 10),

              // ===== FILTER (TURUN KE BAWAH JUDUL) =====
              _buildFilterRow(),

              const SizedBox(height: 16),

              // ===== LIST + PAGINATION =====
              Expanded(
                child: FutureBuilder<CoachReviewsResponse>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Failed to load reviews',
                          style: TextStyle(color: Colors.redAccent),
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
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.statusGrayIndigo),
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
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Be the first to leave a rating & feedback.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
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
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                              )
                            else
                              const SizedBox(width: 64),

                            Text(
                              data.pagination.totalPages > 1
                                  ? 'Page ${data.pagination.page} / ${data.pagination.totalPages}'
                                  : '',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),

                            if (data.pagination.hasNext)
                              TextButton(
                                onPressed: () =>
                                    _changePage(data.pagination.page + 1),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(color: AppColors.textPrimary),
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
