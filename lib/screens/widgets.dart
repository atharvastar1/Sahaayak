import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import '../services/haptic_service.dart';
import '../models/models.dart';

/// Elite MNC-Standard Scheme Card with Tactile Feedback.
class TactileSchemeCard extends StatelessWidget {
  final Scheme scheme;
  final VoidCallback? onTap;

  const TactileSchemeCard({
    super.key,
    required this.scheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: SahaayakTheme.premiumCard(radius: 32),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticService.light();
            if (onTap != null) onTap!();
          },
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: SahaayakTheme.categoryBadge(color: SahaayakTheme.primary),
                      child: Text(
                        (scheme.category ?? 'General').toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: SahaayakTheme.primary,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: SahaayakTheme.textSecondary),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  scheme.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: SahaayakTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  scheme.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: SahaayakTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Divider(color: SahaayakTheme.primary.withValues(alpha: 0.05)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoMini('BENEFITS', scheme.benefits, Icons.stars_rounded),
                    const SizedBox(width: 32),
                    _buildInfoMini('ELIGIBILITY', scheme.eligibility, Icons.person_outline_rounded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart);
  }

  Widget _buildInfoMini(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: SahaayakTheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: SahaayakTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: SahaayakTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// A premium milestone pill for the dashboard.
class MilestoneCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MilestoneCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(24),
        decoration: SahaayakTheme.premiumCard(radius: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                height: 1.2,
                color: SahaayakTheme.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
