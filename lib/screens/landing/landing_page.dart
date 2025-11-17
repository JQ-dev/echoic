import 'package:flutter/material.dart';
import 'package:lenski/screens/navigation/navigation_handler.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'dart:html' as html;

/// Beautiful landing page for LenSki
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _launchDemo() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NavigationHandler()),
    );
  }

  void _downloadWindows() {
    // Link to Windows installer
    html.window.open(
      'https://github.com/SantiagoChamie/echoic/releases/latest',
      '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary.withOpacity(0.1),
              Colors.white,
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, isMobile),
              _buildHeroSection(context, isMobile),
              _buildFeaturesSection(context, isMobile),
              _buildDemoSection(context, isMobile),
              _buildDownloadSection(context, isMobile),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'LenSki',
                style: AppFonts.unbounded.copyWith(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (!isMobile)
            Row(
              children: [
                _buildHeaderButton('Features', () {
                  _scrollToSection(1);
                }),
                const SizedBox(width: 20),
                _buildHeaderButton('Demo', () {
                  _scrollToSection(2);
                }),
                const SizedBox(width: 20),
                _buildHeaderButton('Download', () {
                  _scrollToSection(3);
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppFonts.sansation.copyWith(
          fontSize: 16,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _scrollToSection(int section) {
    // Simple scroll implementation
    // In a real app, you'd use ScrollController with keys
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 80,
            vertical: isMobile ? 60 : 120,
          ),
          child: Column(
            children: [
              Text(
                'Master Any Language',
                textAlign: TextAlign.center,
                style: AppFonts.unbounded.copyWith(
                  fontSize: isMobile ? 36 : 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your autonomous language learning companion',
                textAlign: TextAlign.center,
                style: AppFonts.sansation.copyWith(
                  fontSize: isMobile ? 18 : 24,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildCTAButton(
                    'Try Demo',
                    Icons.play_circle_outline,
                    AppColors.primary,
                    Colors.white,
                    _launchDemo,
                  ),
                  _buildCTAButton(
                    'Download for Windows',
                    Icons.download,
                    Colors.white,
                    AppColors.primary,
                    _downloadWindows,
                    outlined: true,
                  ),
                ],
              ),
              const SizedBox(height: 80),
              _buildHeroImage(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton(
    String text,
    IconData icon,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed, {
    bool outlined = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(
        text,
        style: AppFonts.sansation.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: outlined ? Colors.white : bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        elevation: outlined ? 0 : 8,
        shadowColor: AppColors.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: outlined
              ? BorderSide(color: AppColors.primary, width: 2)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildHeroImage(bool isMobile) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isMobile ? double.infinity : 900,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.computer,
                size: isMobile ? 120 : 200,
                color: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                'Interactive Learning Interface',
                style: AppFonts.sansation.copyWith(
                  fontSize: isMobile ? 16 : 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 60 : 100,
      ),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            'Powerful Features',
            style: AppFonts.unbounded.copyWith(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Everything you need to master a new language',
            textAlign: TextAlign.center,
            style: AppFonts.sansation.copyWith(
              fontSize: isMobile ? 16 : 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 60),
          _buildFeatureGrid(isMobile),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(bool isMobile) {
    final features = [
      _FeatureData(
        icon: Icons.translate,
        title: 'Instant Translation',
        description: 'Powered by DeepL API for accurate, context-aware translations',
        color: Colors.blue,
      ),
      _FeatureData(
        icon: Icons.record_voice_over,
        title: 'Text-to-Speech',
        description: 'Natural pronunciation practice with native TTS',
        color: Colors.purple,
      ),
      _FeatureData(
        icon: Icons.psychology,
        title: 'Spaced Repetition',
        description: 'SM-2 algorithm optimizes your learning schedule',
        color: Colors.orange,
      ),
      _FeatureData(
        icon: Icons.auto_stories,
        title: 'Interactive Reading',
        description: 'Import books and articles, click any word to translate',
        color: Colors.green,
      ),
      _FeatureData(
        icon: Icons.headphones,
        title: 'Listening Practice',
        description: 'Improve comprehension with audio exercises',
        color: Colors.red,
      ),
      _FeatureData(
        icon: Icons.trending_up,
        title: 'Progress Tracking',
        description: 'Track streaks, goals, and language competence',
        color: Colors.teal,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isMobile ? 1 : (constraints.maxWidth > 1200 ? 3 : 2);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isMobile ? 1.2 : 1.1,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _buildFeatureCard(features[index], isMobile);
          },
        );
      },
    );
  }

  Widget _buildFeatureCard(_FeatureData feature, bool isMobile) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500 + (100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: feature.color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature.icon,
                size: isMobile ? 40 : 48,
                color: feature.color,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              feature.title,
              textAlign: TextAlign.center,
              style: AppFonts.unbounded.copyWith(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              feature.description,
              textAlign: TextAlign.center,
              style: AppFonts.sansation.copyWith(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 60 : 100,
      ),
      child: Column(
        children: [
          Text(
            'See LenSki in Action',
            style: AppFonts.unbounded.copyWith(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Try the interactive demo right in your browser',
            textAlign: TextAlign.center,
            style: AppFonts.sansation.copyWith(
              fontSize: isMobile ? 16 : 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 48),
          Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 800,
            ),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.web,
                  size: isMobile ? 80 : 120,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Web Demo Available',
                  style: AppFonts.unbounded.copyWith(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Click the button below to launch the full LenSki experience',
                  textAlign: TextAlign.center,
                  style: AppFonts.sansation.copyWith(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 32),
                _buildCTAButton(
                  'Launch Interactive Demo',
                  Icons.rocket_launch,
                  AppColors.secondary,
                  Colors.white,
                  _launchDemo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 60 : 100,
      ),
      color: AppColors.primary,
      child: Column(
        children: [
          Text(
            'Download LenSki',
            style: AppFonts.unbounded.copyWith(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Get the full desktop experience',
            textAlign: TextAlign.center,
            style: AppFonts.sansation.copyWith(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildDownloadCard(
                'Windows',
                Icons.windows,
                'Download .exe installer',
                _downloadWindows,
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(
    String platform,
    IconData icon,
    String subtitle,
    VoidCallback onPressed,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? double.infinity : 300,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            platform,
            style: AppFonts.unbounded.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppFonts.sansation.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.grey[900],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'LenSki',
                style: AppFonts.unbounded.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Master languages autonomously',
            style: AppFonts.sansation.copyWith(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '© 2024 LenSki. Open source language learning.',
            style: AppFonts.sansation.copyWith(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
