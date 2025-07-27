import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  String _selectedSubject = 'Data Analysis';
  String _selectedTopic = 'DBMS';
  bool _isLoading = false;
  List<String> _questions = [];

  final List<String> _subjects = [
    'Data Analysis',
    'Data Scientist',
    'Business Analyst',
    'Software Engineer',
    'Sales',
  ];

  final Map<String, List<String>> _topicsBySubject = {
    'Data Analysis': ['DBMS', 'Python', 'Excel', 'PowerBI', 'All'],
    'Data Scientist': [
      'Python',
      'Machine Learning',
      'Statistics',
      'Big Data',
      'All'
    ],
    'Business Analyst': [
      'Requirements',
      'Process Analysis',
      'Documentation',
      'Stakeholder Management',
      'All'
    ],
    'Software Engineer': [
      'Programming',
      'Algorithms',
      'System Design',
      'Data Structures',
      'All'
    ],
    'Sales': [
      'Communication',
      'Negotiation',
      'CRM',
      'Product Knowledge',
      'All'
    ],
  };

  @override
  void initState() {
    super.initState();
    _updateTopics();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _updateTopics() {
    setState(() {
      _selectedTopic = _topicsBySubject[_selectedSubject]!.first;
    });
  }

  void _addQuestion() {
    if (_questionController.text.trim().isNotEmpty) {
      setState(() {
        _questions.add(_questionController.text.trim());
        _questionController.clear();
      });
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuestions() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await FirebaseService.addQuestions(
        _selectedSubject,
        _selectedTopic,
        _questions,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${_questions.length} questions added successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _questions.clear();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add questions'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.admin_panel_settings,
                          size: 50,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Welcome, ${FirebaseService.currentUser?.email ?? 'Admin'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Add questions to the database',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Question Form
                Expanded(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Questions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Subject Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedSubject,
                              decoration: InputDecoration(
                                labelText: 'Subject',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: _subjects.map((String subject) {
                                return DropdownMenuItem<String>(
                                  value: subject,
                                  child: Text(subject),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSubject = newValue!;
                                  _updateTopics();
                                });
                              },
                            ),

                            const SizedBox(height: 15),

                            // Topic Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedTopic,
                              decoration: InputDecoration(
                                labelText: 'Topic',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: _topicsBySubject[_selectedSubject]!
                                  .map((String topic) {
                                return DropdownMenuItem<String>(
                                  value: topic,
                                  child: Text(topic),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTopic = newValue!;
                                });
                              },
                            ),

                            const SizedBox(height: 15),

                            // Question Input
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _questionController,
                                    decoration: InputDecoration(
                                      labelText: 'Question',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter a question';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _addQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Questions List
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Questions (${_questions.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: _questions.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No questions added yet',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: _questions.length,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                margin: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: ListTile(
                                                  title: Text(
                                                    _questions[index],
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    onPressed: () =>
                                                        _removeQuestion(index),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading || _questions.isEmpty
                                    ? null
                                    : _saveQuestions,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Save Questions',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
