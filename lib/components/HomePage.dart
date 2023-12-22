import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:velo_flix/components/Register.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final filmNameController = TextEditingController();

  Future<Movies> fetchMovies(String search) async {
    final response =
        await http.get(Uri.parse('https://yts.mx/api/v2/list_movies.json'));

    if (response.statusCode == 200) {
      return Movies.fromJson(jsonDecode(response.body)['data']['movies'][0]
          as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load Movies');
    }
  }

  int currentIndex = 0;
  List navigate = const [HomePage(), Register()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.all(16)),
            const Text("Welcome to Veloflix", style: TextStyle(fontSize: 32)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: filmNameController,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 32,
                  decorationStyle: TextDecorationStyle.solid,
                ),
              ),
            ),
            FutureBuilder(
              future: fetchMovies(filmNameController.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final movies = snapshot.data as Movies;
                  return Card(
                    margin: const EdgeInsets.all(12),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        Text(movies.title),
                        Image.network(movies.url),
                        Text("Link for film: ${movies.url}"),
                        Text("Description: ${movies.description}"),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.support), label: "Support"),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index + 1;
          });
        },
      ),
    );
  }
}

class Movies {
  final String url;
  final String description;
  final String title;

  const Movies({
    required this.url,
    required this.description,
    required this.title,
  });

  factory Movies.fromJson(Map<String, dynamic> json) {
    return Movies(
      url: json['medium_cover_image'] as String,
      description: json['description_full'] as String,
      title: json['title'] as String,
    );
  }
}
