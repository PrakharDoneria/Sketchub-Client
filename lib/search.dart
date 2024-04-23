import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'project.dart'; // Import the project.dart file to navigate to the project details screen

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = fetchProjects('');
  }

  Future<List<Map<String, dynamic>>> fetchProjects(String searchQuery) async {
    final apiKey = '28356352-e2da-4834-990a-25fcbe065433'; // Use the actual API key value here
    final url = 'https://sketchub.in/api/v3/get_project_list';

    final requestBody = {
      'api_key': apiKey,
      'page_number': '1',
      'search_keywords': searchQuery,
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
        throw Exception('Failed to search projects');
      }
    } catch (error) {
      throw Exception('Failed to search projects: $error');
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchFuture = fetchProjects(query);
    });
  }

  Widget _buildProjectItem(BuildContext context, Map<String, dynamic> project) {
    return GestureDetector(
      onTap: () {
        // Navigate to project details screen
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => ProjectScreen(projectDetails: project)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(project['icon'] ?? ''), // Use the project icon URL here
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            // Title, Likes, and Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    project['title'] ?? '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // Likes and Badge
                  Row(
                    children: [
                      Icon(CupertinoIcons.heart, size: 16, color: CupertinoColors.systemRed),
                      SizedBox(width: 4),
                      Text('${project['likes'] ?? ''} Likes'),
                      SizedBox(width: 8),
                      // Icon(CupertinoIcons.badge, size: 16, color: CupertinoColors.systemBlue),
                      SizedBox(width: 4),
                      Text('${project['user_badge'] ?? ''} Badge'),
                    ],
                  ),
                ],
              ),
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
        middle: CupertinoTextField(
          controller: _searchController,
          placeholder: 'Search',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
      ),
      child: FutureBuilder(
        future: _searchFuture,
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
