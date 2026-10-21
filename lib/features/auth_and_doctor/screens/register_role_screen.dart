import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class RegisterRoleScreen extends StatefulWidget {
  const RegisterRoleScreen({super.key});

  @override
  State<RegisterRoleScreen> createState() => _RegisterRoleScreenState();
}

class _RegisterRoleScreenState extends State<RegisterRoleScreen> {
  // Used to validate the entire registration form.
  final _formKey = GlobalKey<FormState>();

  // Controllers hold the values entered into text fields.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  // The default role is Patient.
  // Change this only if the team wants a different default.
  String _selectedRole = 'patient';

  String? _specialization;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // TODO (PARTNER B):
  // Confirm the allowed specialization list with your team.
  // These are display options, not proof of a doctor's qualifications.
  static const List<String> _specializations = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedic Surgeon',
    'Pediatrician',
    'Psychiatrist',
    'Gynecologist',
    'Ophthalmologist',
    'Dentist',
    'Other',
  ];

  // Makes conditional UI easier to read.
  bool get _isDoctor => _selectedRole == 'doctor';

  @override
  void dispose() {
    // Dispose every controller to prevent memory leaks.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }

  // ---------------- FORM VALIDATION ----------------

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please create a password';
    }

    // Firebase projects can configure additional password policies.
    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  String? _validateRegistrationNumber(String? value) {
    // This field is required only for doctor registration.
    if (!_isDoctor) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Medical council registration number is required';
    }

    if (value.trim().length < 3) {
      return 'Please enter a valid registration number';
    }

    // IMPORTANT:
    // This checks only that the field is filled.
    // It does NOT verify that the number belongs to a real doctor.
    return null;
  }

  // ---------------- REGISTRATION LOGIC ----------------

  Future<void> _register() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    User? createdUser;
    bool profileSaved = false;

    try {
      // STEP 1: Create the Firebase Authentication account.
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      createdUser = credential.user;

      if (createdUser == null) {
        throw FirebaseAuthException(
          code: 'registration-failed',
          message: 'Could not create your account.',
        );
      }

      // STEP 2: Save the user's display name.
      await createdUser.updateDisplayName(_nameController.text.trim());

      // STEP 3: Prepare the Firestore profile.
      final Map<String, dynamic> profile = {
        'uid': createdUser.uid,
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // STEP 4: Add role-specific profile information.
      if (_isDoctor) {
        profile.addAll({
          'medicalCouncilRegistrationNumber': _registrationNumberController.text
              .trim(),
          'specialization': _specialization,
          'verificationStatus': 'pending',
          'isVerified': false,
        });
      } else {
        profile.addAll({
          'verificationStatus': 'not_required',
          'isVerified': false,
        });
      }

      // STEP 5: Save the profile in Firestore.
      debugPrint('Saving profile for UID: ${createdUser.uid}');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(createdUser.uid)
          .set(profile);

      profileSaved = true;
      debugPrint('Firestore profile saved successfully.');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isDoctor
                ? 'Account created. Doctor verification is pending.'
                : 'Your LIFE+ account has been created.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // STEP 6: Navigate according to the selected role.
      final destination = _isDoctor ? '/doctor-dashboard' : '/health-feed';

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(destination, (route) => false);
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase Auth error: ${error.code}');
      debugPrint('Message: ${error.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_registrationErrorMessage(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseException catch (error) {
      // Shows the exact Firestore or other Firebase service error.
      debugPrint('Firebase service error: ${error.code}');
      debugPrint('Message: ${error.message}');

      if (!mounted) return;

      final message = createdUser != null && !profileSaved
          ? 'Account created, but profile saving failed: '
                '${error.code} - ${error.message ?? "Unknown error"}'
          : 'Firebase error: ${error.code} - '
                '${error.message ?? "Unknown error"}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Registration error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createdUser != null && !profileSaved
                ? 'Account created, but profile saving failed. Error: $error'
                : 'Registration failed: $error',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Translate Firebase errors into user-friendly messages.
  String _registrationErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Choose a stronger password.';

      case 'operation-not-allowed':
        return 'Email/password registration is not enabled in Firebase.';

      case 'network-request-failed':
        return 'Network error. Check your internet connection.';

      default:
        return error.message ?? 'Registration failed. Please try again.';
    }
  }

  // ---------------- ROLE SELECTOR ----------------

  Widget _buildRoleSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I want to register as',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Patient and Doctor options.
        // SegmentedButton is part of Material 3.
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'patient',
              label: Text('Patient'),
              icon: Icon(Icons.person_outline),
            ),
            ButtonSegment<String>(
              value: 'doctor',
              label: Text('Doctor'),
              icon: Icon(Icons.medical_services_outlined),
            ),
          ],
          selected: {_selectedRole},
          expandedInsets: EdgeInsets.zero,

          // Prevent changing the role while registration is in progress.
          onSelectionChanged: _isLoading
              ? null
              : (selection) {
                  setState(() {
                    _selectedRole = selection.first;

                    // Clear doctor-only fields when switching roles.
                    // This prevents stale doctor information being saved
                    // when the user ultimately registers as a patient.
                    _specialization = null;
                    _registrationNumberController.clear();
                  });
                },
        ),
      ],
    );
  }

  // ---------------- DOCTOR-ONLY FIELDS ----------------

  Widget _buildDoctorFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Explain that registration is not the same as verification.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Doctor accounts require medical council verification '
                  'before they can be presented as verified.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Medical council registration number.
        CustomTextField(
          controller: _registrationNumberController,
          label: 'Medical Council Registration Number',
          hint: 'Enter your registration number',
          prefixIcon: Icons.badge_outlined,
          textInputAction: TextInputAction.next,
          validator: _validateRegistrationNumber,
          enabled: !_isLoading,
        ),

        const SizedBox(height: 18),

        // Specialization dropdown.
        DropdownButtonFormField<String>(
          value: _specialization,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Specialization',
            prefixIcon: const Icon(Icons.medical_information_outlined),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
              0.35,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          hint: const Text('Select specialization'),

          // Generate dropdown choices from the list above.
          items: _specializations.map((specialization) {
            return DropdownMenuItem<String>(
              value: specialization,
              child: Text(specialization, overflow: TextOverflow.ellipsis),
            );
          }).toList(),

          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() {
                    _specialization = value;
                  });
                },

          validator: (value) {
            if (!_isDoctor) return null;

            if (value == null || value.isEmpty) {
              return 'Please select your specialization';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ---------------- REGISTRATION UI ----------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.health_and_safety_rounded,
                        size: 60,
                        color: colors.primary,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Join LIFE+',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Create your account for smarter healthcare.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ROLE SELECTOR
                      _buildRoleSelector(theme),

                      const SizedBox(height: 24),

                      // FULL NAME
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: _validateName,
                        enabled: !_isLoading,
                      ),

                      const SizedBox(height: 18),

                      // EMAIL
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email address',
                        hint: 'you@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: _validateEmail,
                        enabled: !_isLoading,
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _validatePassword,
                        enabled: !_isLoading,
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // CONFIRM PASSWORD
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm password',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: _isDoctor
                            ? TextInputAction.next
                            : TextInputAction.done,
                        validator: _validateConfirmPassword,
                        enabled: !_isLoading,
                        onFieldSubmitted: (_) {
                          if (!_isDoctor) _register();
                        },
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),

                      // DOCTOR FIELDS APPEAR ONLY WHEN DOCTOR IS SELECTED.
                      if (_isDoctor) ...[
                        const SizedBox(height: 24),

                        Text(
                          'Professional details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildDoctorFields(theme),
                      ],

                      const SizedBox(height: 28),

                      // REGISTER BUTTON
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 23,
                                  width: 23,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isDoctor
                                      ? 'Create Doctor Account'
                                      : 'Create Patient Account',
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Already have an account?',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                        '/login',
                                        (route) => false,
                                      ),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
