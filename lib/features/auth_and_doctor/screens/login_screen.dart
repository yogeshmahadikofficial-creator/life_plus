import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:life_plus/features/auth_and_doctor/screens/doctor_dashboard_screen.dart';
import 'package:life_plus/features/auth_and_doctor/screens/health_feed_screen.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Used to validate all form fields together.
  final _formKey = GlobalKey<FormState>();

  // Controllers allow us to read the entered values.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Always dispose controllers when the screen is removed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------- FORM VALIDATION ----------------

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    // Basic client-side email validation.
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }

  // ---------------- LOGIN LOGIC ----------------

  Future<void> _login() async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    // STEP 1: Sign in using Firebase Authentication.
    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    // STEP 2: Fetch the user's role from Firestore.
    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!profile.exists) {
      await FirebaseAuth.instance.signOut();

      throw FirebaseAuthException(
        code: 'profile-not-found',
        message: 'Your account profile was not found.',
      );
    }

    final role = profile.data()?['role'];

    if (role != 'doctor' && role != 'patient') {
      await FirebaseAuth.instance.signOut();

      throw FirebaseAuthException(
        code: 'invalid-user-role',
        message: 'Your account role is invalid.',
      );
    }

    if (!mounted) return;

    // STEP 3: Navigate to the correct screen for the user's role.
    final destination =
        role == 'doctor' ? '/doctor-dashboard' : '/health-feed';

    Navigator.of(context).pushNamedAndRemoveUntil(
      destination,
      (route) => false,
    );
  } on FirebaseAuthException catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_authErrorMessage(error)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  // Converts Firebase error codes into understandable messages.
  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'The email address is invalid.';

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // Keep the message general instead of revealing which
        // part of the login credentials was incorrect.
        return 'Invalid email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Check your internet connection.';

      case 'profile-not-found':
        return 'Account profile missing. Please contact support.';

      case 'invalid-user-role':
        return error.message ?? 'Invalid account role.';

      default:
        return 'Unable to sign in. Please try again.';
    }
  }

  // ---------------- LOGIN UI ----------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            // Prevent the form from becoming excessively wide
            // when running on a tablet or desktop.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      Icon(
                        Icons.health_and_safety_rounded,
                        size: 76,
                        color: colors.primary,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'LIFE+',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Your health, connected.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 36),

                      Text(
                        'Welcome back',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Sign in to continue to your account.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // EMAIL FIELD
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email address',
                        hint: 'you@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD FIELD
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: _validatePassword,

                        // Pressing Done on the keyboard submits the form.
                        onFieldSubmitted: (_) => _login(),

                        // Toggle password visibility.
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

                      const SizedBox(height: 28),

                      // Disable the button while Firebase is processing
                      // to prevent repeated submissions.
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 23,
                                  width: 23,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "Don't have an account?",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed('/register');
                                  },
                            child: const Text('Create account'),
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
