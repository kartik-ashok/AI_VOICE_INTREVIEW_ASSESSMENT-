import 'package:flutter/material.dart';
import 'introduction_screens.dart';

class TopicSelectionPage extends StatelessWidget {
  final String subject;

  const TopicSelectionPage({super.key, required this.subject});

  Map<String, List<Map<String, dynamic>>> getTopicsBySubject() {
    return {
      'Data Analysis': [
        {'name': 'DBMS', 'icon': Icons.storage, 'color': Colors.indigo},
        {'name': 'Python', 'icon': Icons.code, 'color': Colors.blue},
        {'name': 'Excel', 'icon': Icons.table_chart, 'color': Colors.green},
        {'name': 'PowerBI', 'icon': Icons.analytics, 'color': Colors.orange},
        {'name': 'All', 'icon': Icons.all_inclusive, 'color': Colors.purple},
      ],
      'Data Scientist': [
        {'name': 'Python', 'icon': Icons.code, 'color': Colors.blue},
        {'name': 'Machine Learning', 'icon': Icons.psychology, 'color': Colors.purple},
        {'name': 'Statistics', 'icon': Icons.trending_up, 'color': Colors.green},
        {'name': 'Big Data', 'icon': Icons.cloud, 'color': Colors.orange},
        {'name': 'All', 'icon': Icons.all_inclusive, 'color': Colors.red},
      ],
      'Business Analyst': [
        {'name': 'Requirements', 'icon': Icons.description, 'color': Colors.blue},
        {'name': 'Process Analysis', 'icon': Icons.account_tree, 'color': Colors.green},
        {'name': 'Documentation', 'icon': Icons.article, 'color': Colors.orange},
        {'name': 'Stakeholder Management', 'icon': Icons.people, 'color': Colors.purple},
        {'name': 'All', 'icon': Icons.all_inclusive, 'color': Colors.indigo},
      ],
      'Software Engineer': [
        {'name': 'Programming', 'icon': Icons.code, 'color': Colors.blue},
        {'name': 'Algorithms', 'icon': Icons.functions, 'color': Colors.green},
        {'name': 'System Design', 'icon': Icons.architecture, 'color': Colors.orange},
        {'name': 'Data Structures', 'icon': Icons.storage, 'color': Colors.purple},
        {'name': 'All', 'icon': Icons.all_inclusive, 'color': Colors.red},
      ],
      'Sales': [
        {'name': 'Communication', 'icon': Icons.chat, 'color': Colors.blue},
        {'name': 'Negotiation', 'icon': Icons.handshake, 'color': Colors.green},
        {'name': 'CRM', 'icon': Icons.people_alt, 'color': Colors.orange},
        {'name': 'Product Knowledge', 'icon': Icons.inventory, 'color': Colors.purple},
        {'name': 'All', 'icon': Icons.all_inclusive, 'color': Colors.indigo},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final topics = getTopicsBySubject()[subject] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('$subject Topics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Choose Your Topic',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Select specific topics for $subject interview',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IntroductionScreens(
                                  subject: subject,
                                  topic: topic['name'] as String,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: topic['color'] as Color,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    topic['icon'] as IconData,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  topic['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
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
} 