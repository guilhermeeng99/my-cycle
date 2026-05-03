///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsPtBr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPtBr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ptBr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt-BR>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsPtBr _root = this; // ignore: unused_field

	@override 
	TranslationsPtBr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPtBr(meta: meta ?? this.$meta);

	// Translations
	@override String get appName => 'MyCycle';
	@override late final _TranslationsCommonPtBr common = _TranslationsCommonPtBr._(_root);
	@override late final _TranslationsSignInPtBr signIn = _TranslationsSignInPtBr._(_root);
	@override late final _TranslationsPairingChoicePtBr pairingChoice = _TranslationsPairingChoicePtBr._(_root);
	@override late final _TranslationsPartnerPairingPtBr partnerPairing = _TranslationsPartnerPairingPtBr._(_root);
	@override late final _TranslationsOnboardingPtBr onboarding = _TranslationsOnboardingPtBr._(_root);
	@override late final _TranslationsTodayPtBr today = _TranslationsTodayPtBr._(_root);
	@override late final _TranslationsLogPtBr log = _TranslationsLogPtBr._(_root);
	@override late final _TranslationsCalendarPtBr calendar = _TranslationsCalendarPtBr._(_root);
	@override late final _TranslationsSettingsPtBr settings = _TranslationsSettingsPtBr._(_root);
	@override late final _TranslationsPlaceholderPtBr placeholder = _TranslationsPlaceholderPtBr._(_root);
}

// Path: common
class _TranslationsCommonPtBr implements TranslationsCommonEn {
	_TranslationsCommonPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get save => 'Salvar';
	@override String get cancel => 'Cancelar';
	@override String get next => 'Próximo';
	@override String get back => 'Voltar';
	@override String get confirm => 'Confirmar';
	@override String get delete => 'Excluir';
	@override String get loading => 'Carregando…';
	@override String get retry => 'Tentar novamente';
	@override String get ok => 'OK';
}

// Path: signIn
class _TranslationsSignInPtBr implements TranslationsSignInEn {
	_TranslationsSignInPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Um diário do ciclo, calmo e privado — só pra vocês dois.';
	@override String get continueWithGoogle => 'Continuar com Google';
	@override String get privacyHint => 'Seus dados ficam no seu próprio Firebase. Só você e seu parceiro têm acesso.';
	@override String get networkError => 'Não consegui conectar ao servidor. Confira sua internet e tente de novo.';
	@override String get genericError => 'Algo deu errado no login. Tenta novamente.';
	@override String get signOut => 'Sair';
}

// Path: pairingChoice
class _TranslationsPairingChoicePtBr implements TranslationsPairingChoiceEn {
	_TranslationsPairingChoicePtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Como vocês vão usar o MyCycle?';
	@override String get subtitle => 'Dá pra mudar depois — mas só uma das duas pessoas registra o ciclo.';
	@override String get imOwner => 'Quero acompanhar meu ciclo';
	@override String get imPartner => 'Estou entrando com alguém';
}

// Path: partnerPairing
class _TranslationsPartnerPairingPtBr implements TranslationsPartnerPairingEn {
	_TranslationsPartnerPairingPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Conectar com seu parceiro';
	@override String get heading => 'Digite o código de convite';
	@override String get body => 'Peça pra sua parceira gerar um código de 6 caracteres em Configurações — depois digite aqui.';
	@override String get codeHint => 'ABC234';
	@override String get redeem => 'Conectar';
	@override String get errorInvalid => 'Esse código não parece certo. Confere e tenta de novo.';
	@override String get errorExpired => 'Esse código expirou. Peça um novo.';
	@override String get errorFull => 'Esse casal já tem parceiro.';
	@override String get errorAlreadyInCouple => 'Você já está em um casal. Saia do atual primeiro.';
	@override String get errorNetwork => 'Não consegui conectar. Confere sua internet.';
	@override String get errorGeneric => 'Algo deu errado. Tenta de novo.';
}

