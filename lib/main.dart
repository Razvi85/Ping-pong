import 'package:flutter/material.dart';

void main() {
  runApp(PingPongApp());
}

class PingPongApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ping Pong Predicții',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ping Pong Predicții'),
      ),
      body: Center(
        child: Text(
          'Salut! Aici vor apărea predicțiile. 🏓',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
