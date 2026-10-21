import 'package:flutter/material.dart';
import 'package:life_plus/core/app_theme.dart';
import 'package:life_plus/core/app_constants.dart';
import 'camera_pulse_screen.dart';
import 'emergency_sos_screen.dart';
import '../widgets/vitals_card.dart';

// COLLABORATION NOTE (PARTNER A):
// Later when Camera & SOS screens are ready, import them here:
// import 'camera_pulse_screen.dart';
// import 'emergency_sos_screen.dart';

// COLLABORATION NOTE (PARTNER B):
// Import your Doctor Directory / Health Feed screens here when merging:
// import '../../auth_and_doctor/screens/health_feed_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  // Mock tracking values for water and steps
  int _waterGlasses = 4;
  final int _targetGlasses = 8;
  final int _currentSteps = 4250;
  final int _targetSteps = 6000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryBlue,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hello, Alex',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Normal Status',
              style: TextStyle(fontSize: 12, color: AppTheme.successGreen),
            ),
          ],
        ),
        actions: [
          // Emergency SOS Quick Action Icon
          IconButton(
            tooltip: 'Emergency SOS',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.alertRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencySosScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SOS Emergency Banner
            _buildEmergencyBanner(context),
            const SizedBox(height: 24),

            // 2. Live Vitals Grid Section
            const Text(
              'Live Vitals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildVitalsGrid(context),
            const SizedBox(height: 24),

            // 3. Daily Activity & Hydration Trackers
            const Text(
              'Daily Health Trackers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildHabitTrackers(),
            const SizedBox(height: 24),

            // 4. Partner B Integration: Health Feed & Doctor Advisory
            _buildDoctorAdviceBanner(context),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildEmergencyBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.alertRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.alertRed.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.alertRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Emergency Assistance',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Instant alert to family doctor & ambulance',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.alertRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
           onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencySosScreen()),
              );
            },
            child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildVitalsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        VitalsCard(
          title: 'Heart Rate',
          value: '72',
          unit: 'BPM',
          icon: Icons.favorite,
          accentColor: AppTheme.alertRed,
          statusText: 'Normal',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraPulseScreen()),
            );
          },
        ),
        VitalsCard(
          title: 'Blood Pressure',
          value: '120/80',
          unit: 'mmHg',
          icon: Icons.speed,
          accentColor: AppTheme.primaryBlue,
          statusText: 'Optimal',
          onTap: () {},
        ),
        VitalsCard(
          title: 'Blood Glucose',
          value: '95',
          unit: 'mg/dL',
          icon: Icons.water_drop,
          accentColor: AppTheme.successGreen,
          statusText: 'Fasting OK',
          onTap: () {},
        ),
        VitalsCard(
          title: 'Oxygen (SpO2)',
          value: '98',
          unit: '%',
          icon: Icons.air,
          accentColor: Colors.amber,
          statusText: 'Healthy',
          onTap: () {},
        ),
      ],
    );
  }
  Widget _buildHabitTrackers() {
    return Row(
      children: [
        // Water Intake Widget
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Hydration', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Icon(Icons.local_drink, color: Colors.cyan, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$_waterGlasses / $_targetGlasses Glasses',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _waterGlasses / _targetGlasses,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      if (_waterGlasses < _targetGlasses) {
                        setState(() => _waterGlasses++);
                      }
                    },
                    child: const Text(
                      '+ Add Glass',
                      style: TextStyle(fontSize: 11, color: Colors.cyan, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Steps Tracker Widget
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Daily Steps', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Icon(Icons.directions_walk, color: Colors.orange, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$_currentSteps / $_targetSteps',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _currentSteps / _targetSteps,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '70% Goal',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // COLLABORATION NOTE (PARTNER B):
  // When your partner finishes health_feed_screen.dart, this banner will link to it
  Widget _buildDoctorAdviceBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.article_outlined, color: AppTheme.primaryBlue, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Doctor Health Tips',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Verified diets & habits from registered doctors',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onPressed: () {
              // COLLABORATION NOTE (PARTNER B):
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthFeedScreen()));
            },
          ),
        ],
      ),
    );
  }
}