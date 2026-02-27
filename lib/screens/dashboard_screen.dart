import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';
import '../theme/sahaayak_theme.dart';
import '../services/haptic_service.dart';
import 'guided_coach_screen.dart';
import 'vault_screen.dart';
import 'helpline_screen.dart';
import 'widgets.dart';
import '../services/ai_coordinator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildEliteAppBar(context, langCode),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                _buildMarketPillTicker(),
                const SizedBox(height: 32),
                _buildSchemeNewsMarquee(langCode),
                const SizedBox(height: 32),
                _buildLifeMilestones(context),
                const SizedBox(height: 48),
                _buildCitizenPulseWidget(langCode),
                const SizedBox(height: 48),
                _buildHeroTrustCard(context, langCode),
                const SizedBox(height: 48),
                const Text('DIGITAL BHARAT PORTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4, color: SahaayakTheme.textSecondary)),
                const SizedBox(height: 24),
                _buildModernBentoGrid(context, langCode),
                const SizedBox(height: 40),
                _buildVerifiedBadgeBanner(),
                const SizedBox(height: 140),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEliteAppBar(BuildContext context, String langCode) {
    return SliverAppBar(
      expandedHeight: 140,
      backgroundColor: SahaayakTheme.background,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        background: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    "SAHAAYAK AI",
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 10, 
                      letterSpacing: 2, 
                      color: SahaayakTheme.primary.withValues(alpha: 0.5)
                    ),
                  ),
                  if (AICoordinator.isFrontendOnly) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: SahaayakTheme.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: const Text('OFFLINE MODE', style: TextStyle(color: SahaayakTheme.warning, fontSize: 8, fontWeight: FontWeight.w900)),
                    ).animate().fadeIn(),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
        title: const Text(
          'Citizen Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            fontSize: 28, 
            letterSpacing: -1,
            color: SahaayakTheme.primaryDark
          ),
        ),
      ),
    );
  }

  Widget _buildMarketPillTicker() {
    final items = [
      {'label': 'Wheat', 'price': '₹2,450', 'icon': Icons.agriculture_rounded},
      {'label': 'Rice', 'price': '₹3,100', 'icon': Icons.grass_rounded},
      {'label': 'Diesel', 'price': '₹89.62', 'icon': Icons.local_gas_station_rounded},
    ];
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: SahaayakTheme.bentoCard(radius: 20),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, color: SahaayakTheme.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: SahaayakTheme.textSecondary)),
                const SizedBox(width: 8),
                Text(item['price'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchemeNewsMarquee(String langCode) {
    final news = [
      "📢 PM Kisan: Next installment expected by March 15th",
      "⚡ Soubhagya: New connection subsidy increased for hilly regions",
      "🌾 Soil Health Card: District level camps start from Monday",
      "🏥 Ayushman Bharat: 50+ new private hospitals empanelled",
    ];

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: SahaayakTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: SahaayakTheme.primary,
              child: const Center(child: Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10))),
            ),
            Expanded(
              child: _MarqueeText(texts: news),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildLifeMilestones(BuildContext context) {
    final milestones = [
      {'label': 'I\'m getting Married', 'icon': Icons.favorite_rounded, 'color': const Color(0xFFFF2D55), 'desc': 'Wedding Grants'},
      {'label': 'I had a Child', 'icon': Icons.child_care_rounded, 'color': const Color(0xFF5856D6), 'desc': 'Kanya Sumangala'},
      {'label': 'I\'m a Student', 'icon': Icons.school_rounded, 'color': const Color(0xFF007AFF), 'desc': 'Scholarships'},
      {'label': 'I need a Home', 'icon': Icons.home_work_rounded, 'color': const Color(0xFF34C759), 'desc': 'Housing Subsidy'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIFE MILESTONES',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, color: SahaayakTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final m = milestones[index];
              return MilestoneCard(
                label: m['label'] as String,
                icon: m['icon'] as IconData,
                color: m['color'] as Color,
                onTap: () {
                   HapticService.medium();
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text('${m['desc']} identified as your current focus.'),
                       behavior: SnackBarBehavior.floating,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     )
                   );
                },
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1);
  }

  Widget _buildCitizenPulseWidget(String langCode) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: SahaayakTheme.premiumCard(radius: 32).copyWith(
        gradient: LinearGradient(
          colors: [Colors.white, SahaayakTheme.primary.withValues(alpha: 0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: SahaayakTheme.accentAI, size: 24),
              const SizedBox(width: 12),
              const Text('CITIZEN PULSE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, color: SahaayakTheme.textSecondary)),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: SahaayakTheme.success, shape: BoxShape.circle),
              ).animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.5, 1.5)).fadeOut(),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPulseStat('Matches', '14', Icons.auto_awesome_rounded),
              _buildPulseStat('Verified', '85%', Icons.verified_rounded),
              _buildPulseStat('Pending', '2', Icons.pending_actions_rounded),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildPulseStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
             Icon(icon, size: 12, color: SahaayakTheme.textSecondary),
             const SizedBox(width: 4),
             Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: SahaayakTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: SahaayakTheme.primaryDark)),
      ],
    );
  }

  Widget _buildHeroTrustCard(BuildContext context, String langCode) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        Navigator.push(context, MaterialPageRoute(builder: (context) => const GuidedCoachScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: SahaayakTheme.bentoCard(color: SahaayakTheme.primary, radius: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 const Icon(Icons.stars_rounded, color: SahaayakTheme.warning, size: 40),
                 const Spacer(),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                   child: const Text('LIVE SYNC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                 ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Your Benefits\nare waiting.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32, height: 1.05, letterSpacing: -1)),
            const SizedBox(height: 12),
            const Text('3 Government schemes found for your current location.', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Text(
                'OPEN SMART MATCH', 
                style: TextStyle(color: SahaayakTheme.primary, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds, color: Colors.white.withValues(alpha: 0.1));
  }

  Widget _buildModernBentoGrid(BuildContext context, String langCode) {
    final items = [
      {'title': Translations.get(langCode, 'bento_documents'), 'icon': Icons.lock_person_rounded, 'color': SahaayakTheme.primary, 'id': 'Documents'},
      {'title': Translations.get(langCode, 'bento_analytics'), 'icon': Icons.analytics_rounded, 'color': SahaayakTheme.accentAI, 'id': 'Analytics'},
      {'title': Translations.get(langCode, 'bento_helpline'), 'icon': Icons.contact_support_rounded, 'color': SahaayakTheme.success, 'id': 'Helpline'},
      {'title': Translations.get(langCode, 'bento_help'), 'icon': Icons.support_agent_rounded, 'color': SahaayakTheme.warning, 'id': 'Help'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            HapticService.light();
            if (item['id'] == 'Documents') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultScreen()));
            } else if (item['id'] == 'Helpline') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelplineScreen()));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: SahaayakTheme.premiumCard(radius: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item['icon'] as IconData, color: item['color'] as Color, size: 28),
                const Spacer(),
                Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.2, color: SahaayakTheme.primaryDark)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerifiedBadgeBanner() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: SahaayakTheme.bentoCard(radius: 40, color: SahaayakTheme.success.withValues(alpha: 0.05)),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: SahaayakTheme.success, size: 48),
          SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantum Trust Engine', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text('Active in Bharat • End-to-end Encrypted', style: TextStyle(fontSize: 13, color: SahaayakTheme.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final List<String> texts;
  const _MarqueeText({required this.texts});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    while (_scrollController.hasClients) {
      await Future.delayed(const Duration(seconds: 2));
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: widget.texts.length * 5),
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(seconds: 2));
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.texts[index % widget.texts.length],
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: SahaayakTheme.primary),
            ),
          ),
        );
      },
    );
  }
}
