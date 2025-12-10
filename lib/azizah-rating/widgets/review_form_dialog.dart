import 'package:flutter/material.dart';

import '../services/review_api.dart';
import 'review_theme.dart';

class ReviewFormDialog {
  static final _api = ReviewApi();

  static Future<bool?> showCreate(
    BuildContext context, {
    required String coachId,
    String? cookie,
    String? csrfToken,
  }) async {
    return _show(
      context,
      title: 'RATE YOUR COACH',
      subtitle: 'Your honest feedback is valuable to us.',
      onSubmit: (rating, comment) async {
        await _api.createReview(
          coachId: coachId,
          rating: rating,
          comment: comment,
          cookie: cookie,
          csrfToken: csrfToken,
        );
      },
    );
  }

  static Future<bool?> showEdit(
    BuildContext context, {
    required int reviewId,
    required int initialRating,
    required String initialComment,
    String? cookie,
    String? csrfToken,
  }) async {
    return _show(
      context,
      title: 'RATE YOUR COACH',
      subtitle: 'You can update your rating & feedback.',
      initialRating: initialRating,
      initialComment: initialComment,
      onSubmit: (rating, comment) async {
        await _api.updateReview(
          reviewId: reviewId,
          rating: rating,
          comment: comment,
          cookie: cookie,
          csrfToken: csrfToken,
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
              constraints: const BoxConstraints(
                maxWidth: 680, // sama kayak max-w-[680px]
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: ReviewColors.indigo,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E2B55)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                              color: ReviewColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
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
                        color: Colors.white70,
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
                                    fontSize: 30, // text-3xl vibes
                                    color: filled
                                        ? ReviewColors.yellow
                                        : const Color(0xFF3C395F),
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
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: textController,
                      maxLines: 6, // rows="6" di Django
                      maxLength: 1000,
                      style: const TextStyle(
                        color: ReviewColors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ReviewColors.indigoLight,
                        counterText: '',
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF2E2B55)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: ReviewColors.yellow),
                        ),
                        hintText: 'Share your experience…',
                        hintStyle: const TextStyle(
                          color: Colors.white54,
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
                            backgroundColor: const Color(0xFFBE3A3A),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ), // px-4 py-2 vibes
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: ReviewColors.yellow,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ), // px-5 py-2 vibes
                          ),
                          onPressed: () async {
                            final rating = ratingNotifier.value;
                            if (rating < 1 || rating > 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select a rating (1–5).',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            try {
                              await onSubmit(
                                rating,
                                textController.text.trim(),
                              );
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to submit review: $e',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: Color(0xFF1A1834),
                              fontSize: 13,
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
