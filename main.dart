import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() => runApp(PingPongApp());

class PingPongApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predicții Tenis de Masă',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  bool tomorrow = false;
  List<MatchItem> matches = [];
  double threshold = 80.0;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    setState(() { loading = true; matches = []; });
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: tomorrow?1:0)));
    try {
      // Sofascore unofficial endpoint for scheduled events (may change)
      final url = Uri.parse('https://api.sofascore.com/api/v1/sport/table-tennis/scheduled-events/$date');
      final res = await http.get(url);
      if (res.statusCode != 200) throw Exception('Failed: ${res.statusCode}');
      final data = json.decode(res.body);
      final events = data['events'] as List? ?? [];
      for (var e in events) {
        try {
          final eventId = e['id'].toString();
          final event = await fetchEventDetails(eventId);
          if (event != null) {
            final prob = await estimateOverProbability(event);
            if (prob >= threshold) matches.add(MatchItem.fromEvent(event, prob));
          }
        } catch (ex) {
          // skip this event on error
        }
      }
    } catch (e) {
      // network or parsing error
      print('Error fetching matches: $e');
    } finally {
      setState(() { loading = false; });
    }
  }

  Future<Map<String,dynamic>?> fetchEventDetails(String eventId) async {
    final url = Uri.parse('https://api.sofascore.com/api/v1/event/$eventId');
    final res = await http.get(url);
    if (res.statusCode != 200) return null;
    return json.decode(res.body) as Map<String,dynamic>;
  }

  Future<double> estimateOverProbability(Map<String,dynamic> event) async {
    // Try to get player IDs
    int? homeId = event['homeTeam']?['id'];
    int? awayId = event['awayTeam']?['id'];
    if (homeId == null || awayId == null) return 0.0;
    final hProb = await playerOverProb(homeId);
    final aProb = await playerOverProb(awayId);
    // combine probabilities (simple average)
    return ((hProb + aProb) / 2.0) * 100.0;
  }

  Future<double> playerOverProb(int playerId) async {
    try {
      final url = Uri.parse('https://api.sofascore.com/api/v1/player/$playerId/events');
      final res = await http.get(url);
      if (res.statusCode != 200) return 0.0;
      final data = json.decode(res.body);
      final events = data['events'] as List? ?? [];
      int count = 0;
      int total = 0;
      for (var e in events) {
        if (total >= 10) break;
        try {
          final ha = e['homeScore'] ?? e['scores'] ?? null;
          // Try multiple possible fields to compute total points
          int t = 0;
          if (e['homeScore'] != null && e['awayScore'] != null) {
            t = (e['homeScore'] as int) + (e['awayScore'] as int);
          } else if (e['scores'] is List && (e['scores'] as List).isNotEmpty) {
            // some responses include score breakdown
            final scores = e['scores'] as List;
            if (scores.first is Map && scores.first['home']!=null && scores.first['away']!=null) {
              // attempt to sum sets' points if available (best effort)
              int ssum = 0;
              for (var s in scores) {
                final hh = s['home'] ?? 0;
                final aa = s['away'] ?? 0;
                ssum += (hh as int) + (aa as int);
              }
              t = ssum;
            }
          }
          if (t > 0) {
            total += 1;
            if (t > 74) count += 1;
          }
        } catch (ex) {
          // skip malformed
        }
      }
      if (total == 0) return 0.0;
      return count / total;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predicții Tenis de Masă'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: fetchMatches, tooltip: 'Reîncarcă'),
          PopupMenuButton<double>(
            onSelected: (v){ setState(()=> threshold=v); fetchMatches(); },
            itemBuilder: (_) => [80.0,85.0,90.0].map((v)=> PopupMenuItem(value:v, child: Text('${v.toInt()}%'))).toList(),
            icon: Icon(Icons.filter_list),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(tomorrow? 'Meciurile de mâine' : 'Meciurile de azi', style: TextStyle(fontSize:16, fontWeight: FontWeight.w600))),
                  Switch(value: tomorrow, onChanged: (v){ setState(()=> tomorrow=v); fetchMatches(); }),
                ],
              ),
              SizedBox(height:8),
              Expanded(
                child: loading ? Center(child: CircularProgressIndicator()) :
                matches.isEmpty ? Center(child: Text('Niciun meci găsit cu probabilitate ≥ ${threshold.toInt()}%')) :
                ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (_,i){
                    final m = matches[i];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text('${m.home} vs ${m.away}', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${m.time} • Over 74.5 — ${m.prob.toStringAsFixed(0)}%'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                    );
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MatchItem {
  final String home;
  final String away;
  final String time;
  final double prob;
  MatchItem(this.home,this.away,this.time,this.prob);
  factory MatchItem.fromEvent(Map<String,dynamic> e,double prob){
    final home = e['homeTeam']?['name'] ?? 'Unknown';
    final away = e['awayTeam']?['name'] ?? 'Unknown';
    final time = e['startTimestamp'] != null ? DateTime.fromMillisecondsSinceEpoch((e['startTimestamp'] as int)*1000).toLocal().toString().split(' ')[1].substring(0,5) : '—';
    return MatchItem(home,away,time,prob);
  }
}