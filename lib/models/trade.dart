// lib/models/trade.dart

class Trade {
  final String id;
  String pair;
  String date;
  String direction; // "Long" | "Short"
  String slPips;
  String rr;
  String partialRR;
  String partialLevel;
  String outcome; // "TP Hit" | "SL Hit" | "Partial" | "Breakeven"
  String notes;
  Map<String, int> selections; // sectionId -> score
  int score;

  Trade({
    required this.id,
    required this.pair,
    required this.date,
    required this.direction,
    required this.slPips,
    required this.rr,
    required this.partialRR,
    required this.partialLevel,
    required this.outcome,
    required this.notes,
    required this.selections,
    required this.score,
  });

  factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        id: json['id'] as String,
        pair: json['pair'] as String,
        date: json['date'] as String,
        direction: json['direction'] as String,
        slPips: json['slPips'] as String? ?? '',
        rr: json['rr'] as String? ?? '',
        partialRR: json['partialRR'] as String? ?? '',
        partialLevel: json['partialLevel'] as String? ?? '',
        outcome: json['outcome'] as String,
        notes: json['notes'] as String? ?? '',
        selections: (json['selections'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        score: (json['score'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pair': pair,
        'date': date,
        'direction': direction,
        'slPips': slPips,
        'rr': rr,
        'partialRR': partialRR,
        'partialLevel': partialLevel,
        'outcome': outcome,
        'notes': notes,
        'selections': selections,
        'score': score,
      };
}
