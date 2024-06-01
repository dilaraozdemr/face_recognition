class RiskLog {
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final double avgSoundLevel;

  RiskLog({required this.start, required this.end, required this.duration, required this.avgSoundLevel});
}