import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/app/theme/theme_cubit.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/biometric/domain/repositories/biometric_repository.dart';
import 'package:mycycle/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:mycycle/features/settings/presentation/widgets/couple_bond_card.dart';
import 'package:mycycle/features/settings/presentation/widgets/cycle_defaults_sheet.dart';
import 'package:mycycle/features/settings/presentation/widgets/identity_card.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
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
    final isOwner = state.user.role == UserRole.owner;
    final couple = state.couple;

    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
      children: <Widget>[
        BloomLargeHeader(title: t.settings.title),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.screenEdge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              IdentityCard(user: state.user),
              const SizedBox(height: BloomSpacing.s16),
              CoupleBondCard(state: state),
              const SizedBox(height: BloomSpacing.sectionGap),

              BloomGroupHeader(t.settings.preferences),
              BloomGroupedList(
                children: <Widget>[
                  _LanguageTile(current: state.user.language),
                  const _AppearanceTile(),
                ],
              ),
              const SizedBox(height: BloomSpacing.sectionGap),

              BloomGroupHeader(t.settings.privacy),
              _PrivacyGroup(
                notificationsEnabled: state.user.notificationsEnabled,
                biometricEnabled: state.user.biometricEnabled,
              ),
              const SizedBox(height: BloomSpacing.sectionGap),

              if (isOwner && couple != null) ...<Widget>[
                BloomGroupHeader(t.cycleDefaults.title),
                BloomGroupedList(
                  children: <Widget>[
                    BloomSettingsTile(
                      icon: BloomIcons.cycle,
                      title: t.cycleDefaults.cycleLengthLabel,
                      value: t.cycleDefaults.daysCount(
                        n: couple.defaultCycleLength.toString(),
                      ),
                      onTap: () => CycleDefaultsSheet.show(
                        context,
                        couple: couple,
                        field: CycleDefaultsField.cycle,
                      ),
                    ),
                    BloomSettingsTile(
                      icon: BloomIcons.moon,
                      title: t.cycleDefaults.lutealLengthLabel,
                      value: t.cycleDefaults.daysCount(
                        n: couple.defaultLutealLength.toString(),
                      ),
                      onTap: () => CycleDefaultsSheet.show(
                        context,
                        couple: couple,
                        field: CycleDefaultsField.luteal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BloomSpacing.sectionGap),
              ],

              BloomGroupHeader(t.about.title),
              const _AboutGroup(),

              const SizedBox(height: BloomSpacing.sectionGap),
              const _SignOutAction(),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.current});
  final AppLanguage current;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return BloomSettingsTile(
      icon: BloomIcons.globe,
      title: t.settings.language,
      bottom: BloomSegmented<AppLanguage>(
        value: current,
        segments: <BloomSegment<AppLanguage>>[
          BloomSegment(value: AppLanguage.en, label: t.settings.languageEn),
          BloomSegment(
            value: AppLanguage.ptBr,
            label: t.settings.languagePtBr,
          ),
        ],
        onChanged: (lang) => _select(context, lang),
      ),
    );
  }

  Future<void> _select(BuildContext context, AppLanguage lang) async {
    final t = context.t;
    final cubit = context.read<SettingsCubit>();
    final result = await cubit.updateLanguage(lang);
    if (!context.mounted) return;
    if (result is Err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.settings.languageError)),
      );
      return;
    }
    await LocaleSettings.setLocale(
      lang == AppLanguage.en ? AppLocale.en : AppLocale.ptBr,
    );
  }
}

class _AppearanceTile extends StatelessWidget {
  const _AppearanceTile();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => BloomSettingsTile(
        icon: BloomIcons.appearance,
        title: t.settings.appearance,
        bottom: BloomSegmented<ThemeMode>(
          value: mode,
          segments: <BloomSegment<ThemeMode>>[
            BloomSegment(
              value: ThemeMode.system,
              label: t.settings.themeSystem,
            ),
            BloomSegment(value: ThemeMode.light, label: t.settings.themeLight),
            BloomSegment(value: ThemeMode.dark, label: t.settings.themeDark),
          ],
          onChanged: (m) => context.read<ThemeCubit>().setThemeMode(m),
        ),
      ),
    );
  }
}

class _PrivacyGroup extends StatefulWidget {
  const _PrivacyGroup({
    required this.notificationsEnabled,
    required this.biometricEnabled,
  });
  final bool notificationsEnabled;
  final bool biometricEnabled;

  @override
  State<_PrivacyGroup> createState() => _PrivacyGroupState();
}

class _PrivacyGroupState extends State<_PrivacyGroup> {
  bool? _bioAvailable;

  @override
  void initState() {
    super.initState();
    unawaited(_checkBio());
  }

  Future<void> _checkBio() async {
    final available = await getIt<BiometricRepository>().isAvailable();
    if (!mounted) return;
    setState(() => _bioAvailable = available);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tiles = <Widget>[
      BloomSettingsTile(
        icon: BloomIcons.bell,
        title: t.settings.notificationsTitle,
        subtitle: t.settings.notificationsBody,
        trailing: Switch.adaptive(
          value: widget.notificationsEnabled,
          onChanged: _toggleNotifications,
        ),
      ),
      if (_bioAvailable ?? false)
        BloomSettingsTile(
          icon: BloomIcons.shield,
          title: t.biometric.lockedTitle,
          subtitle: t.biometric.lockedBody,
          trailing: Switch.adaptive(
            value: widget.biometricEnabled,
            onChanged: (v) => context
                .read<SettingsCubit>()
                .setBiometricEnabled(enabled: v),
          ),
        ),
    ];

    return BloomGroupedList(children: tiles);
  }

  Future<void> _toggleNotifications(bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.t.settings.notificationsError;
    final result = await context
        .read<SettingsCubit>()
        .setNotificationsEnabled(enabled: value);
    if (!mounted) return;
    if (result is Err) {
      messenger.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }
}

class _AboutGroup extends StatefulWidget {
  const _AboutGroup();

  @override
  State<_AboutGroup> createState() => _AboutGroupState();
}

class _AboutGroupState extends State<_AboutGroup> {
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
    return BloomGroupedList(
      children: <Widget>[
        BloomSettingsTile(
          icon: BloomIcons.info,
          title: t.about.version,
          value: _version ?? '—',
        ),
        BloomSettingsTile(
          icon: BloomIcons.shield,
          title: t.about.privacyHeading,
          subtitle: t.about.privacyBody,
        ),
      ],
    );
  }
}

class _SignOutAction extends StatelessWidget {
  const _SignOutAction();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isSigningOut =
            state is SettingsLoaded && state.isSigningOut;
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: BloomRadii.card,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isSigningOut
                ? null
                : () => context.read<SettingsCubit>().signOut(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BloomSpacing.s16,
                vertical: BloomSpacing.s16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isSigningOut)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.error,
                        ),
                      ),
                    )
                  else
                    Icon(
                      BloomIcons.signOut,
                      size: 14,
                      color: theme.colorScheme.error,
                    ),
                  const SizedBox(width: BloomSpacing.s8),
                  Text(
                    t.signIn.signOut,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
