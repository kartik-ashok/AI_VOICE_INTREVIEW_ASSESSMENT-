import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/interview_result.dart';
import 'subject_selection_page.dart';
import 'profile_screen.dart';

class ThankYouPage extends StatefulWidget {
  final String subject;
  final String topic;
  final List<String> answers;
  final int timeElapsed;

  const ThankYouPage({
    super.key,
    required this.subject,
    required this.topic,
    required this.answers,
    required this.timeElapsed,
  });

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  bool _isSaving = false;
  String? _resultId;

  @override
  void initState() {
    super.initState();
    _saveInterviewResult();
  }

  Future<void> _saveInterviewResult() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        // Create question-answer pairs
        final questions = await FirebaseService.getQuestions(widget.subject, widget.topic);
        final questionAnswers = <QuestionAnswer>[];
        
        for (int i = 0; i < questions.length && i < widget.answers.length; i++) {
          questionAnswers.add(QuestionAnswer(
            question: questions[i],
            userAnswer: widget.answers[i],
          ));
        }

        // Calculate a simple score based on answer length and completeness
        double score = _calculateScore(widget.answers);

        // Create interview result
        final result = InterviewResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          userEmail: user.email ?? '',
          subject: widget.subject,
          topic: widget.topic,
          questions: questionAnswers,
          timeElapsed: widget.timeElapsed,
          completedAt: DateTime.now(),
          score: score,
        );

        // Save to Firestore
        final success = await FirebaseService.saveInterviewResult(result);
        
        if (success) {
          setState(() {
            _resultId = result.id;
            _isSaving = false;
          });
        } else {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  double _calculateScore(List<String> answers) {
    if (answers.isEmpty) return 0.0;
    
    double totalScore = 0.0;
    for (String answer in answers) {
      // Simple scoring based on answer length and content
      double answerScore = 0.0;
      
      if (answer.length > 50) answerScore += 0.3;
      if (answer.length > 100) answerScore += 0.2;
      if (answer.length > 200) answerScore += 0.2;
      
      // Bonus for meaningful content
      if (answer.toLowerCase().contains('because') || 
          answer.toLowerCase().contains('example') ||
          answer.toLowerCase().contains('experience')) {
        answerScore += 0.3;
      }
      
      totalScore += answerScore.clamp(0.0, 1.0);
    }
    
    return (totalScore / answers.length).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Title
                  const Text(
                    'Interview Completed!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Subtitle
                  Text(
                    'Great job completing your ${widget.subject} interview',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Interview Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildSummaryRow('Subject', widget.subject),
                        _buildSummaryRow('Topic', widget.topic),
                        _buildSummaryRow('Questions Answered', '${widget.answers.length}'),
                        _buildSummaryRow('Time Taken', _formatTime(widget.timeElapsed)),
                        
                        if (_isSaving)
                          const Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Saving results...',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SubjectSelectionPage(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Take Another Test',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 15),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 