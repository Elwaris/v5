// lib/screens/checklist_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/checklist.dart';
import '../theme.dart';

class ChecklistEditorScreen extends StatefulWidget {
  const ChecklistEditorScreen({super.key});
  @override
  State<ChecklistEditorScreen> createState() => _ChecklistEditorScreenState();
}

class _ChecklistEditorScreenState extends State<ChecklistEditorScreen> {
  late List<CheckSection> _cl;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    // deep copy so edits don't affect live state until saved
    _cl = context.read<AppState>().checklist
        .map((s) => CheckSection.fromJson(s.toJson()))
        .toList();
  }

  void _save() {
    context.read<AppState>().updateChecklist(_cl);
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist saved.')));
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Reset Checklist', style: TextStyle(color: kText)),
        content: const Text('Reset to factory defaults? All customisations will be lost.',
            style: TextStyle(color: kText2)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _cl = defaultChecklist(); _dirty = true; });
            },
            child: const Text('Reset', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit Checklist'),
          actions: [
            TextButton(
              onPressed: _reset,
              child: const Text('Reset', style: TextStyle(color: kRed)),
            ),
            TextButton(
              onPressed: _dirty ? _save : null,
              child: Text('Save',
                  style: TextStyle(
                      color: _dirty ? kPrimary : kText2,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Column(children: [
          Container(
            color: kSurface2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'Rename sections, adjust scores, add or remove options. Tap Save when done.',
              style: TextStyle(color: kText2, fontSize: 12),
            ),
          ),
          const Divider(height: 1, color: kBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                ..._cl.asMap().entries.map((e) => _SectionEditor(
                      section: e.value,
                      onChanged: () => setState(() => _dirty = true),
                      onRemove: () => setState(() { _cl.removeAt(e.key); _dirty = true; }),
                    )),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary, side: const BorderSide(color: kPrimary)),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Section'),
                    onPressed: () => setState(() {
                      _cl.add(CheckSection(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        title: 'New Section', max: 10,
                        options: [
                          CheckOption(label: 'Option A', score: 10),
                          CheckOption(label: 'Option B', score: 0),
                        ],
                      ));
                      _dirty = true;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ]),
        floatingActionButton: _dirty
            ? FloatingActionButton.extended(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Checklist'),
              )
            : null,
      );
}

// ── Individual section editor ────────────────────────────────────
class _SectionEditor extends StatefulWidget {
  final CheckSection section;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  const _SectionEditor(
      {required this.section, required this.onChanged, required this.onRemove});
  @override
  State<_SectionEditor> createState() => _SectionEditorState();
}

class _SectionEditorState extends State<_SectionEditor> {
  bool _expanded = true;
  late TextEditingController _titleCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.section.title)
      ..addListener(() { widget.section.title = _titleCtrl.text; widget.onChanged(); });
    _maxCtrl = TextEditingController(text: widget.section.max.toString())
      ..addListener(() {
        final v = int.tryParse(_maxCtrl.text);
        if (v != null) { widget.section.max = v; widget.onChanged(); }
      });
    _noteCtrl = TextEditingController(text: widget.section.note)
      ..addListener(() { widget.section.note = _noteCtrl.text; widget.onChanged(); });
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _maxCtrl.dispose(); _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Column(children: [
          // header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              color: kSurface2,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Expanded(child: Text(widget.section.title,
                    style: const TextStyle(color: kText, fontWeight: FontWeight.bold))),
                Text('max ${widget.section.max}%',
                    style: const TextStyle(color: kText2, fontSize: 12)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: kSurface,
                      title: const Text('Remove Section', style: TextStyle(color: kText)),
                      content: const Text('Remove this section?', style: TextStyle(color: kText2)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(onPressed: () { Navigator.pop(context); widget.onRemove(); },
                            child: const Text('Remove', style: TextStyle(color: kRed))),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.delete_outline, color: kRed, size: 20),
                ),
                const SizedBox(width: 4),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: kText2),
              ]),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: kBorder),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // title field
                Row(children: [
                  const SizedBox(width: 60,
                      child: Text('Title', style: TextStyle(color: kText2, fontSize: 12))),
                  Expanded(child: TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(color: kText, fontSize: 13),
                    decoration: const InputDecoration(isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  )),
                ]),
                const SizedBox(height: 10),
                // max score
                Row(children: [
                  const SizedBox(width: 60,
                      child: Text('Max pts', style: TextStyle(color: kText2, fontSize: 12))),
                  SizedBox(width: 70, child: TextField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: kText, fontSize: 13),
                    decoration: const InputDecoration(isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  )),
                ]),
                const SizedBox(height: 10),
                // note
                Row(children: [
                  const SizedBox(width: 60,
                      child: Text('Note', style: TextStyle(color: kText2, fontSize: 12))),
                  Expanded(child: TextField(
                    controller: _noteCtrl,
                    style: const TextStyle(color: kText, fontSize: 13),
                    decoration: const InputDecoration(isDense: true, hintText: 'Optional note',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  )),
                ]),
                const SizedBox(height: 14),
                const Text('Options', style: TextStyle(color: kText2, fontSize: 12)),
                const SizedBox(height: 6),
                ...widget.section.options.asMap().entries.map((e) => _OptionRow(
                      option: e.value,
                      onChanged: widget.onChanged,
                      onRemove: () => setState(() {
                        widget.section.options.removeAt(e.key);
                        widget.onChanged();
                      }),
                    )),
                const SizedBox(height: 6),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: kPrimary),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add option', style: TextStyle(fontSize: 13)),
                  onPressed: () => setState(() {
                    widget.section.options.add(CheckOption(label: 'New option', score: 0));
                    widget.onChanged();
                  }),
                ),
              ]),
            ),
          ],
        ]),
      );
}

// ── Single option row editor ─────────────────────────────────────
class _OptionRow extends StatefulWidget {
  final CheckOption option;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  const _OptionRow({required this.option, required this.onChanged, required this.onRemove});
  @override
  State<_OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends State<_OptionRow> {
  late TextEditingController _labelCtrl;
  late TextEditingController _scoreCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.option.label)
      ..addListener(() { widget.option.label = _labelCtrl.text; widget.onChanged(); });
    _scoreCtrl = TextEditingController(text: widget.option.score.toString())
      ..addListener(() {
        final v = int.tryParse(_scoreCtrl.text);
        if (v != null) { widget.option.score = v; widget.onChanged(); }
      });
  }

  @override
  void dispose() { _labelCtrl.dispose(); _scoreCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _labelCtrl,
            style: const TextStyle(color: kText, fontSize: 13),
            decoration: const InputDecoration(isDense: true, hintText: 'Option label',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
          )),
          const SizedBox(width: 8),
          SizedBox(width: 64, child: TextField(
            controller: _scoreCtrl,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            style: const TextStyle(color: kText, fontSize: 13),
            decoration: const InputDecoration(isDense: true, hintText: 'pts',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
          )),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: kRed),
            onPressed: widget.onRemove,
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
        ]),
      );
}
