import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/interview_result.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static CollectionReference get questionsCollection => 
      _firestore.collection('questions');
  
  static CollectionReference get usersCollection => 
      _firestore.collection('users');

  static CollectionReference get interviewResultsCollection => 
      _firestore.collection('interview_results');

  // Authentication methods
  static Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is admin
  static bool isAdmin(String email) {
    return email == 'admin1@mailinator.com' || email == 'admin2@mailinator.com';
  }

  // Questions methods with fallback indicator
  static Future<Map<String, dynamic>> getQuestionsWithFallback(String subject, String topic) async {
    try {
      QuerySnapshot querySnapshot;
      
      if (topic == 'All') {
        // Get all questions for the subject
        querySnapshot = await questionsCollection
            .where('subject', isEqualTo: subject)
            .get();
      } else {
        // Get questions for specific subject and topic
        querySnapshot = await questionsCollection
            .where('subject', isEqualTo: subject)
            .where('topic', isEqualTo: topic)
            .get();
      }

      List<String> questions = [];
      for (var doc in querySnapshot.docs) {
        questions.add(doc['question'] as String);
      }

      bool usedFallback = false;
      
      // If no questions found in Firestore, use default questions
      if (questions.isEmpty) {
        print('No questions found in Firestore for $subject - $topic, using default questions');
        questions = _getDefaultQuestions(subject, topic);
        usedFallback = true;
      }

      // Shuffle questions to randomize order
      questions.shuffle();
      
      // Return maximum 10 questions with fallback indicator
      return {
        'questions': questions.take(10).toList(),
        'usedFallback': usedFallback,
      };
    } catch (e) {
      print('Error fetching questions from Firestore: $e');
      print('Using default questions for $subject - $topic');
      List<String> fallbackQuestions = _getDefaultQuestions(subject, topic);
      fallbackQuestions.shuffle();
      return {
        'questions': fallbackQuestions.take(10).toList(),
        'usedFallback': true,
      };
    }
  }

  // Questions methods
  static Future<List<String>> getQuestions(String subject, String topic) async {
    try {
      QuerySnapshot querySnapshot;
      
      if (topic == 'All') {
        // Get all questions for the subject
        querySnapshot = await questionsCollection
            .where('subject', isEqualTo: subject)
            .get();
      } else {
        // Get questions for specific subject and topic
        querySnapshot = await questionsCollection
            .where('subject', isEqualTo: subject)
            .where('topic', isEqualTo: topic)
            .get();
      }

      List<String> questions = [];
      for (var doc in querySnapshot.docs) {
        questions.add(doc['question'] as String);
      }

      // If no questions found in Firestore, use default questions
      if (questions.isEmpty) {
        print('No questions found in Firestore for $subject - $topic, using default questions');
        questions = _getDefaultQuestions(subject, topic);
      }

      // Shuffle questions to randomize order
      questions.shuffle();
      
      // Return maximum 10 questions
      return questions.take(10).toList();
    } catch (e) {
      print('Error fetching questions from Firestore: $e');
      print('Using default questions for $subject - $topic');
      return _getDefaultQuestions(subject, topic);
    }
  }

  // Add questions (admin only)
  static Future<bool> addQuestions(String subject, String topic, List<String> questions) async {
    try {
      // Check if current user is admin
      User? user = currentUser;
      if (user == null || !isAdmin(user.email!)) {
        print('Unauthorized: Only admins can add questions');
        return false;
      }

      // Add each question to Firestore
      for (String question in questions) {
        await questionsCollection.add({
          'subject': subject,
          'topic': topic,
          'question': question,
          'createdBy': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Error adding questions: $e');
      return false;
    }
  }

  // Get all subjects and topics
  static Future<Map<String, List<String>>> getSubjectsAndTopics() async {
    try {
      QuerySnapshot querySnapshot = await questionsCollection.get();
      
      Map<String, Set<String>> subjectsMap = {};
      
      for (var doc in querySnapshot.docs) {
        String subject = doc['subject'] as String;
        String topic = doc['topic'] as String;
        
        if (!subjectsMap.containsKey(subject)) {
          subjectsMap[subject] = <String>{};
        }
        subjectsMap[subject]!.add(topic);
      }

      // Convert Set to List
      Map<String, List<String>> result = {};
      subjectsMap.forEach((subject, topics) {
        result[subject] = topics.toList()..sort();
      });

      return result;
    } catch (e) {
      print('Error fetching subjects and topics: $e');
      return _getDefaultSubjectsAndTopics();
    }
  }

  // Default questions fallback
  static List<String> _getDefaultQuestions(String subject, String topic) {
    // Return comprehensive default questions based on subject and topic
    Map<String, Map<String, List<String>>> defaultQuestions = {
      'Data Analysis': {
        'DBMS': [
          'What is a database management system and why is it important?',
          'Explain the difference between SQL and NoSQL databases.',
          'What are the ACID properties in database transactions?',
          'How would you optimize a slow-running SQL query?',
          'Explain the concept of database normalization.',
          'What is the difference between INNER JOIN and LEFT JOIN?',
          'How do you handle database backup and recovery?',
          'What are indexes and when should you use them?',
          'Explain the concept of database sharding.',
          'How do you ensure data integrity in a database?',
        ],
        'Python': [
          'What are the key libraries you use for data analysis in Python?',
          'Explain the difference between pandas and numpy.',
          'How do you handle missing data in a pandas DataFrame?',
          'What is the difference between loc and iloc in pandas?',
          'How would you merge two DataFrames in pandas?',
          'Explain the concept of vectorization in numpy.',
          'How do you create a pivot table in pandas?',
          'What are lambda functions and when would you use them?',
          'How do you handle outliers in your data?',
          'Explain the difference between apply, map, and applymap in pandas.',
        ],
        'Excel': [
          'What are the most useful Excel functions for data analysis?',
          'How do you create a pivot table in Excel?',
          'Explain the difference between VLOOKUP and INDEX-MATCH.',
          'How do you handle large datasets in Excel?',
          'What are array formulas and when would you use them?',
          'How do you create dynamic charts in Excel?',
          'Explain the concept of conditional formatting.',
          'How do you use Power Query for data transformation?',
          'What are the limitations of Excel for data analysis?',
          'How do you create a dashboard in Excel?',
        ],
        'PowerBI': [
          'What are the main components of Power BI?',
          'How do you create relationships between tables in Power BI?',
          'Explain the difference between calculated columns and measures.',
          'How do you create a DAX formula?',
          'What are the best practices for Power BI data modeling?',
          'How do you handle data refresh in Power BI?',
          'Explain the concept of row-level security.',
          'How do you create custom visuals in Power BI?',
          'What are the limitations of Power BI?',
          'How do you optimize Power BI performance?',
        ],
        'All': [
          'What is your experience in data analysis?',
          'How do you approach data cleaning and preprocessing?',
          'What tools do you use for data visualization?',
          'How do you handle large datasets?',
          'Explain your data analysis workflow.',
          'How do you ensure data quality in your analysis?',
          'What statistical methods do you use?',
          'How do you present findings to stakeholders?',
          'What challenges have you faced in data analysis?',
          'How do you stay updated with data analysis trends?',
        ],
      },
      'Data Scientist': {
        'Python': [
          'What are the essential Python libraries for data science?',
          'Explain the difference between supervised and unsupervised learning.',
          'How do you handle imbalanced datasets?',
          'What is cross-validation and why is it important?',
          'Explain the concept of feature engineering.',
          'How do you evaluate the performance of a machine learning model?',
          'What is the difference between overfitting and underfitting?',
          'How do you handle missing values in your dataset?',
          'Explain the concept of regularization in machine learning.',
          'How do you choose the right algorithm for a problem?',
        ],
        'Machine Learning': [
          'Explain the difference between classification and regression.',
          'What is the bias-variance tradeoff?',
          'How do you implement k-means clustering?',
          'Explain the concept of ensemble methods.',
          'What is deep learning and when would you use it?',
          'How do you handle categorical variables in machine learning?',
          'Explain the concept of gradient descent.',
          'What are the assumptions of linear regression?',
          'How do you implement a decision tree?',
          'What is the difference between bagging and boosting?',
        ],
        'Statistics': [
          'Explain the difference between mean, median, and mode.',
          'What is the central limit theorem?',
          'How do you test for normality in your data?',
          'Explain the concept of hypothesis testing.',
          'What is the difference between correlation and causation?',
          'How do you calculate confidence intervals?',
          'Explain the concept of p-values.',
          'What are Type I and Type II errors?',
          'How do you perform A/B testing?',
          'Explain the concept of statistical power.',
        ],
        'Big Data': [
          'What is the difference between batch and stream processing?',
          'Explain the concept of distributed computing.',
          'How do you handle data that doesn\'t fit in memory?',
          'What are the main challenges of big data?',
          'Explain the concept of data lakes vs data warehouses.',
          'How do you implement MapReduce?',
          'What is the difference between Hadoop and Spark?',
          'How do you ensure data quality in big data systems?',
          'Explain the concept of data partitioning.',
          'How do you optimize big data processing?',
        ],
        'All': [
          'What is your experience in data science?',
          'How do you approach a new data science problem?',
          'What is your experience with machine learning algorithms?',
          'How do you handle model deployment?',
          'Explain your experience with big data technologies.',
          'How do you communicate technical results to non-technical stakeholders?',
          'What is your experience with deep learning?',
          'How do you stay updated with data science trends?',
          'What challenges have you faced in data science projects?',
          'How do you ensure reproducibility in your work?',
        ],
      },
      'Business Analyst': {
        'Requirements': [
          'What is the process of gathering business requirements?',
          'How do you identify stakeholders in a project?',
          'Explain the difference between functional and non-functional requirements.',
          'How do you prioritize requirements?',
          'What techniques do you use for requirements elicitation?',
          'How do you document business requirements?',
          'Explain the concept of user stories.',
          'How do you handle conflicting requirements?',
          'What is the role of a business analyst in agile projects?',
          'How do you validate requirements with stakeholders?',
        ],
        'Process Analysis': [
          'What is business process modeling?',
          'How do you identify inefficiencies in business processes?',
          'Explain the concept of process mapping.',
          'How do you measure process performance?',
          'What tools do you use for process analysis?',
          'How do you identify bottlenecks in processes?',
          'Explain the concept of Six Sigma.',
          'How do you implement process improvements?',
          'What is the difference between AS-IS and TO-BE processes?',
          'How do you ensure process compliance?',
        ],
        'Documentation': [
          'What are the key components of business requirements document?',
          'How do you create use case diagrams?',
          'Explain the concept of data flow diagrams.',
          'How do you document system requirements?',
          'What is the purpose of a traceability matrix?',
          'How do you maintain documentation throughout a project?',
          'Explain the concept of technical specifications.',
          'How do you create user acceptance criteria?',
          'What tools do you use for documentation?',
          'How do you ensure documentation quality?',
        ],
        'Stakeholder Management': [
          'How do you identify and analyze stakeholders?',
          'What strategies do you use for stakeholder communication?',
          'How do you handle difficult stakeholders?',
          'Explain the concept of stakeholder mapping.',
          'How do you manage stakeholder expectations?',
          'What is the role of change management in projects?',
          'How do you facilitate stakeholder meetings?',
          'How do you build relationships with stakeholders?',
          'What techniques do you use for conflict resolution?',
          'How do you measure stakeholder satisfaction?',
        ],
        'All': [
          'What is your experience as a business analyst?',
          'How do you approach a new business analysis project?',
          'What tools and techniques do you use for analysis?',
          'How do you handle scope creep in projects?',
          'Explain your experience with agile methodologies.',
          'How do you ensure business value in your recommendations?',
          'What is your experience with data analysis?',
          'How do you handle tight deadlines and pressure?',
          'What challenges have you faced in business analysis?',
          'How do you stay updated with industry trends?',
        ],
      },
      'Software Engineer': {
        'Programming': [
          'What programming languages are you most proficient in?',
          'Explain the concept of object-oriented programming.',
          'How do you handle memory management in your code?',
          'What are design patterns and when would you use them?',
          'How do you write clean and maintainable code?',
          'Explain the concept of SOLID principles.',
          'How do you handle exceptions in your code?',
          'What is the difference between synchronous and asynchronous programming?',
          'How do you optimize code performance?',
          'Explain the concept of dependency injection.',
        ],
        'Algorithms': [
          'What is the time complexity of binary search?',
          'Explain the difference between bubble sort and quick sort.',
          'How do you implement a linked list?',
          'What is dynamic programming?',
          'How do you find the shortest path in a graph?',
          'Explain the concept of recursion.',
          'How do you handle stack overflow in recursive functions?',
          'What is the difference between BFS and DFS?',
          'How do you implement a hash table?',
          'Explain the concept of greedy algorithms.',
        ],
        'System Design': [
          'How do you design a scalable system?',
          'Explain the concept of microservices architecture.',
          'How do you handle system failures?',
          'What is the difference between horizontal and vertical scaling?',
          'How do you design a database schema?',
          'Explain the concept of load balancing.',
          'How do you ensure system security?',
          'What is the difference between SQL and NoSQL databases?',
          'How do you handle data consistency in distributed systems?',
          'Explain the concept of caching strategies.',
        ],
        'Data Structures': [
          'What is the difference between an array and a linked list?',
          'How do you implement a stack and queue?',
          'Explain the concept of trees and binary trees.',
          'How do you implement a binary search tree?',
          'What is the difference between a heap and a stack?',
          'How do you implement a graph data structure?',
          'Explain the concept of hash tables.',
          'How do you handle collisions in hash tables?',
          'What is the difference between a set and a map?',
          'How do you choose the right data structure for a problem?',
        ],
        'All': [
          'What is your experience in software development?',
          'How do you approach debugging complex issues?',
          'What is your experience with version control systems?',
          'How do you handle code reviews?',
          'Explain your experience with testing methodologies.',
          'How do you handle technical debt?',
          'What is your experience with cloud platforms?',
          'How do you stay updated with technology trends?',
          'What challenges have you faced in software development?',
          'How do you ensure code quality and maintainability?',
        ],
      },
      'Sales': {
        'Communication': [
          'How do you build rapport with potential customers?',
          'What is your approach to cold calling?',
          'How do you handle customer objections?',
          'Explain your sales pitch process.',
          'How do you qualify leads?',
          'What techniques do you use for active listening?',
          'How do you adapt your communication style?',
          'Explain the concept of consultative selling.',
          'How do you handle difficult customers?',
          'What is your approach to follow-up communication?',
        ],
        'Negotiation': [
          'What is your negotiation strategy?',
          'How do you handle price negotiations?',
          'Explain the concept of win-win negotiations.',
          'How do you prepare for a negotiation?',
          'What techniques do you use to close deals?',
          'How do you handle multiple stakeholders in negotiations?',
          'Explain the concept of BATNA.',
          'How do you handle rejection in sales?',
          'What is your approach to contract negotiations?',
          'How do you maintain relationships after closing deals?',
        ],
        'CRM': [
          'What CRM systems have you worked with?',
          'How do you manage your sales pipeline?',
          'Explain your lead management process.',
          'How do you track sales activities?',
          'What metrics do you use to measure performance?',
          'How do you forecast sales?',
          'Explain your customer segmentation strategy.',
          'How do you use CRM for customer retention?',
          'What reports do you generate from CRM?',
          'How do you ensure data quality in CRM?',
        ],
        'Product Knowledge': [
          'How do you stay updated with product features?',
          'How do you explain complex products to customers?',
          'What is your approach to competitive analysis?',
          'How do you handle product objections?',
          'Explain your product demonstration process.',
          'How do you match products to customer needs?',
          'What is your approach to product training?',
          'How do you handle product updates?',
          'Explain your approach to cross-selling.',
          'How do you gather customer feedback on products?',
        ],
        'All': [
          'What is your experience in sales?',
          'How do you approach prospecting?',
          'What is your sales methodology?',
          'How do you handle sales targets and quotas?',
          'Explain your experience with different sales channels.',
          'How do you build and maintain customer relationships?',
          'What is your experience with sales technology?',
          'How do you handle sales pressure and stress?',
          'What challenges have you faced in sales?',
          'How do you stay motivated in sales?',
        ],
      },
    };

    // Return specific questions for the subject and topic, or general questions if not found
    return defaultQuestions[subject]?[topic] ?? [
      'What is your experience in $subject?',
      'How do you approach problem-solving in $topic?',
      'What are your strengths in this field?',
      'Where do you see yourself in 5 years?',
      'How do you handle stress and pressure?',
      'What motivates you in your work?',
      'How do you stay updated with industry trends?',
      'Describe a challenging project you worked on.',
      'How do you work in a team environment?',
      'What are your career goals?',
    ];
  }

  // Default subjects and topics fallback
  static Map<String, List<String>> _getDefaultSubjectsAndTopics() {
    return {
      'Data Analysis': ['DBMS', 'Python', 'Excel', 'PowerBI', 'All'],
      'Data Scientist': ['Python', 'Machine Learning', 'Statistics', 'Big Data', 'All'],
      'Business Analyst': ['Requirements', 'Process Analysis', 'Documentation', 'Stakeholder Management', 'All'],
      'Software Engineer': ['Programming', 'Algorithms', 'System Design', 'Data Structures', 'All'],
      'Sales': ['Communication', 'Negotiation', 'CRM', 'Product Knowledge', 'All'],
    };
  }

  // Interview Results methods
  static Future<bool> saveInterviewResult(InterviewResult result) async {
    try {
      await interviewResultsCollection.doc(result.id).set(result.toMap());
      return true;
    } catch (e) {
      print('Error saving interview result: $e');
      return false;
    }
  }

  static Future<List<InterviewResult>> getUserInterviewResults(String userId) async {
    try {
      QuerySnapshot querySnapshot = await interviewResultsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InterviewResult.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching user interview results: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      QuerySnapshot querySnapshot = await interviewResultsCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'totalTests': 0,
          'averageScore': 0.0,
          'totalTime': 0,
          'subjects': <String>[],
          'topics': <String>[],
        };
      }

      int totalTests = querySnapshot.docs.length;
      double totalScore = 0;
      int totalTime = 0;
      Set<String> subjects = {};
      Set<String> topics = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalScore += data['score']?.toDouble() ?? 0.0;
        totalTime += (data['timeElapsed'] as int?) ?? 0;
        subjects.add(data['subject'] ?? '');
        topics.add(data['topic'] ?? '');
      }

      return {
        'totalTests': totalTests,
        'averageScore': totalScore / totalTests,
        'totalTime': totalTime,
        'subjects': subjects.toList(),
        'topics': topics.toList(),
      };
    } catch (e) {
      print('Error fetching user stats: $e');
      return {
        'totalTests': 0,
        'averageScore': 0.0,
        'totalTime': 0,
        'subjects': <String>[],
        'topics': <String>[],
      };
    }
  }

  static Future<bool> updateQuestionWithAiFeedback(
    String resultId, 
    int questionIndex, 
    String aiFeedback
  ) async {
    try {
      final docRef = interviewResultsCollection.doc(resultId);
      final doc = await docRef.get();
      
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
      
      if (questionIndex < questions.length) {
        questions[questionIndex]['aiFeedback'] = aiFeedback;
        questions[questionIndex]['hasAiFeedback'] = true;
        
        await docRef.update({'questions': questions});
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error updating AI feedback: $e');
      return false;
    }
  }
} 