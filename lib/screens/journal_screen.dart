// lib/screens/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/shared.dart';
import 'trade_form_screen.dart';
import 'trade_detail_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final trades = state.trades;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ICT Trade Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TradeFormScreen()),
            ),
          ),
        ],
      ),
      body: trades.isEmpty
          ? _empty(context)
          : Column(children: [
              _statsStrip(trades),
              const Divider(height: 1, color: kBorder),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: trades.length,
                  itemBuilder: (ctx, i) => _TradeCard(trade: trades[i]),
                ),
              ),
            ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TradeFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.receipt_long, size: 64, color: kText2),
          const SizedBox(height: 16),
          const Text('No trades logged yet.', style: TextStyle(color: kText2, fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white),
            icon: const Icon(Icons.add),
            label: const Text('Log First Trade'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TradeFormScreen()),
            ),
          ),
        ]),
      );

  Widget _statsStrip(List trades) {
    final total  = trades.length;
    final wins   = trades.where((t) => t.outcome == 'TP Hit').length;
    final wr     = total > 0 ? '${(wins / total * 100).round()}%' : '—';
    final avgS   = total > 0 ? '${(trades.map((t) => t.score).reduce((a, b) => a + b) / total).round()}%' : '—';
    final rrVals = trades.where((t) => t.rr.isNotEmpty).map((t) => double.tryParse(t.rr) ?? 0.0).toList();
    final avgRR  = rrVals.isEmpty ? '—' : '${(rrVals.reduce((a, b) => a + b) / rrVals.length).toStringAsFixed(1)}R';

    return Container(
      color: kSurface2,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _strip(total.toString(), 'Trades'),
          _strip(wr, 'Win Rate', kGreen),
          _strip(avgS, 'Avg Score', kPrimary),
          _strip(avgRR, 'Avg RR', kBlue),
        ],
      ),
    );
  }

  Widget _strip(String val, String label, [Color col = kText]) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: kText2, fontSize: 11)),
        ],
      );
}

class _TradeCard extends StatelessWidget {
  final dynamic trade;
  const _TradeCard({required this.trade});

  @override
  Widget build(BuildContext context) {
    final dirCol = trade.direction == 'Long' ? kGreen : kRed;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TradeDetailScreen(tradeId: trade.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(trade.pair,
                      style: const TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  DirChip(trade.direction),
                  const SizedBox(width: 6),
                  OutcomeChip(trade.outcome),
                ]),
                const SizedBox(height: 6),
                Text(
                  '${trade.date}  ·  SL: ${trade.slPips.isEmpty ? "—" : trade.slPips + " pips"}  ·  RR: ${trade.rr.isEmpty ? "—" : trade.rr + "R"}',
                  style: const TextStyle(color: kText2, fontSize: 12),
                ),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              ScoreBadge(trade.score),
              const SizedBox(height: 6),
              Row(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TradeFormScreen(tradeId: trade.id)),
                  ),
                  child: const Icon(Icons.edit_outlined, color: kPrimary, size: 20),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: kText2, size: 20),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }
}
