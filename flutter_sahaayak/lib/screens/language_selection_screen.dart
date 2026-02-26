import 'package:flutter/material.dart';
import '../theme/sahaayak_theme.dart';
import 'home_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;

  final List<Map<String, String>> languages = [
    {'name': 'Hindi', 'code': 'hi'},
    {'name': 'English', 'code': 'en'},
    {'name': 'Marathi', 'code': 'mr'},
    {'name': 'Bhojpuri', 'code': 'bho'},
    {'name': 'Tamil', 'code': 'ta'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 60,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Choose your language',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Select the dialect you are most comfortable with.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = selectedLanguage == lang['code'];
                    
                    return GestureDetector(
                      onTap: () => setState(() => selectedLanguage = lang['code']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                        decoration: BoxDecoration(
                          color: isSelected ? SahaayakTheme.accentPurple.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? SahaayakTheme.accentPurple : Colors.grey.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: SahaayakTheme.accentPurple.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang['name']!,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isSelected ? SahaayakTheme.accentPurple : SahaayakTheme.textMain,
                                fontSize: 20,
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: SahaayakTheme.accentPurple),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedLanguage != null 
                    ? () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      ) 
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SahaayakTheme.accentPurple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continue'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
