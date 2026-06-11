// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final trades = state.trades;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: trades.isEmpty
          ? const Center(child: Text('No trades to analyse yet.', style: TextStyle(color: kText2)))
          : _StatsBody(trades: trades, state: state),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final List trades;
  final AppState state;
  const _StatsBody({required this.trades, required this.state});

  @override
  Widget build(BuildContext context) {
    final total  = trades.length;
    final wins   = trades.where((t) => t.outcome == 'TP Hit').length;
    final losses = trades.where((t) => t.outcome == 'SL Hit').length;
    final parts  = trades.where((t) => t.outcome == 'Partial').length;
    final bes    = trades.where((t) => t.outcome == 'Breakeven').length;
    final wr     = total > 0 ? (wins / total * 100).round() : 0;
    final avgS   = total > 0 ? (trades.map((t) => t.score).reduce((a, b) => a + b) / total).round() : 0;
    final rrVals = trades.where((t) => t.rr.isNotEmpty).map((t) => double.tryParse(t.rr) ?? 0.0).toList();
    final avgRR  = rrVals.isEmpty ? '—' : '${(rrVals.reduce((a, b) => a + b) / rrVals.length).toStringAsFixed(1)}R';

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        // ── Overview ─────────────────────────────────────────
        SectionCard(title: 'Overall Performance', children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 1.1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatTile(value: total.toString(),  label: 'Trades'),
                StatTile(value: '$wr%',            label: 'Win Rate',  valueColor: kGreen),
                StatTile(value: '$avgS%',           label: 'Avg Score'),
                StatTile(value: avgRR,             label: 'Avg RR',    valueColor: kBlue),
                StatTile(value: wins.toString(),   label: 'Wins',      valueColor: kGreen),
                StatTile(value: losses.toString(), label: 'Losses',    valueColor: kRed),
                StatTile(value: parts.toString(),  label: 'Partials',  valueColor: kAmber),
                StatTile(value: bes.toString(),    label: 'BEs',       valueColor: kBlue),
              ],
            ),
          ),
        ]),

        // ── Score distribution ────────────────────────────────
        SectionCard(title: 'Score Distribution', children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              for (final r in [
                ('Elite    85–100%', trades.where((t) => t.score >= 85).length,        kGreen),
                ('Strong   70–84%',  trades.where((t) => t.score >= 70 && t.score < 85).length, kBlue),
                ('Tradable 55–69%',  trades.where((t) => t.score >= 55 && t.score < 70).length, kAmber),
                ('Skip     <55%',    trades.where((t) => t.score < 55).length,          kRed),
              ]) ...[
                Row(children: [
                  SizedBox(width: 130, child: Text(r.$1, style: const TextStyle(color: kText2, fontSize: 12))),
                  Expanded(child: MiniBar(pct: total > 0 ? r.$2 / total * 100 : 0, color: r.$3)),
                  const SizedBox(width: 8),
                  Text('${r.$2}', style: TextStyle(color: r.$3, fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
                const SizedBox(height: 10),
              ],
            ]),
          ),
        ]),

        // ── Outcome breakdown ─────────────────────────────────
        SectionCard(title: 'Outcome Breakdown', children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              for (final oc in ['TP Hit', 'SL Hit', 'Partial', 'Breakeven']) ...[
                Row(children: [
                  SizedBox(width: 100,
                      child: Text(oc, style: TextStyle(color: outcomeColor(oc), fontWeight: FontWeight.w600, fontSize: 13))),
                  Expanded(child: MiniBar(
                      pct: total > 0 ? trades.where((t) => t.outcome == oc).length / total * 100 : 0,
                      color: outcomeColor(oc))),
                  const SizedBox(width: 8),
                  Text('${trades.where((t) => t.outcome == oc).length}',
                      style: TextStyle(color: outcomeColor(oc), fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 10),
              ],
            ]),
          ),
        ]),

        // ── Per-pair table ────────────────────────────────────
        SectionCard(title: 'Per-Pair Breakdown', children: [
          // header
          Container(
            color: kSurface2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(children: [
              Expanded(flex: 3, child: Text('Pair', style: TextStyle(color: kText2, fontSize: 12))),
              Expanded(flex: 2, child: Text('Win Rate', style: TextStyle(color: kText2, fontSize: 12))),
              Expanded(flex: 2, child: Text('Avg RR', style: TextStyle(color: kText2, fontSize: 12))),
              Expanded(flex: 2, child: Text('Score', style: TextStyle(color: kText2, fontSize: 12))),
              Expanded(flex: 1, child: Text('W', style: TextStyle(color: kText2, fontSize: 12))),
              Expanded(flex: 1, child: Text('L', style: TextStyle(color: kText2, fontSize: 12))),
              Expanded(flex: 1, child: Text('N', style: TextStyle(color: kText2, fontSize: 12))),
            ]),
          ),
          const Divider(height: 1, color: kBorder),
          ...state.tradesByPair().entries.toList().asMap().entries.map((entry) {
            final i    = entry.key;
            final pair = entry.value.key;
            final pts  = entry.value.value.cast();
            final info = state.pairStats(pts);
            final wrCol = info.wr >= 50 ? kGreen : kRed;
            return Container(
              color: i.isOdd ? kSurface2 : kSurface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Expanded(flex: 3, child: Text(pair,
                    style: const TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('${info.wr}%',
                    style: TextStyle(color: wrCol, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text(info.avgRR,
                    style: const TextStyle(color: kBlue, fontSize: 13))),
                Expanded(flex: 2, child: Text('${info.avgScore}%',
                    style: const TextStyle(color: kPrimary, fontSize: 13))),
                Expanded(flex: 1, child: Text(info.wins.toString(),
                    style: const TextStyle(color: kGreen, fontSize: 13))),
                Expanded(flex: 1, child: Text(info.losses.toString(),
                    style: const TextStyle(color: kRed, fontSize: 13))),
                Expanded(flex: 1, child: Text(info.total.toString(),
                    style: const TextStyle(color: kText2, fontSize: 13))),
              ]),
            );
          }),
        ]),
      ],
    );
  }
}
