import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/pairing/domain/entities/invite_code.dart';
import 'package:mycycle/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class CoupleBondCard extends StatelessWidget {
  const CoupleBondCard({required this.state, super.key});

  final SettingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final couple = state.couple;
    if (couple == null) {
      return _BondShell(
        icon: BloomIcons.heart,
        title: context.t.settings.coupleNotFound,
        body: '',
      );
    }

    final isPaired = couple.isPaired;
    final isOwner = state.user.role == UserRole.owner;
    final t = context.t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _BondShell(
          icon: BloomIcons.heart,
          title: isPaired
              ? t.settings.couplePairedTitle
              : t.settings.coupleSoloTitle,
          body: isPaired
              ? t.settings.couplePairedSubtitle
              : t.settings.coupleSoloSubtitle,
          accent: true,
        ),
        if (isOwner && !isPaired) ...<Widget>[
          const SizedBox(height: BloomSpacing.s16),
          _InviteSection(state: state),
        ],
        if (!isOwner && isPaired) ...<Widget>[
          const SizedBox(height: BloomSpacing.s12),
          const _LeaveCoupleAction(),
        ],
      ],
    );
  }
}

class _BondShell extends StatelessWidget {
  const _BondShell({
    required this.icon,
    required this.title,
    required this.body,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(BloomSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: accent
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  tint.withValues(alpha: 0.10),
                  tint.withValues(alpha: 0.04),
                ],
              )
            : null,
        color: accent ? null : theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: tint),
          ),
          const SizedBox(width: BloomSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (body.isNotEmpty) ...<Widget>[
                  const SizedBox(height: BloomSpacing.s4),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteSection extends StatelessWidget {
  const _InviteSection({required this.state});
  final SettingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final invite = state.activeInviteCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (invite != null) _InviteCodeBlock(invite: invite),
        if (invite != null) const SizedBox(height: BloomSpacing.s12),
        FilledButton.tonalIcon(
          onPressed: state.isGeneratingInvite
              ? null
              : () => _generate(context),
          icon: state.isGeneratingInvite
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(BloomIcons.link, size: 16),
          label: Text(
            invite == null
                ? t.settings.generateInvite
                : t.settings.regenerateInvite,
          ),
        ),
      ],
    );
  }

  Future<void> _generate(BuildContext context) async {
    final t = context.t;
    final result = await context.read<SettingsCubit>().generateInviteCode();
    if (!context.mounted) return;
    if (result is Err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.settings.inviteError)),
      );
    }
  }
}

class _InviteCodeBlock extends StatelessWidget {
  const _InviteCodeBlock({required this.invite});
  final InviteCode invite;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMMd(locale).add_jm();
    return Container(
      padding: const EdgeInsets.all(BloomSpacing.s20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            t.settings.inviteCodeTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: BloomSpacing.s8),
          Row(
            children: <Widget>[
              Expanded(
                child: SelectableText(
                  invite.code,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(BloomIcons.copy, size: 16),
                tooltip: t.settings.copyCode,
                onPressed: () => _copy(context, invite.code),
              ),
            ],
          ),
          const SizedBox(height: BloomSpacing.s4),
          Text(
            t.settings.inviteExpiresAt(time: fmt.format(invite.expiresAt)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String code) async {
    final t = context.t;
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.settings.copiedToClipboard)),
    );
  }
}

class _LeaveCoupleAction extends StatelessWidget {
  const _LeaveCoupleAction();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () => _confirm(context),
      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
      child: Text(t.settings.leaveCouple),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final t = context.t;
    final cubit = context.read<SettingsCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.settings.leaveCoupleConfirmTitle),
        content: Text(t.settings.leaveCoupleConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.settings.leaveCouple),
          ),
        ],
      ),
    );
    if (ok ?? false) await cubit.leaveCouple();
  }
}
