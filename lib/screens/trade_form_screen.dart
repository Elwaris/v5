// lib/screens/trade_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../models/trade.dart';
import '../theme.dart';
import '../widgets/shared.dart';

const _outcomes = ['TP Hit', 'SL Hit', 'Partial', 'Breakeven'];

class TradeFormScreen extends StatefulWidget {
  final String? tradeId; // null = new trade
  const TradeFormScreen({super.key, this.tradeId});
  @override
  State<TradeFormScreen> createState() => _TradeFormScreenState();
}

class _TradeFormScreenState extends State<TradeFormScreen> {
  final _pair        = TextEditingController();
  final _date        = TextEditingController();
  final _sl          = TextEditingController();
  final _rr          = TextEditingController();
  final _partialRR   = TextEditingController();
  final _partialLv   = TextEditingController();
  final _notes       = TextEditingController();

  String _direction = 'Long';
  String _outcome   = 'TP Hit';
  Map<String, int> _selections = {};
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _date.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (widget.tradeId != null) {
      final state = context.read<AppState>();
      final t = state.trades.firstWhere((x) => x.id == widget.tradeId);
      _pair.text      = t.pair;
      _date.text      = t.date;
      _direction      = t.direction;
      _sl.text        = t.slPips;
      _rr.text        = t.rr;
      _partialRR.text = t.partialRR;
      _partialLv.text = t.partialLevel;
      _outcome        = t.outcome;
      _notes.text     = t.notes;
      _selections     = Map.from(t.selections);
    }
  }

  @override
  void dispose() {
    for (final c in [_pair,_date,_sl,_rr,_partialRR,_partialLv,_notes]) c.dispose();
    super.dispose();
  }

  int get _score => context.read<AppState>().calcScore(_selections);

  void _save() {
    final pair = _pair.text.trim().toUpperCase();
    if (pair.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pair name is required.')));
      return;
    }
    final state = context.read<AppState>();
    final score = state.calcScore(_selections);
    final trade = Trade(
      id:           widget.tradeId ?? const Uuid().v4(),
      pair:         pair,
      date:         _date.text.trim().isEmpty ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : _date.text.trim(),
      direction:    _direction,
      slPips:       _sl.text.trim(),
      rr:           _rr.text.trim(),
      partialRR:    _partialRR.text.trim(),
      partialLevel: _partialLv.text.trim(),
      outcome:      _outcome,
      notes:        _notes.text.trim(),
      selections:   _selections,
      score:        score,
    );
    widget.tradeId == null ? state.addTrade(trade) : state.updateTrade(trade);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$pair  ·  $score%  —  ${scoreLabel(score)}')));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isEdit = widget.tradeId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Trade' : 'Log New Trade'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // ── Details card ──────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Trade Details',
                    style: TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 14),

                // pair + date
                Row(children: [
                  Expanded(child: TextField(
                    controller: _pair,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Pair  (e.g. EURUSD)'),
                    style: const TextStyle(color: kText),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: _date,
                    decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    style: const TextStyle(color: kText),
                  )),
                ]),
                const SizedBox(height: 14),

                // direction
                const Text('Direction', style: TextStyle(color: kText2, fontSize: 12)),
                const SizedBox(height: 6),
                Row(children: ['Long','Short'].map((d) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(d),
                    selected: _direction == d,
                    onSelected: (_) => setState(() => _direction = d),
                    selectedColor: d == 'Long' ? kGreenBg : kRedBg,
                    labelStyle: TextStyle(
                      color: _direction == d ? (d == 'Long' ? kGreen : kRed) : kText2,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: kSurface2,
                    side: BorderSide(color: _direction == d ? (d == 'Long' ? kGreen : kRed) : kBorder),
                  ),
                )).toList()),
                const SizedBox(height: 14),

                // sl + rr
                Row(children: [
                  Expanded(child: TextField(
                    controller: _sl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'SL (pips)'),
                    style: const TextStyle(color: kText),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: _rr,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'RR ratio'),
                    style: const TextStyle(color: kText),
                  )),
                ]),
                const SizedBox(height: 14),

                // partials
                Row(children: [
                  Expanded(child: TextField(
                    controller: _partialRR,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Partial at (R)'),
                    style: const TextStyle(color: kText),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: _partialLv,
                    decoration: const InputDecoration(labelText: 'Partial level/price'),
                    style: const TextStyle(color: kText),
                  )),
                ]),
                const SizedBox(height: 14),

                // outcome
                const Text('Outcome', style: TextStyle(color: kText2, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: _outcomes.map((oc) => ChoiceChip(
                  label: Text(oc),
                  selected: _outcome == oc,
                  onSelected: (_) => setState(() => _outcome = oc),
                  selectedColor: outcomeColor(oc).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _outcome == oc ? outcomeColor(oc) : kText2,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: kSurface2,
                  side: BorderSide(color: _outcome == oc ? outcomeColor(oc) : kBorder),
                )).toList()),
                const SizedBox(height: 14),

                // notes
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes / observations'),
                  style: const TextStyle(color: kText),
                ),
              ]),
            ),
          ),

          // ── Score preview ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              const Text('Checklist Score: ', style: TextStyle(color: kText2)),
              StatefulBuilder(builder: (_, ss) {
                final s = state.calcScore(_selections);
                return Text('$s%  —  ${scoreLabel(s)}',
                    style: TextStyle(color: scoreColor(s), fontWeight: FontWeight.bold));
              }),
            ]),
          ),

          // ── Checklist sections ────────────────────────────────
          ...state.checklist.map((sec) => _SectionCard(
                section: sec,
                selected: _selections[sec.id],
                onSelect: (score) => setState(() => _selections[sec.id] = score),
              )),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final dynamic section;
  final int? selected;
  final void Function(int) onSelect;
  const _SectionCard({required this.section, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(section.title,
                    style: const TextStyle(color: kText, fontWeight: FontWeight.bold))),
                Text('max ${section.max}%', style: const TextStyle(color: kText2, fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorder),
          ...section.options.map<Widget>((opt) {
            final isSel = selected == opt.score;
            final ptsCol = opt.score > 0 ? kGreen : opt.score < 0 ? kRed : kText2;
            return InkWell(
              onTap: () => onSelect(opt.score),
              child: Container(
                color: isSel ? kPrimary.withOpacity(0.08) : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSel ? kPrimary : kText2, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(opt.label, style: TextStyle(
                      color: isSel ? kText : kText2, fontSize: 13))),
                  Text('${opt.score >= 0 ? '+' : ''}${opt.score}%',
                      style: TextStyle(color: ptsCol, fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
              ),
            );
          }).toList(),
          if (section.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text('ⓘ  ${section.note}',
                  style: const TextStyle(color: kText2, fontSize: 11)),
            ),
        ]),
      );
}
