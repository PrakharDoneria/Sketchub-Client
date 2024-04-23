import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectScreen extends StatelessWidget {
  final Map<String, dynamic> projectDetails;

  ProjectScreen({required this.projectDetails});

  @override
  Widget build(BuildContext context) {
    final String projectName = projectDetails['title'] ?? 'Unknown';
    final String projectDescription = projectDetails['description'] ?? 'No description available';
    final int projectLikes = int.parse(projectDetails['likes'] ?? '0');
    final String projectIconUrl = projectDetails['icon'] ?? '';
    final List<String> projectScreenshots = [
      projectDetails['screenshot1'] ?? '',
      projectDetails['screenshot2'] ?? '',
      projectDetails['screenshot3'] ?? '',
      projectDetails['screenshot4'] ?? '',
      projectDetails['screenshot5'] ?? '',
    ];
    final String projectLink = 'https://web.sketchub.in/p/${projectDetails['id']}'; // Sketchub project link

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(projectName),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: $projectName',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Description: $projectDescription',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Divider(color: CupertinoColors.systemGrey),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Likes: $projectLikes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _launchURL(projectLink); // Launch download link
                      },
                      child: Text('Download', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(color: CupertinoColors.systemGrey),
              SizedBox(height: 16),
              Text(
                'Screenshots',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: projectScreenshots.length,
                  itemBuilder: (context, index) {
                    final screenshotUrl = projectScreenshots[index];
                    return GestureDetector(
                      onTap: () {
                        // Handle tap to open screenshot
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            screenshotUrl,
                            fit: BoxFit.cover,
                            width: 300,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
