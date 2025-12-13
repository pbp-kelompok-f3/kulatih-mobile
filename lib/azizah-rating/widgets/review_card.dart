import 'package:flutter/material.dart';

import '../models/review_models.dart';
import 'review_theme.dart';

class ReviewCard extends StatelessWidget {
  final ReviewItem review;
  final VoidCallback? onTapDetail;

  const ReviewCard({
    super.key,
    required this.review,
    this.onTapDetail,
  });

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Text(
          '★',
          style: TextStyle(
            fontSize: 14,
            color: filled ? ReviewColors.yellow : const Color(0xFF3C395F),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ReviewColors.indigoLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E2B55)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2F2C56),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              review.initial,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ReviewColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // username + link detail
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerUsername,
                        style: const TextStyle(
                          color: ReviewColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onTapDetail != null)
                      GestureDetector(
                        onTap: onTapDetail,
                        child: const Text(
                          'view detail',
                          style: TextStyle(
                            color: Color(0xFFC9C9D9),
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                // rating + stars
                Row(
                  children: [
                    Text(
                      review.rating.toString(),
                      style: const TextStyle(
                        color: ReviewColors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildStars(review.rating),
                  ],
                ),
                const SizedBox(height: 8),
                // Comment (3 lines clamp style)
                Text(
                  review.comment,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ReviewColors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
