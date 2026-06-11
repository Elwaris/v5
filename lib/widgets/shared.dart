// lib/widgets/shared.dart
import 'package:flutter/material.dart';
import '../theme.dart';

// ── Score badge chip ────────────────────────────────────────────
class ScoreBadge extends StatelessWidget {
  final int score;
  const ScoreBadge(this.score, {super.key});
  @override
  Widget build(BuildContext context) {
    final col = scoreColor(score);
    final lbl = scoreLabel(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: col.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: col.withOpacity(0.4)),
      ),
      child: Text('$score%  $lbl',
          style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

// ── Outcome chip ────────────────────────────────────────────────
class OutcomeChip extends StatelessWidget {
  final String outcome;
  const OutcomeChip(this.outcome, {super.key});
  @override
  Widget build(BuildContext context) {
    final col = outcomeColor(outcome);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: col.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(outcome, style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Direction chip ───────────────────────────────────────────────
class DirChip extends StatelessWidget {
  final String dir;
  const DirChip(this.dir, {super.key});
  @override
  Widget build(BuildContext context) {
    final col = dir == 'Long' ? kGreen : kRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: col.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(dir, style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Stat tile ────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String value, label;
  final Color valueColor;
  const StatTile({super.key, required this.value, required this.label, this.valueColor = kPrimary});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: kText2, fontSize: 11)),
        ]),
      );
}

// ── Mini progress bar ────────────────────────────────────────────
class MiniBar extends StatelessWidget {
  final double pct;
  final Color color;
  const MiniBar({super.key, required this.pct, required this.color});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct / 100,
          backgroundColor: kBorder,
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
        ),
      );
}

// ── Section card ─────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SectionCard({super.key, required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(title,
                  style: const TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const Divider(height: 1, color: kBorder),
            ...children,
          ]),
        ),
      );
}

// ── Info row ─────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label, value;
  final bool odd;
  const InfoRow({super.key, required this.label, required this.value, this.odd = false});
  @override
  Widget build(BuildContext context) => Container(
        color: odd ? kSurface2 : kSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          SizedBox(width: 130,
              child: Text(label, style: const TextStyle(color: kText2, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: kText, fontSize: 13))),
        ]),
      );
}