// Path: onboarding
class _TranslationsOnboardingPtBr implements TranslationsOnboardingEn {
	_TranslationsOnboardingPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get welcomeTitle => 'Vamos configurar seu ciclo';
	@override String get welcomeBody => 'Três perguntinhas rápidas e tá pronto. A gente nunca compartilha seus dados com ninguém.';
	@override String get getStarted => 'Começar';
	@override String get lastPeriodTitle => 'Quando começou sua última menstruação?';
	@override String get lastPeriodBody => 'Escolhe o dia 1 da sua última menstruação — o dia em que o sangramento começou.';
	@override String get pickDate => 'Escolher data';
	@override String get longAgoHint => 'Mais de 60 dias atrás? Pode escolher mesmo assim — as previsões começam com confiança baixa até a gente ter mais dados.';
	@override String get cycleLengthTitle => 'Tamanho do seu ciclo';
	@override String get cycleLengthBody => 'Do dia 1 de uma menstruação até o dia 1 da próxima. A gente vai ajustando conforme você registra.';
	@override String daysCount({required Object n}) => '${n} dias';
	@override String get notificationsTitle => 'Quer um aviso antes da menstruação?';
	@override String get notificationsBody => 'Posso te lembrar discretamente um dia antes da provável chegada. Sem streaks, sem encheção.';
	@override String get notificationsToggle => 'Quero receber lembretes';
	@override String get finish => 'Finalizar';
	@override String get errorNetwork => 'Não consegui salvar — confere a internet e tenta de novo.';
	@override String get errorValidation => 'Tem alguma resposta que não faz sentido. Dá uma conferida.';
	@override String get errorGeneric => 'Algo deu errado. Tenta de novo.';
}

// Path: today
class _TranslationsTodayPtBr implements TranslationsTodayEn {
	_TranslationsTodayPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String greeting({required Object name}) => 'Olá, ${name}';
	@override String get nextPeriodTitle => 'Próxima menstruação';
	@override String get fertileWindowTitle => 'Janela fértil';
	@override String ovulationOn({required Object date}) => 'Ovulação por volta de ${date}';
	@override String aroundRange({required Object from, required Object to}) => 'Entre ${from} e ${to}';
	@override String get confidenceLow => 'BAIXA';
	@override String get confidenceMedium => 'MÉDIA';
	@override String get confidenceHigh => 'ALTA';
	@override String lateBanner({required Object days}) => 'Sua menstruação está atrasada ${days} dias.';
	@override String get logToday => 'Registrar hoje';
	@override String get emptyMessage => 'Sem ciclo ativo. Registre sua primeira menstruação pra começar.';
	@override String get errorGeneric => 'Algo deu errado ao carregar seu ciclo.';
}

// Path: log
class _TranslationsLogPtBr implements TranslationsLogEn {
	_TranslationsLogPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Registro do dia';
	@override String get flowTitle => 'Fluxo';
	@override String get flowSpotting => 'Borra';
	@override String get flowLight => 'Leve';
	@override String get flowMedium => 'Médio';
	@override String get flowHeavy => 'Intenso';
	@override String get symptomsTitle => 'Sintomas';
	@override String get symptomCramps => 'Cólica';
	@override String get symptomHeadache => 'Dor de cabeça';
	@override String get symptomBloating => 'Inchaço';
	@override String get symptomFatigue => 'Cansaço';
	@override String get symptomTenderBreasts => 'Seios sensíveis';
	@override String get symptomAcne => 'Acne';
	@override String get symptomBackPain => 'Dor nas costas';
	@override String get symptomNausea => 'Náusea';
	@override String get moodTitle => 'Humor';
	@override String get moodHappy => 'Feliz';
	@override String get moodCalm => 'Tranquila';
	@override String get moodIrritable => 'Irritada';
	@override String get moodSad => 'Triste';
	@override String get moodAnxious => 'Ansiosa';
	@override String get noteTitle => 'Nota (opcional)';
	@override String get notePlaceholder => 'O que tá passando?';
	@override String get cycleMarkersTitle => 'Marcadores do ciclo';
	@override String get markPeriodStarted => 'Minha menstruação começou hoje';
	@override String get markPeriodEnded => 'Minha menstruação terminou neste dia';
	@override String get savedSuccess => 'Salvo.';
	@override String get saveError => 'Não consegui salvar. Tenta de novo.';
}

