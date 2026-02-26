import 'package:flutter/material.dart';
import '../theme/sahaayak_theme.dart';

/// A specialized card for displaying government schemes with "Bharat-friendly" styling.
class SchemeCard extends StatelessWidget {
  final String title;
  final String description;
  final String benefits;
  final String? link;

  const SchemeCard({
    super.key,
    required this.title,
    required this.description,
    required this.benefits,
    this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: SahaayakTheme.schemeGreen, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: SahaayakTheme.primaryBlue,
                          height: 1.1,
                          fontSize: 22,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SahaayakTheme.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SahaayakTheme.schemeGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SahaayakTheme.schemeGreen.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BENEFITS / फ़ायदे',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: SahaayakTheme.schemeGreen,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    benefits,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: SahaayakTheme.schemeGreen,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

