import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import '../services/haptic_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _isScanning = false;
  String? _scanningText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SahaayakTheme.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Vault',
          style: TextStyle(fontWeight: FontWeight.w800, color: SahaayakTheme.primaryDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: SahaayakTheme.primary),
            onPressed: _startScanning,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildVaultHeader(),
              const SizedBox(height: 48),
              const Text(
                'VERIFIED DOCUMENTS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, color: SahaayakTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildDocItem('Aadhaar Card', 'UIDAI Verified', Icons.fingerprint_rounded, true),
              _buildDocItem('Ration Card', 'Family ID: 8820...', Icons.assignment_ind_rounded, true),
              _buildDocItem('Voter ID', 'Election Ready', Icons.how_to_reg_rounded, false),
              const SizedBox(height: 40),
              _buildSecurityBanner(),
            ],
          ),
          if (_isScanning) _buildScanningOverlay(),
        ],
      ),
    );
  }

  void _startScanning() async {
    HapticService.heavy();
    setState(() {
      _isScanning = true;
      _scanningText = "Aligning with government servers...";
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _scanningText = "Extracting encrypted metadata...");
    
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _scanningText = "Verifying biometric authenticity...");

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isScanning = false);
    HapticService.success();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New document verified and synced locally.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: SahaayakTheme.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Simulated high-tech grid
                      Positioned.fill(
                        child: CustomPaint(
                          painter: GridPainter(),
                        ),
                      ),
                      // The Scanning Line
                      _buildScanningLine(),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.document_scanner_rounded, color: Colors.white24, size: 80),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            _scanningText ?? "",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ).animate().fadeIn().shimmer(),
          const SizedBox(height: 12),
          const Text(
            "AI-SECURE EXTRACTION ACTIVE",
            style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildScanningLine() {
    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SahaayakTheme.primary.withValues(alpha: 0.0),
            SahaayakTheme.primary,
            SahaayakTheme.primary.withValues(alpha: 0.0),
          ],
        ),
        boxShadow: [
          BoxShadow(color: SahaayakTheme.primary.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .moveY(begin: 0, end: 400, duration: 2.seconds, curve: Curves.easeInOut);
  }

  Widget _buildVaultHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: SahaayakTheme.premiumCard(radius: 40),
      child: const Column(
        children: [
          Icon(Icons.shield_moon_rounded, color: SahaayakTheme.primary, size: 64),
          SizedBox(height: 24),
          Text(
            '3/4 Verified',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -1),
          ),
          SizedBox(height: 8),
          Text(
            'Your identity is secured locally.',
            style: TextStyle(color: SahaayakTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildDocItem(String title, String subtitle, IconData icon, bool isVerified) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: SahaayakTheme.premiumCard(radius: 28),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SahaayakTheme.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: SahaayakTheme.primary, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                Text(subtitle, style: const TextStyle(color: SahaayakTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (isVerified)
            const Icon(Icons.verified_rounded, color: SahaayakTheme.success, size: 24)
          else
            const Icon(Icons.pending_actions_rounded, color: SahaayakTheme.warning, size: 24),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildSecurityBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: SahaayakTheme.bentoCard(radius: 32, color: SahaayakTheme.primary.withValues(alpha: 0.05)),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: SahaayakTheme.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Documents are encrypted with on-device hardware security keys.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
