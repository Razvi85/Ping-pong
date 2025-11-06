
import 'package:flutter/material.dart';
import 'services/match_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Ping Pong Predicții')),
        body: Center(child: MatchLoader()),
      ),
    );
  }
}

class MatchLoader extends StatefulWidget {
  @override
  _MatchLoaderState createState() => _MatchLoaderState();
}

class _MatchLoaderState extends State<MatchLoader> {
  bool loading = false;
  List<String> predictions = [];

  void loadMatches() async {
    setState(() => loading = true);
    final matches = await fetchTodaysMatches();
    final preds = matches.map((m) => m.predictionText).toList();
    setState(() {
      predictions = preds;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: loading ? null : loadMatches,
          child: Text('Încarcă meciurile'),
        ),
        SizedBox(height: 20),
        if (loading) CircularProgressIndicator(),
        ...predictions.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(p),
            )),
      ],
    );
  }
}
