import 'package:flutter/material.dart';
import 'package:life_plus/core/app_constants.dart';
import 'package:life_plus/core/app_theme.dart';


void main() {
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety, size: 72, color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              const Text(
                AppConstants.appName,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                AppConstants.appTagline,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Text(
                  'Partner A & B Modules will connect here.',
                  style: TextStyle(color: AppTheme.successGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}