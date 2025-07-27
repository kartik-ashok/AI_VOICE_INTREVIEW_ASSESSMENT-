// import 'package:flutter/material.dart';
// import 'introduction_screens.dart';

// class TopicSelectionPage extends StatelessWidget {
//   final String subject;
//   final List<String> topics;

//   const TopicSelectionPage(
//       {super.key, required this.subject, required this.topics});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$subject Topics'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
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
//               const SizedBox(height: 20),
//               const Text(
//                 'Choose Your Topic',
//                 style: const TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Select specific topics for $subject interview',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.white70,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     padding: const EdgeInsets.all(20),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 15,
//                       mainAxisSpacing: 15,
//                       childAspectRatio: 1.1,
//                     ),
//                     itemCount: topics.length,
//                     itemBuilder: (context, index) {
//                       final topic = topics[index];
//                       return Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => IntroductionScreens(
//                                   subject: subject,
//                                   topic: topic,
//                                 ),
//                               ),
//                             );
//                           },
//                           borderRadius: BorderRadius.circular(15),
//                           child: Padding(
//                             padding: const EdgeInsets.all(15),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(15),
//                                   decoration: BoxDecoration(
//                                     color: _getTopicColor(topic),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   child: Icon(
//                                     _getTopicIcon(topic),
//                                     color: Colors.white,
//                                     size: 35,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 15),
//                                 Text(
//                                   topic,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getTopicColor(String topic) {
//     switch (topic) {
//       case 'DBMS':
//       case 'Python':
//       case 'Requirements':
//       case 'Programming':
//       case 'Communication':
//         return Colors.blue;
//       case 'Excel':
//       case 'Machine Learning':
//       case 'Process Analysis':
//       case 'Algorithms':
//       case 'Negotiation':
//         return Colors.green;
//       case 'PowerBI':
//       case 'Big Data':
//       case 'Documentation':
//       case 'System Design':
//       case 'CRM':
//         return Colors.orange;
//       case 'Statistics':
//       case 'Stakeholder Management':
//       case 'Data Structures':
//       case 'Product Knowledge':
//         return Colors.purple;
//       case 'All':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getTopicIcon(String topic) {
//     switch (topic) {
//       case 'DBMS':
//         return Icons.storage;
//       case 'Python':
//         return Icons.code;
//       case 'Excel':
//         return Icons.table_chart;
//       case 'PowerBI':
//         return Icons.analytics;
//       case 'Machine Learning':
//         return Icons.psychology;
//       case 'Statistics':
//         return Icons.trending_up;
//       case 'Big Data':
//         return Icons.cloud;
//       case 'Requirements':
//         return Icons.description;
//       case 'Process Analysis':
//         return Icons.account_tree;
//       case 'Documentation':
//         return Icons.article;
//       case 'Stakeholder Management':
//         return Icons.people;
//       case 'Programming':
//         return Icons.code;
//       case 'Algorithms':
//         return Icons.functions;
//       case 'System Design':
//         return Icons.architecture;
//       case 'Data Structures':
//         return Icons.storage;
//       case 'Communication':
//         return Icons.chat;
//       case 'Negotiation':
//         return Icons.handshake;
//       case 'CRM':
//         return Icons.people_alt;
//       case 'Product Knowledge':
//         return Icons.inventory;
//       case 'All':
//         return Icons.all_inclusive;
//       default:
//         return Icons.topic;
//     }
//   }
// }

import 'package:ai_voice_intreview/responsiveness.dart';
import 'package:flutter/material.dart';
import 'introduction_screens.dart';

class TopicSelectionPage extends StatelessWidget {
  final String subject;
  final List<String> topics;

  const TopicSelectionPage(
      {super.key, required this.subject, required this.topics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$subject Topics',
          style: TextStyle(fontSize: ResponsiveSize.font(18)),
        ),
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
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: ResponsiveSize.height(20)),
              Text(
                'Choose Your Topic',
                style: TextStyle(
                  fontSize: ResponsiveSize.font(28),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSize.height(10)),
              Text(
                'Select specific topics for $subject interview',
                style: TextStyle(
                  fontSize: ResponsiveSize.font(16),
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSize.height(30)),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ResponsiveSize.width(30)),
                      topRight: Radius.circular(ResponsiveSize.width(30)),
                    ),
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.all(ResponsiveSize.width(20)),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ResponsiveSize.width(15),
                      mainAxisSpacing: ResponsiveSize.height(15),
                      childAspectRatio: 1.1,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ResponsiveSize.width(15)),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IntroductionScreens(
                                  subject: subject,
                                  topic: topic,
                                ),
                              ),
                            );
                          },
                          borderRadius:
                              BorderRadius.circular(ResponsiveSize.width(15)),
                          child: Padding(
                            padding: EdgeInsets.all(ResponsiveSize.width(15)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.all(ResponsiveSize.width(15)),
                                  decoration: BoxDecoration(
                                    color: _getTopicColor(topic),
                                    borderRadius: BorderRadius.circular(
                                        ResponsiveSize.width(15)),
                                  ),
                                  child: Icon(
                                    _getTopicIcon(topic),
                                    color: Colors.white,
                                    size: ResponsiveSize.width(35),
                                  ),
                                ),
                                SizedBox(height: ResponsiveSize.height(15)),
                                Text(
                                  topic,
                                  style: TextStyle(
                                    fontSize: ResponsiveSize.font(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTopicColor(String topic) {
    switch (topic) {
      case 'DBMS':
      case 'Python':
      case 'Requirements':
      case 'Programming':
      case 'Communication':
        return Colors.blue;
      case 'Excel':
      case 'Machine Learning':
      case 'Process Analysis':
      case 'Algorithms':
      case 'Negotiation':
        return Colors.green;
      case 'PowerBI':
      case 'Big Data':
      case 'Documentation':
      case 'System Design':
      case 'CRM':
        return Colors.orange;
      case 'Statistics':
      case 'Stakeholder Management':
      case 'Data Structures':
      case 'Product Knowledge':
        return Colors.purple;
      case 'All':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTopicIcon(String topic) {
    switch (topic) {
      case 'DBMS':
        return Icons.storage;
      case 'Python':
        return Icons.code;
      case 'Excel':
        return Icons.table_chart;
      case 'PowerBI':
        return Icons.analytics;
      case 'Machine Learning':
        return Icons.psychology;
      case 'Statistics':
        return Icons.trending_up;
      case 'Big Data':
        return Icons.cloud;
      case 'Requirements':
        return Icons.description;
      case 'Process Analysis':
        return Icons.account_tree;
      case 'Documentation':
        return Icons.article;
      case 'Stakeholder Management':
        return Icons.people;
      case 'Programming':
        return Icons.code;
      case 'Algorithms':
        return Icons.functions;
      case 'System Design':
        return Icons.architecture;
      case 'Data Structures':
        return Icons.storage;
      case 'Communication':
        return Icons.chat;
      case 'Negotiation':
        return Icons.handshake;
      case 'CRM':
        return Icons.people_alt;
      case 'Product Knowledge':
        return Icons.inventory;
      case 'All':
        return Icons.all_inclusive;
      default:
        return Icons.topic;
    }
  }
}
