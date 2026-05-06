import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/logging/domain/usecases/save_day_log.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class DayLogSheet extends StatefulWidget {
  const DayLogSheet({
    required this.coupleId,
    required this.date,
    required this.saveDayLog,
    required this.dayLogRepository,
    this.currentCycleId,
    this.initialLog,
    this.isPartner = false,
    super.key,
  });

  final String coupleId;
  final String? currentCycleId;
  final DateTime date;
  final SaveDayLog saveDayLog;
  final DayLogRepository dayLogRepository;
  final DayLog? initialLog;
  final bool isPartner;

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
    _noteCtrl = TextEditingController(
      text: widget.isPartner
          ? (initial?.partnerNote ?? '')
          : (initial?.ownerNote ?? ''),
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    final t = context.t;

    final result = widget.isPartner
        ? await widget.dayLogRepository.savePartnerNote(
            coupleId: widget.coupleId,
            date: widget.date,
            note: _noteCtrl.text,
          )
        : await widget.saveDayLog(
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

    switch (result) {
      case Ok():
        Navigator.of(context).pop(true);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(t.log.savedSuccess)));
      case Err():
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(t.log.saveError)));
    }
  }

  Widget _buildBody(BuildContext context) {
    final t = context.t;
    if (widget.isPartner) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          BloomSpacing.screenEdge,
          BloomSpacing.s12,
          BloomSpacing.screenEdge,
          BloomSpacing.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BloomGroupHeader(t.log.partnerNoteTitle),
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: t.log.partnerNotePlaceholder,
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        BloomSpacing.screenEdge,
        BloomSpacing.s12,
        BloomSpacing.screenEdge,
        BloomSpacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BloomGroupHeader(t.log.flowTitle),
          _FlowChips(
            value: _flow,
            onChanged: (v) => setState(() => _flow = v),
          ),
          const SizedBox(height: BloomSpacing.sectionGap),
          BloomGroupHeader(t.log.moodTitle),
          _MoodChips(
            value: _mood,
            onChanged: (v) => setState(() => _mood = v),
          ),
          const SizedBox(height: BloomSpacing.sectionGap),
          BloomGroupHeader(t.log.symptomsTitle),
          _SymptomsChips(
            value: _symptoms,
            onChanged: (next) => setState(() => _symptoms = next),
          ),
          const SizedBox(height: BloomSpacing.sectionGap),
          BloomGroupHeader(t.log.noteTitle),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(hintText: t.log.notePlaceholder),
          ),
          const SizedBox(height: BloomSpacing.sectionGap),
          BloomGroupHeader(t.log.cycleMarkersTitle),
          BloomGroupedList(
            children: <Widget>[
              BloomSettingsTile(
                icon: BloomIcons.flow,
                title: t.log.markPeriodStarted,
                trailing: Switch.adaptive(
                  value: _markPeriodStarted,
                  onChanged: (v) =>
                      setState(() => _markPeriodStarted = v),
                ),
              ),
              BloomSettingsTile(
                icon: BloomIcons.check,
                title: t.log.markPeriodEnded,
                trailing: Switch.adaptive(
                  value: _markPeriodEnded,
                  onChanged: widget.currentCycleId == null
                      ? null
                      : (v) => setState(() => _markPeriodEnded = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _Handle(),
              _Header(date: widget.date),
              Flexible(child: _buildBody(context)),
              _Footer(saving: _saving, onSave: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: BloomSpacing.s8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(BloomRadii.pill),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.MMMMEEEEd(locale);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BloomSpacing.s24,
        BloomSpacing.s24,
        BloomSpacing.s16,
        BloomSpacing.s8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  t.log.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: BloomSpacing.s4),
                Text(
                  dateFmt.format(date),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.t.common.cancel,
            onPressed: () => Navigator.of(context).pop(false),
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}


class _Footer extends StatelessWidget {
  const _Footer({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        BloomSpacing.s24,
        BloomSpacing.s16,
        BloomSpacing.s24,
        BloomSpacing.s16,
      ),
      child: BloomPrimaryButton(
        label: t.common.save,
        loading: saving,
        onPressed: onSave,
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
      padding: const EdgeInsets.only(top: BloomSpacing.s12),
      child: Wrap(
        spacing: BloomSpacing.s8,
        runSpacing: BloomSpacing.s8,
        children: FlowLevel.values
            .map(
              (l) => BloomChoiceChip(
                label: label(l),
                selected: value == l,
                tint: BloomColors.phaseMenstrual,
                onTap: () => onChanged(value == l ? null : l),
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
      padding: const EdgeInsets.only(top: BloomSpacing.s12),
      child: Wrap(
        spacing: BloomSpacing.s8,
        runSpacing: BloomSpacing.s8,
        children: MoodType.values
            .map(
              (m) => BloomChoiceChip(
                label: label(m),
                selected: value == m,
                onTap: () => onChanged(value == m ? null : m),
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
      padding: const EdgeInsets.only(top: BloomSpacing.s12),
      child: Wrap(
        spacing: BloomSpacing.s8,
        runSpacing: BloomSpacing.s8,
        children: SymptomType.values
            .map(
              (s) => BloomChoiceChip(
                label: label(s),
                selected: value.contains(s),
                tint: BloomColors.plum,
                onTap: () {
                  final next = {...value};
                  if (next.contains(s)) {
                    next.remove(s);
                  } else {
                    next.add(s);
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
