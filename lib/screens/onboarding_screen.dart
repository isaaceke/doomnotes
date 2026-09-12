import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_prefs_service.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/onboarding_slide.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _slides = [
    OnboardingSlide(
      title: 'Save from TikTok, YouTube, Instagram',
      subtitle:
          'Use the share sheet on any video or post and send it to DoomNotes. We keep the original source link so you can always go back.',
      icon: Icons.share_rounded,
      accent: DoomNotesTheme.violet,
    ),
    OnboardingSlide(
      title: 'Organized by topic, automatically',
      subtitle:
          'DoomNotes suggests a topic folder based on what you saved. You can always change it or create your own.',
      icon: Icons.folder_rounded,
      accent: DoomNotesTheme.mint,
    ),
    OnboardingSlide(
      title: 'Search that understands you',
      subtitle:
          'Type “gwara”, “qwara”, or “quara” — you still find the dance tutorial. Smart search forgives common spelling variations.',
      icon: Icons.search_rounded,
      accent: DoomNotesTheme.amber,
    ),
    OnboardingSlide(
      title: 'One tap back to the source',
      subtitle:
          'Every saved item shows a “Watch video” or “Open post” button. Tap it to open the original TikTok, YouTube, or Instagram link.',
      icon: Icons.open_in_new_rounded,
      accent: DoomNotesTheme.rose,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    final appPrefs = AppPrefsService(prefs);
    await appPrefs.setHasSeenOnboarding(true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (_, index) => _slides[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ...List.generate(
                    _slides.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: _page == index
                            ? DoomNotesTheme.violet
                            : DoomNotesTheme.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_page < _slides.length - 1)
                    TextButton(
                      onPressed: () => _controller.animateToPage(
                        _slides.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      child: const Text('Skip'),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _page == _slides.length - 1 ? _finish : () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Text(_page == _slides.length - 1 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}