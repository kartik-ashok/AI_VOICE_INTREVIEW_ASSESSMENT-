// //

// import 'package:ai_voice_intreview/responsiveness.dart';
// import 'package:flutter/material.dart';
// import 'interview_page.dart';

// // Assuming you already have ResponsiveSize class with width, height, and font methods.

// class IntroductionScreens extends StatefulWidget {
//   final String subject;
//   final String topic;

//   const IntroductionScreens({
//     super.key,
//     required this.subject,
//     required this.topic,
//   });

//   @override
//   State<IntroductionScreens> createState() => _IntroductionScreensState();
// }

// class _IntroductionScreensState extends State<IntroductionScreens> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   late final List<Map<String, dynamic>> _instructions;

//   @override
//   void initState() {
//     super.initState();
//     _instructions = [
//       {
//         'title': 'Welcome to Your AI Interview!',
//         'description':
//             'Get ready for an interactive interview experience with AI-powered questions and voice recognition.',
//         'icon': Icons.mic,
//         'color': Colors.pink,
//       },
//       {
//         'title': 'How It Works',
//         'description':
//             '1. Listen to the question carefully\n2. Wait for the mic to activate\n3. Speak your answer clearly\n4. Your response will be recorded',
//         'icon': Icons.record_voice_over,
//         'color': Colors.green,
//       },
//       {
//         'title': 'Ready to Start?',
//         'description':
//             'You\'ll be asked 10 questions about ${widget.topic} in ${widget.subject}. Take your time and speak clearly!',
//         'icon': Icons.play_arrow,
//         'color': Colors.orange,
//       },
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue, Colors.red],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Progress indicator
//               Padding(
//                 padding: EdgeInsets.all(ResponsiveSize.height(20)),
//                 child: Row(
//                   children: List.generate(
//                     _instructions.length,
//                     (index) => Expanded(
//                       child: Container(
//                         height: ResponsiveSize.height(4),
//                         margin: EdgeInsets.symmetric(
//                           horizontal: ResponsiveSize.width(4),
//                         ),
//                         decoration: BoxDecoration(
//                           color: _currentPage >= index
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.3),
//                           borderRadius:
//                               BorderRadius.circular(ResponsiveSize.width(2)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Page content
//               Expanded(
//                 child: PageView.builder(
//                   controller: _pageController,
//                   onPageChanged: (index) {
//                     setState(() {
//                       _currentPage = index;
//                     });
//                   },
//                   itemCount: _instructions.length,
//                   itemBuilder: (context, index) {
//                     final instruction = _instructions[index];
//                     return Padding(
//                       padding: EdgeInsets.all(ResponsiveSize.width(30)),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Icon
//                           Container(
//                             width: ResponsiveSize.width(120),
//                             height: ResponsiveSize.height(120),
//                             decoration: BoxDecoration(
//                               color: instruction['color'] as Color,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: instruction['color'] as Color,
//                                   blurRadius: ResponsiveSize.width(20),
//                                   spreadRadius: ResponsiveSize.width(5),
//                                 ),
//                               ],
//                             ),
//                             child: Icon(
//                               instruction['icon'] as IconData,
//                               size: ResponsiveSize.width(60),
//                               color: Colors.white,
//                             ),
//                           ),

//                           SizedBox(height: ResponsiveSize.height(40)),

//                           // Title
//                           Text(
//                             instruction['title'] as String,
//                             style: TextStyle(
//                               fontSize: ResponsiveSize.font(28),
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),

//                           SizedBox(height: ResponsiveSize.height(20)),

//                           // Description
//                           Text(
//                             instruction['description'] as String,
//                             style: TextStyle(
//                               fontSize: ResponsiveSize.font(18),
//                               color: Colors.white,
//                               height: 1.5,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               // Navigation buttons
//               Padding(
//                 padding: EdgeInsets.all(ResponsiveSize.height(30)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Skip button
//                     if (_currentPage < _instructions.length - 1)
//                       TextButton(
//                         onPressed: () {
//                           _pageController.animateToPage(
//                             _instructions.length - 1,
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                           );
//                         },
//                         child: Text(
//                           'Skip',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: ResponsiveSize.font(16),
//                           ),
//                         ),
//                       )
//                     else
//                       SizedBox(width: ResponsiveSize.width(80)),

//                     // Next/Start button
//                     ElevatedButton(
//                       onPressed: () {
//                         if (_currentPage < _instructions.length - 1) {
//                           _pageController.nextPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                           );
//                         } else {
//                           // Start the interview
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => InterviewPage(
//                                 subject: widget.subject,
//                                 topic: widget.topic,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.blue,
//                         padding: EdgeInsets.symmetric(
//                           horizontal: ResponsiveSize.width(30),
//                           vertical: ResponsiveSize.height(15),
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(ResponsiveSize.width(25)),
//                         ),
//                       ),
//                       child: Text(
//                         _currentPage < _instructions.length - 1
//                             ? 'Next'
//                             : 'Start Interview',
//                         style: TextStyle(
//                           fontSize: ResponsiveSize.font(16),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }

import 'package:ai_voice_intreview/responsiveness.dart';
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
                padding: EdgeInsets.all(ResponsiveSize.height(20)),
                child: Row(
                  children: List.generate(
                    _instructions.length,
                    (index) => Expanded(
                      child: Container(
                        height: ResponsiveSize.height(4),
                        margin: EdgeInsets.symmetric(
                          horizontal: ResponsiveSize.width(4),
                        ),
                        decoration: BoxDecoration(
                          color: _currentPage >= index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius:
                              BorderRadius.circular(ResponsiveSize.width(2)),
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
                      padding: EdgeInsets.all(ResponsiveSize.width(30)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            width: ResponsiveSize.width(120),
                            height: ResponsiveSize.height(120),
                            decoration: BoxDecoration(
                              color: instruction['color'] as Color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: instruction['color'] as Color,
                                  blurRadius: ResponsiveSize.width(20),
                                  spreadRadius: ResponsiveSize.width(5),
                                ),
                              ],
                            ),
                            child: Icon(
                              instruction['icon'] as IconData,
                              size: ResponsiveSize.width(60),
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: ResponsiveSize.height(40)),

                          // Title
                          Text(
                            instruction['title'] as String,
                            style: TextStyle(
                              fontSize: ResponsiveSize.font(28),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: ResponsiveSize.height(20)),

                          // Description
                          Text(
                            instruction['description'] as String,
                            style: TextStyle(
                              fontSize: ResponsiveSize.font(18),
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
                padding: EdgeInsets.all(ResponsiveSize.height(30)),
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
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveSize.font(16),
                          ),
                        ),
                      )
                    else
                      SizedBox(width: ResponsiveSize.width(80)),

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
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveSize.width(30),
                          vertical: ResponsiveSize.height(15),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ResponsiveSize.width(25)),
                        ),
                      ),
                      child: Text(
                        _currentPage < _instructions.length - 1
                            ? 'Next'
                            : 'Start Interview',
                        style: TextStyle(
                          fontSize: ResponsiveSize.font(16),
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
