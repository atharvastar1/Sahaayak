import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import '../services/voice_service.dart';

class GuidedCoachScreen extends StatefulWidget {
  const GuidedCoachScreen({super.key});

  @override
  State<GuidedCoachScreen> createState() => _GuidedCoachScreenState();
}

class _GuidedCoachScreenState extends State<GuidedCoachScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceService.speak(_coachSteps[_currentStep]['instruction'], 'en');
    });
  }

  final List<Map<String, dynamic>> _coachSteps = [
    {
      'title': 'Identity Verification',
      'instruction': 'I\'ll need to verify your Aadhaar details to proceed.',
      'action': 'Say your 12-digit number',
      'icon': Icons.badge_rounded,
      'color': Colors.blue,
    },
    {
      'title': 'Document Upload',
      'instruction': 'Is your Ration Card available for a quick scan?',
      'action': 'Hold card to camera',
      'icon': Icons.camera_alt_rounded,
      'color': Colors.orange,
    },
    {
      'title': 'Family Details',
      'instruction': 'Confirming your family members registered under this ID.',
      'action': 'Verify 4 members',
      'icon': Icons.family_restroom_rounded,
      'color': Colors.indigo,
    },
    {
      'title': 'Final Submission',
      'instruction': 'Everything is ready. Shall I transmit your application?',
      'action': 'Confirm with Voice',
      'icon': Icons.cloud_done_rounded,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayakTheme.surface,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCupertinoStepper(),
            Expanded(
              child: _buildCoachContent(),
            ),
            _buildActionFooter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: SahaayakTheme.surface,
      elevation: 0,
      centerTitle: true,
      title: const Text('Guided Coach', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: SahaayakTheme.textSecondary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildCupertinoStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: List.generate(_coachSteps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted ? SahaayakTheme.primaryBlue : (isCurrent ? SahaayakTheme.primaryBlue.withValues(alpha: 0.4) : Colors.black12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index == _coachSteps.length - 1) const SizedBox(width: 0) else const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    ).animate().fadeIn();
  }

  Widget _buildCoachContent() {
    final step = _coachSteps[_currentStep];
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCoachAvatar(step['color']).animate(key: ValueKey(_currentStep)).scale(duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
          const SizedBox(height: 48),
          Text(
            step['title'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SahaayakTheme.textSecondary, letterSpacing: 1),
          ).animate(key: ValueKey('title$_currentStep')).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 12),
          Text(
            step['instruction'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24, height: 1.3),
          ).animate(key: ValueKey('instr$_currentStep')).fadeIn(delay: const Duration(milliseconds: 100)).slideY(begin: 0.1),
          const SizedBox(height: 64),
          _buildInteractionCard(step),
        ],
      ),
    );
  }

  Widget _buildCoachAvatar(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
        ).animate(onPlay: (c) => c.repeat()).scale(duration: const Duration(seconds: 2), begin: const Offset(1, 1), end: const Offset(1.3, 1.3)).fadeOut(),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Icon(_coachSteps[_currentStep]['icon'], color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildInteractionCard(Map<String, dynamic> step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: SahaayakTheme.appleCard(radius: 20),
      child: Row(
        children: [
          const Icon(Icons.mic_none_rounded, color: SahaayakTheme.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              step['action'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          const Icon(Icons.waves_rounded, color: SahaayakTheme.primaryBlue, size: 20),
        ],
      ),
    ).animate(key: ValueKey('card$_currentStep')).fadeIn(delay: const Duration(milliseconds: 300)).slideY(begin: 0.2);
  }

  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              onPressed: () => setState(() => _currentStep--),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black12,
                padding: const EdgeInsets.all(16),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < _coachSteps.length - 1) {
                  setState(() => _currentStep++);
                  VoiceService.speak(_coachSteps[_currentStep]['instruction'], 'en');
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SahaayakTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _currentStep == _coachSteps.length - 1 ? 'Verify & Submit' : 'Continue',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
