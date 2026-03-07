import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/models.dart';
import '../services/ai_coordinator.dart';
import '../theme/sahaayak_theme.dart';
import 'guided_coach_screen.dart';
import 'liquid_mic.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';
import '../services/haptic_service.dart';
import '../services/feedback_engine.dart';
import '../services/voice_service.dart';
import 'widgets.dart';
import '../services/recording_service.dart';
import 'whatsapp_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AICoordinator _coordinator = AICoordinator();
  final RecordingService _recorder = RecordingService();
  final TextEditingController _textController = TextEditingController();
  AppState _state = AppState.idle;
  AIResponse? _response;
  final String _lastWords = "";
  List<AIResponse> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _coordinator.getInsightHistory();
    if (mounted) setState(() => _history = history);
  }

  @override
  void dispose() {
    _recorder.dispose();
    _textController.dispose();
    super.dispose();
  }

  // [C1 FIX] Show a real query dialog instead of using a hardcoded string.
  // Pre-fills with a localized prompt matching the user's selected language.
  Future<void> _startListening() async {
    HapticService.heavy();
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';

    // Language-specific default prompts to guide the user
    const prompts = {
      'hi': 'मुझे किसान योजना के बारे में बताओ',
      'mr': 'मला शेतकरी योजनांची माहिती सांगा',
      'pa': 'ਮੈਨੂੰ ਕਿਸਾਨ ਯੋਜਨਾ ਬਾਰੇ ਦੱਸੋ',
      'te': 'రైతు పథకాల గురించి చెప్పండి',
      'ta': 'விவசாயி திட்டங்கள் பற்றி சொல்லுங்கள்',
      'gu': 'ખેડૂત યોજનાઓ વિશે જણાવો',
      'en': 'I am a farmer and need help with seeds and loans',
    };

    if (!mounted) return;
    final query = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: prompts[langCode] ?? prompts['en']);
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.mic_rounded, color: Color(0xFF00B4D8), size: 22),
              SizedBox(width: 8),
              Text('Liquid Mic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Type your query...',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00B4D8))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2a2a4a))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00B4D8))),
              filled: true,
              fillColor: const Color(0xFF0d0d1a),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4D8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );

    if (query == null || query.isEmpty) return;
    setState(() => _state = AppState.listening);
    await Future.delayed(300.ms);
    _handleQuery(query);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: AICoordinator.isFrontendOnly ? Center(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: SahaayakTheme.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('OFFLINE', style: TextStyle(color: SahaayakTheme.warning, fontSize: 10, fontWeight: FontWeight.w900)),
          ).animate().fadeIn(),
        ) : null,
        title: const Hero(tag: 'logo', child: AnimatedLogo(size: 32)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: SahaayakTheme.premiumShadow,
            ),
            child: IconButton(
              onPressed: () {
                HapticService.light();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WhatsAppChatScreen()));
              },
              icon: const Icon(Icons.forum_rounded, size: 20),
              color: SahaayakTheme.primary,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          _buildPremiumBackground(),
          SafeArea(
            child: AnimatedSwitcher(
              duration: 600.ms,
              switchInCurve: Curves.easeOutQuart,
              child: _buildStateView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SahaayakTheme.primary.withValues(alpha: 0.03),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SahaayakTheme.accentAI.withValues(alpha: 0.04),
            ),
          ),
        ),
        if (_state == AppState.processing || _state == AppState.listening)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withValues(alpha: 0.05)),
            ).animate().fadeIn(duration: 800.ms),
          ),
      ],
    );
  }

  Widget _buildStateView() {
    switch (_state) {
      case AppState.idle: return _buildIdleContent();
      case AppState.listening: return _buildListeningContent();
      case AppState.processing: return _buildProcessingContent();
      case AppState.success: return _buildSuccessContent();
      case AppState.error: return _buildIdleContent();
    }
  }

  Widget _buildIdleContent() {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Column(
      key: const ValueKey('idle'),
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                Translations.get(langCode, 'namaste'),
                style: const TextStyle(fontWeight: FontWeight.w900, color: SahaayakTheme.primary, letterSpacing: 2, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                Translations.get(langCode, 'how_can_i_help'),
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        _buildMicSection(),
        const Spacer(),
        if (_history.isNotEmpty) _buildRecentInsights() else _buildQuickOptions(),
        const SizedBox(height: 40),
      ],
    );
  }



  Widget _buildMicSection() {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Column(
      children: [
        LiquidMicButton(isListening: false, onTap: _startListening),
        const SizedBox(height: 32),
        Text(
          Translations.get(langCode, 'tap_to_speak').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: SahaayakTheme.textSecondary, letterSpacing: 3),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
      ],
    ).animate().fadeIn();
  }

  Widget _buildQuickOptions() {
    final events = [
      {'icon': '🚜', 'label': 'Farmer', 'query': 'I am a Farmer'},
      {'icon': '🎓', 'label': 'Student', 'query': 'I am a Student'},
      {'icon': '🏥', 'label': 'Health', 'query': 'Health Help'},
    ];
    return Column(
      children: [
        const Text('QUICK EXPLORE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4, color: SahaayakTheme.textSecondary)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: events.map((e) => GestureDetector(
            onTap: () => _handleQuery(e['query']!),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(24),
              decoration: SahaayakTheme.premiumCard(radius: 28).copyWith(
                boxShadow: SahaayakTheme.premiumShadow,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: SahaayakTheme.background,
                      shape: BoxShape.circle,
                    ),
                    child: Text(e['icon']!, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(height: 12),
                  Text(e['label']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: SahaayakTheme.primaryDark, letterSpacing: -0.5)),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildRecentInsights() {
     return Column(
       children: [
         const Text('RECENT INSIGHTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4, color: SahaayakTheme.textSecondary)),
         const SizedBox(height: 24),
         SizedBox(
           height: 140,
           child: ListView.builder(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               scrollDirection: Axis.horizontal,
               itemCount: math.min(_history.length, 5),
               itemBuilder: (context, index) {
                 final h = _history[index];
                 return GestureDetector(
                   onTap: () => setState(() { _response = h; _state = AppState.success; }),
                   child: Container(
                     width: 240,
                     margin: const EdgeInsets.only(right: 20, bottom: 10),
                     padding: const EdgeInsets.all(24),
                     decoration: SahaayakTheme.premiumCard(radius: 28).copyWith(
                       boxShadow: SahaayakTheme.premiumShadow,
                       gradient: LinearGradient(
                         colors: [Colors.white, SahaayakTheme.background.withValues(alpha: 0.5)],
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight,
                       ),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             const Icon(Icons.history_edu_rounded, size: 16, color: SahaayakTheme.primary),
                             const SizedBox(width: 8),
                             Expanded(child: Text(h.normalizedText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
                           ],
                         ),
                         const Spacer(),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: SahaayakTheme.categoryBadge(color: SahaayakTheme.primary),
                           child: Text('${h.suggestedSchemes.length} Schemes Found', style: const TextStyle(color: SahaayakTheme.primary, fontWeight: FontWeight.w900, fontSize: 10)),
                         ),
                       ],
                     ),
                   ),
                 );
               },
             ),
           ),
         ],
     ).animate().fadeIn();
  }

  Widget _buildListeningContent() {
    return Center(
      key: const ValueKey('listening'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: SahaayakTheme.siliconOrb(glowColor: SahaayakTheme.primary),
              ).animate(onPlay: (c) => c.repeat()).scale(duration: 2.seconds, curve: Curves.easeInOut),
              LiquidMicButton(isListening: true, onTap: () => setState(() => _state = AppState.idle)),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'LISTENING TO YOUR DIALECT...',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 4, color: SahaayakTheme.primary),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          const SizedBox(height: 12),
          Text(
             _lastWords.isEmpty ? "Speak naturally, I'm here to help." : _lastWords,
             style: const TextStyle(color: SahaayakTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingContent() {
    return Center(
      key: const ValueKey('processing'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: SahaayakTheme.siliconOrb(glowColor: SahaayakTheme.accentAI),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 2.seconds, curve: Curves.easeInOut),
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: SahaayakTheme.primary,
                  strokeCap: StrokeCap.round,
                ),
              ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'SYNCHRONIZING...',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 6,
              color: SahaayakTheme.primaryDark,
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          const SizedBox(height: 12),
          const Text(
             'Scanning government database...',
             style: TextStyle(color: SahaayakTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 14),
          ).animate().fadeIn(delay: 1.seconds),
        ],
      ),
    );
  }

  Future<void> _handleQuery(String text) async {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    setState(() => _state = AppState.processing);
    try {
      final response = await _coordinator.processQuery(text, langCode);
      
      // Auto-assist with voice
      VoiceService.speak(response.aiMessage, langCode);
      
      await Future.delayed(800.ms); // Visual breathing room
      _loadHistory(); // Refresh history for next time
      if (mounted) {
        setState(() {
          _response = response;
          _state = AppState.success;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _state = AppState.idle);
    }
  }

  Widget _buildSuccessContent() {
    if (_response == null) return Container();
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(30, 140, 30, 100),
      children: [
        const Text(
          'AI INSIGHTS',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 3,
            color: SahaayakTheme.accentAI,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        Text(
          _response!.aiMessage,
          style: Theme.of(context).textTheme.displayMedium,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
        // [O1 FIX] Show audio unavailable indicator when TTS failed
        if (_response!.audioUrl == null)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔇', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                Text('Voice Unavailable', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 48),
        
        Text(
          'SUGGESTED FOR YOU',
          style: Theme.of(context).textTheme.labelLarge,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 24),
        
        ..._response!.suggestedSchemes.map((s) => TactileSchemeCard(scheme: s)).toList(),
            
        const SizedBox(height: 40),
        _buildActionSuite(),
      ],
    );
  }

  Widget _buildActionSuite() {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Column(
      children: [
        // RLHF Feedback Unit
        Container(
          padding: const EdgeInsets.all(24),
          decoration: SahaayakTheme.premiumCard(radius: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  Translations.get(langCode, 'was_this_helpful'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticService.light();
                  FeedbackEngine.submitFeedback(_response!.requestId, true);
                },
                icon: const Icon(Icons.thumb_up_rounded, color: SahaayakTheme.success, size: 18),
                style: IconButton.styleFrom(backgroundColor: SahaayakTheme.success.withValues(alpha: 0.1)),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  HapticService.light();
                  FeedbackEngine.submitFeedback(_response!.requestId, false);
                },
                icon: const Icon(Icons.thumb_down_rounded, color: Colors.red, size: 18),
                style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.1)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => setState(() => _state = AppState.idle),
          style: ElevatedButton.styleFrom(
            backgroundColor: SahaayakTheme.primaryDark,
            minimumSize: const Size(double.infinity, 70),
          ),
          child: const Text('ASK ANOTHER QUESTION'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuidedCoachScreen())),
          child: const Text('OPEN GUIDED ASSISTANT', style: TextStyle(fontWeight: FontWeight.w800, color: SahaayakTheme.primary)),
        ),
      ],
    );
  }
}

enum AppState { idle, listening, processing, success, error }
