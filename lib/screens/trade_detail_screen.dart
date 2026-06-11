// lib/screens/trade_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/shared.dart';
import 'trade_form_screen.dart';

class TradeDetailScreen extends StatelessWidget {
  final String tradeId;
  const TradeDetailScreen({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final trade  = state.trades.firstWhere((t) => t.id == tradeId);
    final dirCol = trade.direction == 'Long' ? kGreen : kRed;

    return Scaffold(
      appBar: AppBar(
        title: Text(trade.pair),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: kPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TradeFormScreen(tradeId: tradeId)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kRed),
            onPressed: () => _confirmDelete(context, state),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ── Hero ──────────────────────────────────────────────
          Container(
            color: kSurface,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(trade.pair,
                        style: const TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 22)),
                    const SizedBox(width: 10),
                    DirChip(trade.direction),
                  ]),
                  const SizedBox(height: 4),
                  Text(trade.date, style: const TextStyle(color: kText2, fontSize: 13)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  ScoreBadge(trade.score),
                  const SizedBox(height: 6),
                  OutcomeChip(trade.outcome),
                ]),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorder),

          // ── Trade info ────────────────────────────────────────
          SectionCard(title: 'Trade Info', children: [
            InfoRow(label: 'SL Size',       value: trade.slPips.isEmpty ? '—' : '${trade.slPips} pips'),
            InfoRow(label: 'RR Ratio',      value: trade.rr.isEmpty ? '—' : '${trade.rr}R', odd: true),
            InfoRow(label: 'Partial at R',  value: trade.partialRR.isEmpty ? '—' : '${trade.partialRR}R'),
            InfoRow(label: 'Partial Level', value: trade.partialLevel.isEmpty ? '—' : trade.partialLevel, odd: true),
            if (trade.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Notes', style: TextStyle(color: kText2, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(trade.notes, style: const TextStyle(color: kText, fontSize: 13)),
                ]),
              ),
          ]),

          // ── Checklist breakdown ───────────────────────────────
          SectionCard(
            title: 'Checklist Breakdown',
            children: state.checklist.asMap().entries.map((e) {
              final i    = e.key;
              final sec  = e.value;
              final pts  = trade.selections[sec.id];
              final matched = pts == null
                  ? 'Not scored'
                  : sec.options.firstWhere((o) => o.score == pts,
                        orElse: () => sec.options.first).label;
              final ptsCol = pts == null
                  ? kText2
                  : pts == sec.max ? kGreen : pts > 0 ? kAmber : kText2;
              return Container(
                color: i.isOdd ? kSurface2 : kSurface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sec.title, style: const TextStyle(color: kText2, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(matched, style: const TextStyle(color: kText, fontSize: 13)),
                  ])),
                  if (pts != null)
                    Text('$pts/${sec.max}',
                        style: TextStyle(color: ptsCol, fontWeight: FontWeight.bold)),
                ]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Delete Trade', style: TextStyle(color: kText)),
        content: const Text('Permanently delete this trade?', style: TextStyle(color: kText2)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              state.deleteTrade(tradeId);
              Navigator.pop(context);   // close dialog
              Navigator.pop(context);   // back to journal
            },
            child: const Text('Delete', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }
}
