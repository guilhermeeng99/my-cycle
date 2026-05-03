import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mycycle/app/router/routes.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/pairing/domain/failures/pairing_failure.dart';
import 'package:mycycle/features/pairing/presentation/cubits/partner_pairing_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class PartnerPairingPage extends StatefulWidget {
  const PartnerPairingPage({super.key});

  @override
  State<PartnerPairingPage> createState() => _PartnerPairingPageState();
}

class _PartnerPairingPageState extends State<PartnerPairingPage> {
  late final TextEditingController _codeCtrl;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController();
    _codeCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PartnerPairingCubit, PartnerPairingState>(
          listener: (context, state) {
            if (state is PartnerPairingFailureState) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(_failureLabel(t, state.failure))),
                );
            }
          },
          builder: (context, state) {
            final isRedeeming = state is PartnerPairingRedeeming;
            final canSubmit = !isRedeeming && _codeCtrl.text.length == 6;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BloomSpacing.screenEdge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _BackBar(
                    onBack: () => context.go(AppRoutes.pairingChoice),
                  ),
                  const SizedBox(height: BloomSpacing.s8),
                  BloomLargeHeader(
                    title: t.partnerPairing.heading,
                    subtitle: t.partnerPairing.body,
                  ),
                  _CodeField(
                    controller: _codeCtrl,
                    enabled: !isRedeeming,
                    hint: t.partnerPairing.codeHint,
                    onChanged: (_) {
                      context.read<PartnerPairingCubit>().reset();
                    },
                    onSubmitted: (v) =>
                        context.read<PartnerPairingCubit>().redeem(v),
                  ),
                  const Spacer(),
                  BloomPrimaryButton(
                    label: t.partnerPairing.redeem,
                    loading: isRedeeming,
                    icon: BloomIcons.heart,
                    onPressed: canSubmit
                        ? () => context
                            .read<PartnerPairingCubit>()
                            .redeem(_codeCtrl.text)
                        : null,
                  ),
                  const SizedBox(height: BloomSpacing.s24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _failureLabel(Translations t, PairingFailure failure) {
    return switch (failure) {
      InvalidInviteCode() => t.partnerPairing.errorInvalid,
      ExpiredInviteCode() => t.partnerPairing.errorExpired,
      CoupleFull() => t.partnerPairing.errorFull,
      AlreadyInCouple() => t.partnerPairing.errorAlreadyInCouple,
      PairingNetworkFailure() => t.partnerPairing.errorNetwork,
      PairingStorageFailure() ||
      UnknownPairingFailure() =>
        t.partnerPairing.errorGeneric,
    };
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: BloomSpacing.s8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: theme.colorScheme.surface,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.all(BloomSpacing.s12),
              child: Icon(BloomIcons.chevronLeft, size: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.enabled,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.s24,
        vertical: BloomSpacing.s20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[A-Z2-9]')),
          LengthLimitingTextInputFormatter(6),
        ],
        style: theme.textTheme.displaySmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 12,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          hintText: hint,
          hintStyle: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.5),
            letterSpacing: 4,
          ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
