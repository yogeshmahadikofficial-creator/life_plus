import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:life_plus/features/auth_and_doctor/screens/login_screen.dart';
import 'package:life_plus/features/auth_and_doctor/screens/register_role_screen.dart';
import 'package:life_plus/features/auth_and_doctor/screens/doctor_dashboard_screen.dart';
import 'package:life_plus/features/auth_and_doctor/screens/health_feed_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/register',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterRoleScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/health-feed': (context) => const HealthFeedScreen(),
      },
    ),
  );
}