// Path: calendar
class _TranslationsCalendarPtBr implements TranslationsCalendarEn {
	_TranslationsCalendarPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Calendário';
	@override String get prevMonth => 'Mês anterior';
	@override String get nextMonth => 'Próximo mês';
	@override String get todayPill => 'Hoje';
	@override String get errorGeneric => 'Algo deu errado ao carregar o calendário.';
}

// Path: settings
class _TranslationsSettingsPtBr implements TranslationsSettingsEn {
	_TranslationsSettingsPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configurações';
	@override String get account => 'Conta';
	@override String get language => 'Idioma';
	@override String get languageEn => 'Inglês';
	@override String get languagePtBr => 'Português (Brasil)';
	@override String get languageError => 'Não consegui atualizar o idioma. Tenta de novo.';
	@override String get couple => 'Casal';
	@override String get coupleNotFound => 'Carregando dados do casal…';
	@override String get couplePairedTitle => 'Conectados';
	@override String get couplePairedSubtitle => 'Vocês estão pareados.';
	@override String get coupleSoloTitle => 'Sem parceiro ainda';
	@override String get coupleSoloSubtitle => 'Gere um código de convite pra compartilhar.';
	@override String get generateInvite => 'Gerar código de convite';
	@override String get regenerateInvite => 'Gerar novo código';
	@override String get inviteCodeTitle => 'Código de convite ativo';
	@override String inviteExpiresAt({required Object time}) => 'Expira às ${time}';
	@override String get inviteError => 'Não consegui gerar o código. Tenta de novo.';
	@override String get copyCode => 'Copiar código';
	@override String get copiedToClipboard => 'Código copiado.';
	@override String get leaveCouple => 'Sair do casal';
	@override String get leaveCoupleConfirmTitle => 'Sair do casal?';
	@override String get leaveCoupleConfirmBody => 'Você será removido. A dona pode te convidar de novo depois.';
	@override String get session => 'Sessão';
	@override String get notifications => 'Notificações';
	@override String get notificationsTitle => 'Lembretes de menstruação';
	@override String get notificationsBody => 'Vou te lembrar discretamente um dia antes da provável chegada.';
	@override String get notificationsError => 'Não consegui atualizar as notificações. Tenta de novo.';
}

// Path: placeholder
class _TranslationsPlaceholderPtBr implements TranslationsPlaceholderEn {
	_TranslationsPlaceholderPtBr._(this._root);

	final TranslationsPtBr _root; // ignore: unused_field

	// Translations
	@override String get themeAlive => 'Tema Bloom está vivo.';
	@override String signedInAs({required Object name}) => 'Olá, ${name}';
	@override String get nextStep => 'Próximo passo: onboarding.';
}

