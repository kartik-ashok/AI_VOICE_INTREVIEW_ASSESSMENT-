import 'package:flutter/material.dart';
import 'topic_selection_page.dart';

class SubjectSelectionPage extends StatelessWidget {
  const SubjectSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {
        'name': 'Data Analysis',
        'icon': Icons.analytics,
        'color': Colors.blue,
        'description': 'Excel, SQL, PowerBI, Statistics'
      },
      {
        'name': 'Data Scientist',
        'icon': Icons.science,
        'color': Colors.purple,
        'description': 'Python, ML, Statistics, Big Data'
      },
      {
        'name': 'Business Analyst',
        'icon': Icons.business,
        'color': Colors.green,
        'description': 'Requirements, Process Analysis, Documentation'
      },
      {
        'name': 'Software Engineer',
        'icon': Icons.code,
        'color': Colors.orange,
        'description': 'Programming, Algorithms, System Design'
      },
      {
        'name': 'Sales',
        'icon': Icons.trending_up,
        'color': Colors.red,
        'description': 'Communication, Negotiation, CRM'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Interview Subject'),
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
              const Text(
                'Select Your Interview Subject',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose the field you want to be interviewed in',
                style: TextStyle(
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TopicSelectionPage(
                                  subject: subject['name'] as String,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: subject['color'] as Color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    subject['icon'] as IconData,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        subject['description'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
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