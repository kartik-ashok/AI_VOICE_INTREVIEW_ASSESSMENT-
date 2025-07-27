// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SpeechToTextPage extends StatefulWidget {
//   const SpeechToTextPage({super.key});

//   @override
//   _SpeechToTextPageState createState() => _SpeechToTextPageState();
// }

// class _SpeechToTextPageState extends State<SpeechToTextPage> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _text = 'Press the mic and start speaking...';
//   double _confidence = 1.0;

//   // ✅ Predefined list of questions
//   final List<String> _questions = [
//     "What is your name?",
//     "Where are you from?",
//     "What is your favorite hobby?",
//     "What do you want to achieve this year?"
//   ];

//   int _currentQuestionIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }

//   void _listen() async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (status) => print('onStatus: $status'),
//         onError: (error) => print('onError: $error'),
//       );
//       if (available) {
//         setState(() => _isListening = true);
//         _speech.listen(
//           onResult: (result) => setState(() {
//             _text = result.recognizedWords;
//             if (result.hasConfidenceRating && result.confidence > 0) {
//               _confidence = result.confidence;
//             }
//           }),
//         );
//       } else {
//         setState(() => _isListening = false);
//         _speech.stop();
//       }
//     } else {
//       setState(() => _isListening = false);
//       _speech.stop();
//     }
//   }

//   // ✅ Show next question
//   void _nextQuestion() {
//     if (_currentQuestionIndex < _questions.length - 1) {
//       setState(() {
//         _currentQuestionIndex++;
//         _text = "Press mic and answer the question";
//       });
//     } else {
//       setState(() {
//         _text = "🎉 All questions are done!";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Confidence: ${(_confidence * 100).toStringAsFixed(1)}%'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // ✅ Display current question
//             Text(
//               "Q: ${_questions[_currentQuestionIndex]}",
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             // ✅ Show recognized text
//             Expanded(
//               child: SingleChildScrollView(
//                 reverse: true,
//                 child: Text(
//                   _text,
//                   style: const TextStyle(fontSize: 20),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             // ✅ Next question button
//             ElevatedButton(
//               onPressed: _nextQuestion,
//               child: const Text("Next Question"),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: FloatingActionButton(
//         onPressed: _listen,
//         child: Icon(_isListening ? Icons.mic : Icons.mic_none),
//       ),
//     );
//   }
// }
