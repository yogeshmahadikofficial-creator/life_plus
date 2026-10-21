import 'dart:async';
import 'package:flutter/material.dart';
import 'package:life_plus/core/app_theme.dart';

// COLLABORATION NOTE (PARTNER A):
// When you connect the real camera package (camera: ^0.11.0),
// the image stream and torch toggle will plug into _startMeasurement().

// COLLABORATION NOTE (PARTNER B):
// When Cloud Firestore is ready, use the onSaved callback to write:
// FirebaseFirestore.instance.collection('users').doc(uid).collection('vitals').add(...)

class CameraPulseScreen extends StatefulWidget {
  const CameraPulseScreen({super.key});

  @override
  State<CameraPulseScreen> createState() => _CameraPulseScreenState();
}

class _CameraPulseScreenState extends State<CameraPulseScreen>
    with SingleTickerProviderStateMixin {
  bool _isMeasuring = false;
  double _progress = 0.0;
  int _calculatedBpm = 0;
  Timer? _measurementTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Heartbeat pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startMeasurement() {
    setState(() {
      _isMeasuring = true;
      _progress = 0.0;
      _calculatedBpm = 0;
    });

    _pulseController.repeat(reverse: true);

    // 15-second measurement cycle (simulates rPPG camera sampling)
    const totalTicks = 15;
    int currentTick = 0;

    _measurementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTick++;
      setState(() {
        _progress = currentTick / totalTicks;
      });

      if (currentTick >= totalTicks) {
        timer.cancel();
        _pulseController.stop();
        _pulseController.reset();

        setState(() {
          _isMeasuring = false;
          // Simulated resting heart rate for testing
          _calculatedBpm = 74;
        });

        _showResultSheet();
      }
    });
  }

  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 56),
              const SizedBox(height: 12),
              const Text(
                'Measurement Complete',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '$_calculatedBpm BPM',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.alertRed),
              ),
              const Text('Resting Heart Rate: Normal', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // COLLABORATION NOTE (PARTNER A & B):
                    // Save to Firestore vitals subcollection here
                    Navigator.pop(ctx);
                    Navigator.pop(context); // Return to Dashboard
                  },
                  child: const Text('Save to Health Records', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _measurementTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Pulse Scanner'),
        backgroundColor: AppTheme.cardDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instructions
            Text(
              _isMeasuring
                  ? 'Keep your finger steady over the lens...'
                  : 'Cover the rear camera lens & flashlight firmly',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            // Pulsing Camera / Fingerprint Target
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cardDark,
                  border: Border.all(
                    color: _isMeasuring ? AppTheme.alertRed : Colors.white24,
                    width: 3,
                  ),
                  boxShadow: _isMeasuring
                      ? [
                          BoxShadow(
                            color: AppTheme.alertRed.withValues(alpha: 0.35),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Icon(
                    _isMeasuring ? Icons.favorite : Icons.fingerprint,
                    size: 80,
                    color: _isMeasuring ? AppTheme.alertRed : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Progress Indicator during measurement
            if (_isMeasuring) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.alertRed),
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
              Text(
                'Measuring... ${(15 * (1 - _progress)).toInt()}s left',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
            ],

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isMeasuring ? Colors.grey[800] : AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isMeasuring ? null : _startMeasurement,
                icon: Icon(_isMeasuring ? Icons.hourglass_top : Icons.play_arrow),
                label: Text(
                  _isMeasuring ? 'Scanning...' : 'Start Measurement',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}