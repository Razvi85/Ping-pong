
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import '../models/match.dart';

Future<List<Match>> fetchTodaysMatches() async {
  final url = 'https://www.aiscore.com/table-tennis';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) return [];

  final document = parse(response.body);

  List<Match> matches = [];

  matches.add(Match(
    player1: 'Player A',
    player2: 'Player B',
    last12MatchesPointsPlayer1: [80, 76, 78, 72, 75, 77, 79, 81, 74, 73, 76, 78],
    last12MatchesPointsPlayer2: [77, 79, 81, 70, 75, 80, 78, 76, 74, 79, 75, 77],
  ));

  return matches;
}
