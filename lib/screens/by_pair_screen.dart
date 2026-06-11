// lib/screens/by_pair_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/shared.dart';
import 'trade_detail_screen.dart';
import 'trade_form_screen.dart';

class ByPairScreen extends StatelessWidget {
  const ByPairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final trades = state.trades;

    return Scaffold(
      appBar: AppBar(
        title: const Text('By Pair'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const TradeFormScreen())),
          ),
        ],
      ),
      body: trades.isEmpty
          ? const Center(child: Text('No trades logged yet.', style: TextStyle(color: kText2)))
          : ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                _GlobalSummary(trades: trades),
                ...state.tradesByPair().entries.map(
                      (e) => _PairSection(pair: e.key, trades: e.value, state: state),
                    ),
              ],
            ),
    );
  }
}

// ── Global summary card ──────────────────────────────────────────
class _GlobalSummary extends StatelessWidget {
  final List trades;
  const _GlobalSummary({required this.trades});

  @override
  Widget build(BuildContext context) {
    final total  = trades.length;
    final wins   = trades.where((t) => t.outcome == 'TP Hit').length;
    final wr     = total > 0 ? '${(wins / total * 100).round()}%' : '—';
    final avgS   = total > 0 ? '${(trades.map((t) => t.score).reduce((a, b) => a + b) / total).round()}%' : '—';
    final rrVals = trades.where((t) => t.rr.isNotEmpty).map((t) => double.tryParse(t.rr) ?? 0.0).toList();
    final avgRR  = rrVals.isEmpty ? '—' : '${(rrVals.reduce((a, b) => a + b) / rrVals.length).toStringAsFixed(1)}R';
    final pairs  = context.read<AppState>().tradesByPair().length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Overall Summary',
              style: TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatTile(value: total.toString(), label: 'Trades'),
              StatTile(value: wr,    label: 'Win Rate', valueColor: kGreen),
              StatTile(value: avgS,  label: 'Avg Score'),
              StatTile(value: avgRR, label: 'Avg RR',   valueColor: kBlue),
              StatTile(value: pairs.toString(), label: 'Pairs', valueColor: kAmber),
            ],
          ),
        ]),
      ),
    );
  }
}

// ── Per-pair collapsible section ─────────────────────────────────
class _PairSection extends StatefulWidget {
  final String pair;
  final List trades;
  final AppState state;
  const _PairSection({required this.pair, required this.trades, required this.state});
  @override
  State<_PairSection> createState() => _PairSectionState();
}

class _PairSectionState extends State<_PairSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final info   = widget.state.pairStats(widget.trades.cast());
    final wrCol  = info.wr >= 50 ? kGreen : kRed;

    return Card(
      child: Column(children: [
        // header row
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Container(
            color: kSurface2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(child: Row(children: [
                Text(widget.pair,
                    style: const TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                Text('${info.total} trade${info.total != 1 ? "s" : ""}',
                    style: const TextStyle(color: kText2, fontSize: 12)),
              ])),
              // stat pills
              _pill('${info.wr}%', 'WR', wrCol),
              _pill(info.avgRR, 'RR', kBlue),
              _pill('${info.avgScore}%', 'Score', kPrimary),
              _pill(info.wins.toString(), 'W', kGreen),
              _pill(info.losses.toString(), 'L', kRed),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: kText2),
            ]),
          ),
        ),
        const Divider(height: 1, color: kBorder),
        // trade list
        if (_expanded)
          ...widget.trades.asMap().entries.map((e) {
            final t   = e.value;
            final odd = e.key.isOdd;
            return _tradeRow(context, t, odd);
          }),
      ]),
    );
  }

  Widget _pill(String val, String label, Color col) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(children: [
          Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(color: kText2, fontSize: 10)),
        ]),
      );

  Widget _tradeRow(BuildContext context, dynamic t, bool odd) {
    final dirCol = t.direction == 'Long' ? kGreen : kRed;
    final sl_text = scoreLabel(t.score);
    final slCol   = scoreColor(t.score);
    return InkWell(
      onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (_) => TradeDetailScreen(tradeId: t.id))),
      child: Container(
        color: odd ? kSurface2 : kSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(t.pair,
                  style: const TextStyle(color: kText, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DirChip(t.direction),
              const SizedBox(width: 6),
              OutcomeChip(t.outcome),
            ]),
            const SizedBox(height: 4),
            Text('${t.date}  ·  SL: ${t.slPips.isEmpty ? "—" : t.slPips + " pips"}  ·  RR: ${t.rr.isEmpty ? "—" : t.rr + "R"}',
                style: const TextStyle(color: kText2, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${t.score}%  $sl_text',
                style: TextStyle(color: slCol, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TradeFormScreen(tradeId: t.id))),
                child: const Icon(Icons.edit_outlined, color: kPrimary, size: 18),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: kText2, size: 18),
            ]),
          ]),
        ]),
      ),
    );
  }
}
