import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(PingPongApp());
}

class PingPongApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ping Pong Predictor',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
      ),
      home: MatchListPage(),
    );
  }
}

class MatchListPage extends StatefulWidget {
  @override
  _MatchListPageState createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  List matches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    try {
      // Exemplu endpoint placeholder (înlocuiește cu API real sau scraping)
      final response = await http.get(Uri.parse('https://api.example.com/matches'));
      if (response.statusCode == 200) {
        setState(() {
          matches = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predicții Tenis de Masă'),
        backgroundColor: Colors.black,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("${match['player1']} vs ${match['player2']}"),
                    subtitle: Text("Predicție: ${match['prediction']}"),
                  ),
                );
              },
            ),
    );
  }
}
