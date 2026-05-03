import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

enum CycleDefaultsField { cycle, luteal }

class CycleDefaultsSheet extends StatefulWidget {
  const CycleDefaultsSheet({
    required this.couple,
    required this.field,
    super.key,
  });

  final Couple couple;
  final CycleDefaultsField field;

  static Future<void> show(
    BuildContext context, {
    required Couple couple,
    required CycleDefaultsField field,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CycleDefaultsSheet(couple: couple, field: field),
    );
  }

  @override
  State<CycleDefaultsSheet> createState() => _CycleDefaultsSheetState();
}

class _CycleDefaultsSheetState extends State<CycleDefaultsSheet> {
  late int _value = widget.field == CycleDefaultsField.cycle
      ? widget.couple.defaultCycleLength
      : widget.couple.defaultLutealLength;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final isCycle = widget.field == CycleDefaultsField.cycle;
    final min = isCycle ? 21.0 : 10.0;
    final max = isCycle ? 45.0 : 16.0;
    final divisions = (max - min).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(BloomSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(BloomRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: BloomSpacing.s24),
            Text(
              isCycle
                  ? t.cycleDefaults.cycleLengthLabel
                  : t.cycleDefaults.lutealLengthLabel,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: BloomSpacing.s8),
            Text(
              isCycle
                  ? t.cycleDefaults.cycleLengthHint
                  : t.cycleDefaults.lutealLengthHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: BloomSpacing.s32),
            Center(
              child: Text(
                t.cycleDefaults.daysCount(n: _value.toString()),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: BloomSpacing.s16),
            Slider(
              min: min,
              max: max,
              divisions: divisions,
              value: _value.toDouble(),
              onChanged: (v) => setState(() => _value = v.round()),
              onChangeEnd: (v) => _commit(v.round()),
            ),
            const SizedBox(height: BloomSpacing.s24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.common.cancel == t.common.cancel
                  ? 'OK'
                  : t.common.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _commit(int value) async {
    final cubit = context.read<SettingsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.t.cycleDefaults.saveError;
    final result = await cubit.updateCycleDefaults(
      defaultCycleLength: widget.field == CycleDefaultsField.cycle
          ? value
          : null,
      defaultLutealLength: widget.field == CycleDefaultsField.luteal
          ? value
          : null,
    );
    if (result is Err) {
      messenger.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }
}
