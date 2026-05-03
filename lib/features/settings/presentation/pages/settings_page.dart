import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/app/theme/theme_cubit.dart';
import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/biometric/domain/repositories/biometric_repository.dart';
import 'package:mycycle/features/pairing/domain/entities/invite_code.dart';
import 'package:mycycle/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.title)),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) => switch (state) {
            SettingsLoading() =>
              const Center(child: CircularProgressIndicator()),
            SettingsLoaded() => _LoadedBody(state: state),
          },
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});
  final SettingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListView(
      padding: const EdgeInsets.all(BloomSpacing.screenEdge),
      children: <Widget>[
        _SectionTitle(t.settings.account),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(state.user.name),
          subtitle: Text(state.user.email),
        ),
        const SizedBox(height: BloomSpacing.sectionGap),
        _SectionTitle(t.settings.language),
        _LanguageRadio(current: state.user.language),
        const SizedBox(height: BloomSpacing.sectionGap),
        _SectionTitle(t.settings.notifications),
        _NotificationsToggle(enabled: state.user.notificationsEnabled),
        const SizedBox(height: BloomSpacing.sectionGap),
        _SectionTitle(t.settings.appearance),
        const _AppearanceRadio(),
        const SizedBox(height: BloomSpacing.sectionGap),
        if (state.user.role == UserRole.owner && state.couple != null) ...[
          _SectionTitle(t.cycleDefaults.title),
          _CycleDefaultsSection(couple: state.couple!),
          const SizedBox(height: BloomSpacing.sectionGap),
        ],
        _SectionTitle(t.settings.couple),
        _CoupleSection(state: state),
        const SizedBox(height: BloomSpacing.sectionGap),
        _BiometricToggle(enabled: state.user.biometricEnabled),
        const SizedBox(height: BloomSpacing.sectionGap),
        _SectionTitle(t.settings.session),
        _SignOutButton(isSigningOut: state.isSigningOut),
        const SizedBox(height: BloomSpacing.sectionGap),
        _SectionTitle(t.about.title),
        const _AboutSection(),
      ],
    );
  }
}

class _CycleDefaultsSection extends StatefulWidget {
  const _CycleDefaultsSection({required this.couple});
  final Couple couple;

  @override
  State<_CycleDefaultsSection> createState() => _CycleDefaultsSectionState();
}

class _CycleDefaultsSectionState extends State<_CycleDefaultsSection> {
  late int _cycleLength = widget.couple.defaultCycleLength;
  late int _lutealLength = widget.couple.defaultLutealLength;

  @override
  void didUpdateWidget(_CycleDefaultsSection old) {
    super.didUpdateWidget(old);
    if (old.couple.defaultCycleLength != widget.couple.defaultCycleLength) {
      _cycleLength = widget.couple.defaultCycleLength;
    }
    if (old.couple.defaultLutealLength != widget.couple.defaultLutealLength) {
      _lutealLength = widget.couple.defaultLutealLength;
    }
  }

  Future<void> _commit({int? cycle, int? luteal}) async {
    final cubit = context.read<SettingsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.t.cycleDefaults.saveError;
    final result = await cubit.updateCycleDefaults(
      defaultCycleLength: cycle,
      defaultLutealLength: luteal,
    );
    if (result is Err) {
      messenger.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          t.cycleDefaults.cycleLengthLabel,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: BloomSpacing.s4),
        Text(
          t.cycleDefaults.cycleLengthHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Slider(
          min: 21,
          max: 45,
          divisions: 24,
          value: _cycleLength.toDouble(),
          label: t.cycleDefaults.daysCount(n: _cycleLength.toString()),
          onChanged: (v) => setState(() => _cycleLength = v.round()),
          onChangeEnd: (v) => _commit(cycle: v.round()),
        ),
        const SizedBox(height: BloomSpacing.s8),
        Text(
          t.cycleDefaults.lutealLengthLabel,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: BloomSpacing.s4),
        Text(
          t.cycleDefaults.lutealLengthHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Slider(
          min: 10,
          max: 16,
          divisions: 6,
          value: _lutealLength.toDouble(),
          label: t.cycleDefaults.daysCount(n: _lutealLength.toString()),
          onChanged: (v) => setState(() => _lutealLength = v.round()),
          onChangeEnd: (v) => _commit(luteal: v.round()),
        ),
      ],
    );
  }
}

class _BiometricToggle extends StatefulWidget {
  const _BiometricToggle({required this.enabled});
  final bool enabled;

  @override
  State<_BiometricToggle> createState() => _BiometricToggleState();
}

class _BiometricToggleState extends State<_BiometricToggle> {
  bool? _available;

  @override
  void initState() {
    super.initState();
    unawaited(_checkAvailability());
  }

  Future<void> _checkAvailability() async {
    final available = await getIt<BiometricRepository>().isAvailable();
    if (!mounted) return;
    setState(() => _available = available);
  }

  @override
  Widget build(BuildContext context) {
    if (_available == false) return const SizedBox.shrink();
    final t = context.t;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(t.biometric.lockedTitle),
      subtitle: Text(t.biometric.lockedBody),
      value: widget.enabled,
      onChanged: (v) async {
        await context
            .read<SettingsCubit>()
            .setBiometricEnabled(enabled: v);
      },
    );
  }
}

class _AboutSection extends StatefulWidget {
  const _AboutSection();

  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  String? _version;

