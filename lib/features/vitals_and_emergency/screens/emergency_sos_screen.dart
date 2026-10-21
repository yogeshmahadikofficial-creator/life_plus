import 'dart:async';
import 'package:flutter/material.dart';
import 'package:life_plus/core/app_theme.dart';
import 'package:life_plus/core/app_constants.dart';
import '../widgets/sos_countdown_dialog.dart';

// COLLABORATION NOTE (PARTNER A):
// Later when `geolocator` and `sensors_plus` are integrated,
// the automated fall/unconscious trigger calls _triggerSosFlow(context) directly.

// COLLABORATION NOTE (PARTNER B):
// When Firebase Cloud Firestore & Auth are ready:
// 1. Fetch user emergency contacts from `users/{uid}/emergency_contacts`.
// 2. Trigger Cloud Function or Twilio SMS writing to `emergency_alerts/{alertId}`.

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    // Glowing pulse animation for the SOS button
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rippleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _triggerSosFlow(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SosCountdownDialog(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: AppTheme.cardDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status Indicator Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.alertRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.alertRed.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gps_fixed, color: AppTheme.alertRed, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'GPS Tracking Active • Auto-Alert Ready',
                    style: TextStyle(
                      color: AppTheme.alertRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Pulsing SOS Button
            GestureDetector(
              onTap: () => _triggerSosFlow(context),
              child: ScaleTransition(
                scale: _rippleAnimation,
                child: Container(
                  height: 190,
                  width: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFF5252),
                        AppTheme.alertRed,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.alertRed.withValues(alpha: 0.45),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 40, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          'SOS',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'PRESS FOR HELP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Tap to trigger a 15-second emergency alert',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 36),

            // Emergency Contacts Notification Card
            _buildDispatchCard(),
            const SizedBox(height: 24),

            // Quick Direct Dial Buttons
            _buildDirectCallSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who will be notified:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            Icons.local_hospital,
            'Local Ambulance Service',
            'Auto-dispatched with live GPS',
          ),
          const Divider(color: Colors.white10, height: 16),
          _buildContactRow(
            Icons.medical_services,
            'Family Doctor (Dr. Sharma)',
            'Real-time vitals history sent',
          ),
          const Divider(color: Colors.white10, height: 16),
          _buildContactRow(
            Icons.family_restroom,
            'Emergency Contact (Family)',
            'SMS with Google Maps location link',
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          child: Icon(icon, size: 18, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        const Icon(Icons.check_circle, size: 18, color: AppTheme.successGreen),
      ],
    );
  }

  Widget _buildDirectCallSection() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.alertRed),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dialing 108 Ambulance Service...')),
              );
            },
            icon: const Icon(Icons.call, color: AppTheme.alertRed),
            label: const Text(
              'Call 108',
              style: TextStyle(color: AppTheme.alertRed, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling Linked Family Doctor...')),
              );
            },
            icon: const Icon(Icons.phone_in_talk, color: AppTheme.primaryBlue),
            label: const Text(
              'Call Doctor',
              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

