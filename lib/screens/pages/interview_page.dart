import 'dart:async';
import 'package:ai_voice_intreview/responsiveness.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'thank_you_page.dart';
import '../../services/firebase_service.dart';

class InterviewPage extends StatefulWidget {
  final String subject;
  final String topic;

  const InterviewPage({
    super.key,
    required this.subject,
    required this.topic,
  });

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isRestarting = false;
  String _currentText = '';
  double _confidence = 1.0;
  int _currentQuestionIndex = 0;
  int _timeElapsed = 0;
  Timer? _timer;
  List<String> _answers = [];
  bool _isQuestionRead = false;
  bool _isWaitingForAnswer = false;
  List<String> _questions = [];
  bool _isLoadingQuestions = true;

  // Animation controllers
  late AnimationController _micAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _avatarAnimationController;
  late AnimationController _mouthAnimationController;
  late Animation<double> _micScaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _mouthScaleAnimation;

  // Timer for auto-stop mic after 1 minute
  Timer? _micTimer;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTTS();
    _initializeAnimations();
    _requestPermissions();
    _startTimer();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
    });

    try {
      final questions =
          await FirebaseService.getQuestions(widget.subject, widget.topic);
      setState(() {
        _questions = questions;
        _isLoadingQuestions = false;
      });

      if (questions.isNotEmpty) {
        _readCurrentQuestion();
      } else {
        // No questions found, show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No questions found for this topic'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingQuestions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeSpeech() {
    _speech = stt.SpeechToText();
  }

  void _initializeTTS() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
      // Start listening after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _startListening();
        }
      });
    });
  }

  void _initializeAnimations() {
    _micAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _avatarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _mouthAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _micScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _micAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _avatarScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController,
      curve: Curves.elasticOut,
    ));

    _mouthScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _mouthAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeElapsed++;
      });
    });
  }

  Future<void> _readCurrentQuestion() async {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      _finishInterview();
      return;
    }

    setState(() {
      _isSpeaking = true;
      _isQuestionRead = false;
      _isWaitingForAnswer = false;
    });

    final question = _questions[_currentQuestionIndex];
    await _flutterTts.speak(question);
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    setState(() {
      _isWaitingForAnswer = true;
      _currentText = 'Listening...';
    });

    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
            _micAnimationController.stop();
            _pulseAnimationController.stop();
            _avatarAnimationController.reverse();
            _mouthAnimationController.stop();
          });
          _micTimer?.cancel();

          // Auto-restart listening if it was stopped unexpectedly and we still have time
          if (_micTimer != null && _micTimer!.isActive) {
            setState(() {
              _isRestarting = true;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && !_isListening) {
                setState(() {
                  _isRestarting = false;
                });
                _startListening();
              }
            });
          }
        }
      },
      onError: (error) {
        print('Speech recognition error: $error');
        setState(() {
          _isListening = false;
          _micAnimationController.stop();
          _pulseAnimationController.stop();
          _avatarAnimationController.reverse();
          _mouthAnimationController.stop();
        });
        _micTimer?.cancel();

        // Auto-restart on error if we still have time
        if (_micTimer != null && _micTimer!.isActive) {
          setState(() {
            _isRestarting = true;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_isListening) {
              setState(() {
                _isRestarting = false;
              });
              _startListening();
            }
          });
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _micAnimationController.repeat(reverse: true);
        _pulseAnimationController.repeat(reverse: true);
        _avatarAnimationController.forward();
        _mouthAnimationController.repeat(reverse: true);
      });

      // Start 1-minute timer for auto-stop
      _micTimer = Timer(const Duration(minutes: 1), () {
        if (_isListening) {
          _stopListening();
        }
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            // Use partial results to maintain continuous speech
            if (result.finalResult) {
              _currentText = result.recognizedWords;
            } else {
              // Show partial results while speaking
              _currentText = result.recognizedWords;
            }

            if (result.hasConfidenceRating && result.confidence > 0) {
              _confidence = result.confidence;
            }
          });
        },
        listenFor: const Duration(seconds: 60), // 1 minute total
        pauseFor: const Duration(seconds: 10), // Allow 10 seconds of pause
        partialResults: true, // Enable partial results
        cancelOnError: false, // Don't cancel on minor errors
        listenMode: stt.ListenMode.confirmation, // More forgiving mode
      );
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _micAnimationController.stop();
        _pulseAnimationController.stop();
        _avatarAnimationController.reverse();
        _mouthAnimationController.stop();
      });
      _micTimer?.cancel();
    }
  }

  void _nextQuestion() {
    // Save current answer
    if (_currentText.isNotEmpty && _currentText != 'Listening...') {
      _answers.add(_currentText);
    }

    setState(() {
      _currentQuestionIndex++;
      _currentText = '';
      _isQuestionRead = false;
      _isWaitingForAnswer = false;
    });

    if (_questions.isNotEmpty && _currentQuestionIndex < _questions.length) {
      _readCurrentQuestion();
    } else {
      _finishInterview();
    }
  }

  void _finishInterview() {
    _timer?.cancel();
    _micTimer?.cancel();
    _stopListening();
    _flutterTts.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ThankYouPage(
          subject: widget.subject,
          topic: widget.topic,
          answers: _answers,
          timeElapsed: _timeElapsed,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildAnimatedAvatar() {
    return AnimatedBuilder(
      animation: _avatarScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _avatarScaleAnimation.value,
          child: Container(
            width: ResponsiveSize.width(120),
            height: ResponsiveSize.height(120),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: ResponsiveSize.width(20),
                  spreadRadius: ResponsiveSize.width(5),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Face
                Container(
                  width: ResponsiveSize.width(100),
                  height: ResponsiveSize.height(100),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                ),
                // Eyes
                Positioned(
                  top: ResponsiveSize.height(30),
                  left: ResponsiveSize.width(25),
                  child: Container(
                    width: ResponsiveSize.width(8),
                    height: ResponsiveSize.height(8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: ResponsiveSize.height(30),
                  right: ResponsiveSize.width(25),
                  child: Container(
                    width: ResponsiveSize.width(8),
                    height: ResponsiveSize.height(8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Animated mouth
                Positioned(
                  bottom: ResponsiveSize.height(25),
                  child: AnimatedBuilder(
                    animation: _mouthScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _mouthScaleAnimation.value,
                        child: Container(
                          width: ResponsiveSize.width(20),
                          height: ResponsiveSize.height(12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                                BorderRadius.circular(ResponsiveSize.width(10)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Speech waves
                if (_isListening)
                  ...List.generate(3, (index) {
                    return Positioned(
                      right: ResponsiveSize.width(-20 - (index * 15)),
                      top: ResponsiveSize.height(40 + (index * 10)),
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value * (1 - index * 0.2),
                            child: Container(
                              width: ResponsiveSize.width(8),
                              height: ResponsiveSize.height(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion =
        _questions.isNotEmpty && _currentQuestionIndex < _questions.length
            ? _questions[_currentQuestionIndex]
            : '';

    // Show loading screen while fetching questions
    if (_isLoadingQuestions) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subject} - ${widget.topic}'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.red],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: ResponsiveSize.height(20)),
                Text(
                  'Loading questions...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveSize.font(18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} - ${widget.topic}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: ResponsiveSize.width(16)),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSize.width(12),
              vertical: ResponsiveSize.height(6),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ResponsiveSize.width(20)),
            ),
            child: Text(
              _formatTime(_timeElapsed),
              style: TextStyle(
                fontSize: ResponsiveSize.font(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Color.fromARGB(255, 233, 171, 166)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: EdgeInsets.all(ResponsiveSize.width(20)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveSize.font(16),
                          ),
                        ),
                        Text(
                          'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveSize.font(16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveSize.height(10)),
                    LinearProgressIndicator(
                      value: _questions.isNotEmpty
                          ? (_currentQuestionIndex + 1) / _questions.length
                          : 0.0,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),

              // Animated Avatar (when listening)
              if (_isListening)
                Container(
                  margin:
                      EdgeInsets.symmetric(vertical: ResponsiveSize.height(20)),
                  child: _buildAnimatedAvatar(),
                ),

              // Question display
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(ResponsiveSize.width(20)),
                  padding: EdgeInsets.all(ResponsiveSize.width(30)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(ResponsiveSize.width(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: ResponsiveSize.width(10),
                        spreadRadius: ResponsiveSize.width(2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Question
                      Text(
                        'Question ${_currentQuestionIndex + 1}',
                        style: TextStyle(
                          fontSize: ResponsiveSize.font(18),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: ResponsiveSize.height(20)),

                      Expanded(
                        child: Center(
                          child: Text(
                            currentQuestion.isNotEmpty
                                ? currentQuestion
                                : 'Loading question...',
                            style: TextStyle(
                              fontSize: ResponsiveSize.font(24),
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Status indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSpeaking)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveSize.width(12),
                                vertical: ResponsiveSize.height(6),
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.blue, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(
                                    ResponsiveSize.width(15)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.volume_up,
                                    color: Colors.white,
                                    size: ResponsiveSize.width(16),
                                  ),
                                  SizedBox(width: ResponsiveSize.width(5)),
                                  Text(
                                    'Reading Question',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveSize.font(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isWaitingForAnswer && !_isSpeaking)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveSize.width(12),
                                vertical: ResponsiveSize.height(6),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(
                                    ResponsiveSize.width(15)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                    size: ResponsiveSize.width(16),
                                  ),
                                  SizedBox(width: ResponsiveSize.width(5)),
                                  Text(
                                    'Ready to Listen',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveSize.font(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(width: ResponsiveSize.width(6)),
                          if (_isListening)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveSize.width(12),
                                vertical: ResponsiveSize.height(6),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(
                                    ResponsiveSize.width(15)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.record_voice_over,
                                    color: Colors.white,
                                    size: ResponsiveSize.width(16),
                                  ),
                                  SizedBox(width: ResponsiveSize.width(2)),
                                  Flexible(
                                    // 👈 This allows the text to wrap instead of overflowing
                                    child: Text(
                                      'Listening',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ResponsiveSize.font(12),
                                          overflow: TextOverflow.ellipsis),
                                      overflow: TextOverflow
                                          .ellipsis, // 👈 optional, trims if no space
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isRestarting)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveSize.width(12),
                                vertical: ResponsiveSize.height(6),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(
                                    ResponsiveSize.width(15)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: ResponsiveSize.width(16),
                                  ),
                                  SizedBox(width: ResponsiveSize.width(10)),
                                  Text(
                                    'Restarting...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveSize.font(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: ResponsiveSize.height(10),
                      ),
                      InkWell(
                        onTap: () {
                          // Call the next question method to skip the current question
                          _nextQuestion();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveSize.width(12),
                            vertical: ResponsiveSize.height(6),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius:
                                BorderRadius.circular(ResponsiveSize.width(15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: ResponsiveSize.width(16),
                              ),
                              SizedBox(width: ResponsiveSize.width(10)),
                              Text(
                                'Skip Question',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveSize.font(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Answer display
              if (_currentText.isNotEmpty && _currentText != 'Listening...')
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveSize.width(20),
                  ),
                  padding: EdgeInsets.all(ResponsiveSize.width(20)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius:
                        BorderRadius.circular(ResponsiveSize.width(15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Answer:',
                        style: TextStyle(
                          fontSize: ResponsiveSize.font(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: ResponsiveSize.height(10)),
                      Text(
                        _currentText,
                        style: TextStyle(
                          fontSize: ResponsiveSize.font(16),
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

              // Control buttons
              Padding(
                padding: EdgeInsets.all(ResponsiveSize.width(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Manual mic button
                    FloatingActionButton(
                      onPressed: _isWaitingForAnswer ? _startListening : null,
                      backgroundColor:
                          _isWaitingForAnswer ? Colors.green : Colors.grey,
                      child: const Icon(Icons.mic),
                    ),

                    // Stop listening button
                    if (_isListening)
                      FloatingActionButton(
                        onPressed: _stopListening,
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.stop),
                      ),

                    // Next question button
                    if (_currentText.isNotEmpty &&
                        _currentText != 'Listening...')
                      Container(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: _nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveSize.width(30),
                                  vertical: ResponsiveSize.height(15),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ResponsiveSize.width(25)),
                                ),
                              ),
                              child: Text(
                                'Next Question',
                                style: TextStyle(
                                  fontSize: ResponsiveSize.font(16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.all(ResponsiveSize.width(20)),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       // Manual mic button
              //       FloatingActionButton(
              //         onPressed: _isWaitingForAnswer ? _startListening : null,
              //         backgroundColor:
              //             _isWaitingForAnswer ? Colors.green : Colors.grey,
              //         child: const Icon(Icons.mic),
              //       ),

              //       // Stop listening button
              //       if (_isListening)
              //         FloatingActionButton(
              //           onPressed: _stopListening,
              //           backgroundColor: Colors.red,
              //           child: const Icon(Icons.stop),
              //         ),

              //       // Next question button
              //       if (_currentText.isNotEmpty &&
              //           _currentText != 'Listening...')
              //         ElevatedButton(
              //           onPressed: _nextQuestion,
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: Colors.white,
              //             foregroundColor: Colors.blue,
              //             padding: EdgeInsets.symmetric(
              //               horizontal: ResponsiveSize.width(30),
              //               vertical: ResponsiveSize.height(15),
              //             ),
              //             shape: RoundedRectangleBorder(
              //               borderRadius:
              //                   BorderRadius.circular(ResponsiveSize.width(25)),
              //             ),
              //           ),
              //           child: Text(
              //             'Next Question',
              //             style: TextStyle(
              //               fontSize: ResponsiveSize.font(16),
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _micTimer?.cancel();
    _micAnimationController.dispose();
    _pulseAnimationController.dispose();
    _avatarAnimationController.dispose();
    _mouthAnimationController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
