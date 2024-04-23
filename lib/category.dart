import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'project.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final String categoryDescription;

  CategoryScreen({
    required this.categoryName,
    required this.categoryDescription,
  });

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Map<String, dynamic>>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = fetchProjects();
  }

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    final apiKey = '28356352-e2da-4834-990a-25fcbe065433'; // Replace 'YOUR_API_KEY' with your actual API key
    final categoryId = widget.categoryName.toLowerCase().replaceAll(' ', '-');
    final url = 'https://sketchub.in/api/v3/get_project_list';

    final requestBody = {
      'api_key': apiKey,
      'page_number': '1', 
      'search_keywords': '', 
      'project_type': '', 
      'category': categoryId,
      'user_id': '',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<Map<String, dynamic>> projects = List<Map<String, dynamic>>.from(responseData['projects'] ?? []);
        return projects;
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (error) {
      throw Exception('Failed to load projects: $error');
    }
  }

  void _navigateToProjectDetails(Map<String, dynamic> project) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ProjectScreen(projectDetails: project)),
    );
  }

  Widget _buildProjectItem(BuildContext context, Map<String, dynamic> project) {
    final String projectName = project['title'] ?? 'Unknown';
    final String projectDescription = project['description'] ?? '';

    return GestureDetector(
      onTap: () {
        _navigateToProjectDetails(project);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              projectDescription,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.categoryName),
      ),
      child: FutureBuilder(
        future: _projectsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> projects = snapshot.data ?? [];
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> project = projects[index];
                return _buildProjectItem(context, project);
              },
            );
          }
        },
      ),
    );
  }
}
