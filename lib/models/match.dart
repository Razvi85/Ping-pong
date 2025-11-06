
class Match {
  final String player1;
  final String player2;
  final List<int> last12MatchesPointsPlayer1;
  final List<int> last12MatchesPointsPlayer2;

  Match({
    required this.player1,
    required this.player2,
    required this.last12MatchesPointsPlayer1,
    required this.last12MatchesPointsPlayer2,
  });

  double calculatePrediction() {
    int count1 = last12MatchesPointsPlayer1.where((p) => p > 74.5).length;
    int count2 = last12MatchesPointsPlayer2.where((p) => p > 74.5).length;

    if (count1 >= 9 && count2 >= 9) {
      return 0.9; // 90% probabilitate
    }
    return ((count1 + count2) / 24);
  }

  String get predictionText =>
      '$player1 vs $player2 → Probabilitate: ${(calculatePrediction() * 100).toStringAsFixed(0)}%';
}
