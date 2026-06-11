// lib/app_state.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/trade.dart';
import 'models/checklist.dart';

class AppState extends ChangeNotifier {
  List<Trade> trades = [];
  List<CheckSection> checklist = defaultChecklist();

  static const _tradesKey    = 'ict_trades';
  static const _checklistKey = 'ict_checklist';

  // ── Load ───────────────────────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final tradesJson = prefs.getString(_tradesKey);
    if (tradesJson != null) {
      final list = jsonDecode(tradesJson) as List;
      trades = list.map((e) => Trade.fromJson(e as Map<String, dynamic>)).toList();
    }

    final clJson = prefs.getString(_checklistKey);
    if (clJson != null) {
      final list = jsonDecode(clJson) as List;
      checklist = list.map((e) => CheckSection.fromJson(e as Map<String, dynamic>)).toList();
    }

    notifyListeners();
  }

  // ── Persist ────────────────────────────────────────────────────
  Future<void> _saveTrades() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tradesKey, jsonEncode(trades.map((t) => t.toJson()).toList()));
  }

  Future<void> _saveChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checklistKey, jsonEncode(checklist.map((s) => s.toJson()).toList()));
  }

  // ── Trades CRUD ────────────────────────────────────────────────
  void addTrade(Trade t) {
    trades.insert(0, t);
    _saveTrades();
    notifyListeners();
  }

  void updateTrade(Trade t) {
    final idx = trades.indexWhere((x) => x.id == t.id);
    if (idx != -1) trades[idx] = t;
    _saveTrades();
    notifyListeners();
  }

  void deleteTrade(String id) {
    trades.removeWhere((t) => t.id == id);
    _saveTrades();
    notifyListeners();
  }

  // ── Checklist CRUD ─────────────────────────────────────────────
  void updateChecklist(List<CheckSection> updated) {
    checklist = updated;
    _saveChecklist();
    notifyListeners();
  }

  void resetChecklist() {
    checklist = defaultChecklist();
    _saveChecklist();
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────
  int calcScore(Map<String, int> sel) {
    int total = sel.values.fold(0, (a, b) => a + b);
    return total.clamp(0, 100);
  }

  Map<String, List<Trade>> tradesByPair() {
    final map = <String, List<Trade>>{};
    for (final t in trades) {
      map.putIfAbsent(t.pair, () => []).add(t);
    }
    return Map.fromEntries(map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  PairStats pairStats(List<Trade> pts) {
    final wins    = pts.where((t) => t.outcome == 'TP Hit').length;
    final losses  = pts.where((t) => t.outcome == 'SL Hit').length;
    final parts   = pts.where((t) => t.outcome == 'Partial').length;
    final bes     = pts.where((t) => t.outcome == 'Breakeven').length;
    final rrVals  = pts.where((t) => t.rr.isNotEmpty).map((t) => double.tryParse(t.rr) ?? 0.0).toList();
    final avgRR   = rrVals.isEmpty ? '—' : '${(rrVals.reduce((a, b) => a + b) / rrVals.length).toStringAsFixed(1)}R';
    final avgScore = pts.isEmpty ? 0 : (pts.map((t) => t.score).reduce((a, b) => a + b) / pts.length).round();
    return PairStats(
      total: pts.length, wins: wins, losses: losses, partials: parts, bes: bes,
      wr: pts.isEmpty ? 0 : (wins / pts.length * 100).round(),
      avgRR: avgRR, avgScore: avgScore,
    );
  }
}

class PairStats {
  final int total, wins, losses, partials, bes, wr, avgScore;
  final String avgRR;
  const PairStats({
    required this.total, required this.wins, required this.losses,
    required this.partials, required this.bes, required this.wr,
    required this.avgRR, required this.avgScore,
  });
}
