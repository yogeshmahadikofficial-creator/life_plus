
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/doctor_post_card.dart';

class HealthFeedScreen extends StatefulWidget {
  const HealthFeedScreen({super.key});

  @override
  State<HealthFeedScreen> createState() => _HealthFeedScreenState();
}

class _HealthFeedScreenState extends State<HealthFeedScreen> {
  // The selected category controls which posts the user sees.
  // "All" displays every published category.
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Health Tips',
    'Hydration',
    'Diet & Nutrition',
  ];

  // Keep the Firestore query in one place so it is easy to update.
  //
  // IMPORTANT:
  // DoctorDashboardScreen writes posts to health_posts and sets
  // published = true only for verified doctors.
  Query<Map<String, dynamic>> _buildPostsQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('health_posts')
        .where('published', isEqualTo: true);

    // Apply a category filter only when the user selects one.
    if (_selectedCategory != 'All') {
      query = query.where(
        'category',
        isEqualTo: _selectedCategory,
      );
    }

    // Newest posts appear first.
    // Posts without createdAt may not appear in this ordered query.
    return query.orderBy('createdAt', descending: true);
  }

  // Convert Firestore's Timestamp into Dart's DateTime.
  // Null is possible while a server timestamp is being resolved.
  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }

  // Friendly loading/error/empty states help users understand
  // what is happening instead of seeing a blank screen.
  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LIFE+ Health Community'),
        actions: [
          // Rebuild the stream when the user wants to refresh.
          IconButton(
            tooltip: 'Refresh feed',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header introduction.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Healthy living starts here',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore health tips, hydration advice, and nutrition ideas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Horizontal category selector.
          SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (!selected) return;

                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // StreamBuilder automatically updates when published
          // posts are added or changed in Firestore.
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _buildPostsQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  // TODO (PARTNER B):
                  // If the error mentions a missing index, follow the
                  // Firebase console's index-creation link.
                  // Also verify that Firestore Security Rules allow
                  // patients to read published posts.
                  return _buildMessage(
                    icon: Icons.cloud_off_outlined,
                    title: 'Unable to load health posts',
                    message:
                        'Check your connection and Firestore configuration, '
                        'then try again.',
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return _buildMessage(
                    icon: Icons.article_outlined,
                    title: 'No posts yet',
                    message: _selectedCategory == 'All'
                        ? 'Published health advice will appear here.'
                        : 'No published posts are available in '
                            '$_selectedCategory yet.',
                  );
                }

                // Responsive grid:
                // Phones display one card per row; wider screens can
                // display multiple cards.
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final columns = width >= 1000
                        ? 3
                        : width >= 650
                            ? 2
                            : 1;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        24,
                      ),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,

                        // Cards are taller than they are wide on phones.
                        // Adjust this ratio if you change the card layout.
                        childAspectRatio: columns == 1 ? 0.95 : 0.8,
                      ),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        final post = document.data();

                        // Defensive defaults prevent missing optional
                        // fields from crashing the feed.
                        final title =
                            post['title'] as String? ?? 'Health tip';
                        final content =
                            post['content'] as String? ?? '';
                        final doctorName =
                            post['authorName'] as String? ?? 'Doctor';
                        final specialization =
                            post['specialization'] as String? ??
                                'Healthcare professional';
                        final category =
                            post['category'] as String? ?? 'Health Tips';

                        // IMPORTANT:
                        // This flag is for display only.
                        // Firestore rules/backend verification must ensure
                        // users cannot mark their own posts as verified.
                        final isVerifiedDoctor =
                            post['isVerifiedDoctor'] == true;

                        return DoctorPostCard(
                          title: title,
                          content: content,
                          doctorName: doctorName,
                          specialization: specialization,
                          category: category,
                          isVerifiedDoctor: isVerifiedDoctor,
                          createdAt: _readDate(post['createdAt']),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
