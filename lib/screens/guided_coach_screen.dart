import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import '../services/voice_service.dart';
import '../services/haptic_service.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';

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
    _playCurrentInstruction();
  }

  void _playCurrentInstruction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
      final steps = _getCoachSteps(langCode);
      VoiceService.speak(steps[_currentStep]['instruction'], langCode);
    });
  }

  List<Map<String, dynamic>> _getCoachSteps(String lang) {
    return [
      {
        'title': Translations.get(lang, 'coach_id_title'),
        'instruction': Translations.get(lang, 'coach_id_desc'),
        'action': Translations.get(lang, 'coach_id_action'),
        'icon': Icons.badge_rounded,
        'color': SahaayakTheme.primary,
      },
      {
        'title': Translations.get(lang, 'coach_doc_title'),
        'instruction': Translations.get(lang, 'coach_doc_desc'),
        'action': Translations.get(lang, 'coach_doc_action'),
        'icon': Icons.camera_alt_rounded,
        'color': SahaayakTheme.warning,
      },
      {
        'title': Translations.get(lang, 'coach_family_title'),
        'instruction': Translations.get(lang, 'coach_family_desc'),
        'action': Translations.get(lang, 'coach_family_action'),
        'icon': Icons.family_restroom_rounded,
        'color': SahaayakTheme.accentAI,
      },
      {
        'title': Translations.get(lang, 'coach_submit_title'),
        'instruction': Translations.get(lang, 'coach_submit_desc'),
        'action': Translations.get(lang, 'coach_submit_action'),
        'icon': Icons.cloud_done_rounded,
        'color': SahaayakTheme.success,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    final coachSteps = _getCoachSteps(langCode);
    
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      appBar: _buildAppBar(langCode),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildMncStepper(coachSteps),
            Expanded(
              child: _buildCoachContent(coachSteps, langCode),
            ),
            _buildActionFooter(coachSteps, langCode),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String lang) {
    return AppBar(
      backgroundColor: SahaayakTheme.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        Translations.get(lang, 'application_coach').toUpperCase(), 
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2.5, color: SahaayakTheme.primaryDeep)
      ),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: SahaayakTheme.primaryDeep),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildMncStepper(List<Map<String, dynamic>> steps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? SahaayakTheme.primary 
                    : (isCurrent ? SahaayakTheme.primary.withValues(alpha: 0.3) : SahaayakTheme.primary.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn();
  }

  Widget _buildCoachContent(List<Map<String, dynamic>> steps, String lang) {
    final step = steps[_currentStep];
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCoachAvatar(step['color'], step['icon'] as IconData)
              .animate(key: ValueKey(_currentStep))
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 40),
          Text(
            '${Translations.get(lang, 'step_prefix')} ${_currentStep + 1} ${Translations.get(lang, 'step_of')} ${steps.length}'.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: SahaayakTheme.primaryDeep.withValues(alpha: 0.4), letterSpacing: 3),
          ).animate(key: ValueKey('title$_currentStep')).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 12),
          Text(
            step['instruction'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, height: 1.3, color: SahaayakTheme.primaryDeep),
          ).animate(key: ValueKey('instr$_currentStep')).fadeIn(delay: 100.ms).slideY(begin: 0.1),
          const SizedBox(height: 48),
          _buildSpecializedStepView(),
          const SizedBox(height: 48),
          _buildInteractionCard(step),
        ],
      ),
    );
  }

  Widget _buildSpecializedStepView() {
    switch (_currentStep) {
      case 0: return _buildIdentityView();
      case 1: return _buildScannerView();
      case 2: return _buildFamilyView();
      case 3: return _buildSuccessView();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildIdentityView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SahaayakTheme.primary.withValues(alpha: 0.1), width: 2),
        ),
        child: const Center(child: Text('••••', style: TextStyle(fontSize: 20, color: SahaayakTheme.textSecondary))),
      )),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildScannerView() {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SahaayakTheme.warning.withValues(alpha: 0.2), width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20, left: 20, right: 20, bottom: 20,
            child: Container(color: SahaayakTheme.background, child: const Icon(Icons.qr_code_scanner_rounded, color: SahaayakTheme.warning, size: 48)),
          ),
          Container(
            height: 2,
            width: double.infinity,
            color: SahaayakTheme.warning,
          ).animate(onPlay: (c) => c.repeat()).slideY(duration: 2.seconds, begin: 0, end: 60),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildFamilyView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: [
            CircleAvatar(radius: 24, backgroundColor: SahaayakTheme.accentAI.withValues(alpha: 0.1), child: const Icon(Icons.person_rounded, color: SahaayakTheme.accentAI)),
            const Positioned(right: 0, bottom: 0, child: Icon(Icons.check_circle_rounded, color: SahaayakTheme.success, size: 16)),
          ],
        ),
      )).animate(interval: 100.ms).scale().fadeIn(),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: SahaayakTheme.premiumCard(radius: 24).copyWith(color: SahaayakTheme.success.withValues(alpha: 0.05)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security_rounded, color: SahaayakTheme.success, size: 24),
          SizedBox(width: 16),
          Text('Encrypted Upload Ready', style: TextStyle(fontWeight: FontWeight.w700, color: SahaayakTheme.success)),
        ],
      ),
    ).animate().shimmer();
  }

  Widget _buildCoachAvatar(Color color, IconData icon) {
    return Container(
      width: 140,
      height: 140,
      decoration: SahaayakTheme.siliconOrb(glowColor: color),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.08, 1.08), curve: Curves.easeInOut)
     .shimmer(duration: 4.seconds, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildInteractionCard(Map<String, dynamic> step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: SahaayakTheme.premiumCard(),
      child: Row(
        children: [
          const Icon(Icons.mic_none_rounded, color: SahaayakTheme.accentSaffron, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              step['action'],
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: SahaayakTheme.primaryDeep),
            ),
          ),
          const Icon(Icons.waves_rounded, color: SahaayakTheme.accentTeal, size: 20),
        ],
      ),
    ).animate(key: ValueKey('card$_currentStep')).fadeIn(delay: const Duration(milliseconds: 300)).slideY(begin: 0.2);
  }

  Widget _buildActionFooter(List<Map<String, dynamic>> steps, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              onPressed: () {
                HapticService.light();
                setState(() => _currentStep--);
                _playCurrentInstruction();
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              style: IconButton.styleFrom(
                backgroundColor: SahaayakTheme.primary.withValues(alpha: 0.05),
                padding: const EdgeInsets.all(20),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                HapticService.medium();
                if (_currentStep < steps.length - 1) {
                  setState(() => _currentStep++);
                  _playCurrentInstruction();
                } else {
                  HapticService.success();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SahaayakTheme.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 72),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                (_currentStep == steps.length - 1 ? Translations.get(lang, 'verify_and_submit') : Translations.get(lang, 'continue')).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
