import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../services/review_api.dart';
import '../models/review_models.dart';
import '../widgets/review_form_dialog.dart';
import '/theme/app_colors.dart';

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
  ReviewApi? _api;
  late Future<ReviewDetail> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _api ??= ReviewApi(context.read<CookieRequest>());
    _future = _api!.getReviewDetail(widget.reviewId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api!.getReviewDetail(widget.reviewId);
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
            color: filled ? AppColors.primary : AppColors.statusGrayIndigo,
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review updated'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.cardBg,
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
          backgroundColor: AppColors.cardBg,
          title: const Text(
            'Delete?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _api!.deleteReview(reviewId: int.parse(detail.id));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review deleted'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.cardBg,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete review: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.cardBg,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'RATING AND FEEDBACK',
            style: TextStyle(
              color: AppColors.textHeading,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 0.5,
            ),
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
                  color: AppColors.primary,
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Failed to load review detail',
                  style: TextStyle(color: Colors.redAccent),
                ),
              );
            }

            final detail = snapshot.data;
            if (detail == null) {
              return const Center(
                child: Text(
                  'Review not found',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.statusGrayIndigo),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.statusGrayIndigo,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            (detail.reviewer.username.isNotEmpty
                                    ? detail.reviewer.username[0]
                                    : '?')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                            color: AppColors.textPrimary,
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
                                                color: AppColors.textPrimary,
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

                                  // Owner actions
                                  if (detail.isOwner)
                                    Row(
                                      children: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () => _onEdit(detail),
                                          child: const Text(
                                            'EDIT',
                                            style: TextStyle(
                                              color: AppColors.buttonText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: AppColors.statusRed,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () => _onDelete(detail),
                                          child: const Text(
                                            'DELETE',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
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
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
