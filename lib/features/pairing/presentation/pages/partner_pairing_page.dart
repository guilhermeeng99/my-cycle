import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mycycle/app/router/routes.dart';
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
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(BloomIcons.arrowLeft),
          onPressed: () => context.go(AppRoutes.pairingChoice),
        ),
        title: Text(t.partnerPairing.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(BloomSpacing.screenEdge),
          child: BlocConsumer<PartnerPairingCubit, PartnerPairingState>(
            listener: (context, state) {
              if (state is PartnerPairingFailureState) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(_failureLabel(t, state.failure)),
                    ),
                  );
              }
            },
            builder: (context, state) {
              final isRedeeming = state is PartnerPairingRedeeming;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: BloomSpacing.s24),
                  Text(
                    t.partnerPairing.heading,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: BloomSpacing.s8),
                  Text(
                    t.partnerPairing.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: BloomSpacing.sectionGap),
                  TextField(
                    controller: _codeCtrl,
                    enabled: !isRedeeming,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp('[A-Z2-9]'),
                      ),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      letterSpacing: 6,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: t.partnerPairing.codeHint,
                    ),
                    onChanged: (_) {
                      context.read<PartnerPairingCubit>().reset();
                    },
                    onSubmitted: (v) =>
                        context.read<PartnerPairingCubit>().redeem(v),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: isRedeeming || _codeCtrl.text.length < 6
                        ? null
                        : () => context
                            .read<PartnerPairingCubit>()
                            .redeem(_codeCtrl.text),
                    child: isRedeeming
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
                        : Text(t.partnerPairing.redeem),
                  ),
                  const SizedBox(height: BloomSpacing.s16),
                ],
              );
            },
          ),
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