/// The flat map containing all translations for locale <pt-BR>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsPtBr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'MyCycle',
			'common.save' => 'Salvar',
			'common.cancel' => 'Cancelar',
			'common.next' => 'Próximo',
			'common.back' => 'Voltar',
			'common.confirm' => 'Confirmar',
			'common.delete' => 'Excluir',
			'common.loading' => 'Carregando…',
			'common.retry' => 'Tentar novamente',
			'common.ok' => 'OK',
			'signIn.tagline' => 'Um diário do ciclo, calmo e privado — só pra vocês dois.',
			'signIn.continueWithGoogle' => 'Continuar com Google',
			'signIn.privacyHint' => 'Seus dados ficam no seu próprio Firebase. Só você e seu parceiro têm acesso.',
			'signIn.networkError' => 'Não consegui conectar ao servidor. Confira sua internet e tente de novo.',
			'signIn.genericError' => 'Algo deu errado no login. Tenta novamente.',
			'signIn.signOut' => 'Sair',
			'pairingChoice.title' => 'Como vocês vão usar o MyCycle?',
			'pairingChoice.subtitle' => 'Dá pra mudar depois — mas só uma das duas pessoas registra o ciclo.',
			'pairingChoice.imOwner' => 'Quero acompanhar meu ciclo',
			'pairingChoice.imPartner' => 'Estou entrando com alguém',
			'partnerPairing.title' => 'Conectar com seu parceiro',
			'partnerPairing.heading' => 'Digite o código de convite',
			'partnerPairing.body' => 'Peça pra sua parceira gerar um código de 6 caracteres em Configurações — depois digite aqui.',
			'partnerPairing.codeHint' => 'ABC234',
			'partnerPairing.redeem' => 'Conectar',
			'partnerPairing.errorInvalid' => 'Esse código não parece certo. Confere e tenta de novo.',
			'partnerPairing.errorExpired' => 'Esse código expirou. Peça um novo.',
			'partnerPairing.errorFull' => 'Esse casal já tem parceiro.',
			'partnerPairing.errorAlreadyInCouple' => 'Você já está em um casal. Saia do atual primeiro.',
			'partnerPairing.errorNetwork' => 'Não consegui conectar. Confere sua internet.',
			'partnerPairing.errorGeneric' => 'Algo deu errado. Tenta de novo.',
			'onboarding.welcomeTitle' => 'Vamos configurar seu ciclo',
			'onboarding.welcomeBody' => 'Três perguntinhas rápidas e tá pronto. A gente nunca compartilha seus dados com ninguém.',
			'onboarding.getStarted' => 'Começar',
			'onboarding.lastPeriodTitle' => 'Quando começou sua última menstruação?',
			'onboarding.lastPeriodBody' => 'Escolhe o dia 1 da sua última menstruação — o dia em que o sangramento começou.',
			'onboarding.pickDate' => 'Escolher data',
			'onboarding.longAgoHint' => 'Mais de 60 dias atrás? Pode escolher mesmo assim — as previsões começam com confiança baixa até a gente ter mais dados.',
			'onboarding.cycleLengthTitle' => 'Tamanho do seu ciclo',
			'onboarding.cycleLengthBody' => 'Do dia 1 de uma menstruação até o dia 1 da próxima. A gente vai ajustando conforme você registra.',
			'onboarding.daysCount' => ({required Object n}) => '${n} dias',
			'onboarding.notificationsTitle' => 'Quer um aviso antes da menstruação?',
			'onboarding.notificationsBody' => 'Posso te lembrar discretamente um dia antes da provável chegada. Sem streaks, sem encheção.',
			'onboarding.notificationsToggle' => 'Quero receber lembretes',
			'onboarding.finish' => 'Finalizar',
			'onboarding.errorNetwork' => 'Não consegui salvar — confere a internet e tenta de novo.',
			'onboarding.errorValidation' => 'Tem alguma resposta que não faz sentido. Dá uma conferida.',
			'onboarding.errorGeneric' => 'Algo deu errado. Tenta de novo.',
			'today.greeting' => ({required Object name}) => 'Olá, ${name}',
			'today.nextPeriodTitle' => 'Próxima menstruação',
			'today.fertileWindowTitle' => 'Janela fértil',
			'today.ovulationOn' => ({required Object date}) => 'Ovulação por volta de ${date}',
			'today.aroundRange' => ({required Object from, required Object to}) => 'Entre ${from} e ${to}',
			'today.confidenceLow' => 'BAIXA',
			'today.confidenceMedium' => 'MÉDIA',
			'today.confidenceHigh' => 'ALTA',
			'today.lateBanner' => ({required Object days}) => 'Sua menstruação está atrasada ${days} dias.',
			'today.logToday' => 'Registrar hoje',
			'today.emptyMessage' => 'Sem ciclo ativo. Registre sua primeira menstruação pra começar.',
			'today.errorGeneric' => 'Algo deu errado ao carregar seu ciclo.',
			'log.title' => 'Registro do dia',
			'log.flowTitle' => 'Fluxo',
			'log.flowSpotting' => 'Borra',
			'log.flowLight' => 'Leve',
			'log.flowMedium' => 'Médio',
			'log.flowHeavy' => 'Intenso',
			'log.symptomsTitle' => 'Sintomas',
			'log.symptomCramps' => 'Cólica',
			'log.symptomHeadache' => 'Dor de cabeça',
			'log.symptomBloating' => 'Inchaço',
			'log.symptomFatigue' => 'Cansaço',
			'log.symptomTenderBreasts' => 'Seios sensíveis',
			'log.symptomAcne' => 'Acne',
			'log.symptomBackPain' => 'Dor nas costas',
			'log.symptomNausea' => 'Náusea',
			'log.moodTitle' => 'Humor',
			'log.moodHappy' => 'Feliz',
			'log.moodCalm' => 'Tranquila',
			'log.moodIrritable' => 'Irritada',
			'log.moodSad' => 'Triste',
			'log.moodAnxious' => 'Ansiosa',
			'log.noteTitle' => 'Nota (opcional)',
			'log.notePlaceholder' => 'O que tá passando?',
			'log.cycleMarkersTitle' => 'Marcadores do ciclo',
			'log.markPeriodStarted' => 'Minha menstruação começou hoje',
			'log.markPeriodEnded' => 'Minha menstruação terminou neste dia',
			'log.savedSuccess' => 'Salvo.',
			'log.saveError' => 'Não consegui salvar. Tenta de novo.',
			'calendar.title' => 'Calendário',
			'calendar.prevMonth' => 'Mês anterior',
			'calendar.nextMonth' => 'Próximo mês',
			'calendar.todayPill' => 'Hoje',
			'calendar.errorGeneric' => 'Algo deu errado ao carregar o calendário.',
			'settings.title' => 'Configurações',
			'settings.account' => 'Conta',
			'settings.language' => 'Idioma',
			'settings.languageEn' => 'Inglês',
			'settings.languagePtBr' => 'Português (Brasil)',
			'settings.languageError' => 'Não consegui atualizar o idioma. Tenta de novo.',
			'settings.couple' => 'Casal',
			'settings.coupleNotFound' => 'Carregando dados do casal…',
			'settings.couplePairedTitle' => 'Conectados',
			'settings.couplePairedSubtitle' => 'Vocês estão pareados.',
			'settings.coupleSoloTitle' => 'Sem parceiro ainda',
			'settings.coupleSoloSubtitle' => 'Gere um código de convite pra compartilhar.',
			'settings.generateInvite' => 'Gerar código de convite',
			'settings.regenerateInvite' => 'Gerar novo código',
			'settings.inviteCodeTitle' => 'Código de convite ativo',
			'settings.inviteExpiresAt' => ({required Object time}) => 'Expira às ${time}',
			'settings.inviteError' => 'Não consegui gerar o código. Tenta de novo.',
			'settings.copyCode' => 'Copiar código',
			'settings.copiedToClipboard' => 'Código copiado.',
			'settings.leaveCouple' => 'Sair do casal',
			'settings.leaveCoupleConfirmTitle' => 'Sair do casal?',
			'settings.leaveCoupleConfirmBody' => 'Você será removido. A dona pode te convidar de novo depois.',
			'settings.session' => 'Sessão',
			'settings.notifications' => 'Notificações',
			'settings.notificationsTitle' => 'Lembretes de menstruação',
			'settings.notificationsBody' => 'Vou te lembrar discretamente um dia antes da provável chegada.',
			'settings.notificationsError' => 'Não consegui atualizar as notificações. Tenta de novo.',
			'placeholder.themeAlive' => 'Tema Bloom está vivo.',
			'placeholder.signedInAs' => ({required Object name}) => 'Olá, ${name}',
			'placeholder.nextStep' => 'Próximo passo: onboarding.',
			_ => null,
		};
	}
}
