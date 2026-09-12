# DOOMNOTES - USER ONBOARDING FLOW
# First-time user experience to maximize activation and retention

## Goals

1. **Get user to first capture within 60 seconds**
2. **Explain value proposition clearly**
3. **Minimize friction (no account required)**
4. **Set expectations (how app works)**

---

## Onboarding Flow (Step-by-Step)

### Screen 1: Welcome (First Launch Only)

**UI:**
- Large app icon
- Headline: \"Turn Doomscrolling into Organized Knowledge\"
- Subheadline: \"Auto-transcribe Instagram, TikTok, and YouTube videos\"
- Button: \"Get Started\"
- Skip button (top right)

**Purpose:**
- Set expectations
- Build excitement
- Quick value prop

---

### Screen 2: How It Works (3-Step Visual)

**UI:**
- 3-step illustration (horizontal scroll or carousel)

**Step 1:**
- Icon: Instagram/TikTok logo
- Text: \"Find a video you want to save\"

**Step 2:**
- Icon: Share button
- Text: \"Tap Share → DoomNotes\"

**Step 3:**
- Icon: Organized folders
- Text: \"Get instant transcript, organized by topic\"

**Button:** \"Continue\"

**Purpose:**
- Show, don't tell
- Make it feel easy
- Visual learners understand quickly

---

### Screen 3: Privacy Assurance

**UI:**
- Icon: Lock/Shield
- Headline: \"Privacy First\"
- Bullet points:
  - ✓ No account required
  - ✓ Data stored on your device
  - ✓ No tracking or ads
- Button: \"Start Using DoomNotes\"

**Purpose:**
- Address privacy concerns upfront
- Differentiate from competitors
- Build trust

---

### Screen 4: First Capture Tutorial (Interactive)

**UI:**
- Overlay on top of Instagram app (or screenshot)
- Highlight Share button
- Arrow pointing to Share button
- Text: \"Tap Share to save this video to DoomNotes\"
- Button: \"Try It Now\" (opens Instagram)

**Alternative (if can't open Instagram):**
- Screenshot with annotations
- Button: \"I Understand\"

**Purpose:**
- Hands-on learning
- Muscle memory
- Reduce anxiety about \"doing it wrong\"

---

### Screen 5: Empty State (Home Screen)

**If user has no notes yet:**

**UI:**
- Large empty inbox icon
- Text: \"No notes yet\"
- Subtext: \"Share your first video from Instagram, TikTok, or YouTube\"
- Button: \"Open Instagram\" (deep link)
- OR: \"Watch Demo Video\" (30-second tutorial)

**Purpose:**
- Clear call-to-action
- Guide to first capture
- Reduce confusion

---

## Implementation

### lib/screens/onboarding_welcome_screen.dart

\`\`\`dart
class OnboardingWelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Image.asset('assets/app_icon.png', width: 120),
              
              const SizedBox(height: 40),
              
              // Headline
              Text(
                'Turn Doomscrolling into\\nOrganized Knowledge',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Subheadline
              Text(
                'Auto-transcribe Instagram, TikTok, and YouTube videos',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Get Started button
              ElevatedButton(
                onPressed: () => _navigateToHowItWorks(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                ),
                child: const Text('Get Started'),
              ),
              
              const SizedBox(height: 20),
              
              // Skip button
              TextButton(
                onPressed: () => _completeOnboarding(context),
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToHowItWorks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OnboardingHowItWorksScreen()),
    );
  }
  
  void _completeOnboarding(BuildContext context) {
    // Set flag: onboarding complete
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    // Navigate to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}
\`\`\`

### lib/screens/onboarding_how_it_works_screen.dart

\`\`\`dart
class OnboardingHowItWorksScreen extends StatelessWidget {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, String>> steps = [
    {
      'icon': '📱',
      'title': 'Find a Video',
      'text': 'Browse Instagram, TikTok, or YouTube',
    },
    {
      'icon': '📤',
      'title': 'Tap Share',
      'text': 'Select DoomNotes from the share sheet',
    },
    {
      'icon': '📁',
      'title': 'Get Organized',
      'text': 'Instant transcript, sorted by topic',
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                steps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Step content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => _currentPage = index,
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(step['icon']!, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 24),
                      Text(
                        step['title']!,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step['text']!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const Spacer(),
            
            // Continue button
            Padding(
              padding: const EdgeInsets.all(40),
              child: ElevatedButton(
                onPressed: _currentPage < steps.length - 1
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : () => _completeOnboarding(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(_currentPage < steps.length - 1 ? 'Continue' : 'Got It'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
\`\`\`

---

## Best Practices

### Do's
- ✅ Keep onboarding under 2 minutes total
- ✅ Use visuals over text
- ✅ Let users skip (some already know what to do)
- ✅ Make it interactive (not just reading)
- ✅ Test with real users (watch where they get confused)

### Don'ts
- ❌ Don't require account creation (huge drop-off)
- ❌ Don't show long text walls
- ❌ Don't make onboarding mandatory (allow skip)
- ❌ Don't ask for permissions upfront (ask when needed)
- ❌ Don't over-explain (let users explore)

---

## Metrics to Track

### Onboarding Completion Rate
\`\`\`
Completion Rate = (Users who complete onboarding) / (Users who start onboarding) × 100

Target: >80%
\`\`\`

### Time to First Capture
\`\`\`
Time to First Capture = Time from app install to first video captured

Target: <60 seconds
\`\`\`

### Activation Rate
\`\`\`
Activation Rate = (Users who capture at least 1 video) / (Total installs) × 100

Target: >60%
\`\`\`

### Day 1 Retention
\`\`\`
Day 1 Retention = (Users who open app next day) / (Users who installed today) × 100

Target: >40%
\`\`\`

---

## A/B Tests to Run

### Test 1: Onboarding vs No Onboarding
- **Hypothesis:** Onboarding increases activation rate
- **Variant A:** No onboarding (go straight to home)
- **Variant B:** Full onboarding flow (4 screens)
- **Metric:** Activation rate (% who capture first video)

### Test 2: Short vs Long Onboarding
- **Hypothesis:** Shorter onboarding = better completion
- **Variant A:** 2 screens (welcome + how it works)
- **Variant B:** 4 screens (full flow)
- **Metric:** Onboarding completion rate

### Test 3: Interactive vs Static
- **Hypothesis:** Interactive tutorial = better retention
- **Variant A:** Static screenshots
- **Variant B:** Interactive (try it now, opens Instagram)
- **Metric:** Day 1 retention

---

## Resources

- \"Don't Make Me Think\" by Steve Krug (UX book)
- \"Hooked\" by Nir Eyal (habit-forming products)
- UX Design CC (YouTube channel for onboarding examples)

---

**Great onboarding can 2-3x your activation rate. Invest time here!** 🎯