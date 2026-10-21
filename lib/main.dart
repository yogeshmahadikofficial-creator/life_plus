import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// Partner B imports
import 'package:life_plus/core/app_constants.dart';
import 'package:life_plus/core/app_theme.dart';
//Partner A imports
import 'package:life_plus/features/vitals_and_emergency/screens/patient_dashboard_screen.dart';
// Partner B imports
import 'features/auth_and_doctor/screens/doctor_dashboard_screen.dart';
import 'features/auth_and_doctor/screens/health_feed_screen.dart';
import 'features/auth_and_doctor/screens/login_screen.dart';
import 'features/auth_and_doctor/screens/register_role_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LifePlusApp());
}

class LifePlusApp extends StatelessWidget {
  const LifePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      // Use initialRoute instead of home to handle multi-screen navigation smoothly
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterRoleScreen(),
        '/patient-dashboard': (_) => const PatientDashboardScreen(),
        '/health-feed': (_) => const HealthFeedScreen(),
        '/doctor-dashboard': (_) => const DoctorDashboardScreen(),
      },
    );
  }
}
