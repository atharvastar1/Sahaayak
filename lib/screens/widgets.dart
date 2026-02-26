import 'package:flutter/material.dart';
import '../theme/sahaayak_theme.dart';

/// A specialized card for displaying government schemes with "Bharat-friendly" styling.
class SchemeCard extends StatelessWidget {
  final String title;
  final String description;
  final String benefits;
  final String? link;
  final VoidCallback? onListen;

  const SchemeCard({
    super.key,
    required this.title,
    required this.description,
    required this.benefits,
    this.link,
    this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: SahaayakTheme.primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: SahaayakTheme.primaryGreen, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: SahaayakTheme.primaryBlue,
                              height: 1.1,
                            ),
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded, size: 20, color: SahaayakTheme.offlineGrey)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border_rounded, size: 20, color: SahaayakTheme.offlineGrey)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: SahaayakTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SahaayakTheme.primaryGreen.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SahaayakTheme.primaryGreen.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefits,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: SahaayakTheme.primaryGreen,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
          InkWell(
            onTap: onListen,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: SahaayakTheme.primaryBlue.withValues(alpha: 0.03),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_up_rounded, color: SahaayakTheme.primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    'LISTEN / सुनिए',
                    style: TextStyle(fontWeight: FontWeight.w900, color: SahaayakTheme.primaryBlue, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

