import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _isSubmittingPost = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>>? get _profileReference {
    final user = _currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  Future<void> _showCreatePostDialog({
    required String doctorName,
    required String specialization,
    required bool isVerified,
  }) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String category = 'Health Tips';

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          bool dialogIsSaving = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Create health post'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: category,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Post category',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Health Tips',
                              child: Text('Health Tips'),
                            ),
                            DropdownMenuItem(
                              value: 'Hydration',
                              child: Text('Hydration'),
                            ),
                            DropdownMenuItem(
                              value: 'Diet & Nutrition',
                              child: Text('Diet & Nutrition'),
                            ),
                          ],
                          onChanged: dialogIsSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      category = value;
                                    });
                                  }
                                },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: titleController,
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Post title',
                            hintText: 'e.g. Benefits of drinking water',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a title';
                            }
                            if (value.trim().length < 5) {
                              return 'Title must be at least 5 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: contentController,
                          maxLines: 5,
                          minLines: 3,
                          maxLength: 2000,
                          decoration: const InputDecoration(
                            labelText: 'Post content',
                            hintText: 'Write useful health information...',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter the post content';
                            }
                            if (value.trim().length < 20) {
                              return 'Please provide more detail';
                            }
                            return null;
                          },
                        ),
                        if (!isVerified) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Your post will remain unpublished until '
                            'your doctor verification is complete.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: dialogIsSaving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: dialogIsSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              dialogIsSaving = true;
                            });

                            try {
                              await _savePost(
                                title: titleController.text.trim(),
                                content: contentController.text.trim(),
                                category: category,
                                doctorName: doctorName,
                                specialization: specialization,
                                isVerified: isVerified,
                              );

                              if (!mounted) return;

                              Navigator.of(dialogContext).pop();

                              ScaffoldMessenger.of(this.context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isVerified
                                          ? 'Health post submitted.'
                                          : 'Post saved as unpublished.',
                                    ),
                                  ),
                                );
                            } on FirebaseException catch (e, stackTrace) {
                              debugPrint(
                                'Firestore error code: ${e.code}',
                              );
                              debugPrint(
                                'Firestore error message: ${e.message}',
                              );
                              debugPrint('Stack trace: $stackTrace');

                              if (dialogContext.mounted) {
                                setDialogState(() {
                                  dialogIsSaving = false;
                                });
                              }

                              if (!mounted) return;

                              ScaffoldMessenger.of(this.context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to save post: '
                                      '${e.message ?? e.code}',
                                    ),
                                    duration: const Duration(seconds: 6),
                                  ),
                                );
                            } catch (e, stackTrace) {
                              debugPrint('Unexpected post error: $e');
                              debugPrint('Stack trace: $stackTrace');

                              if (dialogContext.mounted) {
                                setDialogState(() {
                                  dialogIsSaving = false;
                                });
                              }

                              if (!mounted) return;

                              ScaffoldMessenger.of(this.context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Something went wrong: $e',
                                    ),
                                    duration: const Duration(seconds: 6),
                                  ),
                                );
                            }
                          },
                    child: dialogIsSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Submit post'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      titleController.dispose();
      contentController.dispose();
    }
  }

  Future<void> _savePost({
    required String title,
    required String content,
    required String category,
    required String doctorName,
    required String specialization,
    required bool isVerified,
  }) async {
    final user = _currentUser;

    if (user == null) {
      throw StateError('No authenticated user. Please sign in again.');
    }

    if (title.trim().isEmpty || content.trim().isEmpty) {
      throw ArgumentError('Post title and content cannot be empty.');
    }

    if (mounted) {
      setState(() => _isSubmittingPost = true);
    }

    try {
      await FirebaseFirestore.instance.collection('health_posts').add({
        'title': title.trim(),
        'content': content.trim(),
        'category': category,
        'authorId': user.uid,
        'authorName': doctorName,
        'specialization': specialization,
        'isVerifiedDoctor': isVerified,
        'published': isVerified,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmittingPost = false);
      }
    }
  }

  Widget _buildVerificationBanner({
    required bool isVerified,
    required String status,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isVerified
            ? colors.primaryContainer
            : colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isVerified
                ? Icons.verified_user_rounded
                : Icons.hourglass_top_rounded,
            size: 30,
            color: isVerified
                ? colors.onPrimaryContainer
                : colors.onTertiaryContainer,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified
                      ? 'Verified Doctor'
                      : 'Pending Council Approval',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isVerified
                        ? colors.onPrimaryContainer
                        : colors.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isVerified
                      ? 'Your profile is marked as verified.'
                      : 'Your submitted credentials are awaiting review.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: $status',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileReference = _profileReference;

    if (_currentUser == null || profileReference == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Dashboard')),
        body: const Center(
          child: Text('Please sign in to access your dashboard.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: profileReference.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load your doctor profile. Please try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = snapshot.data!.data()!;
          final doctorName = profile['fullName'] as String? ?? 'Doctor';
          final specialization =
              profile['specialization'] as String? ??
                  'Specialization not set';
          final status =
              profile['verificationStatus'] as String? ?? 'pending';
          final isVerified = profile['isVerified'] == true;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Welcome, $doctorName',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                specialization,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildVerificationBanner(
                isVerified: isVerified,
                status: status,
              ),
              const SizedBox(height: 24),
              Text(
                'Professional verification',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.upload_file_rounded),
                  title: const Text('Upload medical documents'),
                  subtitle: const Text(
                    'Medical council license and certificates',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Document upload will be connected next.',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Doctor community',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSubmittingPost
                      ? null
                      : () => _showCreatePostDialog(
                            doctorName: doctorName,
                            specialization: specialization,
                            isVerified: isVerified,
                          ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create health post'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isVerified
                    ? 'Share helpful health and nutrition education.'
                    : 'Your posts will stay unpublished until verification.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
