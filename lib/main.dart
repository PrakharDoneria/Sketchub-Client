import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'search.dart';
import 'category.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Sketchub Categories'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.search),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
      ),
      child: BeeHiveUI(),
    );
  }
}

class BeeHiveUI extends StatefulWidget {
  @override
  _BeeHiveUIState createState() => _BeeHiveUIState();
}

class _BeeHiveUIState extends State<BeeHiveUI> {
  final String apiKey = '28356352-e2da-4834-990a-25fcbe065433';
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = getCategories();
  }

  Future<List<dynamic>> getCategories() async {
    try {
      var response = await http.post(
        Uri.parse('https://sketchub.in/api/v3/get_categories'),
        body: {'api_key': apiKey},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['categories'] ?? [];
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      throw Exception('Failed to load categories: $error');
    }
  }

  Color _randomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
  }

  void _navigateToCategory(String categoryName, String categoryDescription) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => CategoryScreen(
        categoryName: categoryName,
        categoryDescription: categoryDescription,
      )),
    );
  }

  Widget _buildOption(BuildContext context, String name, String description) {
    return GestureDetector(
      onTap: () {
        _navigateToCategory(name, description);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _randomColor(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _categoriesFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<dynamic> categories = snapshot.data ?? [];
          return Scaffold(
            body: GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) {
                String categoryName = categories[index]['category_name'] ?? '';
                String categoryDescription = categories[index]['category_description'] ?? '';
                return _buildOption(context, categoryName, categoryDescription);
              },
            ),
          );
        }
      },
    );
  }
}
