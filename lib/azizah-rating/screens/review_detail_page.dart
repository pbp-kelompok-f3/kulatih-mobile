import 'package:flutter/material.dart';

import '../services/review_api.dart';
import '../models/review_models.dart';
import '../widgets/review_theme.dart';
import '../widgets/review_form_dialog.dart';

class ReviewDetailPage extends StatefulWidget {
  final int reviewId;

  const ReviewDetailPage({
    super.key,
    required this.reviewId,
  });

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  final _api = ReviewApi();

  late Future<ReviewDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getReviewDetail(widget.reviewId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api.getReviewDetail(widget.reviewId);
    });
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Text(
          '★',
          style: TextStyle(
            fontSize: 16,
            color: filled ? ReviewColors.yellow : const Color(0xFF3C395F),
          ),
        );
      }),
    );
  }

  Future<void> _onEdit(ReviewDetail detail) async {
    final updated = await ReviewFormDialog.showEdit(
      context,
      reviewId: int.parse(detail.id),
      initialRating: detail.rating,
      initialComment: detail.comment,
    );
    if (updated == true) {
      await _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).maybePop(true);
    }
  }

  Future<void> _onDelete(ReviewDetail detail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ReviewColors.indigo,
          title: const Text(
            'Delete?',
            style: TextStyle(color: ReviewColors.white),
          ),
          content: const Text(
            'This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: ReviewColors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: ReviewColors.yellow),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _api.deleteReview(reviewId: int.parse(detail.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete review: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReviewColors.indigoDark,
      appBar: AppBar(
        backgroundColor: ReviewColors.indigoDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: ReviewColors.white),
        title: const Text(
          'RATING AND FEEDBACK',
          style: TextStyle(
            color: ReviewColors.yellow,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<ReviewDetail>(
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
              return Center(
                child: Text(
                  'Failed to load review detail',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }
            final detail = snapshot.data;
            if (detail == null) {
              return const Center(
                child: Text(
                  'Review not found',
                  style: TextStyle(color: ReviewColors.white),
                ),
              );
            }

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: ReviewColors.indigoLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E2B55)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2C56),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (detail.reviewer.username.isNotEmpty
                                ? detail.reviewer.username[0]
                                : '?')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: ReviewColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // header row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '@${detail.reviewer.username}',
                                      style: const TextStyle(
                                        color: ReviewColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          detail.rating.toString(),
                                          style: const TextStyle(
                                            color: ReviewColors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        _buildStars(detail.rating),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (detail.isOwner)
                                Row(
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: ReviewColors.yellow,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => _onEdit(detail),
                                      child: const Text(
                                        'EDIT',
                                        style: TextStyle(
                                          color: Color(0xFF28253E),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: ReviewColors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => _onDelete(detail),
                                      child: const Text(
                                        'DELETE',
                                        style: TextStyle(
                                          color: ReviewColors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            detail.comment,
                            style: const TextStyle(
                              color: ReviewColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
