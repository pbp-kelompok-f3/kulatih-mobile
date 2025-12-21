import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../services/review_api.dart';
import '/theme/app_colors.dart';

class ReviewFormDialog {
  static Future<bool?> showCreate(
    BuildContext context, {
    required String coachId,
  }) async {
    final api = ReviewApi(context.read<CookieRequest>());

    return _show(
      context,
      title: 'RATE YOUR COACH',
      subtitle: 'Your honest feedback is valuable to us.',
      onSubmit: (rating, comment) async {
        await api.createReview(
          coachId: coachId,
          rating: rating,
          comment: comment,
        );
      },
    );
  }

  static Future<bool?> showEdit(
    BuildContext context, {
    required int reviewId,
    required int initialRating,
    required String initialComment,
  }) async {
    final api = ReviewApi(context.read<CookieRequest>());

    return _show(
      context,
      title: 'RATE YOUR COACH',
      subtitle: 'You can update your rating & feedback.',
      initialRating: initialRating,
      initialComment: initialComment,
      onSubmit: (rating, comment) async {
        await api.updateReview(
          reviewId: reviewId,
          rating: rating,
          comment: comment,
        );
      },
    );
  }

  static Future<bool?> _show(
    BuildContext context, {
    required String title,
    required String subtitle,
    int initialRating = 0,
    String initialComment = '',
    required Future<void> Function(int rating, String comment) onSubmit,
  }) async {
    final ratingNotifier = ValueNotifier<int>(initialRating);
    final textController = TextEditingController(text: initialComment);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.statusGrayIndigo),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER =====
                    Center(
                      child: Column(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const SizedBox(height: 0),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== YOUR RATING =====
                    const Text(
                      'YOUR RATING',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ValueListenableBuilder<int>(
                      valueListenable: ratingNotifier,
                      builder: (context, rating, _) {
                        return Row(
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            final filled = starIndex <= rating;
                            return GestureDetector(
                              onTap: () => ratingNotifier.value = starIndex,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '★',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: filled
                                        ? AppColors.primary
                                        : AppColors.statusGrayIndigo,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // ===== FEEDBACK =====
                    const Text(
                      'FEEDBACK (optional)',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: textController,
                      maxLines: 6,
                      maxLength: 1000,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bg,
                        counterText: '',
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.statusGrayIndigo),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        hintText: 'Share your experience…',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ===== BUTTONS =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.statusRed,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () async {
                            final rating = ratingNotifier.value;
                            if (rating < 1 || rating > 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a rating (1–5).'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.cardBg,
                                ),
                              );
                              return;
                            }
                            try {
                              await onSubmit(
                                rating,
                                textController.text.trim(),
                              );
                              if (!context.mounted) return;
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to submit review: $e'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.cardBg,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: AppColors.buttonText,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