  @override
  void initState() {
    super.initState();
    unawaited(_loadVersion());
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.about.version),
          trailing: Text(_version ?? '—'),
        ),
        const SizedBox(height: BloomSpacing.s8),
        Text(t.about.privacyHeading, style: theme.textTheme.titleSmall),
        const SizedBox(height: BloomSpacing.s8),
        Text(
          t.about.privacyBody,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BloomSpacing.s8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _LanguageRadio extends StatelessWidget {
  const _LanguageRadio({required this.current});
  final AppLanguage current;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Future<void> select(AppLanguage lang) async {
      final cubit = context.read<SettingsCubit>();
      final result = await cubit.updateLanguage(lang);
      if (!context.mounted) return;
      if (result is Err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.languageError)),
        );
      } else {
        // Apply the locale immediately.
        await LocaleSettings.setLocale(
          lang == AppLanguage.en ? AppLocale.en : AppLocale.ptBr,
        );
      }
    }

    return RadioGroup<AppLanguage>(
      groupValue: current,
      onChanged: (v) => v == null ? null : select(v),
      child: Column(
        children: <Widget>[
          RadioListTile<AppLanguage>(
            contentPadding: EdgeInsets.zero,
            title: Text(t.settings.languageEn),
            value: AppLanguage.en,
          ),
          RadioListTile<AppLanguage>(
            contentPadding: EdgeInsets.zero,
            title: Text(t.settings.languagePtBr),
            value: AppLanguage.ptBr,
          ),
        ],
      ),
    );
  }
}

class _AppearanceRadio extends StatelessWidget {
  const _AppearanceRadio();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return RadioGroup<ThemeMode>(
          groupValue: mode,
          onChanged: (v) =>
              v == null ? null : context.read<ThemeCubit>().setThemeMode(v),
          child: Column(
            children: <Widget>[
              RadioListTile<ThemeMode>(
                contentPadding: EdgeInsets.zero,
                title: Text(t.settings.themeSystem),
                value: ThemeMode.system,
              ),
              RadioListTile<ThemeMode>(
                contentPadding: EdgeInsets.zero,
                title: Text(t.settings.themeLight),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                contentPadding: EdgeInsets.zero,
                title: Text(t.settings.themeDark),
                value: ThemeMode.dark,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationsToggle extends StatelessWidget {
  const _NotificationsToggle({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(t.settings.notificationsTitle),
      subtitle: Text(t.settings.notificationsBody),
      value: enabled,
      onChanged: (v) async {
        final result = await context
            .read<SettingsCubit>()
            .setNotificationsEnabled(enabled: v);
        if (!context.mounted) return;
        if (result is Err) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.settings.notificationsError)),
          );
        }
      },
    );
  }
}

class _CoupleSection extends StatelessWidget {
  const _CoupleSection({required this.state});
  final SettingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final couple = state.couple;

    if (couple == null) {
      return Text(
        t.settings.coupleNotFound,
        style: theme.textTheme.bodyMedium,
      );
    }

    final isOwner = state.user.role == UserRole.owner;
    final isPaired = couple.isPaired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isPaired)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.settings.couplePairedTitle),
            subtitle: Text(t.settings.couplePairedSubtitle),
          )
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.settings.coupleSoloTitle),
            subtitle: Text(t.settings.coupleSoloSubtitle),
          ),
        if (isOwner && !isPaired) _InviteCodeSection(state: state),
        if (!isOwner && isPaired) _LeaveCoupleButton(state: state),
      ],
    );
  }
}

class _InviteCodeSection extends StatelessWidget {
  const _InviteCodeSection({required this.state});
  final SettingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final invite = state.activeInviteCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (invite != null) _InviteCodeCard(invite: invite),
        const SizedBox(height: BloomSpacing.s8),
        OutlinedButton.icon(
          onPressed: state.isGeneratingInvite
              ? null
              : () async {
                  final result = await context
                      .read<SettingsCubit>()
                      .generateInviteCode();
                  if (!context.mounted) return;
                  if (result is Err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.settings.inviteError)),
                    );
                  }
                },
          icon: state.isGeneratingInvite
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                )
              : const Icon(BloomIcons.link),
          label: Text(
            invite == null
                ? t.settings.generateInvite
                : t.settings.regenerateInvite,
          ),
        ),
      ],
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.invite});
  final InviteCode invite;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMMd(locale).add_jm();
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BloomRadii.card),
      child: Padding(
        padding: const EdgeInsets.all(BloomSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              t.settings.inviteCodeTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: BloomSpacing.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SelectableText(
                  invite.code,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 6,
                  ),
                ),
                IconButton(
                  icon: const Icon(BloomIcons.copy),
                  tooltip: t.settings.copyCode,
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: invite.code),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.settings.copiedToClipboard)),
                    );
                  },
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
      ),
    );
  }
}

class _LeaveCoupleButton extends StatelessWidget {
  const _LeaveCoupleButton({required this.state});
  final SettingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return TextButton.icon(
      onPressed: state.isLeavingCouple
          ? null
          : () async {
              final confirmed = await _confirm(context);
              if (!confirmed || !context.mounted) return;
              await context.read<SettingsCubit>().leaveCouple();
            },
      icon: const Icon(BloomIcons.signOut),
      label: Text(t.settings.leaveCouple),
    );
  }

  Future<bool> _confirm(BuildContext context) async {
    final t = context.t;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.settings.leaveCoupleConfirmTitle),
        content: Text(t.settings.leaveCoupleConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.common.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.settings.leaveCouple),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.isSigningOut});
  final bool isSigningOut;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return OutlinedButton.icon(
      onPressed: isSigningOut
          ? null
          : () => context.read<SettingsCubit>().signOut(),
      icon: const Icon(BloomIcons.signOut),
      label: Text(t.signIn.signOut),
    );
  }
}
