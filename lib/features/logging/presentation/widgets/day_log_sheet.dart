import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/logging/domain/usecases/save_day_log.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

/// Bottom-sheet log editor — owner only for now (partner sheet ships when
/// partner pairing arrives).
class DayLogSheet extends StatefulWidget {
  const DayLogSheet({
    required this.coupleId,
    required this.date,
    required this.saveDayLog,
    this.currentCycleId,
    this.initialLog,
    super.key,
  });

  final String coupleId;
  final String? currentCycleId;
  final DateTime date;
  final SaveDayLog saveDayLog;
  final DayLog? initialLog;

  @override
  State<DayLogSheet> createState() => _DayLogSheetState();
}

class _DayLogSheetState extends State<DayLogSheet> {
  late FlowLevel? _flow;
  late Set<SymptomType> _symptoms;
  late MoodType? _mood;
  late TextEditingController _noteCtrl;
  bool _markPeriodStarted = false;
  bool _markPeriodEnded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLog;
    _flow = initial?.flow;
    _symptoms = {...?initial?.symptoms};
    _mood = initial?.mood;
    _noteCtrl = TextEditingController(text: initial?.ownerNote ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final result = await widget.saveDayLog(
      SaveDayLogParams(
        coupleId: widget.coupleId,
        currentCycleId: widget.currentCycleId,
        date: widget.date,
        flow: _flow,
        symptoms: _symptoms,
        mood: _mood,
        ownerNote: _noteCtrl.text,
        markPeriodStarted: _markPeriodStarted,
        markPeriodEnded: _markPeriodEnded,
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    final t = context.t;
    switch (result) {
      case Ok():
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(t.log.savedSuccess)));
      case Err():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(t.log.saveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.MMMMEEEEd(locale);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            BloomSpacing.screenEdge,
            BloomSpacing.s8,
            BloomSpacing.screenEdge,
            BloomSpacing.s24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: BloomSpacing.s12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BloomRadii.pillShape,
                  ),
                ),
              ),
              Text(t.log.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: BloomSpacing.s4),
              Text(
                dateFmt.format(widget.date),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: BloomSpacing.sectionGap),
              _SectionLabel(t.log.flowTitle),
              _FlowChips(
                value: _flow,
                onChanged: (v) => setState(() => _flow = v),
              ),
              const SizedBox(height: BloomSpacing.sectionGap),
              _SectionLabel(t.log.symptomsTitle),
              _SymptomsChips(
                value: _symptoms,
                onChanged: (next) => setState(() => _symptoms = next),
              ),
              const SizedBox(height: BloomSpacing.sectionGap),
              _SectionLabel(t.log.moodTitle),
              _MoodChips(
                value: _mood,
                onChanged: (v) => setState(() => _mood = v),
              ),
              const SizedBox(height: BloomSpacing.sectionGap),
              _SectionLabel(t.log.noteTitle),
              const SizedBox(height: BloomSpacing.s8),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: t.log.notePlaceholder,
                ),
              ),
              const SizedBox(height: BloomSpacing.s16),
              _SectionLabel(t.log.cycleMarkersTitle),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.log.markPeriodStarted),
                value: _markPeriodStarted,
                onChanged: (v) => setState(() => _markPeriodStarted = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.log.markPeriodEnded),
                value: _markPeriodEnded,
                onChanged: widget.currentCycleId == null
                    ? null
                    : (v) => setState(() => _markPeriodEnded = v),
              ),
              const SizedBox(height: BloomSpacing.s24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(t.common.save),
              ),
              const SizedBox(height: BloomSpacing.s8),
              TextButton(
                onPressed:
                    _saving ? null : () => Navigator.of(context).pop(false),
                child: Text(t.common.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            letterSpacing: 0.4,
          ),
    );
  }
}

class _FlowChips extends StatelessWidget {
  const _FlowChips({required this.value, required this.onChanged});
  final FlowLevel? value;
  final ValueChanged<FlowLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    String label(FlowLevel l) => switch (l) {
          FlowLevel.spotting => t.log.flowSpotting,
          FlowLevel.light => t.log.flowLight,
          FlowLevel.medium => t.log.flowMedium,
          FlowLevel.heavy => t.log.flowHeavy,
        };
    return Padding(
      padding: const EdgeInsets.only(top: BloomSpacing.s8),
      child: Wrap(
        spacing: BloomSpacing.s8,
        runSpacing: BloomSpacing.s8,
        children: FlowLevel.values
            .map(
              (l) => FilterChip(
                label: Text(label(l)),
                selected: value == l,
                onSelected: (selected) => onChanged(selected ? l : null),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SymptomsChips extends StatelessWidget {
  const _SymptomsChips({required this.value, required this.onChanged});
  final Set<SymptomType> value;
  final ValueChanged<Set<SymptomType>> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    String label(SymptomType s) => switch (s) {
          SymptomType.cramps => t.log.symptomCramps,
          SymptomType.headache => t.log.symptomHeadache,
          SymptomType.bloating => t.log.symptomBloating,
          SymptomType.fatigue => t.log.symptomFatigue,
          SymptomType.tenderBreasts => t.log.symptomTenderBreasts,
          SymptomType.acne => t.log.symptomAcne,
          SymptomType.backPain => t.log.symptomBackPain,
          SymptomType.nausea => t.log.symptomNausea,
        };
    return Padding(
      padding: const EdgeInsets.only(top: BloomSpacing.s8),
      child: Wrap(
        spacing: BloomSpacing.s8,
        runSpacing: BloomSpacing.s8,
        children: SymptomType.values
            .map(
              (s) => FilterChip(
                label: Text(label(s)),
                selected: value.contains(s),
                onSelected: (selected) {
                  final next = {...value};
                  if (selected) {
                    next.add(s);
                  } else {
                    next.remove(s);
                  }
                  onChanged(next);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MoodChips extends StatelessWidget {
  const _MoodChips({required this.value, required this.onChanged});
  final MoodType? value;
  final ValueChanged<MoodType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    String label(MoodType m) => switch (m) {
          MoodType.happy => t.log.moodHappy,
          MoodType.calm => t.log.moodCalm,
          MoodType.irritable => t.log.moodIrritable,
          MoodType.sad => t.log.moodSad,
          MoodType.anxious => t.log.moodAnxious,
        };
    return Padding(
      padding: const EdgeInsets.only(top: BloomSpacing.s8),
      child: Wrap(
        spacing: BloomSpacing.s8,
        runSpacing: BloomSpacing.s8,
        children: MoodType.values
            .map(
              (m) => FilterChip(
                label: Text(label(m)),
                selected: value == m,
                onSelected: (selected) => onChanged(selected ? m : null),
              ),
            )
            .toList(),
      ),
    );
  }
}
