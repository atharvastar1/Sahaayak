import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/local_engine.dart';
import '../theme/sahaayak_theme.dart';
import 'guided_coach_screen.dart';
import 'liquid_mic.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final LocalEngine _engine = LocalEngine();
  AppState _state = AppState.idle;
  AIResponse? _response;
  final bool _isOffline = true;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        title: Hero(tag: 'logo', child: Image.asset('assets/logo.png', height: 40)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildOfflineIndicator(),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildPremiumBackground(),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.fastLinearToSlowEaseIn,
              switchOutCurve: Curves.fastOutSlowIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildStateView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBackground() {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            if (_state == AppState.listening) SahaayakTheme.primaryBlue.withValues(alpha: 0.08)
            else if (_state == AppState.processing) SahaayakTheme.primaryGreen.withValues(alpha: 0.12)
            else SahaayakTheme.primaryBlue.withValues(alpha: 0.03),
            Colors.white,
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: _isOffline ? Colors.black.withValues(alpha: 0.05) : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
            size: 14,
            color: _isOffline ? SahaayakTheme.offlineGrey : Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            _isOffline ? Translations.get(langCode, 'offline_active') : Translations.get(langCode, 'connected'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: _isOffline ? SahaayakTheme.offlineGrey : Colors.green,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateView() {
    switch (_state) {
      case AppState.idle: return _buildIdleContent();
      case AppState.listening: return _buildListeningContent();
      case AppState.processing: return _buildProcessingContent();
      case AppState.success: return _buildSuccessContent();
      case AppState.error: return _buildErrorContent();
    }
  }

  Widget _buildIdleContent() {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Column(
      key: const ValueKey('idle'),
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            Translations.get(langCode, 'how_can_i_help'),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 34),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        LiquidMicButton(isListening: false, onTap: () => setState(() => _state = AppState.listening)),
        const SizedBox(height: 32),
        Text(
          Translations.get(langCode, 'tap_to_speak').toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: SahaayakTheme.textSecondary.withValues(alpha: 0.6),
            letterSpacing: 3,
          ),
        ),
        const Spacer(),
        _buildLifeEventMode(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLifeEventMode() {
    final events = [
      {'icon': '🚜', 'label': 'Farmer', 'query': 'I am a Farmer'},
      {'icon': '🎓', 'label': 'Student', 'query': 'I am a Student'},
      {'icon': '🏥', 'label': 'Health', 'query': 'Health Help'},
      {'icon': '💼', 'label': 'Laborer', 'query': 'I am a Laborer'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'QUICK OPTIONS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: SahaayakTheme.textSecondary.withValues(alpha: 0.5),
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _handleQuery(events[index]['query']!),
              child: Container(
                width: 100,
                decoration: SahaayakTheme.glassDecoration(radius: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(events[index]['icon']!, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 10),
                    Text(
                      events[index]['label']!,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: SahaayakTheme.primaryBlue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListeningContent() {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Column(
      key: const ValueKey('listening'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Translations.get(langCode, 'sahaayak_intelligence'),
          style: const TextStyle(color: SahaayakTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
        ).animate().fadeIn(),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => SahaayakTheme.appleGradient.createShader(bounds),
          child: Text(Translations.get(langCode, 'listening'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.5.seconds),
        const SizedBox(height: 64),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
               // Apple-style glow
               Container(
                 width: 240,
                 height: 240,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   gradient: RadialGradient(
                     colors: [
                       SahaayakTheme.primaryBlue.withValues(alpha: 0.15),
                       SahaayakTheme.primaryBlue.withValues(alpha: 0.0),
                     ],
                   ),
                 ),
               ).animate(onPlay: (c) => c.repeat()).scale(duration: 2.seconds, curve: Curves.easeInOut),
               
               GestureDetector(
                onTap: () => _handleQuery("PM Kisan Yojana"),
                child: LiquidMicButton(isListening: true, onTap: () => _handleQuery("PM Kisan Yojana")),
               ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingContent() {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Column(
      key: const ValueKey('processing'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(SahaayakTheme.primaryBlue),
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 48),
        Text(Translations.get(langCode, 'sahaayak_intelligence'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SahaayakTheme.textSecondary)),
        const SizedBox(height: 8),
        Text(Translations.get(langCode, 'analyzing_regional_context'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _handleQuery(String text) async {
    setState(() => _state = AppState.processing);
    try {
      final response = await _engine.processVoice(text);
      if (mounted) {
        setState(() {
          _response = response;
          _state = AppState.success;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _state = AppState.error);
    }
  }

  Widget _buildSuccessContent() {
    if (_response == null) return Container();
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      children: [
        Row(
          children: [
             const Icon(Icons.auto_awesome_rounded, color: SahaayakTheme.primaryBlue, size: 20),
             const SizedBox(width: 8),
             Text(Translations.get(langCode, 'sahaayak_intelligence_upper'), style: const TextStyle(color: SahaayakTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
          ],
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        Text(_response!.aiMessage, style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.2)).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 48),
        
        Text(Translations.get(langCode, 'recommended_for_you'), style: const TextStyle(color: SahaayakTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 16),
        ..._response!.suggestedSchemes.map((s) => _buildAppleSchemeCard(s, langCode)).toList()
          .animate(interval: 150.ms).fadeIn().slideY(begin: 0.1),

        const SizedBox(height: 64),
        _buildGuidedAssistantPromo(langCode).animate().fadeIn(delay: 800.ms),
        const SizedBox(height: 64),
        
        Center(
          child: TextButton.icon(
             onPressed: () => setState(() => _state = AppState.idle),
             icon: const Icon(Icons.mic_none_rounded, size: 20),
             label: Text(Translations.get(langCode, 'tap_to_ask_something_else'), style: const TextStyle(fontWeight: FontWeight.w600)),
             style: TextButton.styleFrom(foregroundColor: SahaayakTheme.primaryBlue),
          ),
        ).animate().fadeIn(delay: 1.seconds),
        
        const SizedBox(height: 64),
        _buildRLHFSection(langCode).animate().fadeIn(delay: 1200.ms),
        const SizedBox(height: 40),
        _buildFooter().animate().fadeIn(delay: 1500.ms),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildAppleSchemeCard(Scheme s, String langCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: SahaayakTheme.appleCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
              const Icon(Icons.chevron_right_rounded, color: SahaayakTheme.offlineGrey),
            ],
          ),
          const SizedBox(height: 8),
          Text(s.description, style: const TextStyle(color: SahaayakTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 20),
          Row(
            children: [
               const Icon(Icons.check_circle_rounded, color: SahaayakTheme.primaryGreen, size: 16),
               const SizedBox(width: 6),
               Text(Translations.get(langCode, 'verified_match'), style: const TextStyle(color: SahaayakTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
               const Spacer(),
               Text(Translations.get(langCode, 'on_device_ai'), style: const TextStyle(color: SahaayakTheme.offlineGrey, fontWeight: FontWeight.w800, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedAssistantPromo(String langCode) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuidedCoachScreen())),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: SahaayakTheme.appleCard(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: SahaayakTheme.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.assistant_rounded, color: SahaayakTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Translations.get(langCode, 'application_coach'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 2),
                  Text(Translations.get(langCode, 'step_by_step_guidANCE'), style: const TextStyle(color: SahaayakTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: SahaayakTheme.offlineGrey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRLHFSection(String langCode) {
    return Column(
      children: [
        Text(Translations.get(langCode, 'was_this_helpful'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeedbackBtn('👍 YES', Colors.green),
            const SizedBox(width: 20),
            _buildFeedbackBtn('👎 NO', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildFeedbackBtn(String label, Color color) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.2), width: 2.5),
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      width: double.infinity,
      color: Colors.transparent,
      child: Text(
        'SAHAAYAK AI • NEXT-GEN FOR BHARAT 🇮🇳',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w900, color: SahaayakTheme.textSecondary.withValues(alpha: 0.3), letterSpacing: 3, fontSize: 10),
      ),
    );
  }

  Widget _buildErrorContent() {
    return _buildIdleContent();
  }
}

enum AppState { idle, listening, processing, success, error }
