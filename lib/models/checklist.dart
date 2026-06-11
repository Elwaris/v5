// lib/models/checklist.dart

class CheckOption {
  String label;
  int score;
  CheckOption({required this.label, required this.score});

  factory CheckOption.fromJson(Map<String, dynamic> j) =>
      CheckOption(label: j['label'] as String, score: (j['score'] as num).toInt());

  Map<String, dynamic> toJson() => {'label': label, 'score': score};
}

class CheckSection {
  String id;
  String title;
  int max;
  String note;
  List<CheckOption> options;

  CheckSection({
    required this.id,
    required this.title,
    required this.max,
    this.note = '',
    required this.options,
  });

  factory CheckSection.fromJson(Map<String, dynamic> j) => CheckSection(
        id: j['id'] as String,
        title: j['title'] as String,
        max: (j['max'] as num).toInt(),
        note: j['note'] as String? ?? '',
        options: (j['options'] as List)
            .map((o) => CheckOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'max': max,
        'note': note,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

// ── Default checklist ──────────────────────────────────────────────────────

List<CheckSection> defaultChecklist() => [
      CheckSection(id: 'htf', title: '1. HTF Alignment', max: 15, options: [
        CheckOption(label: '15M + 1H + 4H aligned', score: 15),
        CheckOption(label: '15M + 1H aligned', score: 10),
        CheckOption(label: 'Only 15M aligned', score: 5),
        CheckOption(label: 'Full countertrend', score: 0),
      ]),
      CheckSection(
          id: 'sweep',
          title: '2. Sweep Quality',
          max: 20,
          note: 'Clean = strong displacement, obvious target, decisive rejection.',
          options: [
            CheckOption(label: 'Clean liquidity sweep', score: 20),
            CheckOption(label: 'Takeout + sharp reversal', score: 15),
            CheckOption(label: 'Messy liquidity sweep', score: 8),
            CheckOption(label: 'Weak / unclear sweep', score: 0),
          ]),
      CheckSection(id: 'trend', title: '3. Trend Context', max: 10, options: [
        CheckOption(label: 'Supports HTF trend', score: 10),
        CheckOption(label: 'Mild countertrend', score: 5),
        CheckOption(label: 'Strong countertrend', score: 0),
      ]),
      CheckSection(
          id: 'poi', title: '4. External POI Confluence', max: 20, options: [
        CheckOption(label: '1H FVG + 15M POI', score: 20),
        CheckOption(label: '1H FVG only', score: 17),
        CheckOption(label: '1H POI only', score: 14),
        CheckOption(label: '15M FVG + 5M POI', score: 10),
        CheckOption(label: '15M FVG only', score: 7),
        CheckOption(label: '15M POI only', score: 5),
        CheckOption(label: 'No significant POI', score: 0),
      ]),
      CheckSection(
          id: 'reaction',
          title: '5. Post-Sweep Reaction',
          max: 15,
          note: 'FVG before last HH/LL → wait for inversion or −5% penalty.',
          options: [
            CheckOption(label: 'IFVG', score: 15),
            CheckOption(label: 'Clean rejection block', score: 11),
            CheckOption(label: 'FVG', score: 8),
            CheckOption(label: 'Weak reaction', score: 0),
          ]),
      CheckSection(
          id: 'mss', title: '6. Market Structure Shift', max: 10, options: [
        CheckOption(label: 'Clear MSS + displacement', score: 10),
        CheckOption(label: 'Weak MSS', score: 5),
        CheckOption(label: 'No MSS', score: 0),
      ]),
      CheckSection(
          id: 'fib', title: '7. Fibonacci Entry', max: 5, options: [
        CheckOption(label: 'Entry below 50% fib', score: 5),
        CheckOption(label: 'Entry slightly above 50%', score: 2),
        CheckOption(label: 'Deep retracement / chase', score: 0),
      ]),
      CheckSection(
          id: 'timing',
          title: '8. Session Timing',
          max: 5,
          note: 'London KZ: 8–11AM WAT  |  NY KZ: 1:30–4PM WAT',
          options: [
            CheckOption(label: 'London Kill Zone (8–11AM WAT)', score: 5),
            CheckOption(label: 'New York Kill Zone (1:30–4PM WAT)', score: 5),
            CheckOption(label: 'Active session, outside KZ', score: 2),
            CheckOption(label: 'Off session', score: -5),
          ]),
    ];
