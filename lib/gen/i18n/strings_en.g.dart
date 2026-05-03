///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'MyCycle'
	String get appName => 'MyCycle';

	late final TranslationsCommonEn common = TranslationsCommonEn._(_root);
	late final TranslationsSignInEn signIn = TranslationsSignInEn._(_root);
	late final TranslationsPairingChoiceEn pairingChoice = TranslationsPairingChoiceEn._(_root);
	late final TranslationsPartnerPairingEn partnerPairing = TranslationsPartnerPairingEn._(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn._(_root);
	late final TranslationsTodayEn today = TranslationsTodayEn._(_root);
	late final TranslationsLogEn log = TranslationsLogEn._(_root);
	late final TranslationsCalendarEn calendar = TranslationsCalendarEn._(_root);
	late final TranslationsNavEn nav = TranslationsNavEn._(_root);
	late final TranslationsInsightsEn insights = TranslationsInsightsEn._(_root);
	late final TranslationsBiometricEn biometric = TranslationsBiometricEn._(_root);
	late final TranslationsAboutEn about = TranslationsAboutEn._(_root);
	late final TranslationsCycleDefaultsEn cycleDefaults = TranslationsCycleDefaultsEn._(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	late final TranslationsPlaceholderEn placeholder = TranslationsPlaceholderEn._(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Loading…'
	String get loading => 'Loading…';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'OK'
	String get ok => 'OK';
}

// Path: signIn
class TranslationsSignInEn {
	TranslationsSignInEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'A calm, private cycle journal — just for the two of you.'
	String get tagline => 'A calm, private cycle journal — just for the two of you.';

	/// en: 'Continue with Google'
	String get continueWithGoogle => 'Continue with Google';

	/// en: 'Your cycle data stays in your Firebase project. Only you and your partner can read it.'
	String get privacyHint => 'Your cycle data stays in your Firebase project. Only you and your partner can read it.';

	/// en: 'Couldn't reach the server. Check your connection and try again.'
	String get networkError => 'Couldn\'t reach the server. Check your connection and try again.';

	/// en: 'Something went wrong signing in. Please try again.'
	String get genericError => 'Something went wrong signing in. Please try again.';

	/// en: 'Sign out'
	String get signOut => 'Sign out';
}

// Path: pairingChoice
class TranslationsPairingChoiceEn {
	TranslationsPairingChoiceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How will you use MyCycle?'
	String get title => 'How will you use MyCycle?';

	/// en: 'You can change this later — but only one of you tracks the cycle.'
	String get subtitle => 'You can change this later — but only one of you tracks the cycle.';

	/// en: 'I want to track my cycle'
	String get imOwner => 'I want to track my cycle';

	/// en: 'I'm joining someone'
	String get imPartner => 'I\'m joining someone';
}

// Path: partnerPairing
class TranslationsPartnerPairingEn {
	TranslationsPartnerPairingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Join your partner'
	String get title => 'Join your partner';

	/// en: 'Enter your invite code'
	String get heading => 'Enter your invite code';

	/// en: 'Ask your partner to generate a 6-character code in their Settings — then type it here.'
	String get body => 'Ask your partner to generate a 6-character code in their Settings — then type it here.';

	/// en: 'ABC234'
	String get codeHint => 'ABC234';

	/// en: 'Connect'
	String get redeem => 'Connect';

	/// en: 'That code doesn't seem right. Double-check and try again.'
	String get errorInvalid => 'That code doesn\'t seem right. Double-check and try again.';

	/// en: 'That code expired. Ask your partner for a new one.'
	String get errorExpired => 'That code expired. Ask your partner for a new one.';

	/// en: 'That couple already has a partner.'
	String get errorFull => 'That couple already has a partner.';

	/// en: 'You're already in a couple. Leave the current one first.'
	String get errorAlreadyInCouple => 'You\'re already in a couple. Leave the current one first.';

	/// en: 'Couldn't reach the server. Check your connection.'
	String get errorNetwork => 'Couldn\'t reach the server. Check your connection.';

	/// en: 'Something went wrong. Please try again.'
	String get errorGeneric => 'Something went wrong. Please try again.';
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Let's set up your cycle'
	String get welcomeTitle => 'Let\'s set up your cycle';

	/// en: 'Three quick questions and you're done. We never share your data with anyone.'
	String get welcomeBody => 'Three quick questions and you\'re done. We never share your data with anyone.';

	/// en: 'Get started'
	String get getStarted => 'Get started';

	/// en: 'When did your last period start?'
	String get lastPeriodTitle => 'When did your last period start?';

	/// en: 'Pick day 1 of your most recent period — the day bleeding began.'
	String get lastPeriodBody => 'Pick day 1 of your most recent period — the day bleeding began.';

	/// en: 'Choose a date'
	String get pickDate => 'Choose a date';

	/// en: 'More than 60 days ago? You can still pick that date — predictions will start with low confidence until we have more data.'
	String get longAgoHint => 'More than 60 days ago? You can still pick that date — predictions will start with low confidence until we have more data.';

	/// en: 'Your usual cycle length'
	String get cycleLengthTitle => 'Your usual cycle length';

	/// en: 'From day 1 of one period to day 1 of the next. We'll fine-tune this as you log cycles.'
	String get cycleLengthBody => 'From day 1 of one period to day 1 of the next. We\'ll fine-tune this as you log cycles.';

	/// en: '$n days'
	String daysCount({required Object n}) => '${n} days';

	/// en: 'Heads-up before your period?'
	String get notificationsTitle => 'Heads-up before your period?';

	/// en: 'We can quietly remind you the day before your period is likely to start. No streaks, no nagging.'
	String get notificationsBody => 'We can quietly remind you the day before your period is likely to start. No streaks, no nagging.';

	/// en: 'Send me reminders'
	String get notificationsToggle => 'Send me reminders';

	/// en: 'Finish setup'
	String get finish => 'Finish setup';

	/// en: 'Couldn't save — check your connection and try again.'
	String get errorNetwork => 'Couldn\'t save — check your connection and try again.';

	/// en: 'Some answers don't look right. Please review.'
	String get errorValidation => 'Some answers don\'t look right. Please review.';

	/// en: 'Something went wrong. Please try again.'
	String get errorGeneric => 'Something went wrong. Please try again.';
}

// Path: today
class TranslationsTodayEn {
	TranslationsTodayEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Hello, $name'
	String greeting({required Object name}) => 'Hello, ${name}';

	/// en: 'Next period'
	String get nextPeriodTitle => 'Next period';

	/// en: 'Fertile window'
	String get fertileWindowTitle => 'Fertile window';

	/// en: 'Ovulation around $date'
	String ovulationOn({required Object date}) => 'Ovulation around ${date}';

	/// en: 'Around $from – $to'
	String aroundRange({required Object from, required Object to}) => 'Around ${from} – ${to}';

	/// en: 'LOW'
	String get confidenceLow => 'LOW';

	/// en: 'MEDIUM'
	String get confidenceMedium => 'MEDIUM';

	/// en: 'HIGH'
	String get confidenceHigh => 'HIGH';

	/// en: 'Period seems late by $days days.'
	String lateBanner({required Object days}) => 'Period seems late by ${days} days.';

	/// en: 'Log today'
	String get logToday => 'Log today';

	/// en: 'No active cycle. Log your first period to begin.'
	String get emptyMessage => 'No active cycle. Log your first period to begin.';

	/// en: 'Something went wrong loading your cycle.'
	String get errorGeneric => 'Something went wrong loading your cycle.';
}

// Path: log
class TranslationsLogEn {
	TranslationsLogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log entry'
	String get title => 'Log entry';

	/// en: 'Flow'
	String get flowTitle => 'Flow';

	/// en: 'Spotting'
	String get flowSpotting => 'Spotting';

	/// en: 'Light'
	String get flowLight => 'Light';

	/// en: 'Medium'
	String get flowMedium => 'Medium';

	/// en: 'Heavy'
	String get flowHeavy => 'Heavy';

	/// en: 'Symptoms'
	String get symptomsTitle => 'Symptoms';

	/// en: 'Cramps'
	String get symptomCramps => 'Cramps';

	/// en: 'Headache'
	String get symptomHeadache => 'Headache';

	/// en: 'Bloating'
	String get symptomBloating => 'Bloating';

	/// en: 'Fatigue'
	String get symptomFatigue => 'Fatigue';

	/// en: 'Tender breasts'
	String get symptomTenderBreasts => 'Tender breasts';

	/// en: 'Acne'
	String get symptomAcne => 'Acne';

	/// en: 'Back pain'
	String get symptomBackPain => 'Back pain';

	/// en: 'Nausea'
	String get symptomNausea => 'Nausea';

	/// en: 'Mood'
	String get moodTitle => 'Mood';

	/// en: 'Happy'
	String get moodHappy => 'Happy';

	/// en: 'Calm'
	String get moodCalm => 'Calm';

	/// en: 'Irritable'
	String get moodIrritable => 'Irritable';

	/// en: 'Sad'
	String get moodSad => 'Sad';

	/// en: 'Anxious'
	String get moodAnxious => 'Anxious';

	/// en: 'Note (optional)'
	String get noteTitle => 'Note (optional)';

	/// en: 'What's on your mind?'
	String get notePlaceholder => 'What\'s on your mind?';

	/// en: 'Cycle markers'
	String get cycleMarkersTitle => 'Cycle markers';

	/// en: 'My period started today'
	String get markPeriodStarted => 'My period started today';

	/// en: 'My period ended on this day'
	String get markPeriodEnded => 'My period ended on this day';

	/// en: 'Saved.'
	String get savedSuccess => 'Saved.';

	/// en: 'Couldn't save. Try again.'
	String get saveError => 'Couldn\'t save. Try again.';
}

// Path: calendar
class TranslationsCalendarEn {
	TranslationsCalendarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Calendar'
	String get title => 'Calendar';

	/// en: 'Previous month'
	String get prevMonth => 'Previous month';

	/// en: 'Next month'
	String get nextMonth => 'Next month';

	/// en: 'Today'
	String get todayPill => 'Today';

	/// en: 'Something went wrong loading the calendar.'
	String get errorGeneric => 'Something went wrong loading the calendar.';
}

// Path: nav
class TranslationsNavEn {
	TranslationsNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Calendar'
	String get calendar => 'Calendar';

	/// en: 'Insights'
	String get insights => 'Insights';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: insights
class TranslationsInsightsEn {
	TranslationsInsightsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Insights'
	String get title => 'Insights';

	/// en: 'Not enough data yet'
	String get emptyTitle => 'Not enough data yet';

	/// en: 'Log a few cycles and your patterns will appear here — averages, regularity, and a confidence-aware next prediction.'
	String get emptyBody => 'Log a few cycles and your patterns will appear here — averages, regularity, and a confidence-aware next prediction.';

	/// en: 'Your averages'
	String get averagesTitle => 'Your averages';

	/// en: 'Cycle'
	String get averageCycle => 'Cycle';

	/// en: 'Period'
	String get averagePeriod => 'Period';

	/// en: 'Regularity'
	String get regularityTitle => 'Regularity';

	/// en: 'Very steady'
	String get regularityHigh => 'Very steady';

	/// en: 'Mostly steady'
	String get regularityMedium => 'Mostly steady';

	/// en: 'Quite variable'
	String get regularityLow => 'Quite variable';

	/// en: 'Based on the last $n closed cycles.'
	String regularityHint({required Object n}) => 'Based on the last ${n} closed cycles.';

	/// en: 'Next prediction'
	String get nextPredictionTitle => 'Next prediction';

	/// en: '$from — $to'
	String nextPredictionBody({required Object from, required Object to}) => '${from} — ${to}';

	/// en: 'Ovulation around $date'
	String ovulationLabel({required Object date}) => 'Ovulation around ${date}';

	/// en: 'Low confidence'
	String get confidenceLow => 'Low confidence';

	/// en: 'Medium confidence'
	String get confidenceMedium => 'Medium confidence';

	/// en: 'High confidence'
	String get confidenceHigh => 'High confidence';

	/// en: '$n cycles tracked'
	String sampleSize({required Object n}) => '${n} cycles tracked';

	/// en: '$n d'
	String daysShort({required Object n}) => '${n} d';
}

// Path: biometric
class TranslationsBiometricEn {
	TranslationsBiometricEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'MyCycle is locked'
	String get lockedTitle => 'MyCycle is locked';

	/// en: 'Use Face ID or your fingerprint to unlock.'
	String get lockedBody => 'Use Face ID or your fingerprint to unlock.';

	/// en: 'Unlock'
	String get unlockButton => 'Unlock';

	/// en: 'Unlock MyCycle'
	String get unlockReason => 'Unlock MyCycle';

	/// en: '$n attempts left'
	String failedAttempts({required Object n}) => '${n} attempts left';

	/// en: 'Too many attempts'
	String get forcedSignOutTitle => 'Too many attempts';

	/// en: 'For your safety we signed you out. Sign in again to continue.'
	String get forcedSignOutBody => 'For your safety we signed you out. Sign in again to continue.';

	/// en: 'Biometric unlock isn't available on this device.'
	String get unavailable => 'Biometric unlock isn\'t available on this device.';
}

// Path: about
class TranslationsAboutEn {
	TranslationsAboutEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'About'
	String get title => 'About';

	/// en: 'Version'
	String get version => 'Version';

	/// en: 'Privacy'
	String get privacyHeading => 'Privacy';

	/// en: 'MyCycle stores your cycle data in your own Firebase project. There is no analytics on cycle content. Your partner can read your data; nobody else can.'
	String get privacyBody => 'MyCycle stores your cycle data in your own Firebase project. There is no analytics on cycle content. Your partner can read your data; nobody else can.';

	/// en: 'Open source'
	String get openSource => 'Open source';
}

// Path: cycleDefaults
class TranslationsCycleDefaultsEn {
	TranslationsCycleDefaultsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cycle'
	String get title => 'Cycle';

	/// en: 'Average cycle length'
	String get cycleLengthLabel => 'Average cycle length';

	/// en: 'From day 1 of one period to day 1 of the next.'
	String get cycleLengthHint => 'From day 1 of one period to day 1 of the next.';

	/// en: 'Time between ovulation and period'
	String get lutealLengthLabel => 'Time between ovulation and period';

	/// en: 'Most people sit between 12 and 14 days.'
	String get lutealLengthHint => 'Most people sit between 12 and 14 days.';

	/// en: '$n days'
	String daysCount({required Object n}) => '${n} days';

	/// en: 'Couldn't update. Try again.'
	String get saveError => 'Couldn\'t update. Try again.';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'English'
	String get languageEn => 'English';

	/// en: 'Português'
	String get languagePtBr => 'Português';

	/// en: 'Couldn't update language. Try again.'
	String get languageError => 'Couldn\'t update language. Try again.';

	/// en: 'Couple'
	String get couple => 'Couple';

	/// en: 'Couple data is loading…'
	String get coupleNotFound => 'Couple data is loading…';

	/// en: 'Paired'
	String get couplePairedTitle => 'Paired';

	/// en: 'You're both connected.'
	String get couplePairedSubtitle => 'You\'re both connected.';

	/// en: 'Not paired yet'
	String get coupleSoloTitle => 'Not paired yet';

	/// en: 'Generate an invite code to share with your partner.'
	String get coupleSoloSubtitle => 'Generate an invite code to share with your partner.';

	/// en: 'Generate invite code'
	String get generateInvite => 'Generate invite code';

	/// en: 'Generate new code'
	String get regenerateInvite => 'Generate new code';

	/// en: 'Active invite code'
	String get inviteCodeTitle => 'Active invite code';

	/// en: 'Expires at $time'
	String inviteExpiresAt({required Object time}) => 'Expires at ${time}';

	/// en: 'Couldn't generate code. Try again.'
	String get inviteError => 'Couldn\'t generate code. Try again.';

	/// en: 'Copy code'
	String get copyCode => 'Copy code';

	/// en: 'Code copied.'
	String get copiedToClipboard => 'Code copied.';

	/// en: 'Leave couple'
	String get leaveCouple => 'Leave couple';

	/// en: 'Leave couple?'
	String get leaveCoupleConfirmTitle => 'Leave couple?';

	/// en: 'You'll be removed from the couple. The owner can invite you again later.'
	String get leaveCoupleConfirmBody => 'You\'ll be removed from the couple. The owner can invite you again later.';

	/// en: 'Session'
	String get session => 'Session';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Period reminders'
	String get notificationsTitle => 'Period reminders';

	/// en: 'We'll quietly remind you the day before your period is likely to start.'
	String get notificationsBody => 'We\'ll quietly remind you the day before your period is likely to start.';

	/// en: 'Couldn't update notifications. Try again.'
	String get notificationsError => 'Couldn\'t update notifications. Try again.';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Auto'
	String get themeSystem => 'Auto';

	/// en: 'Light'
	String get themeLight => 'Light';

	/// en: 'Dark'
	String get themeDark => 'Dark';

	/// en: 'Preferences'
	String get preferences => 'Preferences';

	/// en: 'Privacy'
	String get privacy => 'Privacy';
}

// Path: placeholder
class TranslationsPlaceholderEn {
	TranslationsPlaceholderEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bloom theme is alive.'
	String get themeAlive => 'Bloom theme is alive.';

	/// en: 'Hello, $name'
	String signedInAs({required Object name}) => 'Hello, ${name}';

	/// en: 'Next step: onboarding.'
	String get nextStep => 'Next step: onboarding.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'MyCycle',
			'common.save' => 'Save',
			'common.cancel' => 'Cancel',
			'common.next' => 'Next',
			'common.back' => 'Back',
			'common.confirm' => 'Confirm',
			'common.delete' => 'Delete',
			'common.loading' => 'Loading…',
			'common.retry' => 'Retry',
			'common.ok' => 'OK',
			'signIn.tagline' => 'A calm, private cycle journal — just for the two of you.',
			'signIn.continueWithGoogle' => 'Continue with Google',
			'signIn.privacyHint' => 'Your cycle data stays in your Firebase project. Only you and your partner can read it.',
			'signIn.networkError' => 'Couldn\'t reach the server. Check your connection and try again.',
			'signIn.genericError' => 'Something went wrong signing in. Please try again.',
			'signIn.signOut' => 'Sign out',
			'pairingChoice.title' => 'How will you use MyCycle?',
			'pairingChoice.subtitle' => 'You can change this later — but only one of you tracks the cycle.',
			'pairingChoice.imOwner' => 'I want to track my cycle',
			'pairingChoice.imPartner' => 'I\'m joining someone',
			'partnerPairing.title' => 'Join your partner',
			'partnerPairing.heading' => 'Enter your invite code',
			'partnerPairing.body' => 'Ask your partner to generate a 6-character code in their Settings — then type it here.',
			'partnerPairing.codeHint' => 'ABC234',
			'partnerPairing.redeem' => 'Connect',
			'partnerPairing.errorInvalid' => 'That code doesn\'t seem right. Double-check and try again.',
			'partnerPairing.errorExpired' => 'That code expired. Ask your partner for a new one.',
			'partnerPairing.errorFull' => 'That couple already has a partner.',
			'partnerPairing.errorAlreadyInCouple' => 'You\'re already in a couple. Leave the current one first.',
			'partnerPairing.errorNetwork' => 'Couldn\'t reach the server. Check your connection.',
			'partnerPairing.errorGeneric' => 'Something went wrong. Please try again.',
			'onboarding.welcomeTitle' => 'Let\'s set up your cycle',
			'onboarding.welcomeBody' => 'Three quick questions and you\'re done. We never share your data with anyone.',
			'onboarding.getStarted' => 'Get started',
			'onboarding.lastPeriodTitle' => 'When did your last period start?',
			'onboarding.lastPeriodBody' => 'Pick day 1 of your most recent period — the day bleeding began.',
			'onboarding.pickDate' => 'Choose a date',
			'onboarding.longAgoHint' => 'More than 60 days ago? You can still pick that date — predictions will start with low confidence until we have more data.',
			'onboarding.cycleLengthTitle' => 'Your usual cycle length',
			'onboarding.cycleLengthBody' => 'From day 1 of one period to day 1 of the next. We\'ll fine-tune this as you log cycles.',
			'onboarding.daysCount' => ({required Object n}) => '${n} days',
			'onboarding.notificationsTitle' => 'Heads-up before your period?',
			'onboarding.notificationsBody' => 'We can quietly remind you the day before your period is likely to start. No streaks, no nagging.',
			'onboarding.notificationsToggle' => 'Send me reminders',
			'onboarding.finish' => 'Finish setup',
			'onboarding.errorNetwork' => 'Couldn\'t save — check your connection and try again.',
			'onboarding.errorValidation' => 'Some answers don\'t look right. Please review.',
			'onboarding.errorGeneric' => 'Something went wrong. Please try again.',
			'today.greeting' => ({required Object name}) => 'Hello, ${name}',
			'today.nextPeriodTitle' => 'Next period',
			'today.fertileWindowTitle' => 'Fertile window',
			'today.ovulationOn' => ({required Object date}) => 'Ovulation around ${date}',
			'today.aroundRange' => ({required Object from, required Object to}) => 'Around ${from} – ${to}',
			'today.confidenceLow' => 'LOW',
			'today.confidenceMedium' => 'MEDIUM',
			'today.confidenceHigh' => 'HIGH',
			'today.lateBanner' => ({required Object days}) => 'Period seems late by ${days} days.',
			'today.logToday' => 'Log today',
			'today.emptyMessage' => 'No active cycle. Log your first period to begin.',
			'today.errorGeneric' => 'Something went wrong loading your cycle.',
			'log.title' => 'Log entry',
			'log.flowTitle' => 'Flow',
			'log.flowSpotting' => 'Spotting',
			'log.flowLight' => 'Light',
			'log.flowMedium' => 'Medium',
			'log.flowHeavy' => 'Heavy',
			'log.symptomsTitle' => 'Symptoms',
			'log.symptomCramps' => 'Cramps',
			'log.symptomHeadache' => 'Headache',
			'log.symptomBloating' => 'Bloating',
			'log.symptomFatigue' => 'Fatigue',
			'log.symptomTenderBreasts' => 'Tender breasts',
			'log.symptomAcne' => 'Acne',
			'log.symptomBackPain' => 'Back pain',
			'log.symptomNausea' => 'Nausea',
			'log.moodTitle' => 'Mood',
			'log.moodHappy' => 'Happy',
			'log.moodCalm' => 'Calm',
			'log.moodIrritable' => 'Irritable',
			'log.moodSad' => 'Sad',
			'log.moodAnxious' => 'Anxious',
			'log.noteTitle' => 'Note (optional)',
			'log.notePlaceholder' => 'What\'s on your mind?',
			'log.cycleMarkersTitle' => 'Cycle markers',
			'log.markPeriodStarted' => 'My period started today',
			'log.markPeriodEnded' => 'My period ended on this day',
			'log.savedSuccess' => 'Saved.',
			'log.saveError' => 'Couldn\'t save. Try again.',
			'calendar.title' => 'Calendar',
			'calendar.prevMonth' => 'Previous month',
			'calendar.nextMonth' => 'Next month',
			'calendar.todayPill' => 'Today',
			'calendar.errorGeneric' => 'Something went wrong loading the calendar.',
			'nav.today' => 'Today',
			'nav.calendar' => 'Calendar',
			'nav.insights' => 'Insights',
			'nav.settings' => 'Settings',
			'insights.title' => 'Insights',
			'insights.emptyTitle' => 'Not enough data yet',
			'insights.emptyBody' => 'Log a few cycles and your patterns will appear here — averages, regularity, and a confidence-aware next prediction.',
			'insights.averagesTitle' => 'Your averages',
			'insights.averageCycle' => 'Cycle',
			'insights.averagePeriod' => 'Period',
			'insights.regularityTitle' => 'Regularity',
			'insights.regularityHigh' => 'Very steady',
			'insights.regularityMedium' => 'Mostly steady',
			'insights.regularityLow' => 'Quite variable',
			'insights.regularityHint' => ({required Object n}) => 'Based on the last ${n} closed cycles.',
			'insights.nextPredictionTitle' => 'Next prediction',
			'insights.nextPredictionBody' => ({required Object from, required Object to}) => '${from} — ${to}',
			'insights.ovulationLabel' => ({required Object date}) => 'Ovulation around ${date}',
			'insights.confidenceLow' => 'Low confidence',
			'insights.confidenceMedium' => 'Medium confidence',
			'insights.confidenceHigh' => 'High confidence',
			'insights.sampleSize' => ({required Object n}) => '${n} cycles tracked',
			'insights.daysShort' => ({required Object n}) => '${n} d',
			'biometric.lockedTitle' => 'MyCycle is locked',
			'biometric.lockedBody' => 'Use Face ID or your fingerprint to unlock.',
			'biometric.unlockButton' => 'Unlock',
			'biometric.unlockReason' => 'Unlock MyCycle',
			'biometric.failedAttempts' => ({required Object n}) => '${n} attempts left',
			'biometric.forcedSignOutTitle' => 'Too many attempts',
			'biometric.forcedSignOutBody' => 'For your safety we signed you out. Sign in again to continue.',
			'biometric.unavailable' => 'Biometric unlock isn\'t available on this device.',
			'about.title' => 'About',
			'about.version' => 'Version',
			'about.privacyHeading' => 'Privacy',
			'about.privacyBody' => 'MyCycle stores your cycle data in your own Firebase project. There is no analytics on cycle content. Your partner can read your data; nobody else can.',
			'about.openSource' => 'Open source',
			'cycleDefaults.title' => 'Cycle',
			'cycleDefaults.cycleLengthLabel' => 'Average cycle length',
			'cycleDefaults.cycleLengthHint' => 'From day 1 of one period to day 1 of the next.',
			'cycleDefaults.lutealLengthLabel' => 'Time between ovulation and period',
			'cycleDefaults.lutealLengthHint' => 'Most people sit between 12 and 14 days.',
			'cycleDefaults.daysCount' => ({required Object n}) => '${n} days',
			'cycleDefaults.saveError' => 'Couldn\'t update. Try again.',
			'settings.title' => 'Settings',
			'settings.account' => 'Account',
			'settings.language' => 'Language',
			'settings.languageEn' => 'English',
			'settings.languagePtBr' => 'Português',
			'settings.languageError' => 'Couldn\'t update language. Try again.',
			'settings.couple' => 'Couple',
			'settings.coupleNotFound' => 'Couple data is loading…',
			'settings.couplePairedTitle' => 'Paired',
			'settings.couplePairedSubtitle' => 'You\'re both connected.',
			'settings.coupleSoloTitle' => 'Not paired yet',
			'settings.coupleSoloSubtitle' => 'Generate an invite code to share with your partner.',
			'settings.generateInvite' => 'Generate invite code',
			'settings.regenerateInvite' => 'Generate new code',
			'settings.inviteCodeTitle' => 'Active invite code',
			'settings.inviteExpiresAt' => ({required Object time}) => 'Expires at ${time}',
			'settings.inviteError' => 'Couldn\'t generate code. Try again.',
			'settings.copyCode' => 'Copy code',
			'settings.copiedToClipboard' => 'Code copied.',
			'settings.leaveCouple' => 'Leave couple',
			'settings.leaveCoupleConfirmTitle' => 'Leave couple?',
			'settings.leaveCoupleConfirmBody' => 'You\'ll be removed from the couple. The owner can invite you again later.',
			'settings.session' => 'Session',
			'settings.notifications' => 'Notifications',
			'settings.notificationsTitle' => 'Period reminders',
			'settings.notificationsBody' => 'We\'ll quietly remind you the day before your period is likely to start.',
			'settings.notificationsError' => 'Couldn\'t update notifications. Try again.',
			'settings.appearance' => 'Appearance',
			'settings.themeSystem' => 'Auto',
			'settings.themeLight' => 'Light',
			'settings.themeDark' => 'Dark',
			'settings.preferences' => 'Preferences',
			'settings.privacy' => 'Privacy',
			'placeholder.themeAlive' => 'Bloom theme is alive.',
			'placeholder.signedInAs' => ({required Object name}) => 'Hello, ${name}',
			'placeholder.nextStep' => 'Next step: onboarding.',
			_ => null,
		};
	}
}
