
import 'package:flutter/material.dart';

/// Reusable card for displaying one health-community post.
///
/// The card receives post data from its parent screen.
/// It does not connect directly to Firebase, which keeps the
/// UI reusable and easier to test.
class DoctorPostCard extends StatelessWidget {
  const DoctorPostCard({
    super.key,
    required this.title,
    required this.content,
    required this.doctorName,
    required this.specialization,
    required this.isVerifiedDoctor,
    required this.category,
    this.createdAt,
  });

  final String title;
  final String content;
  final String doctorName;
  final String specialization;
  final bool isVerifiedDoctor;
  final String category;
  final DateTime? createdAt;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';

    // Display a simple local date without adding another dependency.
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and publication date.
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Main post title.
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Post body. The card can grow to fit longer content.
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),
            Divider(color: colors.outlineVariant),
            const SizedBox(height: 12),

            // Author information and verification status.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: const Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        specialization,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Show the verified badge only when the post's
                      // verification flag says the author is verified.
                      if (isVerifiedDoctor)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: colors.onPrimaryContainer,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'Verified Doctor Advice',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Health content is educational and not a replacement
            // for an individual medical consultation.
            Text(
              'General health information. Consult a qualified '
              'professional for personal medical advice.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
