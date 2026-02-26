import 'package:flutter/material.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/sahaayak_theme.dart';
import 'widgets.dart';
import 'help_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  AppState _state = AppState.idle;
  AIResponse? _response;
  String _errorMessage = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );
    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() => _state = AppState.listening);
    _pulseController.repeat();
  }

  Future<void> _handleSpeechSubmission(String text) async {
    _pulseController.stop();
    setState(() => _state = AppState.processing);

    try {
      await Future.delayed(const Duration(milliseconds: 2000));
      final response = await _apiService.processVoice(text);
      if (mounted) {
        setState(() {
          _response = response;
          _state = AppState.success;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _state = AppState.error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 40),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: SahaayakTheme.primaryBlue),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildStateView(),
            ),
          ),
          _buildFooter(),
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
    return Column(
      key: const ValueKey('idle'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          '"How can I help you today?"',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        _buildMicButton(false),
        const SizedBox(height: 32),
        Text(
          'Tap & Speak',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: SahaayakTheme.textSecondary,
            fontSize: 20,
          ),
        ),
        const Spacer(),
        _buildRecentHelpSection(),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildListeningContent() {
    return Column(
      key: const ValueKey('listening'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Listening...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: SahaayakTheme.accentPurple,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '"Boliyé..."',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: SahaayakTheme.textSecondary),
        ),
        const SizedBox(height: 64),
        // WAVE ANIMATION HERO
        _buildWaveAnimation(), 
        const SizedBox(height: 64),
        _buildMicButton(true),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildWaveAnimation() {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(15, (index) => _WaveBar(index: index)),
      ),
    );
  }

  Widget _buildMicButton(bool isActive) {
    return GestureDetector(
      onTap: isActive ? () => _handleSpeechSubmission("Mujhe kisan yojana chahiye") : _startListening,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isActive ? SahaayakTheme.accentPurple : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: SahaayakTheme.accentPurple.withOpacity(0.1),
            width: 8,
          ),
          boxShadow: [
            BoxShadow(
              color: SahaayakTheme.accentPurple.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isActive ? Icons.stop_rounded : Icons.mic_rounded,
            size: 64,
            color: isActive ? Colors.white : SahaayakTheme.accentPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingContent() {
    return Column(
      key: const ValueKey('processing'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color>(SahaayakTheme.accentPurple),
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Understanding your request...',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Checking schemes...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildRecentHelpSection() {
    final chips = ['Farmer schemes', 'Scholarship', 'Pension'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'QUICK HELP:',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: SahaayakTheme.textSecondary,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 54,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            scrollDirection: Axis.horizontal,
            itemCount: chips.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => ActionChip(
              label: Text(chips[index]),
              onPressed: () {},
              backgroundColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: SahaayakTheme.primaryBlue),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    if (_response == null) return Container();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Text('User said:', style: TextStyle(fontWeight: FontWeight.w900, color: SahaayakTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Text('"${_response!.normalizedText}"', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SahaayakTheme.accentPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SahaayakTheme.accentPurple.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🤖 ', style: TextStyle(fontSize: 20)),
                  Text('AI Response:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 12),
              Text(_response!.aiMessage, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ..._response!.suggestedSchemes.map((s) => SchemeCard(
          title: s.name,
          description: s.description,
          benefits: s.benefits,
          link: s.link,
        )).toList(),
        const SizedBox(height: 40),
        _buildResultActions(),
        const SizedBox(height: 48),
        _buildFeedbackSection(),
      ],
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(child: _buildActionButton('🔊 Listen', () {}, outline: true)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton('📄 Apply Guide', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
        })),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      children: [
        const Text('Was this helpful?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeedbackBtn('👍 Yes', Colors.green),
            const SizedBox(width: 24),
            _buildFeedbackBtn('👎 No', Colors.red),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Your feedback improves Sahaayak AI',
          style: TextStyle(fontSize: 14, color: SahaayakTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 48),
        _buildActionButton('🎤 Ask Again', () => setState(() => _state = AppState.idle), outline: true),
      ],
    );
  }

  Widget _buildFeedbackBtn(String label, Color color) {
    return SizedBox(
      width: 120,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      width: double.infinity,
      color: Colors.white,
      child: const Text(
        'Built for Bharat 🇮🇳',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w900, color: SahaayakTheme.primaryBlue, letterSpacing: 2, fontSize: 13),
      ),
    );
  }

  Widget _buildErrorContent() {
    return _buildIdleContent();
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, {bool outline = false}) {
    if (outline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: SahaayakTheme.accentPurple, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          foregroundColor: SahaayakTheme.accentPurple,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: SahaayakTheme.accentPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    );
  }
}

class _WaveBar extends StatefulWidget {
  final int index;
  const _WaveBar({required this.index});

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 100) % 600),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 10, end: 60).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: _animation.value,
          decoration: BoxDecoration(
            color: SahaayakTheme.accentPurple.withOpacity(0.6 + (widget.index / 30)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

enum AppState { idle, listening, processing, success, error }
