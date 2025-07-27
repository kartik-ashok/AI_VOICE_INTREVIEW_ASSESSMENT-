import 'package:flutter/material.dart';
import 'interview_page.dart';

class IntroductionScreens extends StatefulWidget {
  final String subject;
  final String topic;

  const IntroductionScreens({
    super.key,
    required this.subject,
    required this.topic,
  });

  @override
  State<IntroductionScreens> createState() => _IntroductionScreensState();
}

class _IntroductionScreensState extends State<IntroductionScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<Map<String, dynamic>> _instructions;

  @override
  void initState() {
    super.initState();
    _instructions = [
      {
        'title': 'Welcome to Your AI Interview!',
        'description':
            'Get ready for an interactive interview experience with AI-powered questions and voice recognition.',
        'icon': Icons.mic,
        'color': Colors.pink,
      },
      {
        'title': 'How It Works',
        'description':
            '1. Listen to the question carefully\n2. Wait for the mic to activate\n3. Speak your answer clearly\n4. Your response will be recorded',
        'icon': Icons.record_voice_over,
        'color': Colors.green,
      },
      {
        'title': 'Ready to Start?',
        'description':
            'You\'ll be asked 10 questions about ${widget.topic} in ${widget.subject}. Take your time and speak clearly!',
        'icon': Icons.play_arrow,
        'color': Colors.orange,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.red],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: List.generate(
                    _instructions.length,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage >= index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _instructions.length,
                  itemBuilder: (context, index) {
                    final instruction = _instructions[index];
                    return Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: instruction['color'] as Color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: instruction['color'] as Color,
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              instruction['icon'] as IconData,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Title
                          Text(
                            instruction['title'] as String,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Description
                          Text(
                            instruction['description'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button
                    if (_currentPage < _instructions.length - 1)
                      TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            _instructions.length - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),

                    // Next/Start button
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _instructions.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Start the interview
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InterviewPage(
                                subject: widget.subject,
                                topic: widget.topic,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        _currentPage < _instructions.length - 1
                            ? 'Next'
                            : 'Start Interview',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
