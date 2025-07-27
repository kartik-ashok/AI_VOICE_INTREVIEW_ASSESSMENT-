 import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/interview_result.dart';
import 'test_detail_screen.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  bool _isLoading = true;
  List<InterviewResult> _allResults = [];
  List<InterviewResult> _filteredResults = [];
  String _selectedSubject = 'All';
  String _selectedTopic = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTestHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTestHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        final results = await FirebaseService.getUserInterviewResults(user.uid);
        setState(() {
          _allResults = results;
          _filteredResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterResults() {
    setState(() {
      _filteredResults = _allResults.where((result) {
        bool matchesSubject = _selectedSubject == 'All' || result.subject == _selectedSubject;
        bool matchesTopic = _selectedTopic == 'All' || result.topic == _selectedTopic;
        bool matchesSearch = _searchController.text.isEmpty ||
            result.subject.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            result.topic.toLowerCase().contains(_searchController.text.toLowerCase());

        return matchesSubject && matchesTopic && matchesSearch;
      }).toList();
    });
  }

  List<String> get _subjects {
    final subjects = _allResults.map((r) => r.subject).toSet().toList();
    subjects.sort();
    return ['All', ...subjects];
  }

  List<String> get _topics {
    final topics = _allResults
        .where((r) => _selectedSubject == 'All' || r.subject == _selectedSubject)
        .map((r) => r.topic)
        .toSet()
        .toList();
    topics.sort();
    return ['All', ...topics];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History'),
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
              // Search and Filter Section
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by subject or topic...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (value) => _filterResults(),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Filters
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSubject,
                            decoration: InputDecoration(
                              labelText: 'Subject',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: _subjects.map((subject) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Text(subject),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubject = value!;
                                _selectedTopic = 'All';
                              });
                              _filterResults();
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 10),
                        
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedTopic,
                            decoration: InputDecoration(
                              labelText: 'Topic',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: _topics.map((topic) {
                              return DropdownMenuItem<String>(
                                value: topic,
                                child: Text(topic),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTopic = value!;
                              });
                              _filterResults();
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Results Count
                    Text(
                      '${_filteredResults.length} test${_filteredResults.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Results List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _filteredResults.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 80,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'No tests found',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Try adjusting your filters',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _filteredResults.length,
                              itemBuilder: (context, index) {
                                final result = _filteredResults[index];
                                return _buildTestCard(result);
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

  Widget _buildTestCard(InterviewResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSubjectColor(result.subject),
          child: Text(
            result.subject.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${result.subject} - ${result.topic}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.score,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Score: ${(result.score * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Time: ${_formatTime(result.timeElapsed)}',
                  style: TextStyle(
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${result.completedAt.day}/${result.completedAt.month}/${result.completedAt.year}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestDetailScreen(result: result),
              ),
            );
          },
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

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}