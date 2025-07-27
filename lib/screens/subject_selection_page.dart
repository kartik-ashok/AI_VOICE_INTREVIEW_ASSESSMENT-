import 'package:flutter/material.dart';
import 'topic_selection_page.dart';
import '../services/firebase_service.dart';
import 'profile_screen.dart'; // Added import for ProfileScreen

class SubjectSelectionPage extends StatefulWidget {
  const SubjectSelectionPage({super.key});

  @override
  State<SubjectSelectionPage> createState() => _SubjectSelectionPageState();
}

class _SubjectSelectionPageState extends State<SubjectSelectionPage> {
  bool _isLoading = true;
  Map<String, List<String>> _subjectsAndTopics = {};

  @override
  void initState() {
    super.initState();
    _loadSubjectsAndTopics();
  }

  Future<void> _loadSubjectsAndTopics() async {
    try {
      final data = await FirebaseService.getSubjectsAndTopics();
      setState(() {
        _subjectsAndTopics = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'Loading subjects...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final subjects = _subjectsAndTopics.keys.toList();
    
    // Default subjects if Firebase fails
    if (subjects.isEmpty) {
      _subjectsAndTopics = {
        'Data Analysis': ['DBMS', 'Python', 'Excel', 'PowerBI', 'All'],
        'Data Scientist': ['Python', 'Machine Learning', 'Statistics', 'Big Data', 'All'],
        'Business Analyst': ['Requirements', 'Process Analysis', 'Documentation', 'Stakeholder Management', 'All'],
        'Software Engineer': ['Programming', 'Algorithms', 'System Design', 'Data Structures', 'All'],
        'Sales': ['Communication', 'Negotiation', 'CRM', 'Product Knowledge', 'All'],
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Interview Subject'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
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
                    itemCount: _subjectsAndTopics.length,
                    itemBuilder: (context, index) {
                      final subject = _subjectsAndTopics.keys.elementAt(index);
                      final topics = _subjectsAndTopics[subject]!;
                      final description = topics.take(3).join(', ') + (topics.length > 3 ? '...' : '');
                      
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
                                  subject: subject,
                                  topics: topics,
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
                                    color: _getSubjectColor(subject),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getSubjectIcon(subject),
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
                                        subject,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        description,
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

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Data Analysis':
        return Colors.blue;
      case 'Data Scientist':
        return Colors.purple;
      case 'Business Analyst':
        return Colors.green;
      case 'Software Engineer':
        return Colors.orange;
      case 'Sales':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Data Analysis':
        return Icons.analytics;
      case 'Data Scientist':
        return Icons.science;
      case 'Business Analyst':
        return Icons.business;
      case 'Software Engineer':
        return Icons.code;
      case 'Sales':
        return Icons.trending_up;
      default:
        return Icons.school;
    }
  }
} 