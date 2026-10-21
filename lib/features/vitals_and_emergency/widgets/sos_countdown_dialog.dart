import 'dart:async';
import 'package:flutter/material.dart';
import 'package:life_plus/core/app_constants.dart';
import 'package:life_plus/core/app_theme.dart';

// COLLABORATION NOTE (PARTNER A):
// When background fall-detection or abnormal vital thresholds fire,
// launch this dialog using:
// showDialog(context: context, barrierDismissible: false, builder: (_) => const SosCountdownDialog());

// COLLABORATION NOTE (PARTNER B):
// Inside `_dispatchEmergencyPayload()`, call Firebase Cloud Function or Twilio SMS service
// to notify emergency contacts and the assigned doctor with live GPS coordinates.

class SosCountdownDialog extends StatefulWidget {
  final VoidCallback? onCancelled;
  final VoidCallback? onDispatched;

  const SosCountdownDialog({
    super.key,
    this.onCancelled,
    this.onDispatched,
  });

  @override
  State<SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<SosCountdownDialog>
    with SingleTickerProviderStateMixin {
  late int _secondsLeft;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _secondsLeft = AppConstants.emergencyCountdownSeconds;

    // Glowing pulse animation for the timer ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _dispatchEmergencyPayload();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _dispatchEmergencyPayload() {
    if (widget.onDispatched != null) {
      widget.onDispatched!();
    }

    Navigator.of(context, rootNavigator: true).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.alertRed,
        duration: Duration(seconds: 5),
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'EMERGENCY ALERT SENT: Ambulance, Doctor & Family contacts notified with GPS!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelAlert() {
    _timer?.cancel();
    if (widget.onCancelled != null) {
      widget.onCancelled!();
    }
    Navigator.of(context, rootNavigator: true).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alert cancelled safely.'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progressFraction =
        _secondsLeft / AppConstants.emergencyCountdownSeconds;

    return PopScope(
      canPop: false, // Prevents closing by tapping outside or back button
      child: AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.alertRed.withValues(alpha: 0.5), width: 1.5),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: const Column(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.alertRed, size: 48),
            SizedBox(height: 8),
            Text(
              'CRITICAL SOS ALERT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.alertRed,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Emergency services and assigned contacts will be alerted with your location in:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 28),

            // Pulsing Countdown Timer with Radial Progress
            ScaleTransition(
              scale: _pulseScale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: progressFraction,
                      strokeWidth: 8,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.alertRed),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_secondsLeft',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'SECONDS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.alertRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
              onPressed: _cancelAlert,
              icon: const Icon(Icons.close),
              label: const Text(
                'I AM SAFE • CANCEL ALARM',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}