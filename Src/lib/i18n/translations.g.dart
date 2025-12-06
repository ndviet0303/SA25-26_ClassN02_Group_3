/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 2
/// Strings: 1004 (502 per locale)

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	vi(languageCode: 'vi', build: _TranslationsVi.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
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

	// Translations
	String get locale => 'en';
	late final _TranslationsAppEn app = _TranslationsAppEn._(_root);
	late final _TranslationsCommonEn common = _TranslationsCommonEn._(_root);
	late final _TranslationsNotificationEn notification = _TranslationsNotificationEn._(_root);
	late final _TranslationsAuthEn auth = _TranslationsAuthEn._(_root);
	late final _TranslationsWelcomeEn welcome = _TranslationsWelcomeEn._(_root);
	late final _TranslationsSettingsEn settings = _TranslationsSettingsEn._(_root);
	late final _TranslationsProfileEn profile = _TranslationsProfileEn._(_root);
	late final _TranslationsValidationEn validation = _TranslationsValidationEn._(_root);
	late final _TranslationsNavigationEn navigation = _TranslationsNavigationEn._(_root);
	late final _TranslationsSearchEn search = _TranslationsSearchEn._(_root);
	late final _TranslationsUtilsEn utils = _TranslationsUtilsEn._(_root);
	late final _TranslationsCardsEn cards = _TranslationsCardsEn._(_root);
	late final _TranslationsPurchaseDetailEn purchaseDetail = _TranslationsPurchaseDetailEn._(_root);
	late final _TranslationsDiscoverEn discover = _TranslationsDiscoverEn._(_root);
	late final _TranslationsHomeEn home = _TranslationsHomeEn._(_root);
	late final _TranslationsGenreEn genre = _TranslationsGenreEn._(_root);
	late final _TranslationsPurchaseEn purchase = _TranslationsPurchaseEn._(_root);
	late final _TranslationsMovieEn movie = _TranslationsMovieEn._(_root);
	late final _TranslationsWishlistEn wishlist = _TranslationsWishlistEn._(_root);
}

// Path: app
class _TranslationsAppEn {
	_TranslationsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'NoZie';
}

// Path: common
class _TranslationsCommonEn {
	_TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get skip => 'Skip';
	String get continueText => 'Continue';
	String get confirm => 'Confirm';
	String get data => 'Data';
	String get save => 'Save';
	String get cancel => 'Cancel';
	String get next => 'Next';
	String get back => 'Back';
	String get done => 'Done';
	String get empty => 'Empty';
	String get yes => 'Yes';
	String get no => 'No';
	String get addNew => 'Add New';
	String get clear => 'Clear';
	String get search => 'Search';
	String get loading => 'Loading…';
	String get signOut => 'Sign out';
	String get retry => 'Retry';
	String get errorPrefix => 'Error:';
}

// Path: notification
class _TranslationsNotificationEn {
	_TranslationsNotificationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notifications';
	String get empty => 'You don\'t have any notification at this time';
	String get markAllAsRead => 'Mark all as read';
	String get newItem => 'New notification';
	String get seeAll => 'See all notifications';
	String get today => 'Today';
	String get dayAgo => 'Days ago';
	String get loadFailed => 'Error loading notifications';
	String markAllAsReadFailed({required Object error}) => 'Failed to mark all as read: ${error}';
}

// Path: auth
class _TranslationsAuthEn {
	_TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get login => 'Login';
	String get signIn => 'Sign In';
	String get signUp => 'Sign Up';
	String get email => 'Email';
	String get password => 'Password';
	String get username => 'Username';
	String get confirmPassword => 'Confirm Password';
	String get rememberMe => 'Remember me';
	late final _TranslationsAuthErrorsEn errors = _TranslationsAuthErrorsEn._(_root);
	late final _TranslationsAuthLoginScreenEn loginScreen = _TranslationsAuthLoginScreenEn._(_root);
	late final _TranslationsAuthOauthEn oauth = _TranslationsAuthOauthEn._(_root);
	late final _TranslationsAuthForgotPasswordEn forgotPassword = _TranslationsAuthForgotPasswordEn._(_root);
	late final _TranslationsAuthRegisterEn register = _TranslationsAuthRegisterEn._(_root);
}

// Path: welcome
class _TranslationsWelcomeEn {
	_TranslationsWelcomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Welcome to NoZie 👋';
	String get titlePrefix => 'Welcome to ';
	String get description => 'Your personal movie companion. Get personalized recommendations, discover new films, and track your watchlist.';
	String get getStarted => 'Get Started';
	String get continueWithGoogle => 'Continue with Google';
	String get iAlreadyHaveAnAccount => 'I Already Have an Account';
	late final _TranslationsWelcomeSlidesEn slides = _TranslationsWelcomeSlidesEn._(_root);
}

// Path: settings
class _TranslationsSettingsEn {
	_TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsSettingsLanguageEn language = _TranslationsSettingsLanguageEn._(_root);
	late final _TranslationsSettingsThemeEn theme = _TranslationsSettingsThemeEn._(_root);
}

// Path: profile
class _TranslationsProfileEn {
	_TranslationsProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfileHeaderEn header = _TranslationsProfileHeaderEn._(_root);
	late final _TranslationsProfileMenuEn menu = _TranslationsProfileMenuEn._(_root);
	late final _TranslationsProfileLanguageEn language = _TranslationsProfileLanguageEn._(_root);
	late final _TranslationsProfileLogoutSheetEn logoutSheet = _TranslationsProfileLogoutSheetEn._(_root);
	late final _TranslationsProfileHelpCenterEn helpCenter = _TranslationsProfileHelpCenterEn._(_root);
	late final _TranslationsProfilePaymentEn payment = _TranslationsProfilePaymentEn._(_root);
	late final _TranslationsProfileNotificationEn notification = _TranslationsProfileNotificationEn._(_root);
	late final _TranslationsProfilePersonalInfoEn personalInfo = _TranslationsProfilePersonalInfoEn._(_root);
	late final _TranslationsProfilePreferencesEn preferences = _TranslationsProfilePreferencesEn._(_root);
	late final _TranslationsProfileSecurityEn security = _TranslationsProfileSecurityEn._(_root);
}

// Path: validation
class _TranslationsValidationEn {
	_TranslationsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsValidationGeneralEn general = _TranslationsValidationGeneralEn._(_root);
	late final _TranslationsValidationNameEn name = _TranslationsValidationNameEn._(_root);
	late final _TranslationsValidationPhoneEn phone = _TranslationsValidationPhoneEn._(_root);
	late final _TranslationsValidationDateOfBirthEn dateOfBirth = _TranslationsValidationDateOfBirthEn._(_root);
	late final _TranslationsValidationCountryEn country = _TranslationsValidationCountryEn._(_root);
	late final _TranslationsValidationUsernameEn username = _TranslationsValidationUsernameEn._(_root);
	late final _TranslationsValidationEmailEn email = _TranslationsValidationEmailEn._(_root);
	late final _TranslationsValidationPasswordEn password = _TranslationsValidationPasswordEn._(_root);
}

// Path: navigation
class _TranslationsNavigationEn {
	_TranslationsNavigationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get home => 'Home';
	String get discover => 'Discover';
	String get wishlist => 'Wishlist';
	String get purchase => 'Purchase';
	String get profile => 'Profile';
}

// Path: search
class _TranslationsSearchEn {
	_TranslationsSearchEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get searchMovies => 'Search movies, TV shows, actors...';
	String get popularSearches => 'Popular Searches';
	String get noResultsFound => 'No results found';
	String get tryDifferentKeywords => 'Try different keywords or check your spelling';
	String get all => 'All';
	String get movies => 'Movies';
	String get tvShows => 'TV Shows';
	String get actors => 'Actors';
	String get previousSearches => 'Previous Searches';
	String get noResults => 'No results found';
	String get showIn => 'Show in';
	late final _TranslationsSearchFilterEn filter = _TranslationsSearchFilterEn._(_root);
}

// Path: utils
class _TranslationsUtilsEn {
	_TranslationsUtilsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get itemsCount => '{count} items';
	String get helloUser => 'Hello, {name}!';
	String get counterText => '';
}

// Path: cards
class _TranslationsCardsEn {
	_TranslationsCardsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get showIn => 'Show in';
}

// Path: purchaseDetail
class _TranslationsPurchaseDetailEn {
	_TranslationsPurchaseDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Purchase Details';
	String get infoTitle => 'Purchase Information';
	late final _TranslationsPurchaseDetailLabelsEn labels = _TranslationsPurchaseDetailLabelsEn._(_root);
	late final _TranslationsPurchaseDetailStatesEn states = _TranslationsPurchaseDetailStatesEn._(_root);
	late final _TranslationsPurchaseDetailEmptyEn empty = _TranslationsPurchaseDetailEmptyEn._(_root);
	late final _TranslationsPurchaseDetailErrorEn error = _TranslationsPurchaseDetailErrorEn._(_root);
}

// Path: discover
class _TranslationsDiscoverEn {
	_TranslationsDiscoverEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsDiscoverSectionsEn sections = _TranslationsDiscoverSectionsEn._(_root);
}

// Path: home
class _TranslationsHomeEn {
	_TranslationsHomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsHomeSectionsEn sections = _TranslationsHomeSectionsEn._(_root);
}

// Path: genre
class _TranslationsGenreEn {
	_TranslationsGenreEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsGenreExploreEn explore = _TranslationsGenreExploreEn._(_root);
}

// Path: purchase
class _TranslationsPurchaseEn {
	_TranslationsPurchaseEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsPurchaseCommonEn common = _TranslationsPurchaseCommonEn._(_root);
	late final _TranslationsPurchaseCheckoutEn checkout = _TranslationsPurchaseCheckoutEn._(_root);
	late final _TranslationsPurchaseItemEn item = _TranslationsPurchaseItemEn._(_root);
	late final _TranslationsPurchaseNotificationsEn notifications = _TranslationsPurchaseNotificationsEn._(_root);
}

// Path: movie
class _TranslationsMovieEn {
	_TranslationsMovieEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsMovieDetailsEn details = _TranslationsMovieDetailsEn._(_root);
	late final _TranslationsMovieRatingsEn ratings = _TranslationsMovieRatingsEn._(_root);
	late final _TranslationsMovieInfoEn info = _TranslationsMovieInfoEn._(_root);
	late final _TranslationsMoviePlayerEn player = _TranslationsMoviePlayerEn._(_root);
	late final _TranslationsMovieHeroEn hero = _TranslationsMovieHeroEn._(_root);
	late final _TranslationsMovieSimilarEn similar = _TranslationsMovieSimilarEn._(_root);
	late final _TranslationsMovieReportEn report = _TranslationsMovieReportEn._(_root);
}

// Path: wishlist
class _TranslationsWishlistEn {
	_TranslationsWishlistEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsWishlistCommonEn common = _TranslationsWishlistCommonEn._(_root);
	late final _TranslationsWishlistItemEn item = _TranslationsWishlistItemEn._(_root);
	late final _TranslationsWishlistEmptyEn empty = _TranslationsWishlistEmptyEn._(_root);
}

// Path: auth.errors
class _TranslationsAuthErrorsEn {
	_TranslationsAuthErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get invalidCredentials => 'Incorrect username or password';
}

// Path: auth.loginScreen
class _TranslationsAuthLoginScreenEn {
	_TranslationsAuthLoginScreenEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Hello there 👋';
	String get description => 'Please enter your username/email and password to sign in.';
	late final _TranslationsAuthLoginScreenPlaceholderEn placeholder = _TranslationsAuthLoginScreenPlaceholderEn._(_root);
}

// Path: auth.oauth
class _TranslationsAuthOauthEn {
	_TranslationsAuthOauthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get featureInDevelopment => 'This feature is under development';
}

// Path: auth.forgotPassword
class _TranslationsAuthForgotPasswordEn {
	_TranslationsAuthForgotPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Forgot Password 🔑';
	String get description => 'Enter your email address. We will send an OTP code for verification in the next step.';
	String get orContinueWith => 'or continue with';
	late final _TranslationsAuthForgotPasswordOtpEn otp = _TranslationsAuthForgotPasswordOtpEn._(_root);
	late final _TranslationsAuthForgotPasswordNewPasswordEn newPassword = _TranslationsAuthForgotPasswordNewPasswordEn._(_root);
}

// Path: auth.register
class _TranslationsAuthRegisterEn {
	_TranslationsAuthRegisterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get createAccount => 'Create an Account';
	String get description => 'Enter your username, email & password. If you forget it, then you have to do forgot password.';
	late final _TranslationsAuthRegisterPlaceholderEn placeholder = _TranslationsAuthRegisterPlaceholderEn._(_root);
	String get registrationSuccessful => 'Registration successful!';
	late final _TranslationsAuthRegisterStepsEn steps = _TranslationsAuthRegisterStepsEn._(_root);
}

// Path: welcome.slides
class _TranslationsWelcomeSlidesEn {
	_TranslationsWelcomeSlidesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsWelcomeSlidesDiscoverEn discover = _TranslationsWelcomeSlidesDiscoverEn._(_root);
	late final _TranslationsWelcomeSlidesTrackEn track = _TranslationsWelcomeSlidesTrackEn._(_root);
	late final _TranslationsWelcomeSlidesCommunityEn community = _TranslationsWelcomeSlidesCommunityEn._(_root);
}

// Path: settings.language
class _TranslationsSettingsLanguageEn {
	_TranslationsSettingsLanguageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get vietnamese => 'Tiếng Việt';
	String get english => 'English';
}

// Path: settings.theme
class _TranslationsSettingsThemeEn {
	_TranslationsSettingsThemeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get system => 'System';
	String get light => 'Light';
	String get dark => 'Dark';
}

// Path: profile.header
class _TranslationsProfileHeaderEn {
	_TranslationsProfileHeaderEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get defaultName => 'NoZie User';
	String get loadError => 'Unable to load profile';
}

// Path: profile.menu
class _TranslationsProfileMenuEn {
	_TranslationsProfileMenuEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get paymentMethods => 'Payment Methods';
	String get personalInfo => 'Personal Info';
	String get notification => 'Notification';
	String get preferences => 'Preferences';
	String get security => 'Security';
	String get language => 'Language';
	String get helpCenter => 'Help Center';
	String get about => 'About NoZie';
	String get darkMode => 'Dark Mode';
	String get logout => 'Logout';
}

// Path: profile.language
class _TranslationsProfileLanguageEn {
	_TranslationsProfileLanguageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Language';
	String get sectionSuggested => 'Suggested';
	String get sectionOthers => 'Other Languages';
	String loadError({required Object error}) => 'Failed to load languages: ${error}';
	String get fallback => 'English (US)';
}

// Path: profile.logoutSheet
class _TranslationsProfileLogoutSheetEn {
	_TranslationsProfileLogoutSheetEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Logout';
	String get description => 'Are you sure you want to logout from NoZie? You can log in again anytime.';
}

// Path: profile.helpCenter
class _TranslationsProfileHelpCenterEn {
	_TranslationsProfileHelpCenterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Help Center';
	late final _TranslationsProfileHelpCenterTabsEn tabs = _TranslationsProfileHelpCenterTabsEn._(_root);
	late final _TranslationsProfileHelpCenterCategoriesEn categories = _TranslationsProfileHelpCenterCategoriesEn._(_root);
	late final _TranslationsProfileHelpCenterSearchEn search = _TranslationsProfileHelpCenterSearchEn._(_root);
	late final _TranslationsProfileHelpCenterFilterEn filter = _TranslationsProfileHelpCenterFilterEn._(_root);
	late final _TranslationsProfileHelpCenterFaqEn faq = _TranslationsProfileHelpCenterFaqEn._(_root);
	late final _TranslationsProfileHelpCenterContactsEn contacts = _TranslationsProfileHelpCenterContactsEn._(_root);
}

// Path: profile.payment
class _TranslationsProfilePaymentEn {
	_TranslationsProfilePaymentEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Payment Methods';
	String loadError({required Object error}) => 'Failed to load payment methods: ${error}';
	String get addNewMessage => 'Add payment method tapped';
	String get comingSoon => 'More payment methods coming soon';
}

// Path: profile.notification
class _TranslationsProfileNotificationEn {
	_TranslationsProfileNotificationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notification';
	String loadError({required Object error}) => 'Failed to load settings: ${error}';
	String get sectionTitle => 'Notify me when...';
	late final _TranslationsProfileNotificationTogglesEn toggles = _TranslationsProfileNotificationTogglesEn._(_root);
}

// Path: profile.personalInfo
class _TranslationsProfilePersonalInfoEn {
	_TranslationsProfilePersonalInfoEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Personal Info';
	String get loadError => 'Failed to load profile. Please try again later.';
	String get success => 'Profile updated';
	late final _TranslationsProfilePersonalInfoFieldsEn fields = _TranslationsProfilePersonalInfoFieldsEn._(_root);
	String get saveChanges => 'Save Changes';
}

// Path: profile.preferences
class _TranslationsProfilePreferencesEn {
	_TranslationsProfilePreferencesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Preferences';
	late final _TranslationsProfilePreferencesSectionsEn sections = _TranslationsProfilePreferencesSectionsEn._(_root);
	late final _TranslationsProfilePreferencesTogglesEn toggles = _TranslationsProfilePreferencesTogglesEn._(_root);
	late final _TranslationsProfilePreferencesActionsEn actions = _TranslationsProfilePreferencesActionsEn._(_root);
	late final _TranslationsProfilePreferencesStorageLabelEn storageLabel = _TranslationsProfilePreferencesStorageLabelEn._(_root);
}

// Path: profile.security
class _TranslationsProfileSecurityEn {
	_TranslationsProfileSecurityEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Security';
	String loadError({required Object error}) => 'Failed to load security settings: ${error}';
	late final _TranslationsProfileSecurityTogglesEn toggles = _TranslationsProfileSecurityTogglesEn._(_root);
	late final _TranslationsProfileSecurityActionsEn actions = _TranslationsProfileSecurityActionsEn._(_root);
	late final _TranslationsProfileSecurityDeviceManagementEn deviceManagement = _TranslationsProfileSecurityDeviceManagementEn._(_root);
}

// Path: validation.general
class _TranslationsValidationGeneralEn {
	_TranslationsValidationGeneralEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get fillAllFields => 'Please fill in all fields.';
	String get required => 'This field is required.';
	String length({required Object length}) => 'The length must be ${length}.';
	String min({required Object length}) => 'The minimum length is ${length}.';
	String max({required Object length}) => 'The maximum length is ${length}.';
	String get regex => 'The field is invalid.';
	late final _TranslationsValidationGeneralCustomEn custom = _TranslationsValidationGeneralCustomEn._(_root);
}

// Path: validation.name
class _TranslationsValidationNameEn {
	_TranslationsValidationNameEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Full name is required';
	String get minLength => 'Full name must be at least 2 characters';
}

// Path: validation.phone
class _TranslationsValidationPhoneEn {
	_TranslationsValidationPhoneEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Phone number is required';
	String get minLength => 'Phone number must be at least 10 digits';
}

// Path: validation.dateOfBirth
class _TranslationsValidationDateOfBirthEn {
	_TranslationsValidationDateOfBirthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Date of birth is required';
}

// Path: validation.country
class _TranslationsValidationCountryEn {
	_TranslationsValidationCountryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Country is required';
}

// Path: validation.username
class _TranslationsValidationUsernameEn {
	_TranslationsValidationUsernameEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Username is required';
	String get minLength => 'Username must be at least 3 characters';
	String get invalidChars => 'Username can only contain letters, numbers, and underscores';
}

// Path: validation.email
class _TranslationsValidationEmailEn {
	_TranslationsValidationEmailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Email is required';
	String get invalid => 'Please enter a valid email address';
}

// Path: validation.password
class _TranslationsValidationPasswordEn {
	_TranslationsValidationPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Password is required';
	String get minLength => 'Password must be at least 8 characters';
	String get complexity => 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
	String get confirmRequired => 'Please confirm your password';
	String get mismatch => 'Passwords do not match';
}

// Path: search.filter
class _TranslationsSearchFilterEn {
	_TranslationsSearchFilterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get header => 'Filter';
	String get reset => 'Reset';
	String get apply => 'Apply';
	late final _TranslationsSearchFilterSectionsEn sections = _TranslationsSearchFilterSectionsEn._(_root);
	late final _TranslationsSearchFilterSortOptionsEn sortOptions = _TranslationsSearchFilterSortOptionsEn._(_root);
	late final _TranslationsSearchFilterGenresEn genres = _TranslationsSearchFilterGenresEn._(_root);
	late final _TranslationsSearchFilterRangePriceEn rangePrice = _TranslationsSearchFilterRangePriceEn._(_root);
	late final _TranslationsSearchFilterLanguagesEn languages = _TranslationsSearchFilterLanguagesEn._(_root);
	late final _TranslationsSearchFilterAgeEn age = _TranslationsSearchFilterAgeEn._(_root);
}

// Path: purchaseDetail.labels
class _TranslationsPurchaseDetailLabelsEn {
	_TranslationsPurchaseDetailLabelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get movieId => 'Movie ID';
	String get downloaded => 'Downloaded';
	String get finished => 'Finished';
	String get transactions => 'Transactions';
	String get amount => 'Amount';
	String get created => 'Created';
	String get paidAt => 'Paid At';
	String get failedAt => 'Failed At';
	String get canceledAt => 'Canceled At';
	String get paymentIntent => 'Payment Intent';
	String get chargeId => 'Charge ID';
}

// Path: purchaseDetail.states
class _TranslationsPurchaseDetailStatesEn {
	_TranslationsPurchaseDetailStatesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get succeeded => 'Succeeded';
	String get failed => 'Failed';
	String get canceled => 'Canceled';
	String get pending => 'Pending';
}

// Path: purchaseDetail.empty
class _TranslationsPurchaseDetailEmptyEn {
	_TranslationsPurchaseDetailEmptyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get transactions => 'No transactions found';
	String get purchaseNotFound => 'Purchase not found';
}

// Path: purchaseDetail.error
class _TranslationsPurchaseDetailErrorEn {
	_TranslationsPurchaseDetailErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String generic({required Object error}) => 'Error: ${error}';
}

// Path: discover.sections
class _TranslationsDiscoverSectionsEn {
	_TranslationsDiscoverSectionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get topCharts => 'Top Charts';
	String get topSelling => 'Top Selling';
	String get topFree => 'Top Free';
	String get topNewReleases => 'Top New Releases';
}

// Path: home.sections
class _TranslationsHomeSectionsEn {
	_TranslationsHomeSectionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get recommendedForYou => 'Recommended For You';
	String get yourPurchases => 'Your Purchases';
	String get yourWishlist => 'Your Wishlist';
	String get recentlyWatched => 'Recently Watched';
	String get exploreByGenre => 'Explore by Genre';
}

// Path: genre.explore
class _TranslationsGenreExploreEn {
	_TranslationsGenreExploreEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Genre:';
	String get empty => 'No movies found for';
	String get loadFailed => 'Failed to load movies';
}

// Path: purchase.common
class _TranslationsPurchaseCommonEn {
	_TranslationsPurchaseCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get free => 'Free';
	String get purchased => 'Purchased';
	String get movieNotFound => 'Movie not found';
	String get comingSoon => 'Coming soon';
	String get errorPrefix => 'Error:';
}

// Path: purchase.checkout
class _TranslationsPurchaseCheckoutEn {
	_TranslationsPurchaseCheckoutEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Checkout';
	late final _TranslationsPurchaseCheckoutSectionEn section = _TranslationsPurchaseCheckoutSectionEn._(_root);
	late final _TranslationsPurchaseCheckoutLabelsEn labels = _TranslationsPurchaseCheckoutLabelsEn._(_root);
	late final _TranslationsPurchaseCheckoutActionsEn actions = _TranslationsPurchaseCheckoutActionsEn._(_root);
	late final _TranslationsPurchaseCheckoutToastsEn toasts = _TranslationsPurchaseCheckoutToastsEn._(_root);
}

// Path: purchase.item
class _TranslationsPurchaseItemEn {
	_TranslationsPurchaseItemEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsPurchaseItemMenuEn menu = _TranslationsPurchaseItemMenuEn._(_root);
	late final _TranslationsPurchaseItemSnackbarEn snackbar = _TranslationsPurchaseItemSnackbarEn._(_root);
}

// Path: purchase.notifications
class _TranslationsPurchaseNotificationsEn {
	_TranslationsPurchaseNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get successTitle => 'Purchase Successful! 🎬';
	String get successDescription => 'You now own';
}

// Path: movie.details
class _TranslationsMovieDetailsEn {
	_TranslationsMovieDetailsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get notFound => 'Movie not found';
	String get alreadyPurchased => 'This movie is already in your purchased library';
	String get quality1080p => '1080p';
	String get seriesFallback => 'Series';
}

// Path: movie.ratings
class _TranslationsMovieRatingsEn {
	_TranslationsMovieRatingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Ratings & Reviews';
	String get noReviews => 'No reviews yet';
	String get rateThisFilm => 'Rate this Film';
	String get purchaseRequired => 'Purchase required to rate';
	String get writeAReview => 'Write a Review';
	late final _TranslationsMovieRatingsDialogEn dialog = _TranslationsMovieRatingsDialogEn._(_root);
}

// Path: movie.info
class _TranslationsMovieInfoEn {
	_TranslationsMovieInfoEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get images => 'Images';
	String get cannotLoadImage => 'Cannot load image';
	String get episodesList => 'Episodes';
	String get language => 'Language';
	String get genres => 'Genres';
	String get countries => 'Countries';
	String get directors => 'Directors';
	String get actors => 'Actors';
	String get aboutThisFilm => 'About This Film';
	String get trailer => 'Trailer';
	String get watchTrailer => 'Watch trailer';
	String get episodePrefix => 'Episode';
	String get episodesPrefix => 'Episodes';
}

// Path: movie.player
class _TranslationsMoviePlayerEn {
	_TranslationsMoviePlayerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get noAccess => 'You do not have access to this movie';
	String get videoUrlMissing => 'Video URL not available';
	String get tryingFallback => 'Trying fallback URL...';
	String get cannotLoadM3u8 => 'Cannot load video from m3u8 URL';
	String get cannotLoadBoth => 'Cannot load video from both m3u8 and embed URL';
	String get unknownError => 'Unknown error';
	String get cannotOpenTrailer => 'Cannot open trailer';
	String get playbackSpeed => 'Playback Speed';
	String get quality => 'Quality';
}

// Path: movie.hero
class _TranslationsMovieHeroEn {
	_TranslationsMovieHeroEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get ratings => 'ratings';
	String get reviews => 'reviews';
	String get duration => 'duration';
	String get quality => 'quality';
	String get watched => 'watched';
	String get watchNow => 'Watch now';
	String get aboutThisFilm => 'About This Film';
	String get viewMore => 'View More';
}

// Path: movie.similar
class _TranslationsMovieSimilarEn {
	_TranslationsMovieSimilarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Similar Movies';
}

// Path: movie.report
class _TranslationsMovieReportEn {
	_TranslationsMovieReportEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get headerTitle => 'Report an Issue';
	String get headerSubtitle => 'Help us improve the service quality';
	String get movieInfo => 'Movie Information';
	late final _TranslationsMovieReportLabelsEn labels = _TranslationsMovieReportLabelsEn._(_root);
	String get issueTypeLabel => 'Issue Type *';
	String get descriptionLabel => 'Detailed Description *';
	String get descriptionHint => 'Describe the issue you encountered...';
	late final _TranslationsMovieReportValidationsEn validations = _TranslationsMovieReportValidationsEn._(_root);
	late final _TranslationsMovieReportActionsEn actions = _TranslationsMovieReportActionsEn._(_root);
	String get success => 'Report submitted successfully. Thank you for your feedback!';
	String get failurePrefix => 'Failed to submit report:';
}

// Path: wishlist.common
class _TranslationsWishlistCommonEn {
	_TranslationsWishlistCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get retry => 'Retry';
	String get errorPrefix => 'Error:';
	String get movieNotFound => 'Movie not found';
}

// Path: wishlist.item
class _TranslationsWishlistItemEn {
	_TranslationsWishlistItemEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsWishlistItemMenuEn menu = _TranslationsWishlistItemMenuEn._(_root);
	late final _TranslationsWishlistItemSnackbarEn snackbar = _TranslationsWishlistItemSnackbarEn._(_root);
}

// Path: wishlist.empty
class _TranslationsWishlistEmptyEn {
	_TranslationsWishlistEmptyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Your wishlist is empty';
	String get subtitle => 'Add movies you want to watch later';
}

// Path: auth.loginScreen.placeholder
class _TranslationsAuthLoginScreenPlaceholderEn {
	_TranslationsAuthLoginScreenPlaceholderEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get email => 'admin@ziet.dev';
	String get password => '●●●●●●●●●●●●';
}

// Path: auth.forgotPassword.otp
class _TranslationsAuthForgotPasswordOtpEn {
	_TranslationsAuthForgotPasswordOtpEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'You\'ve Got Mail 📩';
	String get description => 'We have sent the OTP verification code to your email address. Check your email and enter the code below.';
	String get didntReceiveCode => 'Didn\'t receive the code?';
	String get resendCode => 'Resend Code';
	String resendAfter({required Object seconds}) => 'You can resend after ${seconds}s';
}

// Path: auth.forgotPassword.newPassword
class _TranslationsAuthForgotPasswordNewPasswordEn {
	_TranslationsAuthForgotPasswordNewPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Create New Password 🔐';
	String get description => 'Enter your new password. If you forget it, then you have to do forgot password.';
}

// Path: auth.register.placeholder
class _TranslationsAuthRegisterPlaceholderEn {
	_TranslationsAuthRegisterPlaceholderEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get username => 'Enter your username';
	String get password => 'Enter your password';
	String get email => 'Enter your email address';
	String get confirmPassword => 'Confirm your password';
}

// Path: auth.register.steps
class _TranslationsAuthRegisterStepsEn {
	_TranslationsAuthRegisterStepsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get stepOf => 'Step {current} of {total}';
	String get contentForStep => 'Content for step {step}';
	late final _TranslationsAuthRegisterStepsGenderEn gender = _TranslationsAuthRegisterStepsGenderEn._(_root);
	late final _TranslationsAuthRegisterStepsAgeEn age = _TranslationsAuthRegisterStepsAgeEn._(_root);
	late final _TranslationsAuthRegisterStepsGenresEn genres = _TranslationsAuthRegisterStepsGenresEn._(_root);
	late final _TranslationsAuthRegisterStepsProfileEn profile = _TranslationsAuthRegisterStepsProfileEn._(_root);
}

// Path: welcome.slides.discover
class _TranslationsWelcomeSlidesDiscoverEn {
	_TranslationsWelcomeSlidesDiscoverEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Discover New Movies';
	String get description => 'Explore thousands of movies from different genres. Find hidden gems and trending films that match your taste.';
}

// Path: welcome.slides.track
class _TranslationsWelcomeSlidesTrackEn {
	_TranslationsWelcomeSlidesTrackEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Track Your Watchlist';
	String get description => 'Save movies you want to watch, mark what you\'ve seen, and get recommendations based on your preferences.';
}

// Path: welcome.slides.community
class _TranslationsWelcomeSlidesCommunityEn {
	_TranslationsWelcomeSlidesCommunityEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Join the Community';
	String get description => 'Connect with other movie lovers, share reviews, and discover what\'s trending in the film world.';
}

// Path: profile.helpCenter.tabs
class _TranslationsProfileHelpCenterTabsEn {
	_TranslationsProfileHelpCenterTabsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get faq => 'FAQ';
	String get contact => 'Contact us';
}

// Path: profile.helpCenter.categories
class _TranslationsProfileHelpCenterCategoriesEn {
	_TranslationsProfileHelpCenterCategoriesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get all => 'All';
	String get general => 'General';
	String get account => 'Account';
	String get service => 'Service';
	String get movies => 'Movies';
	String get ebook => 'Ebook';
}

// Path: profile.helpCenter.search
class _TranslationsProfileHelpCenterSearchEn {
	_TranslationsProfileHelpCenterSearchEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get hint => 'Search';
	String get noResults => 'No FAQs found';
}

// Path: profile.helpCenter.filter
class _TranslationsProfileHelpCenterFilterEn {
	_TranslationsProfileHelpCenterFilterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get clear => 'Clear';
}

// Path: profile.helpCenter.faq
class _TranslationsProfileHelpCenterFaqEn {
	_TranslationsProfileHelpCenterFaqEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfileHelpCenterFaqGeneralEn general = _TranslationsProfileHelpCenterFaqGeneralEn._(_root);
	late final _TranslationsProfileHelpCenterFaqServiceEn service = _TranslationsProfileHelpCenterFaqServiceEn._(_root);
	late final _TranslationsProfileHelpCenterFaqAccountEn account = _TranslationsProfileHelpCenterFaqAccountEn._(_root);
	late final _TranslationsProfileHelpCenterFaqEbookEn ebook = _TranslationsProfileHelpCenterFaqEbookEn._(_root);
	late final _TranslationsProfileHelpCenterFaqMoviesEn movies = _TranslationsProfileHelpCenterFaqMoviesEn._(_root);
}

// Path: profile.helpCenter.contacts
class _TranslationsProfileHelpCenterContactsEn {
	_TranslationsProfileHelpCenterContactsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfileHelpCenterContactsCustomerServiceEn customerService = _TranslationsProfileHelpCenterContactsCustomerServiceEn._(_root);
	late final _TranslationsProfileHelpCenterContactsWhatsappEn whatsapp = _TranslationsProfileHelpCenterContactsWhatsappEn._(_root);
	late final _TranslationsProfileHelpCenterContactsWebsiteEn website = _TranslationsProfileHelpCenterContactsWebsiteEn._(_root);
	late final _TranslationsProfileHelpCenterContactsFacebookEn facebook = _TranslationsProfileHelpCenterContactsFacebookEn._(_root);
	late final _TranslationsProfileHelpCenterContactsTwitterEn twitter = _TranslationsProfileHelpCenterContactsTwitterEn._(_root);
	late final _TranslationsProfileHelpCenterContactsInstagramEn instagram = _TranslationsProfileHelpCenterContactsInstagramEn._(_root);
}

// Path: profile.notification.toggles
class _TranslationsProfileNotificationTogglesEn {
	_TranslationsProfileNotificationTogglesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get newRecommendation => 'There is a New Recommendation';
	String get newBookSeries => 'There\'s a New Book Series';
	String get authorUpdates => 'There is an update from Authors';
	String get priceDrops => 'There are Price Drops Available';
	String get purchase => 'When I Make a Purchase';
	String get appSystem => 'Enable App System Notifications';
	String get tipsServices => 'New Tips & Services Available';
	String get survey => 'Participate in Survey';
}

// Path: profile.personalInfo.fields
class _TranslationsProfilePersonalInfoFieldsEn {
	_TranslationsProfilePersonalInfoFieldsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfilePersonalInfoFieldsFullNameEn fullName = _TranslationsProfilePersonalInfoFieldsFullNameEn._(_root);
	late final _TranslationsProfilePersonalInfoFieldsUsernameEn username = _TranslationsProfilePersonalInfoFieldsUsernameEn._(_root);
	late final _TranslationsProfilePersonalInfoFieldsEmailEn email = _TranslationsProfilePersonalInfoFieldsEmailEn._(_root);
	late final _TranslationsProfilePersonalInfoFieldsPhoneEn phone = _TranslationsProfilePersonalInfoFieldsPhoneEn._(_root);
	late final _TranslationsProfilePersonalInfoFieldsDobEn dob = _TranslationsProfilePersonalInfoFieldsDobEn._(_root);
	late final _TranslationsProfilePersonalInfoFieldsCountryEn country = _TranslationsProfilePersonalInfoFieldsCountryEn._(_root);
}

// Path: profile.preferences.sections
class _TranslationsProfilePreferencesSectionsEn {
	_TranslationsProfilePreferencesSectionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get general => 'General';
	String get playback => 'Playback';
	String get video => 'Video';
	String get audio => 'Audio';
}

// Path: profile.preferences.toggles
class _TranslationsProfilePreferencesTogglesEn {
	_TranslationsProfilePreferencesTogglesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get wifiOnlyDownloads => 'Watch over Wi-Fi Only';
	String get autoPlayNextEpisode => 'Auto Play Next Episode';
	String get continueWatching => 'Continue Watching from Last Position';
	String get subtitlesEnabled => 'Subtitles';
	String get autoRotateScreen => 'Auto Rotate Screen';
	String get autoDownloadAudio => 'Automatically Download Audio';
}

// Path: profile.preferences.actions
class _TranslationsProfilePreferencesActionsEn {
	_TranslationsProfilePreferencesActionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfilePreferencesActionsClearCacheEn clearCache = _TranslationsProfilePreferencesActionsClearCacheEn._(_root);
	late final _TranslationsProfilePreferencesActionsVideoQualityEn videoQuality = _TranslationsProfilePreferencesActionsVideoQualityEn._(_root);
	late final _TranslationsProfilePreferencesActionsAudioPreferenceEn audioPreference = _TranslationsProfilePreferencesActionsAudioPreferenceEn._(_root);
}

// Path: profile.preferences.storageLabel
class _TranslationsProfilePreferencesStorageLabelEn {
	_TranslationsProfilePreferencesStorageLabelEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get empty => '0 MB stored';
	String value({required Object amount}) => '${amount} MB stored';
}

// Path: profile.security.toggles
class _TranslationsProfileSecurityTogglesEn {
	_TranslationsProfileSecurityTogglesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get rememberMe => 'Remember me';
	String get biometricId => 'Biometric ID';
	String get faceId => 'Face ID';
	String get smsAuthenticator => 'SMS Authenticator';
	String get googleAuthenticator => 'Google Authenticator';
}

// Path: profile.security.actions
class _TranslationsProfileSecurityActionsEn {
	_TranslationsProfileSecurityActionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get deviceManagement => 'Device Management';
	String get changePassword => 'Change Password';
	String get changePasswordMessage => 'Change password tapped';
	String signOutDevice({required Object name}) => 'Signed out ${name}';
	String get signOutAll => 'Signed out from all devices';
}

// Path: profile.security.deviceManagement
class _TranslationsProfileSecurityDeviceManagementEn {
	_TranslationsProfileSecurityDeviceManagementEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Device Management';
	String get description => 'Manage devices that have access to your account.';
	String get signOutAll => 'Sign Out All Devices';
	String get current => 'Current';
	String lastActive({required Object time}) => 'Last active: ${time}';
}

// Path: validation.general.custom
class _TranslationsValidationGeneralCustomEn {
	_TranslationsValidationGeneralCustomEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get password => 'The password must have characters, numbers.';
	String get username => 'The username must only contain lowercase letters (a-z), numbers (0-9), hyphens (-), and underscores (_).';
}

// Path: search.filter.sections
class _TranslationsSearchFilterSectionsEn {
	_TranslationsSearchFilterSectionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get sort => 'Sort';
	String get price => 'Price';
	String get rating => 'Rating';
	String get genre => 'Genre';
	String get language => 'Language';
	String get age => 'Age';
}

// Path: search.filter.sortOptions
class _TranslationsSearchFilterSortOptionsEn {
	_TranslationsSearchFilterSortOptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get trending => 'Trending';
	String get newReleases => 'New Releases';
	String get highestRating => 'Highest Rating';
	String get lowestRating => 'Lowest Rating';
	String get highestPrice => 'Highest Price';
	String get lowestPrice => 'Lowest Price';
}

// Path: search.filter.genres
class _TranslationsSearchFilterGenresEn {
	_TranslationsSearchFilterGenresEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get action => 'Action';
	String get adventure => 'Adventure';
	String get romance => 'Romance';
	String get comics => 'Comics';
	String get comedy => 'Comedy';
	String get fantasy => 'Fantasy';
	String get mystery => 'Mystery';
	String get horror => 'Horror';
	String get scienceFiction => 'Science Fiction';
	String get thriller => 'Thriller';
	String get travel => 'Travel';
}

// Path: search.filter.rangePrice
class _TranslationsSearchFilterRangePriceEn {
	_TranslationsSearchFilterRangePriceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get min => '0';
	String get max => '30';
}

// Path: search.filter.languages
class _TranslationsSearchFilterLanguagesEn {
	_TranslationsSearchFilterLanguagesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get english => 'English';
	String get vietnamese => 'Vietnamese';
	String get others => 'Others';
}

// Path: search.filter.age
class _TranslationsSearchFilterAgeEn {
	_TranslationsSearchFilterAgeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get under12 => 'Age 12 & Under';
	String get above12 => '12+';
	String get above16 => '16+';
	String get above18 => '18+';
}

// Path: purchase.checkout.section
class _TranslationsPurchaseCheckoutSectionEn {
	_TranslationsPurchaseCheckoutSectionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get movieSummary => 'Movie Summary';
	String get priceDetails => 'Price Details';
	String get paymentMethod => 'Payment Method';
}

// Path: purchase.checkout.labels
class _TranslationsPurchaseCheckoutLabelsEn {
	_TranslationsPurchaseCheckoutLabelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get price => 'Price';
	String get total => 'Total';
	String get visa => 'Visa';
}

// Path: purchase.checkout.actions
class _TranslationsPurchaseCheckoutActionsEn {
	_TranslationsPurchaseCheckoutActionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get confirm => 'Confirm';
	String get payNow => 'Pay Now';
	String get processing => 'Processing...';
}

// Path: purchase.checkout.toasts
class _TranslationsPurchaseCheckoutToastsEn {
	_TranslationsPurchaseCheckoutToastsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get addedSuccess => 'Movie added successfully! 🎬';
	String get paymentSuccess => 'Payment successful! 🎬';
	String get paymentFailed => 'Payment failed. Please try again.';
	String get paymentCanceled => 'Payment was canceled';
}

// Path: purchase.item.menu
class _TranslationsPurchaseItemMenuEn {
	_TranslationsPurchaseItemMenuEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get watchNow => 'Watch now';
	String get viewSeries => 'View Series';
	String get purchaseDetails => 'Purchase Details';
	String get aboutMovie => 'About Movie';
}

// Path: purchase.item.snackbar
class _TranslationsPurchaseItemSnackbarEn {
	_TranslationsPurchaseItemSnackbarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get viewSeriesComing => 'View series - coming soon';
}

// Path: movie.ratings.dialog
class _TranslationsMovieRatingsDialogEn {
	_TranslationsMovieRatingsDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Write a Review';
	String get yourRatingPrefix => 'Your rating:';
	String get star => 'star';
	String get stars => 'stars';
	String get hint => 'Write your review...';
	String get cancel => 'Cancel';
	String get submit => 'Submit';
	String get submitted => 'Review submitted';
}

// Path: movie.report.labels
class _TranslationsMovieReportLabelsEn {
	_TranslationsMovieReportLabelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get movieName => 'Movie Name';
	String get director => 'Director';
	String get videoUrl => 'Video URL';
	String get error => 'Error';
}

// Path: movie.report.validations
class _TranslationsMovieReportValidationsEn {
	_TranslationsMovieReportValidationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get selectIssue => 'Please select an issue type';
	String get descRequired => 'Please enter a detailed description';
	String get descMin => 'Description must be at least 10 characters';
}

// Path: movie.report.actions
class _TranslationsMovieReportActionsEn {
	_TranslationsMovieReportActionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get cancel => 'Cancel';
	String get submit => 'Submit Report';
	String get sending => 'Sending...';
}

// Path: wishlist.item.menu
class _TranslationsWishlistItemMenuEn {
	_TranslationsWishlistItemMenuEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get removeFromWishlist => 'Remove from Wishlist';
	String get share => 'Share';
	String get aboutMovie => 'About Movie';
}

// Path: wishlist.item.snackbar
class _TranslationsWishlistItemSnackbarEn {
	_TranslationsWishlistItemSnackbarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get removed => 'Removed from wishlist';
	String get shareComing => 'Share functionality coming soon';
}

// Path: auth.register.steps.gender
class _TranslationsAuthRegisterStepsGenderEn {
	_TranslationsAuthRegisterStepsGenderEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get select => 'Select your gender';
	String get question => 'What is your gender?';
	String get description => 'Select gender for better content';
	late final _TranslationsAuthRegisterStepsGenderOptionsEn options = _TranslationsAuthRegisterStepsGenderOptionsEn._(_root);
	late final _TranslationsAuthRegisterStepsGenderChoicesEn choices = _TranslationsAuthRegisterStepsGenderChoicesEn._(_root);
}

// Path: auth.register.steps.age
class _TranslationsAuthRegisterStepsAgeEn {
	_TranslationsAuthRegisterStepsAgeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get select => 'Select your age';
	String get title => 'Choose your Age';
	String get description => 'Select age range for better content';
	late final _TranslationsAuthRegisterStepsAgeRangesEn ranges = _TranslationsAuthRegisterStepsAgeRangesEn._(_root);
}

// Path: auth.register.steps.genres
class _TranslationsAuthRegisterStepsGenresEn {
	_TranslationsAuthRegisterStepsGenresEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get select => 'Select your favorite genres';
	String get title => 'Choose the Movie Genre You Like';
	String get description => 'Select your preferred movie genre for better recommendation or you can skip it';
	late final _TranslationsAuthRegisterStepsGenresListEn list = _TranslationsAuthRegisterStepsGenresListEn._(_root);
}

// Path: auth.register.steps.profile
class _TranslationsAuthRegisterStepsProfileEn {
	_TranslationsAuthRegisterStepsProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Complete Your Profile';
	String get infoTitle => 'Profile Information';
	String get accountTitle => 'Account Information';
	String get privacyNote => 'Don\'t worry, only you can see your personal data. No one else will be able to see it.';
	late final _TranslationsAuthRegisterStepsProfilePhotoEn photo = _TranslationsAuthRegisterStepsProfilePhotoEn._(_root);
	late final _TranslationsAuthRegisterStepsProfileFieldsEn fields = _TranslationsAuthRegisterStepsProfileFieldsEn._(_root);
}

// Path: profile.helpCenter.faq.general
class _TranslationsProfileHelpCenterFaqGeneralEn {
	_TranslationsProfileHelpCenterFaqGeneralEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfileHelpCenterFaqGeneralWhatIsNozieEn whatIsNozie = _TranslationsProfileHelpCenterFaqGeneralWhatIsNozieEn._(_root);
	late final _TranslationsProfileHelpCenterFaqGeneralSyncProgressEn syncProgress = _TranslationsProfileHelpCenterFaqGeneralSyncProgressEn._(_root);
	late final _TranslationsProfileHelpCenterFaqGeneralFormatsSupportEn formatsSupport = _TranslationsProfileHelpCenterFaqGeneralFormatsSupportEn._(_root);
}

// Path: profile.helpCenter.faq.service
class _TranslationsProfileHelpCenterFaqServiceEn {
	_TranslationsProfileHelpCenterFaqServiceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfileHelpCenterFaqServicePurchaseEbookEn purchaseEbook = _TranslationsProfileHelpCenterFaqServicePurchaseEbookEn._(_root);
	late final _TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingEn audiobookNotPlaying = _TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingEn._(_root);
	late final _TranslationsProfileHelpCenterFaqServiceManageNotificationsEn manageNotifications = _TranslationsProfileHelpCenterFaqServiceManageNotificationsEn._(_root);
	late final _TranslationsProfileHelpCenterFaqServiceRequestRefundEn requestRefund = _TranslationsProfileHelpCenterFaqServiceRequestRefundEn._(_root);
	late final _TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueEn purchaseEbookIssue = _TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueEn._(_root);
	late final _TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueEn downloadEbookIssue = _TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueEn._(_root);
}

// Path: profile.helpCenter.faq.account
class _TranslationsProfileHelpCenterFaqAccountEn {
	_TranslationsProfileHelpCenterFaqAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodEn addPaymentMethod = _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodEn._(_root);
	late final _TranslationsProfileHelpCenterFaqAccountResetPasswordEn resetPassword = _TranslationsProfileHelpCenterFaqAccountResetPasswordEn._(_root);
	late final _TranslationsProfileHelpCenterFaqAccountChangeLanguageEn changeLanguage = _TranslationsProfileHelpCenterFaqAccountChangeLanguageEn._(_root);
	late final _TranslationsProfileHelpCenterFaqAccountDeleteAccountEn deleteAccount = _TranslationsProfileHelpCenterFaqAccountDeleteAccountEn._(_root);
	late final _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueEn addPaymentMethodIssue = _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueEn._(_root);
}

// Path: profile.helpCenter.faq.ebook
class _TranslationsProfileHelpCenterFaqEbookEn {
	_TranslationsProfileHelpCenterFaqEbookEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfileHelpCenterFaqEbookDownloadOfflineEn downloadOffline = _TranslationsProfileHelpCenterFaqEbookDownloadOfflineEn._(_root);
}

// Path: profile.helpCenter.faq.movies
class _TranslationsProfileHelpCenterFaqMoviesEn {
	_TranslationsProfileHelpCenterFaqMoviesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountEn closeErabookAccount = _TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountEn._(_root);
}

// Path: profile.helpCenter.contacts.customerService
class _TranslationsProfileHelpCenterContactsCustomerServiceEn {
	_TranslationsProfileHelpCenterContactsCustomerServiceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Customer Service';
	String get subtitle => 'support@nozie.app';
}

// Path: profile.helpCenter.contacts.whatsapp
class _TranslationsProfileHelpCenterContactsWhatsappEn {
	_TranslationsProfileHelpCenterContactsWhatsappEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'WhatsApp';
	String get subtitle => '+1 800 123 4567';
}

// Path: profile.helpCenter.contacts.website
class _TranslationsProfileHelpCenterContactsWebsiteEn {
	_TranslationsProfileHelpCenterContactsWebsiteEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Website';
	String get subtitle => 'www.nozie.app/support';
}

// Path: profile.helpCenter.contacts.facebook
class _TranslationsProfileHelpCenterContactsFacebookEn {
	_TranslationsProfileHelpCenterContactsFacebookEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Facebook';
	String get subtitle => '@NozieOfficial';
}

// Path: profile.helpCenter.contacts.twitter
class _TranslationsProfileHelpCenterContactsTwitterEn {
	_TranslationsProfileHelpCenterContactsTwitterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Twitter';
	String get subtitle => '@NozieApp';
}

// Path: profile.helpCenter.contacts.instagram
class _TranslationsProfileHelpCenterContactsInstagramEn {
	_TranslationsProfileHelpCenterContactsInstagramEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Instagram';
	String get subtitle => '@nozie.app';
}

// Path: profile.personalInfo.fields.fullName
class _TranslationsProfilePersonalInfoFieldsFullNameEn {
	_TranslationsProfilePersonalInfoFieldsFullNameEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Full Name';
	String get hint => 'Enter full name';
}

// Path: profile.personalInfo.fields.username
class _TranslationsProfilePersonalInfoFieldsUsernameEn {
	_TranslationsProfilePersonalInfoFieldsUsernameEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Username';
	String get hint => 'Enter username';
}

// Path: profile.personalInfo.fields.email
class _TranslationsProfilePersonalInfoFieldsEmailEn {
	_TranslationsProfilePersonalInfoFieldsEmailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Email';
	String get hint => 'Enter email address';
}

// Path: profile.personalInfo.fields.phone
class _TranslationsProfilePersonalInfoFieldsPhoneEn {
	_TranslationsProfilePersonalInfoFieldsPhoneEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Phone Number';
	String get hint => 'Enter phone number';
}

// Path: profile.personalInfo.fields.dob
class _TranslationsProfilePersonalInfoFieldsDobEn {
	_TranslationsProfilePersonalInfoFieldsDobEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Date of Birth';
	String get hint => 'DD/MM/YYYY';
}

// Path: profile.personalInfo.fields.country
class _TranslationsProfilePersonalInfoFieldsCountryEn {
	_TranslationsProfilePersonalInfoFieldsCountryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Country';
	String get hint => 'Select country';
}

// Path: profile.preferences.actions.clearCache
class _TranslationsProfilePreferencesActionsClearCacheEn {
	_TranslationsProfilePreferencesActionsClearCacheEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Clear Cache';
	String description({required Object size}) => 'Currently stored: ${size}. Removing cache will delete temporary files but keep your downloads and preferences.';
	String get button => 'Clear Cache';
	String get success => 'Cache cleared';
}

// Path: profile.preferences.actions.videoQuality
class _TranslationsProfilePreferencesActionsVideoQualityEn {
	_TranslationsProfilePreferencesActionsVideoQualityEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Video Quality';
	late final _TranslationsProfilePreferencesActionsVideoQualityOptionsEn options = _TranslationsProfilePreferencesActionsVideoQualityOptionsEn._(_root);
}

// Path: profile.preferences.actions.audioPreference
class _TranslationsProfilePreferencesActionsAudioPreferenceEn {
	_TranslationsProfilePreferencesActionsAudioPreferenceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Audio Language / Quality';
	late final _TranslationsProfilePreferencesActionsAudioPreferenceOptionsEn options = _TranslationsProfilePreferencesActionsAudioPreferenceOptionsEn._(_root);
}

// Path: auth.register.steps.gender.options
class _TranslationsAuthRegisterStepsGenderOptionsEn {
	_TranslationsAuthRegisterStepsGenderOptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get male => 'Male';
	String get female => 'Female';
	String get other => 'Other';
	String get preferNotToSay => 'Prefer not to say';
}

// Path: auth.register.steps.gender.choices
class _TranslationsAuthRegisterStepsGenderChoicesEn {
	_TranslationsAuthRegisterStepsGenderChoicesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get iAmMale => 'I am male';
	String get iAmFemale => 'I am female';
	String get ratherNotToSay => 'Rather not to say';
}

// Path: auth.register.steps.age.ranges
class _TranslationsAuthRegisterStepsAgeRangesEn {
	_TranslationsAuthRegisterStepsAgeRangesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get age14to17 => '14-17';
	String get age18to24 => '18-24';
	String get age25to29 => '25-29';
	String get age30to34 => '30-34';
	String get age35to39 => '35-39';
	String get age40to44 => '40-44';
	String get age45to49 => '45-49';
	String get age50plus => '50+';
}

// Path: auth.register.steps.genres.list
class _TranslationsAuthRegisterStepsGenresListEn {
	_TranslationsAuthRegisterStepsGenresListEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get amNhac => 'Music';
	String get biAn => 'Mystery';
	String get chienTranh => 'War';
	String get chinhKich => 'Drama';
	String get coTrang => 'Historical';
	String get giaDinh => 'Family';
	String get haiHuoc => 'Comedy';
	String get hanhDong => 'Action';
	String get hinhSu => 'Crime';
	String get hocDuong => 'School';
	String get khoaHoc => 'Science';
	String get kinhDi => 'Horror';
	String get kinhDien => 'Classic';
	String get phieuLuu => 'Adventure';
	String get phim18 => 'Adult 18+';
	String get shortDrama => 'Short Drama';
	String get taiLieu => 'Documentary';
	String get tamLy => 'Psychological';
	String get thanThoai => 'Mythology';
	String get theThao => 'Sport';
	String get tinhCam => 'Romance';
	String get vienTuong => 'Sci-Fi';
	String get voThuat => 'Martial Arts';
}

// Path: auth.register.steps.profile.photo
class _TranslationsAuthRegisterStepsProfilePhotoEn {
	_TranslationsAuthRegisterStepsProfilePhotoEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get add => 'Add Photo';
	String get tapToAdd => 'Tap to add profile picture';
}

// Path: auth.register.steps.profile.fields
class _TranslationsAuthRegisterStepsProfileFieldsEn {
	_TranslationsAuthRegisterStepsProfileFieldsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsAuthRegisterStepsProfileFieldsFullNameEn fullName = _TranslationsAuthRegisterStepsProfileFieldsFullNameEn._(_root);
	late final _TranslationsAuthRegisterStepsProfileFieldsPhoneNumberEn phoneNumber = _TranslationsAuthRegisterStepsProfileFieldsPhoneNumberEn._(_root);
	late final _TranslationsAuthRegisterStepsProfileFieldsDateOfBirthEn dateOfBirth = _TranslationsAuthRegisterStepsProfileFieldsDateOfBirthEn._(_root);
	late final _TranslationsAuthRegisterStepsProfileFieldsCountryEn country = _TranslationsAuthRegisterStepsProfileFieldsCountryEn._(_root);
}

// Path: profile.helpCenter.faq.general.whatIsNozie
class _TranslationsProfileHelpCenterFaqGeneralWhatIsNozieEn {
	_TranslationsProfileHelpCenterFaqGeneralWhatIsNozieEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'What is Nozie?';
	String get answer => 'Nozie is your personal hub for discovering, reading, and listening to stories. Browse curated recommendations, organise your library, and stay synced across devices.';
}

// Path: profile.helpCenter.faq.general.syncProgress
class _TranslationsProfileHelpCenterFaqGeneralSyncProgressEn {
	_TranslationsProfileHelpCenterFaqGeneralSyncProgressEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How do I sync reading progress across devices?';
	String get answer => 'Make sure you are signed in on all devices. Progress syncs automatically when the device is online; pull to refresh in Library to force a sync.';
}

// Path: profile.helpCenter.faq.general.formatsSupport
class _TranslationsProfileHelpCenterFaqGeneralFormatsSupportEn {
	_TranslationsProfileHelpCenterFaqGeneralFormatsSupportEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'What formats does Nozie support?';
	String get answer => 'Nozie supports EPUB, PDF, and MP3 audiobook files. Uploaded personal files are converted automatically for best playback.';
}

// Path: profile.helpCenter.faq.service.purchaseEbook
class _TranslationsProfileHelpCenterFaqServicePurchaseEbookEn {
	_TranslationsProfileHelpCenterFaqServicePurchaseEbookEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How to purchase an Ebook?';
	String get answer => 'Open the book detail page, tap the "Buy" button, choose a payment method, then confirm. Purchased titles instantly appear in your Library tab.';
}

// Path: profile.helpCenter.faq.service.audiobookNotPlaying
class _TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingEn {
	_TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'Why is my audiobook not playing?';
	String get answer => 'Ensure your device volume is up and you have a stable connection. If the issue persists, try clearing cache from Profile > Help Center and restart the app.';
}

// Path: profile.helpCenter.faq.service.manageNotifications
class _TranslationsProfileHelpCenterFaqServiceManageNotificationsEn {
	_TranslationsProfileHelpCenterFaqServiceManageNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How to manage notifications?';
	String get answer => 'Go to Profile > Notification Settings to enable or disable alerts for recommendations, purchases, promotions, and more.';
}

// Path: profile.helpCenter.faq.service.requestRefund
class _TranslationsProfileHelpCenterFaqServiceRequestRefundEn {
	_TranslationsProfileHelpCenterFaqServiceRequestRefundEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How do I request a refund?';
	String get answer => 'Contact support via Help Center > Contact Us, provide your order ID, and our team will review within 24 hours.';
}

// Path: profile.helpCenter.faq.service.purchaseEbookIssue
class _TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueEn {
	_TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'Why can\'t I purchase an ebook?';
	String get answer => 'Verify that you have a valid payment method added and a stable internet connection. If the issue persists, try signing out and back in before attempting the purchase again.';
}

// Path: profile.helpCenter.faq.service.downloadEbookIssue
class _TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueEn {
	_TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'Why can\'t I download an ebook?';
	String get answer => 'Ensure the title is purchased and you have sufficient storage space. Downloads require Wi-Fi unless you enable cellular downloads in Preferences.';
}

// Path: profile.helpCenter.faq.account.addPaymentMethod
class _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodEn {
	_TranslationsProfileHelpCenterFaqAccountAddPaymentMethodEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How to add a payment method?';
	String get answer => 'Head to Profile > Payment Methods, choose "Add New", enter your card or wallet details, and save. You can manage or remove methods anytime from the same screen.';
}

// Path: profile.helpCenter.faq.account.resetPassword
class _TranslationsProfileHelpCenterFaqAccountResetPasswordEn {
	_TranslationsProfileHelpCenterFaqAccountResetPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How do I reset my password?';
	String get answer => 'Go to Login > Forgot Password, enter your email, and follow the verification steps. You can set a new password once you confirm the OTP sent to your inbox.';
}

// Path: profile.helpCenter.faq.account.changeLanguage
class _TranslationsProfileHelpCenterFaqAccountChangeLanguageEn {
	_TranslationsProfileHelpCenterFaqAccountChangeLanguageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How do I change the app language?';
	String get answer => 'Navigate to Profile > Language to select your preferred language. Your choice syncs instantly across all sections of the app.';
}

// Path: profile.helpCenter.faq.account.deleteAccount
class _TranslationsProfileHelpCenterFaqAccountDeleteAccountEn {
	_TranslationsProfileHelpCenterFaqAccountDeleteAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How can I delete my account?';
	String get answer => 'Open Settings > Security > Delete Account. Follow the instructions to confirm your identity and complete the deletion process.';
}

// Path: profile.helpCenter.faq.account.addPaymentMethodIssue
class _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueEn {
	_TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'Why can\'t I add a payment method?';
	String get answer => 'Check that your card details are correct and supported in your region. Some prepaid cards and virtual wallets may be restricted by your bank or country.';
}

// Path: profile.helpCenter.faq.ebook.downloadOffline
class _TranslationsProfileHelpCenterFaqEbookDownloadOfflineEn {
	_TranslationsProfileHelpCenterFaqEbookDownloadOfflineEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'How can I download ebooks for offline reading?';
	String get answer => 'Open any purchased title, tap the download icon, and choose the device storage location. Downloads are available offline from your Library tab.';
}

// Path: profile.helpCenter.faq.movies.closeErabookAccount
class _TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountEn {
	_TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get question => 'Why can\'t I close an account on Erabook?';
	String get answer => 'If you linked your Nozie account with Erabook, unlink the integration under Profile > Connected Services first. Afterwards, submit the closure request from the Erabook dashboard.';
}

// Path: profile.preferences.actions.videoQuality.options
class _TranslationsProfilePreferencesActionsVideoQualityOptionsEn {
	_TranslationsProfilePreferencesActionsVideoQualityOptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get auto => 'Auto';
	String get hd => 'HD';
	String get fullHd => 'Full HD';
}

// Path: profile.preferences.actions.audioPreference.options
class _TranslationsProfilePreferencesActionsAudioPreferenceOptionsEn {
	_TranslationsProfilePreferencesActionsAudioPreferenceOptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get systemDefault => 'System Default';
	String get englishHigh => 'English • High Quality';
	String get originalStandard => 'Original • Standard';
}

// Path: auth.register.steps.profile.fields.fullName
class _TranslationsAuthRegisterStepsProfileFieldsFullNameEn {
	_TranslationsAuthRegisterStepsProfileFieldsFullNameEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Full Name';
	String get placeholder => 'Enter your full name';
}

// Path: auth.register.steps.profile.fields.phoneNumber
class _TranslationsAuthRegisterStepsProfileFieldsPhoneNumberEn {
	_TranslationsAuthRegisterStepsProfileFieldsPhoneNumberEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Phone Number';
	String get placeholder => 'Enter your phone number';
}

// Path: auth.register.steps.profile.fields.dateOfBirth
class _TranslationsAuthRegisterStepsProfileFieldsDateOfBirthEn {
	_TranslationsAuthRegisterStepsProfileFieldsDateOfBirthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Date of Birth';
	String get format => 'DD/MM/YYYY';
}

// Path: auth.register.steps.profile.fields.country
class _TranslationsAuthRegisterStepsProfileFieldsCountryEn {
	_TranslationsAuthRegisterStepsProfileFieldsCountryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Country';
	String get placeholder => 'Enter your country';
}

// Path: <root>
class _TranslationsVi extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsVi.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.vi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <vi>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _TranslationsVi _root = this; // ignore: unused_field

	// Translations
	@override String get locale => 'vi';
	@override late final _TranslationsAppVi app = _TranslationsAppVi._(_root);
	@override late final _TranslationsCommonVi common = _TranslationsCommonVi._(_root);
	@override late final _TranslationsNotificationVi notification = _TranslationsNotificationVi._(_root);
	@override late final _TranslationsAuthVi auth = _TranslationsAuthVi._(_root);
	@override late final _TranslationsWelcomeVi welcome = _TranslationsWelcomeVi._(_root);
	@override late final _TranslationsSettingsVi settings = _TranslationsSettingsVi._(_root);
	@override late final _TranslationsProfileVi profile = _TranslationsProfileVi._(_root);
	@override late final _TranslationsValidationVi validation = _TranslationsValidationVi._(_root);
	@override late final _TranslationsNavigationVi navigation = _TranslationsNavigationVi._(_root);
	@override late final _TranslationsSearchVi search = _TranslationsSearchVi._(_root);
	@override late final _TranslationsUtilsVi utils = _TranslationsUtilsVi._(_root);
	@override late final _TranslationsCardsVi cards = _TranslationsCardsVi._(_root);
	@override late final _TranslationsPurchaseDetailVi purchaseDetail = _TranslationsPurchaseDetailVi._(_root);
	@override late final _TranslationsDiscoverVi discover = _TranslationsDiscoverVi._(_root);
	@override late final _TranslationsHomeVi home = _TranslationsHomeVi._(_root);
	@override late final _TranslationsGenreVi genre = _TranslationsGenreVi._(_root);
	@override late final _TranslationsPurchaseVi purchase = _TranslationsPurchaseVi._(_root);
	@override late final _TranslationsMovieVi movie = _TranslationsMovieVi._(_root);
	@override late final _TranslationsWishlistVi wishlist = _TranslationsWishlistVi._(_root);
}

// Path: app
class _TranslationsAppVi extends _TranslationsAppEn {
	_TranslationsAppVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'NoZie';
}

// Path: common
class _TranslationsCommonVi extends _TranslationsCommonEn {
	_TranslationsCommonVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get skip => 'Bỏ qua';
	@override String get continueText => 'Tiếp tục';
	@override String get confirm => 'Xác nhận';
	@override String get data => 'Dữ liệu';
	@override String get save => 'Lưu';
	@override String get cancel => 'Hủy';
	@override String get next => 'Tiếp theo';
	@override String get back => 'Quay lại';
	@override String get done => 'Hoàn thành';
	@override String get empty => 'Trống';
	@override String get yes => 'Có';
	@override String get no => 'Không';
	@override String get addNew => 'Thêm mới';
	@override String get clear => 'Xoá';
	@override String get search => 'Tìm kiếm';
	@override String get loading => 'Đang tải…';
	@override String get signOut => 'Đăng xuất';
	@override String get retry => 'Thử lại';
	@override String get errorPrefix => 'Lỗi:';
}

// Path: notification
class _TranslationsNotificationVi extends _TranslationsNotificationEn {
	_TranslationsNotificationVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Thông báo';
	@override String get empty => 'Chưa có thông báo nào';
	@override String get markAllAsRead => 'Đánh dấu tất cả là đã đọc';
	@override String get newItem => 'Thông báo mới';
	@override String get seeAll => 'Xem tất cả';
	@override String get today => 'Hôm nay';
	@override String get dayAgo => 'Ngày trước';
	@override String get loadFailed => 'Lỗi khi tải thông báo';
	@override String markAllAsReadFailed({required Object error}) => 'Không thể đánh dấu tất cả là đã đọc: ${error}';
}

// Path: auth
class _TranslationsAuthVi extends _TranslationsAuthEn {
	_TranslationsAuthVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get login => 'Đăng nhập';
	@override String get signIn => 'Đăng Nhập';
	@override String get signUp => 'Đăng ký';
	@override String get email => 'Email';
	@override String get password => 'Mật khẩu';
	@override String get username => 'Tên đăng nhập';
	@override String get confirmPassword => 'Xác nhận mật khẩu';
	@override String get rememberMe => 'Ghi nhớ tôi';
	@override late final _TranslationsAuthErrorsVi errors = _TranslationsAuthErrorsVi._(_root);
	@override late final _TranslationsAuthLoginScreenVi loginScreen = _TranslationsAuthLoginScreenVi._(_root);
	@override late final _TranslationsAuthOauthVi oauth = _TranslationsAuthOauthVi._(_root);
	@override late final _TranslationsAuthForgotPasswordVi forgotPassword = _TranslationsAuthForgotPasswordVi._(_root);
	@override late final _TranslationsAuthRegisterVi register = _TranslationsAuthRegisterVi._(_root);
}

// Path: welcome
class _TranslationsWelcomeVi extends _TranslationsWelcomeEn {
	_TranslationsWelcomeVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Chào mừng đến với NoZie 👋';
	@override String get titlePrefix => 'Chào mừng đến với ';
	@override String get description => 'Người bạn đồng hành phim của bạn. Nhận gợi ý cá nhân hóa, khám phá phim mới và theo dõi danh sách xem của bạn.';
	@override String get getStarted => 'Bắt đầu';
	@override String get continueWithGoogle => 'Tiếp tục với Google';
	@override String get iAlreadyHaveAnAccount => 'Tôi đã có tài khoản';
	@override late final _TranslationsWelcomeSlidesVi slides = _TranslationsWelcomeSlidesVi._(_root);
}

// Path: settings
class _TranslationsSettingsVi extends _TranslationsSettingsEn {
	_TranslationsSettingsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSettingsLanguageVi language = _TranslationsSettingsLanguageVi._(_root);
	@override late final _TranslationsSettingsThemeVi theme = _TranslationsSettingsThemeVi._(_root);
}

// Path: profile
class _TranslationsProfileVi extends _TranslationsProfileEn {
	_TranslationsProfileVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfileHeaderVi header = _TranslationsProfileHeaderVi._(_root);
	@override late final _TranslationsProfileMenuVi menu = _TranslationsProfileMenuVi._(_root);
	@override late final _TranslationsProfileLanguageVi language = _TranslationsProfileLanguageVi._(_root);
	@override late final _TranslationsProfileLogoutSheetVi logoutSheet = _TranslationsProfileLogoutSheetVi._(_root);
	@override late final _TranslationsProfileHelpCenterVi helpCenter = _TranslationsProfileHelpCenterVi._(_root);
	@override late final _TranslationsProfilePaymentVi payment = _TranslationsProfilePaymentVi._(_root);
	@override late final _TranslationsProfileNotificationVi notification = _TranslationsProfileNotificationVi._(_root);
	@override late final _TranslationsProfilePersonalInfoVi personalInfo = _TranslationsProfilePersonalInfoVi._(_root);
	@override late final _TranslationsProfilePreferencesVi preferences = _TranslationsProfilePreferencesVi._(_root);
	@override late final _TranslationsProfileSecurityVi security = _TranslationsProfileSecurityVi._(_root);
}

// Path: validation
class _TranslationsValidationVi extends _TranslationsValidationEn {
	_TranslationsValidationVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsValidationGeneralVi general = _TranslationsValidationGeneralVi._(_root);
	@override late final _TranslationsValidationNameVi name = _TranslationsValidationNameVi._(_root);
	@override late final _TranslationsValidationPhoneVi phone = _TranslationsValidationPhoneVi._(_root);
	@override late final _TranslationsValidationDateOfBirthVi dateOfBirth = _TranslationsValidationDateOfBirthVi._(_root);
	@override late final _TranslationsValidationCountryVi country = _TranslationsValidationCountryVi._(_root);
	@override late final _TranslationsValidationUsernameVi username = _TranslationsValidationUsernameVi._(_root);
	@override late final _TranslationsValidationEmailVi email = _TranslationsValidationEmailVi._(_root);
	@override late final _TranslationsValidationPasswordVi password = _TranslationsValidationPasswordVi._(_root);
}

// Path: navigation
class _TranslationsNavigationVi extends _TranslationsNavigationEn {
	_TranslationsNavigationVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get home => 'Trang chủ';
	@override String get discover => 'Khám phá';
	@override String get wishlist => 'Yêu thích';
	@override String get purchase => 'Mua';
	@override String get profile => 'Hồ sơ';
}

// Path: search
class _TranslationsSearchVi extends _TranslationsSearchEn {
	_TranslationsSearchVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get searchMovies => 'Tìm kiếm phim, chương trình TV, diễn viên...';
	@override String get popularSearches => 'Tìm kiếm phổ biến';
	@override String get noResultsFound => 'Không tìm thấy kết quả';
	@override String get tryDifferentKeywords => 'Thử từ khóa khác hoặc kiểm tra chính tả';
	@override String get all => 'Tất cả';
	@override String get movies => 'Phim';
	@override String get tvShows => 'Chương trình TV';
	@override String get actors => 'Diễn viên';
	@override String get previousSearches => 'Tìm kiếm trước';
	@override String get noResults => 'Không tìm thấy kết quả';
	@override String get showIn => 'Kết quả';
	@override late final _TranslationsSearchFilterVi filter = _TranslationsSearchFilterVi._(_root);
}

// Path: utils
class _TranslationsUtilsVi extends _TranslationsUtilsEn {
	_TranslationsUtilsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get itemsCount => '{count, plural, =0{Không có mục} =1{1 mục} other{{count} mục}}';
	@override String get helloUser => 'Xin chào, {name}!';
	@override String get counterText => '';
}

// Path: cards
class _TranslationsCardsVi extends _TranslationsCardsEn {
	_TranslationsCardsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get showIn => 'Hiển thị trong';
}

// Path: purchaseDetail
class _TranslationsPurchaseDetailVi extends _TranslationsPurchaseDetailEn {
	_TranslationsPurchaseDetailVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Chi tiết giao dịch';
	@override String get infoTitle => 'Thông tin mua hàng';
	@override late final _TranslationsPurchaseDetailLabelsVi labels = _TranslationsPurchaseDetailLabelsVi._(_root);
	@override late final _TranslationsPurchaseDetailStatesVi states = _TranslationsPurchaseDetailStatesVi._(_root);
	@override late final _TranslationsPurchaseDetailEmptyVi empty = _TranslationsPurchaseDetailEmptyVi._(_root);
	@override late final _TranslationsPurchaseDetailErrorVi error = _TranslationsPurchaseDetailErrorVi._(_root);
}

// Path: discover
class _TranslationsDiscoverVi extends _TranslationsDiscoverEn {
	_TranslationsDiscoverVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDiscoverSectionsVi sections = _TranslationsDiscoverSectionsVi._(_root);
}

// Path: home
class _TranslationsHomeVi extends _TranslationsHomeEn {
	_TranslationsHomeVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsHomeSectionsVi sections = _TranslationsHomeSectionsVi._(_root);
}

// Path: genre
class _TranslationsGenreVi extends _TranslationsGenreEn {
	_TranslationsGenreVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsGenreExploreVi explore = _TranslationsGenreExploreVi._(_root);
}

// Path: purchase
class _TranslationsPurchaseVi extends _TranslationsPurchaseEn {
	_TranslationsPurchaseVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsPurchaseCommonVi common = _TranslationsPurchaseCommonVi._(_root);
	@override late final _TranslationsPurchaseCheckoutVi checkout = _TranslationsPurchaseCheckoutVi._(_root);
	@override late final _TranslationsPurchaseItemVi item = _TranslationsPurchaseItemVi._(_root);
	@override late final _TranslationsPurchaseNotificationsVi notifications = _TranslationsPurchaseNotificationsVi._(_root);
}

// Path: movie
class _TranslationsMovieVi extends _TranslationsMovieEn {
	_TranslationsMovieVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMovieDetailsVi details = _TranslationsMovieDetailsVi._(_root);
	@override late final _TranslationsMovieRatingsVi ratings = _TranslationsMovieRatingsVi._(_root);
	@override late final _TranslationsMovieInfoVi info = _TranslationsMovieInfoVi._(_root);
	@override late final _TranslationsMoviePlayerVi player = _TranslationsMoviePlayerVi._(_root);
	@override late final _TranslationsMovieHeroVi hero = _TranslationsMovieHeroVi._(_root);
	@override late final _TranslationsMovieSimilarVi similar = _TranslationsMovieSimilarVi._(_root);
	@override late final _TranslationsMovieReportVi report = _TranslationsMovieReportVi._(_root);
}

// Path: wishlist
class _TranslationsWishlistVi extends _TranslationsWishlistEn {
	_TranslationsWishlistVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsWishlistCommonVi common = _TranslationsWishlistCommonVi._(_root);
	@override late final _TranslationsWishlistItemVi item = _TranslationsWishlistItemVi._(_root);
	@override late final _TranslationsWishlistEmptyVi empty = _TranslationsWishlistEmptyVi._(_root);
}

// Path: auth.errors
class _TranslationsAuthErrorsVi extends _TranslationsAuthErrorsEn {
	_TranslationsAuthErrorsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get invalidCredentials => 'Sai tên đăng nhập hoặc mật khẩu';
}

// Path: auth.loginScreen
class _TranslationsAuthLoginScreenVi extends _TranslationsAuthLoginScreenEn {
	_TranslationsAuthLoginScreenVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Xin chào bạn 👋';
	@override String get description => 'Điền email/tên đăng nhập và mật khẩu để tiếp tục nha ✨';
	@override late final _TranslationsAuthLoginScreenPlaceholderVi placeholder = _TranslationsAuthLoginScreenPlaceholderVi._(_root);
}

// Path: auth.oauth
class _TranslationsAuthOauthVi extends _TranslationsAuthOauthEn {
	_TranslationsAuthOauthVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get featureInDevelopment => 'Tính năng đang phát triển';
}

// Path: auth.forgotPassword
class _TranslationsAuthForgotPasswordVi extends _TranslationsAuthForgotPasswordEn {
	_TranslationsAuthForgotPasswordVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quên Mật Khẩu 🔑';
	@override String get description => 'Nhập email của bạn, chúng tôi sẽ gửi mã OTP để xác minh ở bước tiếp theo.';
	@override String get orContinueWith => 'hoặc tiếp tục với';
	@override late final _TranslationsAuthForgotPasswordOtpVi otp = _TranslationsAuthForgotPasswordOtpVi._(_root);
	@override late final _TranslationsAuthForgotPasswordNewPasswordVi newPassword = _TranslationsAuthForgotPasswordNewPasswordVi._(_root);
}

// Path: auth.register
class _TranslationsAuthRegisterVi extends _TranslationsAuthRegisterEn {
	_TranslationsAuthRegisterVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get createAccount => 'Tạo tài khoản';
	@override String get description => 'Nhập tên đăng nhập, email và mật khẩu. Nếu bạn quên, bạn sẽ phải làm quên mật khẩu.';
	@override late final _TranslationsAuthRegisterPlaceholderVi placeholder = _TranslationsAuthRegisterPlaceholderVi._(_root);
	@override String get registrationSuccessful => 'Đăng ký thành công!';
	@override late final _TranslationsAuthRegisterStepsVi steps = _TranslationsAuthRegisterStepsVi._(_root);
}

// Path: welcome.slides
class _TranslationsWelcomeSlidesVi extends _TranslationsWelcomeSlidesEn {
	_TranslationsWelcomeSlidesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsWelcomeSlidesDiscoverVi discover = _TranslationsWelcomeSlidesDiscoverVi._(_root);
	@override late final _TranslationsWelcomeSlidesTrackVi track = _TranslationsWelcomeSlidesTrackVi._(_root);
	@override late final _TranslationsWelcomeSlidesCommunityVi community = _TranslationsWelcomeSlidesCommunityVi._(_root);
}

// Path: settings.language
class _TranslationsSettingsLanguageVi extends _TranslationsSettingsLanguageEn {
	_TranslationsSettingsLanguageVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get vietnamese => 'Tiếng Việt';
	@override String get english => 'English';
}

// Path: settings.theme
class _TranslationsSettingsThemeVi extends _TranslationsSettingsThemeEn {
	_TranslationsSettingsThemeVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get system => 'Hệ thống';
	@override String get light => 'Sáng';
	@override String get dark => 'Tối';
}

// Path: profile.header
class _TranslationsProfileHeaderVi extends _TranslationsProfileHeaderEn {
	_TranslationsProfileHeaderVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get defaultName => 'Người dùng NoZie';
	@override String get loadError => 'Không thể tải hồ sơ';
}

// Path: profile.menu
class _TranslationsProfileMenuVi extends _TranslationsProfileMenuEn {
	_TranslationsProfileMenuVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get paymentMethods => 'Phương thức thanh toán';
	@override String get personalInfo => 'Thông tin cá nhân';
	@override String get notification => 'Thông báo';
	@override String get preferences => 'Tùy chỉnh';
	@override String get security => 'Bảo mật';
	@override String get language => 'Ngôn ngữ';
	@override String get helpCenter => 'Trung tâm trợ giúp';
	@override String get about => 'Giới thiệu về NoZie';
	@override String get darkMode => 'Chế độ tối';
	@override String get logout => 'Đăng xuất';
}

// Path: profile.language
class _TranslationsProfileLanguageVi extends _TranslationsProfileLanguageEn {
	_TranslationsProfileLanguageVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ngôn ngữ';
	@override String get sectionSuggested => 'Đề xuất';
	@override String get sectionOthers => 'Ngôn ngữ khác';
	@override String loadError({required Object error}) => 'Không thể tải danh sách ngôn ngữ: ${error}';
	@override String get fallback => 'Tiếng Anh (Mỹ)';
}

// Path: profile.logoutSheet
class _TranslationsProfileLogoutSheetVi extends _TranslationsProfileLogoutSheetEn {
	_TranslationsProfileLogoutSheetVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Đăng xuất';
	@override String get description => 'Bạn có chắc muốn đăng xuất khỏi NoZie? Bạn có thể đăng nhập lại bất cứ lúc nào.';
}

// Path: profile.helpCenter
class _TranslationsProfileHelpCenterVi extends _TranslationsProfileHelpCenterEn {
	_TranslationsProfileHelpCenterVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Trung tâm trợ giúp';
	@override late final _TranslationsProfileHelpCenterTabsVi tabs = _TranslationsProfileHelpCenterTabsVi._(_root);
	@override late final _TranslationsProfileHelpCenterCategoriesVi categories = _TranslationsProfileHelpCenterCategoriesVi._(_root);
	@override late final _TranslationsProfileHelpCenterSearchVi search = _TranslationsProfileHelpCenterSearchVi._(_root);
	@override late final _TranslationsProfileHelpCenterFilterVi filter = _TranslationsProfileHelpCenterFilterVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqVi faq = _TranslationsProfileHelpCenterFaqVi._(_root);
	@override late final _TranslationsProfileHelpCenterContactsVi contacts = _TranslationsProfileHelpCenterContactsVi._(_root);
}

// Path: profile.payment
class _TranslationsProfilePaymentVi extends _TranslationsProfilePaymentEn {
	_TranslationsProfilePaymentVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Phương thức thanh toán';
	@override String loadError({required Object error}) => 'Không thể tải phương thức thanh toán: ${error}';
	@override String get addNewMessage => 'Đã chạm vào thêm phương thức thanh toán';
	@override String get comingSoon => 'Nozie đang phát triển thêm phương thức thanh toán khác';
}

// Path: profile.notification
class _TranslationsProfileNotificationVi extends _TranslationsProfileNotificationEn {
	_TranslationsProfileNotificationVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Thông báo';
	@override String loadError({required Object error}) => 'Không thể tải cài đặt: ${error}';
	@override String get sectionTitle => 'Thông báo cho tôi khi...';
	@override late final _TranslationsProfileNotificationTogglesVi toggles = _TranslationsProfileNotificationTogglesVi._(_root);
}

// Path: profile.personalInfo
class _TranslationsProfilePersonalInfoVi extends _TranslationsProfilePersonalInfoEn {
	_TranslationsProfilePersonalInfoVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Thông tin cá nhân';
	@override String get loadError => 'Không thể tải hồ sơ. Vui lòng thử lại sau.';
	@override String get success => 'Cập nhật hồ sơ thành công';
	@override late final _TranslationsProfilePersonalInfoFieldsVi fields = _TranslationsProfilePersonalInfoFieldsVi._(_root);
	@override String get saveChanges => 'Lưu thay đổi';
}

// Path: profile.preferences
class _TranslationsProfilePreferencesVi extends _TranslationsProfilePreferencesEn {
	_TranslationsProfilePreferencesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tùy chỉnh';
	@override late final _TranslationsProfilePreferencesSectionsVi sections = _TranslationsProfilePreferencesSectionsVi._(_root);
	@override late final _TranslationsProfilePreferencesTogglesVi toggles = _TranslationsProfilePreferencesTogglesVi._(_root);
	@override late final _TranslationsProfilePreferencesActionsVi actions = _TranslationsProfilePreferencesActionsVi._(_root);
	@override late final _TranslationsProfilePreferencesStorageLabelVi storageLabel = _TranslationsProfilePreferencesStorageLabelVi._(_root);
}

// Path: profile.security
class _TranslationsProfileSecurityVi extends _TranslationsProfileSecurityEn {
	_TranslationsProfileSecurityVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bảo mật';
	@override String loadError({required Object error}) => 'Không thể tải cài đặt bảo mật: ${error}';
	@override late final _TranslationsProfileSecurityTogglesVi toggles = _TranslationsProfileSecurityTogglesVi._(_root);
	@override late final _TranslationsProfileSecurityActionsVi actions = _TranslationsProfileSecurityActionsVi._(_root);
	@override late final _TranslationsProfileSecurityDeviceManagementVi deviceManagement = _TranslationsProfileSecurityDeviceManagementVi._(_root);
}

// Path: validation.general
class _TranslationsValidationGeneralVi extends _TranslationsValidationGeneralEn {
	_TranslationsValidationGeneralVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get fillAllFields => 'Vui lòng điền đầy đủ tất cả các trường.';
	@override String get required => 'Trường này là bắt buộc.';
	@override String length({required Object length}) => 'Độ dài phải là ${length}.';
	@override String min({required Object length}) => 'Độ dài tối thiểu là ${length}.';
	@override String max({required Object length}) => 'Độ dài tối đa là ${length}.';
	@override String get regex => 'Trường không hợp lệ.';
	@override late final _TranslationsValidationGeneralCustomVi custom = _TranslationsValidationGeneralCustomVi._(_root);
}

// Path: validation.name
class _TranslationsValidationNameVi extends _TranslationsValidationNameEn {
	_TranslationsValidationNameVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get required => 'Họ và tên là bắt buộc';
	@override String get minLength => 'Họ và tên phải có ít nhất 2 ký tự';
}

// Path: validation.phone
class _TranslationsValidationPhoneVi extends _TranslationsValidationPhoneEn {
	_TranslationsValidationPhoneVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get required => 'Số điện thoại là bắt buộc';
	@override String get minLength => 'Số điện thoại phải có ít nhất 10 chữ số';
}

// Path: validation.dateOfBirth
class _TranslationsValidationDateOfBirthVi extends _TranslationsValidationDateOfBirthEn {
	_TranslationsValidationDateOfBirthVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get required => 'Ngày sinh là bắt buộc';
}

// Path: validation.country
class _TranslationsValidationCountryVi extends _TranslationsValidationCountryEn {
	_TranslationsValidationCountryVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get required => 'Quốc gia là bắt buộc';
}

// Path: validation.username
class _TranslationsValidationUsernameVi extends _TranslationsValidationUsernameEn {
	_TranslationsValidationUsernameVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get required => 'Tên đăng nhập là bắt buộc';
	@override String get minLength => 'Tên đăng nhập phải có ít nhất 3 ký tự';
	@override String get invalidChars => 'Tên đăng nhập chỉ có thể chứa chữ cái, số và dấu gạch dưới';
}

// Path: validation.email
class _TranslationsValidationEmailVi extends _TranslationsValidationEmailEn {
	_TranslationsValidationEmailVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get required => 'Email là bắt buộc';
	@override String get invalid => 'Vui lòng nhập địa chỉ email hợp lệ';
}

// Path: validation.password
class _TranslationsValidationPasswordVi extends _TranslationsValidationPasswordEn {
	_TranslationsValidationPasswordVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get required => 'Mật khẩu là bắt buộc';
	@override String get minLength => 'Mật khẩu phải có ít nhất 8 ký tự';
	@override String get complexity => 'Mật khẩu phải chứa ít nhất một chữ hoa, một chữ thường và một số';
	@override String get confirmRequired => 'Vui lòng xác nhận mật khẩu của bạn';
	@override String get mismatch => 'Mật khẩu không khớp';
}

// Path: search.filter
class _TranslationsSearchFilterVi extends _TranslationsSearchFilterEn {
	_TranslationsSearchFilterVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get header => 'Bộ lọc';
	@override String get reset => 'Đặt lại';
	@override String get apply => 'Áp dụng';
	@override late final _TranslationsSearchFilterSectionsVi sections = _TranslationsSearchFilterSectionsVi._(_root);
	@override late final _TranslationsSearchFilterSortOptionsVi sortOptions = _TranslationsSearchFilterSortOptionsVi._(_root);
	@override late final _TranslationsSearchFilterGenresVi genres = _TranslationsSearchFilterGenresVi._(_root);
	@override late final _TranslationsSearchFilterRangePriceVi rangePrice = _TranslationsSearchFilterRangePriceVi._(_root);
	@override late final _TranslationsSearchFilterLanguagesVi languages = _TranslationsSearchFilterLanguagesVi._(_root);
	@override late final _TranslationsSearchFilterAgeVi age = _TranslationsSearchFilterAgeVi._(_root);
}

// Path: purchaseDetail.labels
class _TranslationsPurchaseDetailLabelsVi extends _TranslationsPurchaseDetailLabelsEn {
	_TranslationsPurchaseDetailLabelsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get movieId => 'Mã phim';
	@override String get downloaded => 'Đã tải xuống';
	@override String get finished => 'Đã xem xong';
	@override String get transactions => 'Giao dịch';
	@override String get amount => 'Số tiền';
	@override String get created => 'Tạo lúc';
	@override String get paidAt => 'Thanh toán lúc';
	@override String get failedAt => 'Thất bại lúc';
	@override String get canceledAt => 'Hủy lúc';
	@override String get paymentIntent => 'Mã Payment Intent';
	@override String get chargeId => 'Mã giao dịch (Charge ID)';
}

// Path: purchaseDetail.states
class _TranslationsPurchaseDetailStatesVi extends _TranslationsPurchaseDetailStatesEn {
	_TranslationsPurchaseDetailStatesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get succeeded => 'Thành công';
	@override String get failed => 'Thất bại';
	@override String get canceled => 'Đã hủy';
	@override String get pending => 'Đang xử lý';
}

// Path: purchaseDetail.empty
class _TranslationsPurchaseDetailEmptyVi extends _TranslationsPurchaseDetailEmptyEn {
	_TranslationsPurchaseDetailEmptyVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get transactions => 'Chưa có giao dịch nào';
	@override String get purchaseNotFound => 'Không tìm thấy thông tin mua hàng';
}

// Path: purchaseDetail.error
class _TranslationsPurchaseDetailErrorVi extends _TranslationsPurchaseDetailErrorEn {
	_TranslationsPurchaseDetailErrorVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String generic({required Object error}) => 'Lỗi: ${error}';
}

// Path: discover.sections
class _TranslationsDiscoverSectionsVi extends _TranslationsDiscoverSectionsEn {
	_TranslationsDiscoverSectionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get topCharts => 'Bảng xếp hạng';
	@override String get topSelling => 'Bán chạy';
	@override String get topFree => 'Miễn phí hàng đầu';
	@override String get topNewReleases => 'Phát hành mới';
}

// Path: home.sections
class _TranslationsHomeSectionsVi extends _TranslationsHomeSectionsEn {
	_TranslationsHomeSectionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get recommendedForYou => 'Gợi ý cho bạn';
	@override String get yourPurchases => 'Giao dịch của bạn';
	@override String get yourWishlist => 'Danh sách yêu thích';
	@override String get recentlyWatched => 'Xem gần đây';
	@override String get exploreByGenre => 'Khám phá theo thể loại';
}

// Path: genre.explore
class _TranslationsGenreExploreVi extends _TranslationsGenreExploreEn {
	_TranslationsGenreExploreVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Thể loại:';
	@override String get empty => 'Không tìm thấy phim cho';
	@override String get loadFailed => 'Không tải được danh sách phim';
}

// Path: purchase.common
class _TranslationsPurchaseCommonVi extends _TranslationsPurchaseCommonEn {
	_TranslationsPurchaseCommonVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get free => 'Miễn phí';
	@override String get purchased => 'Đã mua';
	@override String get movieNotFound => 'Không tìm thấy phim';
	@override String get comingSoon => 'Sắp ra mắt';
	@override String get errorPrefix => 'Lỗi:';
}

// Path: purchase.checkout
class _TranslationsPurchaseCheckoutVi extends _TranslationsPurchaseCheckoutEn {
	_TranslationsPurchaseCheckoutVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Thanh toán';
	@override late final _TranslationsPurchaseCheckoutSectionVi section = _TranslationsPurchaseCheckoutSectionVi._(_root);
	@override late final _TranslationsPurchaseCheckoutLabelsVi labels = _TranslationsPurchaseCheckoutLabelsVi._(_root);
	@override late final _TranslationsPurchaseCheckoutActionsVi actions = _TranslationsPurchaseCheckoutActionsVi._(_root);
	@override late final _TranslationsPurchaseCheckoutToastsVi toasts = _TranslationsPurchaseCheckoutToastsVi._(_root);
}

// Path: purchase.item
class _TranslationsPurchaseItemVi extends _TranslationsPurchaseItemEn {
	_TranslationsPurchaseItemVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsPurchaseItemMenuVi menu = _TranslationsPurchaseItemMenuVi._(_root);
	@override late final _TranslationsPurchaseItemSnackbarVi snackbar = _TranslationsPurchaseItemSnackbarVi._(_root);
}

// Path: purchase.notifications
class _TranslationsPurchaseNotificationsVi extends _TranslationsPurchaseNotificationsEn {
	_TranslationsPurchaseNotificationsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get successTitle => 'Mua hàng thành công! 🎬';
	@override String get successDescription => 'Bạn đã sở hữu';
}

// Path: movie.details
class _TranslationsMovieDetailsVi extends _TranslationsMovieDetailsEn {
	_TranslationsMovieDetailsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get notFound => 'Không tìm thấy phim';
	@override String get alreadyPurchased => 'Phim này đã có trong thư viện đã mua của bạn';
	@override String get quality1080p => '1080p';
	@override String get seriesFallback => 'Series';
}

// Path: movie.ratings
class _TranslationsMovieRatingsVi extends _TranslationsMovieRatingsEn {
	_TranslationsMovieRatingsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Đánh giá & Nhận xét';
	@override String get noReviews => 'Chưa có đánh giá nào';
	@override String get rateThisFilm => 'Đánh giá phim này';
	@override String get purchaseRequired => 'Cần mua để đánh giá';
	@override String get writeAReview => 'Viết đánh giá';
	@override late final _TranslationsMovieRatingsDialogVi dialog = _TranslationsMovieRatingsDialogVi._(_root);
}

// Path: movie.info
class _TranslationsMovieInfoVi extends _TranslationsMovieInfoEn {
	_TranslationsMovieInfoVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get images => 'Hình ảnh';
	@override String get cannotLoadImage => 'Không thể tải ảnh';
	@override String get episodesList => 'Danh sách tập';
	@override String get language => 'Ngôn ngữ';
	@override String get genres => 'Thể loại';
	@override String get countries => 'Quốc gia';
	@override String get directors => 'Đạo diễn';
	@override String get actors => 'Diễn viên';
	@override String get aboutThisFilm => 'Giới thiệu';
	@override String get trailer => 'Trailer';
	@override String get watchTrailer => 'Xem trailer';
	@override String get episodePrefix => 'Tập';
	@override String get episodesPrefix => 'Tập';
}

// Path: movie.player
class _TranslationsMoviePlayerVi extends _TranslationsMoviePlayerEn {
	_TranslationsMoviePlayerVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get noAccess => 'Bạn chưa có quyền truy cập phim này';
	@override String get videoUrlMissing => 'Không có URL video';
	@override String get tryingFallback => 'Đang thử URL thay thế...';
	@override String get cannotLoadM3u8 => 'Không thể load video từ URL m3u8';
	@override String get cannotLoadBoth => 'Không thể load video từ cả m3u8 và embed URL';
	@override String get unknownError => 'Lỗi không xác định';
	@override String get cannotOpenTrailer => 'Không mở được trailer';
	@override String get playbackSpeed => 'Tốc độ phát';
	@override String get quality => 'Chất lượng';
}

// Path: movie.hero
class _TranslationsMovieHeroVi extends _TranslationsMovieHeroEn {
	_TranslationsMovieHeroVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get ratings => 'lượt đánh giá';
	@override String get reviews => 'nhận xét';
	@override String get duration => 'thời lượng';
	@override String get quality => 'chất lượng';
	@override String get watched => 'lượt xem';
	@override String get watchNow => 'Xem ngay';
	@override String get aboutThisFilm => 'Giới thiệu';
	@override String get viewMore => 'Xem thêm';
}

// Path: movie.similar
class _TranslationsMovieSimilarVi extends _TranslationsMovieSimilarEn {
	_TranslationsMovieSimilarVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Phim tương tự';
}

// Path: movie.report
class _TranslationsMovieReportVi extends _TranslationsMovieReportEn {
	_TranslationsMovieReportVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get headerTitle => 'Báo cáo vấn đề';
	@override String get headerSubtitle => 'Giúp chúng tôi cải thiện chất lượng dịch vụ';
	@override String get movieInfo => 'Thông tin phim';
	@override late final _TranslationsMovieReportLabelsVi labels = _TranslationsMovieReportLabelsVi._(_root);
	@override String get issueTypeLabel => 'Loại vấn đề *';
	@override String get descriptionLabel => 'Mô tả chi tiết *';
	@override String get descriptionHint => 'Mô tả chi tiết vấn đề bạn gặp phải...';
	@override late final _TranslationsMovieReportValidationsVi validations = _TranslationsMovieReportValidationsVi._(_root);
	@override late final _TranslationsMovieReportActionsVi actions = _TranslationsMovieReportActionsVi._(_root);
	@override String get success => 'Báo cáo đã được gửi thành công. Cảm ơn bạn đã phản hồi!';
	@override String get failurePrefix => 'Lỗi khi gửi báo cáo:';
}

// Path: wishlist.common
class _TranslationsWishlistCommonVi extends _TranslationsWishlistCommonEn {
	_TranslationsWishlistCommonVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get retry => 'Thử lại';
	@override String get errorPrefix => 'Lỗi:';
	@override String get movieNotFound => 'Không tìm thấy phim';
}

// Path: wishlist.item
class _TranslationsWishlistItemVi extends _TranslationsWishlistItemEn {
	_TranslationsWishlistItemVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsWishlistItemMenuVi menu = _TranslationsWishlistItemMenuVi._(_root);
	@override late final _TranslationsWishlistItemSnackbarVi snackbar = _TranslationsWishlistItemSnackbarVi._(_root);
}

// Path: wishlist.empty
class _TranslationsWishlistEmptyVi extends _TranslationsWishlistEmptyEn {
	_TranslationsWishlistEmptyVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Danh sách yêu thích của bạn đang trống';
	@override String get subtitle => 'Thêm những phim bạn muốn xem sau';
}

// Path: auth.loginScreen.placeholder
class _TranslationsAuthLoginScreenPlaceholderVi extends _TranslationsAuthLoginScreenPlaceholderEn {
	_TranslationsAuthLoginScreenPlaceholderVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get email => 'admin@ziet.dev';
	@override String get password => '●●●●●●●●●●●●';
}

// Path: auth.forgotPassword.otp
class _TranslationsAuthForgotPasswordOtpVi extends _TranslationsAuthForgotPasswordOtpEn {
	_TranslationsAuthForgotPasswordOtpVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'OTP tới rồi nè 📩';
	@override String get description => 'Chúng tôi đã gửi mã xác thực OTP đến email của bạn. Vui lòng kiểm tra email và nhập mã bên dưới nhé.';
	@override String get didntReceiveCode => 'Chưa có mã?';
	@override String get resendCode => 'Gửi lại mã ngay';
	@override String resendAfter({required Object seconds}) => 'Đợi ${seconds}s rồi gửi lại';
}

// Path: auth.forgotPassword.newPassword
class _TranslationsAuthForgotPasswordNewPasswordVi extends _TranslationsAuthForgotPasswordNewPasswordEn {
	_TranslationsAuthForgotPasswordNewPasswordVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tạo mật khẩu mới 🔐';
	@override String get description => 'Nhập mật khẩu mới của bạn. Nếu quên, bạn sẽ cần thực hiện lại bước quên mật khẩu.';
}

// Path: auth.register.placeholder
class _TranslationsAuthRegisterPlaceholderVi extends _TranslationsAuthRegisterPlaceholderEn {
	_TranslationsAuthRegisterPlaceholderVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get username => 'Nhập tên đăng nhập của bạn';
	@override String get password => 'Nhập mật khẩu của bạn';
	@override String get email => 'Nhập địa chỉ email của bạn';
	@override String get confirmPassword => 'Xác nhận mật khẩu của bạn';
}

// Path: auth.register.steps
class _TranslationsAuthRegisterStepsVi extends _TranslationsAuthRegisterStepsEn {
	_TranslationsAuthRegisterStepsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get stepOf => 'Bước {current} của {total}';
	@override String get contentForStep => 'Nội dung cho bước {step}';
	@override late final _TranslationsAuthRegisterStepsGenderVi gender = _TranslationsAuthRegisterStepsGenderVi._(_root);
	@override late final _TranslationsAuthRegisterStepsAgeVi age = _TranslationsAuthRegisterStepsAgeVi._(_root);
	@override late final _TranslationsAuthRegisterStepsGenresVi genres = _TranslationsAuthRegisterStepsGenresVi._(_root);
	@override late final _TranslationsAuthRegisterStepsProfileVi profile = _TranslationsAuthRegisterStepsProfileVi._(_root);
}

// Path: welcome.slides.discover
class _TranslationsWelcomeSlidesDiscoverVi extends _TranslationsWelcomeSlidesDiscoverEn {
	_TranslationsWelcomeSlidesDiscoverVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Khám phá phim mới';
	@override String get description => 'Khám phá hàng nghìn bộ phim từ các thể loại khác nhau. Tìm những viên ngọc ẩn và phim xu hướng phù hợp với sở thích của bạn.';
}

// Path: welcome.slides.track
class _TranslationsWelcomeSlidesTrackVi extends _TranslationsWelcomeSlidesTrackEn {
	_TranslationsWelcomeSlidesTrackVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Theo dõi danh sách xem';
	@override String get description => 'Lưu phim bạn muốn xem, đánh dấu những gì bạn đã xem và nhận gợi ý dựa trên sở thích của bạn.';
}

// Path: welcome.slides.community
class _TranslationsWelcomeSlidesCommunityVi extends _TranslationsWelcomeSlidesCommunityEn {
	_TranslationsWelcomeSlidesCommunityVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tham gia cộng đồng';
	@override String get description => 'Kết nối với những người yêu phim khác, chia sẻ đánh giá và khám phá những gì đang xu hướng trong thế giới điện ảnh.';
}

// Path: profile.helpCenter.tabs
class _TranslationsProfileHelpCenterTabsVi extends _TranslationsProfileHelpCenterTabsEn {
	_TranslationsProfileHelpCenterTabsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get faq => 'FAQ';
	@override String get contact => 'Liên hệ';
}

// Path: profile.helpCenter.categories
class _TranslationsProfileHelpCenterCategoriesVi extends _TranslationsProfileHelpCenterCategoriesEn {
	_TranslationsProfileHelpCenterCategoriesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get all => 'Tất cả';
	@override String get general => 'Chung';
	@override String get account => 'Tài khoản';
	@override String get service => 'Dịch vụ';
	@override String get movies => 'Phim';
	@override String get ebook => 'Sách điện tử';
}

// Path: profile.helpCenter.search
class _TranslationsProfileHelpCenterSearchVi extends _TranslationsProfileHelpCenterSearchEn {
	_TranslationsProfileHelpCenterSearchVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Tìm kiếm';
	@override String get noResults => 'Không tìm thấy câu hỏi phù hợp';
}

// Path: profile.helpCenter.filter
class _TranslationsProfileHelpCenterFilterVi extends _TranslationsProfileHelpCenterFilterEn {
	_TranslationsProfileHelpCenterFilterVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get clear => 'Xoá';
}

// Path: profile.helpCenter.faq
class _TranslationsProfileHelpCenterFaqVi extends _TranslationsProfileHelpCenterFaqEn {
	_TranslationsProfileHelpCenterFaqVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfileHelpCenterFaqGeneralVi general = _TranslationsProfileHelpCenterFaqGeneralVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqServiceVi service = _TranslationsProfileHelpCenterFaqServiceVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqAccountVi account = _TranslationsProfileHelpCenterFaqAccountVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqEbookVi ebook = _TranslationsProfileHelpCenterFaqEbookVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqMoviesVi movies = _TranslationsProfileHelpCenterFaqMoviesVi._(_root);
}

// Path: profile.helpCenter.contacts
class _TranslationsProfileHelpCenterContactsVi extends _TranslationsProfileHelpCenterContactsEn {
	_TranslationsProfileHelpCenterContactsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfileHelpCenterContactsCustomerServiceVi customerService = _TranslationsProfileHelpCenterContactsCustomerServiceVi._(_root);
	@override late final _TranslationsProfileHelpCenterContactsWhatsappVi whatsapp = _TranslationsProfileHelpCenterContactsWhatsappVi._(_root);
	@override late final _TranslationsProfileHelpCenterContactsWebsiteVi website = _TranslationsProfileHelpCenterContactsWebsiteVi._(_root);
	@override late final _TranslationsProfileHelpCenterContactsFacebookVi facebook = _TranslationsProfileHelpCenterContactsFacebookVi._(_root);
	@override late final _TranslationsProfileHelpCenterContactsTwitterVi twitter = _TranslationsProfileHelpCenterContactsTwitterVi._(_root);
	@override late final _TranslationsProfileHelpCenterContactsInstagramVi instagram = _TranslationsProfileHelpCenterContactsInstagramVi._(_root);
}

// Path: profile.notification.toggles
class _TranslationsProfileNotificationTogglesVi extends _TranslationsProfileNotificationTogglesEn {
	_TranslationsProfileNotificationTogglesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get newRecommendation => 'Có gợi ý mới';
	@override String get newBookSeries => 'Có phim mới';
	@override String get authorUpdates => 'Có cập nhật từ tác giả';
	@override String get priceDrops => 'Có khuyến mãi giảm giá';
	@override String get purchase => 'Khi tôi thực hiện giao dịch';
	@override String get appSystem => 'Bật thông báo hệ thống ứng dụng';
	@override String get tipsServices => 'Có mẹo và dịch vụ mới';
	@override String get survey => 'Tham gia khảo sát';
}

// Path: profile.personalInfo.fields
class _TranslationsProfilePersonalInfoFieldsVi extends _TranslationsProfilePersonalInfoFieldsEn {
	_TranslationsProfilePersonalInfoFieldsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfilePersonalInfoFieldsFullNameVi fullName = _TranslationsProfilePersonalInfoFieldsFullNameVi._(_root);
	@override late final _TranslationsProfilePersonalInfoFieldsUsernameVi username = _TranslationsProfilePersonalInfoFieldsUsernameVi._(_root);
	@override late final _TranslationsProfilePersonalInfoFieldsEmailVi email = _TranslationsProfilePersonalInfoFieldsEmailVi._(_root);
	@override late final _TranslationsProfilePersonalInfoFieldsPhoneVi phone = _TranslationsProfilePersonalInfoFieldsPhoneVi._(_root);
	@override late final _TranslationsProfilePersonalInfoFieldsDobVi dob = _TranslationsProfilePersonalInfoFieldsDobVi._(_root);
	@override late final _TranslationsProfilePersonalInfoFieldsCountryVi country = _TranslationsProfilePersonalInfoFieldsCountryVi._(_root);
}

// Path: profile.preferences.sections
class _TranslationsProfilePreferencesSectionsVi extends _TranslationsProfilePreferencesSectionsEn {
	_TranslationsProfilePreferencesSectionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get general => 'Chung';
	@override String get playback => 'Phát lại';
	@override String get video => 'Video';
	@override String get audio => 'Âm thanh';
}

// Path: profile.preferences.toggles
class _TranslationsProfilePreferencesTogglesVi extends _TranslationsProfilePreferencesTogglesEn {
	_TranslationsProfilePreferencesTogglesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get wifiOnlyDownloads => 'Chỉ xem qua Wi-Fi';
	@override String get autoPlayNextEpisode => 'Tự phát tập tiếp theo';
	@override String get continueWatching => 'Tiếp tục xem từ vị trí dở';
	@override String get subtitlesEnabled => 'Phụ đề';
	@override String get autoRotateScreen => 'Tự xoay màn hình';
	@override String get autoDownloadAudio => 'Tự động tải âm thanh';
}

// Path: profile.preferences.actions
class _TranslationsProfilePreferencesActionsVi extends _TranslationsProfilePreferencesActionsEn {
	_TranslationsProfilePreferencesActionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfilePreferencesActionsClearCacheVi clearCache = _TranslationsProfilePreferencesActionsClearCacheVi._(_root);
	@override late final _TranslationsProfilePreferencesActionsVideoQualityVi videoQuality = _TranslationsProfilePreferencesActionsVideoQualityVi._(_root);
	@override late final _TranslationsProfilePreferencesActionsAudioPreferenceVi audioPreference = _TranslationsProfilePreferencesActionsAudioPreferenceVi._(_root);
}

// Path: profile.preferences.storageLabel
class _TranslationsProfilePreferencesStorageLabelVi extends _TranslationsProfilePreferencesStorageLabelEn {
	_TranslationsProfilePreferencesStorageLabelVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get empty => '0 MB đã lưu';
	@override String value({required Object amount}) => '${amount} MB đã lưu';
}

// Path: profile.security.toggles
class _TranslationsProfileSecurityTogglesVi extends _TranslationsProfileSecurityTogglesEn {
	_TranslationsProfileSecurityTogglesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get rememberMe => 'Ghi nhớ tôi';
	@override String get biometricId => 'Sinh trắc học';
	@override String get faceId => 'Face ID';
	@override String get smsAuthenticator => 'Xác thực SMS';
	@override String get googleAuthenticator => 'Google Authenticator';
}

// Path: profile.security.actions
class _TranslationsProfileSecurityActionsVi extends _TranslationsProfileSecurityActionsEn {
	_TranslationsProfileSecurityActionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get deviceManagement => 'Quản lý thiết bị';
	@override String get changePassword => 'Đổi mật khẩu';
	@override String get changePasswordMessage => 'Đã chạm vào đổi mật khẩu';
	@override String signOutDevice({required Object name}) => 'Đã đăng xuất ${name}';
	@override String get signOutAll => 'Đã đăng xuất khỏi tất cả thiết bị';
}

// Path: profile.security.deviceManagement
class _TranslationsProfileSecurityDeviceManagementVi extends _TranslationsProfileSecurityDeviceManagementEn {
	_TranslationsProfileSecurityDeviceManagementVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quản lý thiết bị';
	@override String get description => 'Quản lý các thiết bị được phép truy cập tài khoản của bạn.';
	@override String get signOutAll => 'Đăng xuất tất cả thiết bị';
	@override String get current => 'Thiết bị hiện tại';
	@override String lastActive({required Object time}) => 'Hoạt động lần cuối: ${time}';
}

// Path: validation.general.custom
class _TranslationsValidationGeneralCustomVi extends _TranslationsValidationGeneralCustomEn {
	_TranslationsValidationGeneralCustomVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get password => 'Mật khẩu phải có ký tự, số.';
	@override String get username => 'Tên người dùng chỉ được chứa chữ cái thường (a-z), số (0-9), dấu gạch ngang (-) và dấu gạch dưới (_).';
}

// Path: search.filter.sections
class _TranslationsSearchFilterSectionsVi extends _TranslationsSearchFilterSectionsEn {
	_TranslationsSearchFilterSectionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get sort => 'Sắp xếp';
	@override String get price => 'Giá';
	@override String get rating => 'Đánh giá';
	@override String get genre => 'Thể loại';
	@override String get language => 'Ngôn ngữ';
	@override String get age => 'Độ tuổi';
}

// Path: search.filter.sortOptions
class _TranslationsSearchFilterSortOptionsVi extends _TranslationsSearchFilterSortOptionsEn {
	_TranslationsSearchFilterSortOptionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get trending => 'Xu hướng';
	@override String get newReleases => 'Phát hành mới';
	@override String get highestRating => 'Đánh giá cao nhất';
	@override String get lowestRating => 'Đánh giá thấp nhất';
	@override String get highestPrice => 'Giá cao nhất';
	@override String get lowestPrice => 'Giá thấp nhất';
}

// Path: search.filter.genres
class _TranslationsSearchFilterGenresVi extends _TranslationsSearchFilterGenresEn {
	_TranslationsSearchFilterGenresVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get action => 'Hành động';
	@override String get adventure => 'Phiêu lưu';
	@override String get romance => 'Lãng mạn';
	@override String get comics => 'Truyện tranh';
	@override String get comedy => 'Hài';
	@override String get fantasy => 'Giả tưởng';
	@override String get mystery => 'Bí ẩn';
	@override String get horror => 'Kinh dị';
	@override String get scienceFiction => 'Khoa học viễn tưởng';
	@override String get thriller => 'Giật gân';
	@override String get travel => 'Du lịch';
}

// Path: search.filter.rangePrice
class _TranslationsSearchFilterRangePriceVi extends _TranslationsSearchFilterRangePriceEn {
	_TranslationsSearchFilterRangePriceVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get min => '0';
	@override String get max => '500000';
}

// Path: search.filter.languages
class _TranslationsSearchFilterLanguagesVi extends _TranslationsSearchFilterLanguagesEn {
	_TranslationsSearchFilterLanguagesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get english => 'Tiếng Anh';
	@override String get vietnamese => 'Tiếng Việt';
	@override String get others => 'Khác';
}

// Path: search.filter.age
class _TranslationsSearchFilterAgeVi extends _TranslationsSearchFilterAgeEn {
	_TranslationsSearchFilterAgeVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get under12 => 'Dưới 12 tuổi';
	@override String get above12 => '12+';
	@override String get above16 => '16+';
	@override String get above18 => '18+';
}

// Path: purchase.checkout.section
class _TranslationsPurchaseCheckoutSectionVi extends _TranslationsPurchaseCheckoutSectionEn {
	_TranslationsPurchaseCheckoutSectionVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get movieSummary => 'Tóm tắt phim';
	@override String get priceDetails => 'Chi tiết giá';
	@override String get paymentMethod => 'Phương thức thanh toán';
}

// Path: purchase.checkout.labels
class _TranslationsPurchaseCheckoutLabelsVi extends _TranslationsPurchaseCheckoutLabelsEn {
	_TranslationsPurchaseCheckoutLabelsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get price => 'Giá';
	@override String get total => 'Tổng cộng';
	@override String get visa => 'Visa';
}

// Path: purchase.checkout.actions
class _TranslationsPurchaseCheckoutActionsVi extends _TranslationsPurchaseCheckoutActionsEn {
	_TranslationsPurchaseCheckoutActionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get confirm => 'Xác nhận';
	@override String get payNow => 'Thanh toán ngay';
	@override String get processing => 'Đang xử lý...';
}

// Path: purchase.checkout.toasts
class _TranslationsPurchaseCheckoutToastsVi extends _TranslationsPurchaseCheckoutToastsEn {
	_TranslationsPurchaseCheckoutToastsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get addedSuccess => 'Đã thêm phim thành công! 🎬';
	@override String get paymentSuccess => 'Thanh toán thành công! 🎬';
	@override String get paymentFailed => 'Thanh toán thất bại. Vui lòng thử lại.';
	@override String get paymentCanceled => 'Thanh toán đã bị hủy';
}

// Path: purchase.item.menu
class _TranslationsPurchaseItemMenuVi extends _TranslationsPurchaseItemMenuEn {
	_TranslationsPurchaseItemMenuVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get watchNow => 'Xem ngay';
	@override String get viewSeries => 'Xem series';
	@override String get purchaseDetails => 'Chi tiết giao dịch';
	@override String get aboutMovie => 'Về phim';
}

// Path: purchase.item.snackbar
class _TranslationsPurchaseItemSnackbarVi extends _TranslationsPurchaseItemSnackbarEn {
	_TranslationsPurchaseItemSnackbarVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get viewSeriesComing => 'Tính năng xem series - sắp ra mắt';
}

// Path: movie.ratings.dialog
class _TranslationsMovieRatingsDialogVi extends _TranslationsMovieRatingsDialogEn {
	_TranslationsMovieRatingsDialogVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Viết đánh giá';
	@override String get yourRatingPrefix => 'Đánh giá của bạn:';
	@override String get star => 'sao';
	@override String get stars => 'sao';
	@override String get hint => 'Viết đánh giá của bạn...';
	@override String get cancel => 'Hủy';
	@override String get submit => 'Gửi';
	@override String get submitted => 'Đã gửi đánh giá';
}

// Path: movie.report.labels
class _TranslationsMovieReportLabelsVi extends _TranslationsMovieReportLabelsEn {
	_TranslationsMovieReportLabelsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get movieName => 'Tên phim';
	@override String get director => 'Đạo diễn';
	@override String get videoUrl => 'Video URL';
	@override String get error => 'Lỗi';
}

// Path: movie.report.validations
class _TranslationsMovieReportValidationsVi extends _TranslationsMovieReportValidationsEn {
	_TranslationsMovieReportValidationsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get selectIssue => 'Vui lòng chọn loại vấn đề';
	@override String get descRequired => 'Vui lòng nhập mô tả chi tiết';
	@override String get descMin => 'Mô tả phải có ít nhất 10 ký tự';
}

// Path: movie.report.actions
class _TranslationsMovieReportActionsVi extends _TranslationsMovieReportActionsEn {
	_TranslationsMovieReportActionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Hủy';
	@override String get submit => 'Gửi báo cáo';
	@override String get sending => 'Đang gửi...';
}

// Path: wishlist.item.menu
class _TranslationsWishlistItemMenuVi extends _TranslationsWishlistItemMenuEn {
	_TranslationsWishlistItemMenuVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get removeFromWishlist => 'Xóa khỏi danh sách yêu thích';
	@override String get share => 'Chia sẻ';
	@override String get aboutMovie => 'Về phim';
}

// Path: wishlist.item.snackbar
class _TranslationsWishlistItemSnackbarVi extends _TranslationsWishlistItemSnackbarEn {
	_TranslationsWishlistItemSnackbarVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get removed => 'Đã xóa khỏi danh sách yêu thích';
	@override String get shareComing => 'Tính năng chia sẻ sẽ có sớm';
}

// Path: auth.register.steps.gender
class _TranslationsAuthRegisterStepsGenderVi extends _TranslationsAuthRegisterStepsGenderEn {
	_TranslationsAuthRegisterStepsGenderVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get select => 'Chọn giới tính của bạn';
	@override String get question => 'Giới tính của bạn là gì?';
	@override String get description => 'Chọn giới tính để có nội dung phù hợp hơn';
	@override late final _TranslationsAuthRegisterStepsGenderOptionsVi options = _TranslationsAuthRegisterStepsGenderOptionsVi._(_root);
	@override late final _TranslationsAuthRegisterStepsGenderChoicesVi choices = _TranslationsAuthRegisterStepsGenderChoicesVi._(_root);
}

// Path: auth.register.steps.age
class _TranslationsAuthRegisterStepsAgeVi extends _TranslationsAuthRegisterStepsAgeEn {
	_TranslationsAuthRegisterStepsAgeVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get select => 'Chọn độ tuổi của bạn';
	@override String get title => 'Chọn độ tuổi của bạn';
	@override String get description => 'Chọn khoảng tuổi để có nội dung phù hợp hơn';
	@override late final _TranslationsAuthRegisterStepsAgeRangesVi ranges = _TranslationsAuthRegisterStepsAgeRangesVi._(_root);
}

// Path: auth.register.steps.genres
class _TranslationsAuthRegisterStepsGenresVi extends _TranslationsAuthRegisterStepsGenresEn {
	_TranslationsAuthRegisterStepsGenresVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get select => 'Chọn thể loại yêu thích';
	@override String get title => 'Chọn thể loại phim bạn thích';
	@override String get description => 'Chọn thể loại phim yêu thích để có gợi ý tốt hơn hoặc bạn có thể bỏ qua';
	@override late final _TranslationsAuthRegisterStepsGenresListVi list = _TranslationsAuthRegisterStepsGenresListVi._(_root);
}

// Path: auth.register.steps.profile
class _TranslationsAuthRegisterStepsProfileVi extends _TranslationsAuthRegisterStepsProfileEn {
	_TranslationsAuthRegisterStepsProfileVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Hoàn thành hồ sơ của bạn';
	@override String get infoTitle => 'Thông tin cá nhân';
	@override String get accountTitle => 'Thông tin tài khoản';
	@override String get privacyNote => 'Đừng lo lắng, chỉ bạn mới có thể xem dữ liệu cá nhân của mình. Không ai khác có thể xem được.';
	@override late final _TranslationsAuthRegisterStepsProfilePhotoVi photo = _TranslationsAuthRegisterStepsProfilePhotoVi._(_root);
	@override late final _TranslationsAuthRegisterStepsProfileFieldsVi fields = _TranslationsAuthRegisterStepsProfileFieldsVi._(_root);
}

// Path: profile.helpCenter.faq.general
class _TranslationsProfileHelpCenterFaqGeneralVi extends _TranslationsProfileHelpCenterFaqGeneralEn {
	_TranslationsProfileHelpCenterFaqGeneralVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfileHelpCenterFaqGeneralWhatIsNozieVi whatIsNozie = _TranslationsProfileHelpCenterFaqGeneralWhatIsNozieVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqGeneralSyncProgressVi syncProgress = _TranslationsProfileHelpCenterFaqGeneralSyncProgressVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqGeneralFormatsSupportVi formatsSupport = _TranslationsProfileHelpCenterFaqGeneralFormatsSupportVi._(_root);
}

// Path: profile.helpCenter.faq.service
class _TranslationsProfileHelpCenterFaqServiceVi extends _TranslationsProfileHelpCenterFaqServiceEn {
	_TranslationsProfileHelpCenterFaqServiceVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfileHelpCenterFaqServicePurchaseEbookVi purchaseEbook = _TranslationsProfileHelpCenterFaqServicePurchaseEbookVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingVi audiobookNotPlaying = _TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqServiceManageNotificationsVi manageNotifications = _TranslationsProfileHelpCenterFaqServiceManageNotificationsVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqServiceRequestRefundVi requestRefund = _TranslationsProfileHelpCenterFaqServiceRequestRefundVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueVi purchaseEbookIssue = _TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueVi downloadEbookIssue = _TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueVi._(_root);
}

// Path: profile.helpCenter.faq.account
class _TranslationsProfileHelpCenterFaqAccountVi extends _TranslationsProfileHelpCenterFaqAccountEn {
	_TranslationsProfileHelpCenterFaqAccountVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodVi addPaymentMethod = _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqAccountResetPasswordVi resetPassword = _TranslationsProfileHelpCenterFaqAccountResetPasswordVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqAccountChangeLanguageVi changeLanguage = _TranslationsProfileHelpCenterFaqAccountChangeLanguageVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqAccountDeleteAccountVi deleteAccount = _TranslationsProfileHelpCenterFaqAccountDeleteAccountVi._(_root);
	@override late final _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueVi addPaymentMethodIssue = _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueVi._(_root);
}

// Path: profile.helpCenter.faq.ebook
class _TranslationsProfileHelpCenterFaqEbookVi extends _TranslationsProfileHelpCenterFaqEbookEn {
	_TranslationsProfileHelpCenterFaqEbookVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfileHelpCenterFaqEbookDownloadOfflineVi downloadOffline = _TranslationsProfileHelpCenterFaqEbookDownloadOfflineVi._(_root);
}

// Path: profile.helpCenter.faq.movies
class _TranslationsProfileHelpCenterFaqMoviesVi extends _TranslationsProfileHelpCenterFaqMoviesEn {
	_TranslationsProfileHelpCenterFaqMoviesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountVi closeErabookAccount = _TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountVi._(_root);
}

// Path: profile.helpCenter.contacts.customerService
class _TranslationsProfileHelpCenterContactsCustomerServiceVi extends _TranslationsProfileHelpCenterContactsCustomerServiceEn {
	_TranslationsProfileHelpCenterContactsCustomerServiceVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Chăm sóc khách hàng';
	@override String get subtitle => 'support@nozie.app';
}

// Path: profile.helpCenter.contacts.whatsapp
class _TranslationsProfileHelpCenterContactsWhatsappVi extends _TranslationsProfileHelpCenterContactsWhatsappEn {
	_TranslationsProfileHelpCenterContactsWhatsappVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'WhatsApp';
	@override String get subtitle => '+1 800 123 4567';
}

// Path: profile.helpCenter.contacts.website
class _TranslationsProfileHelpCenterContactsWebsiteVi extends _TranslationsProfileHelpCenterContactsWebsiteEn {
	_TranslationsProfileHelpCenterContactsWebsiteVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Website';
	@override String get subtitle => 'www.nozie.app/support';
}

// Path: profile.helpCenter.contacts.facebook
class _TranslationsProfileHelpCenterContactsFacebookVi extends _TranslationsProfileHelpCenterContactsFacebookEn {
	_TranslationsProfileHelpCenterContactsFacebookVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Facebook';
	@override String get subtitle => '@NozieOfficial';
}

// Path: profile.helpCenter.contacts.twitter
class _TranslationsProfileHelpCenterContactsTwitterVi extends _TranslationsProfileHelpCenterContactsTwitterEn {
	_TranslationsProfileHelpCenterContactsTwitterVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Twitter';
	@override String get subtitle => '@NozieApp';
}

// Path: profile.helpCenter.contacts.instagram
class _TranslationsProfileHelpCenterContactsInstagramVi extends _TranslationsProfileHelpCenterContactsInstagramEn {
	_TranslationsProfileHelpCenterContactsInstagramVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Instagram';
	@override String get subtitle => '@nozie.app';
}

// Path: profile.personalInfo.fields.fullName
class _TranslationsProfilePersonalInfoFieldsFullNameVi extends _TranslationsProfilePersonalInfoFieldsFullNameEn {
	_TranslationsProfilePersonalInfoFieldsFullNameVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Họ và tên';
	@override String get hint => 'Nhập họ và tên';
}

// Path: profile.personalInfo.fields.username
class _TranslationsProfilePersonalInfoFieldsUsernameVi extends _TranslationsProfilePersonalInfoFieldsUsernameEn {
	_TranslationsProfilePersonalInfoFieldsUsernameVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Tên đăng nhập';
	@override String get hint => 'Nhập tên đăng nhập';
}

// Path: profile.personalInfo.fields.email
class _TranslationsProfilePersonalInfoFieldsEmailVi extends _TranslationsProfilePersonalInfoFieldsEmailEn {
	_TranslationsProfilePersonalInfoFieldsEmailVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Email';
	@override String get hint => 'Nhập địa chỉ email';
}

// Path: profile.personalInfo.fields.phone
class _TranslationsProfilePersonalInfoFieldsPhoneVi extends _TranslationsProfilePersonalInfoFieldsPhoneEn {
	_TranslationsProfilePersonalInfoFieldsPhoneVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Số điện thoại';
	@override String get hint => 'Nhập số điện thoại';
}

// Path: profile.personalInfo.fields.dob
class _TranslationsProfilePersonalInfoFieldsDobVi extends _TranslationsProfilePersonalInfoFieldsDobEn {
	_TranslationsProfilePersonalInfoFieldsDobVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Ngày sinh';
	@override String get hint => 'DD/MM/YYYY';
}

// Path: profile.personalInfo.fields.country
class _TranslationsProfilePersonalInfoFieldsCountryVi extends _TranslationsProfilePersonalInfoFieldsCountryEn {
	_TranslationsProfilePersonalInfoFieldsCountryVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Quốc gia';
	@override String get hint => 'Chọn quốc gia';
}

// Path: profile.preferences.actions.clearCache
class _TranslationsProfilePreferencesActionsClearCacheVi extends _TranslationsProfilePreferencesActionsClearCacheEn {
	_TranslationsProfilePreferencesActionsClearCacheVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Xóa bộ nhớ đệm';
	@override String description({required Object size}) => 'Đang lưu trữ: ${size}. Xóa bộ nhớ đệm sẽ loại bỏ tệp tạm nhưng giữ lại nội dung đã tải và cài đặt của bạn.';
	@override String get button => 'Xóa bộ nhớ đệm';
	@override String get success => 'Đã xóa bộ nhớ đệm';
}

// Path: profile.preferences.actions.videoQuality
class _TranslationsProfilePreferencesActionsVideoQualityVi extends _TranslationsProfilePreferencesActionsVideoQualityEn {
	_TranslationsProfilePreferencesActionsVideoQualityVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Chất lượng video';
	@override late final _TranslationsProfilePreferencesActionsVideoQualityOptionsVi options = _TranslationsProfilePreferencesActionsVideoQualityOptionsVi._(_root);
}

// Path: profile.preferences.actions.audioPreference
class _TranslationsProfilePreferencesActionsAudioPreferenceVi extends _TranslationsProfilePreferencesActionsAudioPreferenceEn {
	_TranslationsProfilePreferencesActionsAudioPreferenceVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ngôn ngữ / Chất lượng âm thanh';
	@override late final _TranslationsProfilePreferencesActionsAudioPreferenceOptionsVi options = _TranslationsProfilePreferencesActionsAudioPreferenceOptionsVi._(_root);
}

// Path: auth.register.steps.gender.options
class _TranslationsAuthRegisterStepsGenderOptionsVi extends _TranslationsAuthRegisterStepsGenderOptionsEn {
	_TranslationsAuthRegisterStepsGenderOptionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get male => 'Nam';
	@override String get female => 'Nữ';
	@override String get other => 'Khác';
	@override String get preferNotToSay => 'Không muốn nói';
}

// Path: auth.register.steps.gender.choices
class _TranslationsAuthRegisterStepsGenderChoicesVi extends _TranslationsAuthRegisterStepsGenderChoicesEn {
	_TranslationsAuthRegisterStepsGenderChoicesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get iAmMale => 'Tôi là nam';
	@override String get iAmFemale => 'Tôi là nữ';
	@override String get ratherNotToSay => 'Không muốn nói';
}

// Path: auth.register.steps.age.ranges
class _TranslationsAuthRegisterStepsAgeRangesVi extends _TranslationsAuthRegisterStepsAgeRangesEn {
	_TranslationsAuthRegisterStepsAgeRangesVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get age14to17 => '14-17';
	@override String get age18to24 => '18-24';
	@override String get age25to29 => '25-29';
	@override String get age30to34 => '30-34';
	@override String get age35to39 => '35-39';
	@override String get age40to44 => '40-44';
	@override String get age45to49 => '45-49';
	@override String get age50plus => '50+';
}

// Path: auth.register.steps.genres.list
class _TranslationsAuthRegisterStepsGenresListVi extends _TranslationsAuthRegisterStepsGenresListEn {
	_TranslationsAuthRegisterStepsGenresListVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get amNhac => 'Âm Nhạc';
	@override String get biAn => 'Bí ẩn';
	@override String get chienTranh => 'Chiến Tranh';
	@override String get chinhKich => 'Chính kịch';
	@override String get coTrang => 'Cổ Trang';
	@override String get giaDinh => 'Gia Đình';
	@override String get haiHuoc => 'Hài Hước';
	@override String get hanhDong => 'Hành Động';
	@override String get hinhSu => 'Hình Sự';
	@override String get hocDuong => 'Học Đường';
	@override String get khoaHoc => 'Khoa Học';
	@override String get kinhDi => 'Kinh Dị';
	@override String get kinhDien => 'Kinh Điển';
	@override String get phieuLuu => 'Phiêu Lưu';
	@override String get phim18 => 'Phim 18+';
	@override String get shortDrama => 'Short Drama';
	@override String get taiLieu => 'Tài Liệu';
	@override String get tamLy => 'Tâm Lý';
	@override String get thanThoai => 'Thần Thoại';
	@override String get theThao => 'Thể Thao';
	@override String get tinhCam => 'Tình Cảm';
	@override String get vienTuong => 'Viễn Tưởng';
	@override String get voThuat => 'Võ Thuật';
}

// Path: auth.register.steps.profile.photo
class _TranslationsAuthRegisterStepsProfilePhotoVi extends _TranslationsAuthRegisterStepsProfilePhotoEn {
	_TranslationsAuthRegisterStepsProfilePhotoVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get add => 'Thêm ảnh';
	@override String get tapToAdd => 'Nhấn để thêm ảnh đại diện';
}

// Path: auth.register.steps.profile.fields
class _TranslationsAuthRegisterStepsProfileFieldsVi extends _TranslationsAuthRegisterStepsProfileFieldsEn {
	_TranslationsAuthRegisterStepsProfileFieldsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAuthRegisterStepsProfileFieldsFullNameVi fullName = _TranslationsAuthRegisterStepsProfileFieldsFullNameVi._(_root);
	@override late final _TranslationsAuthRegisterStepsProfileFieldsPhoneNumberVi phoneNumber = _TranslationsAuthRegisterStepsProfileFieldsPhoneNumberVi._(_root);
	@override late final _TranslationsAuthRegisterStepsProfileFieldsDateOfBirthVi dateOfBirth = _TranslationsAuthRegisterStepsProfileFieldsDateOfBirthVi._(_root);
	@override late final _TranslationsAuthRegisterStepsProfileFieldsCountryVi country = _TranslationsAuthRegisterStepsProfileFieldsCountryVi._(_root);
}

// Path: profile.helpCenter.faq.general.whatIsNozie
class _TranslationsProfileHelpCenterFaqGeneralWhatIsNozieVi extends _TranslationsProfileHelpCenterFaqGeneralWhatIsNozieEn {
	_TranslationsProfileHelpCenterFaqGeneralWhatIsNozieVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Nozie là gì?';
	@override String get answer => 'Nozie là trung tâm cá nhân giúp bạn khám phá, đọc và nghe sách. Dễ dàng duyệt gợi ý tuyển chọn, sắp xếp thư viện và đồng bộ trên mọi thiết bị.';
}

// Path: profile.helpCenter.faq.general.syncProgress
class _TranslationsProfileHelpCenterFaqGeneralSyncProgressVi extends _TranslationsProfileHelpCenterFaqGeneralSyncProgressEn {
	_TranslationsProfileHelpCenterFaqGeneralSyncProgressVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Làm sao đồng bộ tiến độ đọc trên nhiều thiết bị?';
	@override String get answer => 'Đảm bảo bạn đã đăng nhập trên tất cả thiết bị. Tiến độ sẽ tự đồng bộ khi có kết nối; hãy kéo để làm mới trong tab Thư viện nếu muốn đồng bộ ngay.';
}

// Path: profile.helpCenter.faq.general.formatsSupport
class _TranslationsProfileHelpCenterFaqGeneralFormatsSupportVi extends _TranslationsProfileHelpCenterFaqGeneralFormatsSupportEn {
	_TranslationsProfileHelpCenterFaqGeneralFormatsSupportVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Nozie hỗ trợ định dạng nào?';
	@override String get answer => 'Nozie hỗ trợ tệp EPUB, PDF và audiobook MP3. Các tệp cá nhân tải lên sẽ được chuyển đổi tự động để phát tốt nhất.';
}

// Path: profile.helpCenter.faq.service.purchaseEbook
class _TranslationsProfileHelpCenterFaqServicePurchaseEbookVi extends _TranslationsProfileHelpCenterFaqServicePurchaseEbookEn {
	_TranslationsProfileHelpCenterFaqServicePurchaseEbookVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Làm thế nào để mua ebook?';
	@override String get answer => 'Mở trang chi tiết sách, nhấn "Mua", chọn phương thức thanh toán rồi xác nhận. Sách đã mua sẽ xuất hiện ngay trong tab Thư viện.';
}

// Path: profile.helpCenter.faq.service.audiobookNotPlaying
class _TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingVi extends _TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingEn {
	_TranslationsProfileHelpCenterFaqServiceAudiobookNotPlayingVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Vì sao audiobook không phát?';
	@override String get answer => 'Kiểm tra âm lượng thiết bị và kết nối ổn định. Nếu vẫn lỗi, hãy xóa bộ nhớ đệm tại Hồ sơ > Trung tâm trợ giúp rồi khởi động lại ứng dụng.';
}

// Path: profile.helpCenter.faq.service.manageNotifications
class _TranslationsProfileHelpCenterFaqServiceManageNotificationsVi extends _TranslationsProfileHelpCenterFaqServiceManageNotificationsEn {
	_TranslationsProfileHelpCenterFaqServiceManageNotificationsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Quản lý thông báo như thế nào?';
	@override String get answer => 'Vào Hồ sơ > Cài đặt thông báo để bật hoặc tắt cảnh báo cho gợi ý, mua sắm, khuyến mãi và nhiều loại khác.';
}

// Path: profile.helpCenter.faq.service.requestRefund
class _TranslationsProfileHelpCenterFaqServiceRequestRefundVi extends _TranslationsProfileHelpCenterFaqServiceRequestRefundEn {
	_TranslationsProfileHelpCenterFaqServiceRequestRefundVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Làm sao yêu cầu hoàn tiền?';
	@override String get answer => 'Liên hệ hỗ trợ qua Trung tâm trợ giúp > Liên hệ, cung cấp mã đơn hàng và đội ngũ của chúng tôi sẽ phản hồi trong 24 giờ.';
}

// Path: profile.helpCenter.faq.service.purchaseEbookIssue
class _TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueVi extends _TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueEn {
	_TranslationsProfileHelpCenterFaqServicePurchaseEbookIssueVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Tại sao tôi không thể mua ebook?';
	@override String get answer => 'Kiểm tra bạn đã thêm phương thức thanh toán hợp lệ và có kết nối ổn định. Nếu vẫn không được, hãy đăng xuất rồi đăng nhập lại trước khi thử mua.';
}

// Path: profile.helpCenter.faq.service.downloadEbookIssue
class _TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueVi extends _TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueEn {
	_TranslationsProfileHelpCenterFaqServiceDownloadEbookIssueVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Tại sao tôi không tải được ebook?';
	@override String get answer => 'Đảm bảo bạn đã mua tựa sách và còn đủ dung lượng lưu trữ. Việc tải xuống cần Wi-Fi trừ khi bạn bật tải bằng dữ liệu di động trong phần Tùy chỉnh.';
}

// Path: profile.helpCenter.faq.account.addPaymentMethod
class _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodVi extends _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodEn {
	_TranslationsProfileHelpCenterFaqAccountAddPaymentMethodVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Làm sao thêm phương thức thanh toán?';
	@override String get answer => 'Vào Hồ sơ > Phương thức thanh toán, chọn "Thêm mới", nhập thông tin thẻ hoặc ví rồi lưu. Bạn có thể quản lý hoặc xóa bất cứ lúc nào tại đây.';
}

// Path: profile.helpCenter.faq.account.resetPassword
class _TranslationsProfileHelpCenterFaqAccountResetPasswordVi extends _TranslationsProfileHelpCenterFaqAccountResetPasswordEn {
	_TranslationsProfileHelpCenterFaqAccountResetPasswordVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Làm sao đặt lại mật khẩu?';
	@override String get answer => 'Vào Đăng nhập > Quên mật khẩu, nhập email và làm theo bước xác minh. Bạn có thể đặt mật khẩu mới sau khi xác nhận OTP gửi đến hộp thư.';
}

// Path: profile.helpCenter.faq.account.changeLanguage
class _TranslationsProfileHelpCenterFaqAccountChangeLanguageVi extends _TranslationsProfileHelpCenterFaqAccountChangeLanguageEn {
	_TranslationsProfileHelpCenterFaqAccountChangeLanguageVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Làm sao đổi ngôn ngữ ứng dụng?';
	@override String get answer => 'Chuyển đến Hồ sơ > Ngôn ngữ để chọn ngôn ngữ mong muốn. Cài đặt sẽ áp dụng tức thì trên toàn ứng dụng.';
}

// Path: profile.helpCenter.faq.account.deleteAccount
class _TranslationsProfileHelpCenterFaqAccountDeleteAccountVi extends _TranslationsProfileHelpCenterFaqAccountDeleteAccountEn {
	_TranslationsProfileHelpCenterFaqAccountDeleteAccountVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Làm sao xóa tài khoản?';
	@override String get answer => 'Mở Cài đặt > Bảo mật > Xóa tài khoản. Thực hiện các bước xác minh danh tính để hoàn tất.';
}

// Path: profile.helpCenter.faq.account.addPaymentMethodIssue
class _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueVi extends _TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueEn {
	_TranslationsProfileHelpCenterFaqAccountAddPaymentMethodIssueVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Tại sao tôi không thêm được phương thức thanh toán?';
	@override String get answer => 'Hãy kiểm tra thông tin thẻ chính xác và được hỗ trợ ở khu vực của bạn. Một số thẻ trả trước hoặc ví điện tử có thể bị hạn chế bởi ngân hàng hoặc quốc gia.';
}

// Path: profile.helpCenter.faq.ebook.downloadOffline
class _TranslationsProfileHelpCenterFaqEbookDownloadOfflineVi extends _TranslationsProfileHelpCenterFaqEbookDownloadOfflineEn {
	_TranslationsProfileHelpCenterFaqEbookDownloadOfflineVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Làm sao tải ebook để đọc offline?';
	@override String get answer => 'Mở bất kỳ sách đã mua nào, nhấn biểu tượng tải xuống và chọn nơi lưu. Bản tải sẽ sẵn sàng offline trong tab Thư viện.';
}

// Path: profile.helpCenter.faq.movies.closeErabookAccount
class _TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountVi extends _TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountEn {
	_TranslationsProfileHelpCenterFaqMoviesCloseErabookAccountVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get question => 'Tại sao tôi không thể đóng tài khoản trên Erabook?';
	@override String get answer => 'Nếu bạn đã liên kết Nozie với Erabook, hãy hủy liên kết tại Hồ sơ > Dịch vụ liên kết trước. Sau đó gửi yêu cầu đóng tài khoản từ bảng điều khiển Erabook.';
}

// Path: profile.preferences.actions.videoQuality.options
class _TranslationsProfilePreferencesActionsVideoQualityOptionsVi extends _TranslationsProfilePreferencesActionsVideoQualityOptionsEn {
	_TranslationsProfilePreferencesActionsVideoQualityOptionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get auto => 'Tự động';
	@override String get hd => 'HD';
	@override String get fullHd => 'Full HD';
}

// Path: profile.preferences.actions.audioPreference.options
class _TranslationsProfilePreferencesActionsAudioPreferenceOptionsVi extends _TranslationsProfilePreferencesActionsAudioPreferenceOptionsEn {
	_TranslationsProfilePreferencesActionsAudioPreferenceOptionsVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get systemDefault => 'Theo hệ thống';
	@override String get englishHigh => 'Tiếng Anh • Chất lượng cao';
	@override String get originalStandard => 'Bản gốc • Tiêu chuẩn';
}

// Path: auth.register.steps.profile.fields.fullName
class _TranslationsAuthRegisterStepsProfileFieldsFullNameVi extends _TranslationsAuthRegisterStepsProfileFieldsFullNameEn {
	_TranslationsAuthRegisterStepsProfileFieldsFullNameVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Họ và tên';
	@override String get placeholder => 'Nhập họ và tên của bạn';
}

// Path: auth.register.steps.profile.fields.phoneNumber
class _TranslationsAuthRegisterStepsProfileFieldsPhoneNumberVi extends _TranslationsAuthRegisterStepsProfileFieldsPhoneNumberEn {
	_TranslationsAuthRegisterStepsProfileFieldsPhoneNumberVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Số điện thoại';
	@override String get placeholder => 'Nhập số điện thoại của bạn';
}

// Path: auth.register.steps.profile.fields.dateOfBirth
class _TranslationsAuthRegisterStepsProfileFieldsDateOfBirthVi extends _TranslationsAuthRegisterStepsProfileFieldsDateOfBirthEn {
	_TranslationsAuthRegisterStepsProfileFieldsDateOfBirthVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Ngày sinh';
	@override String get format => 'DD/MM/YYYY';
}

// Path: auth.register.steps.profile.fields.country
class _TranslationsAuthRegisterStepsProfileFieldsCountryVi extends _TranslationsAuthRegisterStepsProfileFieldsCountryEn {
	_TranslationsAuthRegisterStepsProfileFieldsCountryVi._(_TranslationsVi root) : this._root = root, super._(root);

	@override final _TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get label => 'Quốc gia';
	@override String get placeholder => 'Nhập quốc gia của bạn';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'locale': return 'en';
			case 'app.title': return 'NoZie';
			case 'common.skip': return 'Skip';
			case 'common.continueText': return 'Continue';
			case 'common.confirm': return 'Confirm';
			case 'common.data': return 'Data';
			case 'common.save': return 'Save';
			case 'common.cancel': return 'Cancel';
			case 'common.next': return 'Next';
			case 'common.back': return 'Back';
			case 'common.done': return 'Done';
			case 'common.empty': return 'Empty';
			case 'common.yes': return 'Yes';
			case 'common.no': return 'No';
			case 'common.addNew': return 'Add New';
			case 'common.clear': return 'Clear';
			case 'common.search': return 'Search';
			case 'common.loading': return 'Loading…';
			case 'common.signOut': return 'Sign out';
			case 'common.retry': return 'Retry';
			case 'common.errorPrefix': return 'Error:';
			case 'notification.title': return 'Notifications';
			case 'notification.empty': return 'You don\'t have any notification at this time';
			case 'notification.markAllAsRead': return 'Mark all as read';
			case 'notification.newItem': return 'New notification';
			case 'notification.seeAll': return 'See all notifications';
			case 'notification.today': return 'Today';
			case 'notification.dayAgo': return 'Days ago';
			case 'notification.loadFailed': return 'Error loading notifications';
			case 'notification.markAllAsReadFailed': return ({required Object error}) => 'Failed to mark all as read: ${error}';
			case 'auth.login': return 'Login';
			case 'auth.signIn': return 'Sign In';
			case 'auth.signUp': return 'Sign Up';
			case 'auth.email': return 'Email';
			case 'auth.password': return 'Password';
			case 'auth.username': return 'Username';
			case 'auth.confirmPassword': return 'Confirm Password';
			case 'auth.rememberMe': return 'Remember me';
			case 'auth.errors.invalidCredentials': return 'Incorrect username or password';
			case 'auth.loginScreen.title': return 'Hello there 👋';
			case 'auth.loginScreen.description': return 'Please enter your username/email and password to sign in.';
			case 'auth.loginScreen.placeholder.email': return 'admin@ziet.dev';
			case 'auth.loginScreen.placeholder.password': return '●●●●●●●●●●●●';
			case 'auth.oauth.featureInDevelopment': return 'This feature is under development';
			case 'auth.forgotPassword.title': return 'Forgot Password 🔑';
			case 'auth.forgotPassword.description': return 'Enter your email address. We will send an OTP code for verification in the next step.';
			case 'auth.forgotPassword.orContinueWith': return 'or continue with';
			case 'auth.forgotPassword.otp.title': return 'You\'ve Got Mail 📩';
			case 'auth.forgotPassword.otp.description': return 'We have sent the OTP verification code to your email address. Check your email and enter the code below.';
			case 'auth.forgotPassword.otp.didntReceiveCode': return 'Didn\'t receive the code?';
			case 'auth.forgotPassword.otp.resendCode': return 'Resend Code';
			case 'auth.forgotPassword.otp.resendAfter': return ({required Object seconds}) => 'You can resend after ${seconds}s';
			case 'auth.forgotPassword.newPassword.title': return 'Create New Password 🔐';
			case 'auth.forgotPassword.newPassword.description': return 'Enter your new password. If you forget it, then you have to do forgot password.';
			case 'auth.register.createAccount': return 'Create an Account';
			case 'auth.register.description': return 'Enter your username, email & password. If you forget it, then you have to do forgot password.';
			case 'auth.register.placeholder.username': return 'Enter your username';
			case 'auth.register.placeholder.password': return 'Enter your password';
			case 'auth.register.placeholder.email': return 'Enter your email address';
			case 'auth.register.placeholder.confirmPassword': return 'Confirm your password';
			case 'auth.register.registrationSuccessful': return 'Registration successful!';
			case 'auth.register.steps.stepOf': return 'Step {current} of {total}';
			case 'auth.register.steps.contentForStep': return 'Content for step {step}';
			case 'auth.register.steps.gender.select': return 'Select your gender';
			case 'auth.register.steps.gender.question': return 'What is your gender?';
			case 'auth.register.steps.gender.description': return 'Select gender for better content';
			case 'auth.register.steps.gender.options.male': return 'Male';
			case 'auth.register.steps.gender.options.female': return 'Female';
			case 'auth.register.steps.gender.options.other': return 'Other';
			case 'auth.register.steps.gender.options.preferNotToSay': return 'Prefer not to say';
			case 'auth.register.steps.gender.choices.iAmMale': return 'I am male';
			case 'auth.register.steps.gender.choices.iAmFemale': return 'I am female';
			case 'auth.register.steps.gender.choices.ratherNotToSay': return 'Rather not to say';
			case 'auth.register.steps.age.select': return 'Select your age';
			case 'auth.register.steps.age.title': return 'Choose your Age';
			case 'auth.register.steps.age.description': return 'Select age range for better content';
			case 'auth.register.steps.age.ranges.age14to17': return '14-17';
			case 'auth.register.steps.age.ranges.age18to24': return '18-24';
			case 'auth.register.steps.age.ranges.age25to29': return '25-29';
			case 'auth.register.steps.age.ranges.age30to34': return '30-34';
			case 'auth.register.steps.age.ranges.age35to39': return '35-39';
			case 'auth.register.steps.age.ranges.age40to44': return '40-44';
			case 'auth.register.steps.age.ranges.age45to49': return '45-49';
			case 'auth.register.steps.age.ranges.age50plus': return '50+';
			case 'auth.register.steps.genres.select': return 'Select your favorite genres';
			case 'auth.register.steps.genres.title': return 'Choose the Movie Genre You Like';
			case 'auth.register.steps.genres.description': return 'Select your preferred movie genre for better recommendation or you can skip it';
			case 'auth.register.steps.genres.list.amNhac': return 'Music';
			case 'auth.register.steps.genres.list.biAn': return 'Mystery';
			case 'auth.register.steps.genres.list.chienTranh': return 'War';
			case 'auth.register.steps.genres.list.chinhKich': return 'Drama';
			case 'auth.register.steps.genres.list.coTrang': return 'Historical';
			case 'auth.register.steps.genres.list.giaDinh': return 'Family';
			case 'auth.register.steps.genres.list.haiHuoc': return 'Comedy';
			case 'auth.register.steps.genres.list.hanhDong': return 'Action';
			case 'auth.register.steps.genres.list.hinhSu': return 'Crime';
			case 'auth.register.steps.genres.list.hocDuong': return 'School';
			case 'auth.register.steps.genres.list.khoaHoc': return 'Science';
			case 'auth.register.steps.genres.list.kinhDi': return 'Horror';
			case 'auth.register.steps.genres.list.kinhDien': return 'Classic';
			case 'auth.register.steps.genres.list.phieuLuu': return 'Adventure';
			case 'auth.register.steps.genres.list.phim18': return 'Adult 18+';
			case 'auth.register.steps.genres.list.shortDrama': return 'Short Drama';
			case 'auth.register.steps.genres.list.taiLieu': return 'Documentary';
			case 'auth.register.steps.genres.list.tamLy': return 'Psychological';
			case 'auth.register.steps.genres.list.thanThoai': return 'Mythology';
			case 'auth.register.steps.genres.list.theThao': return 'Sport';
			case 'auth.register.steps.genres.list.tinhCam': return 'Romance';
			case 'auth.register.steps.genres.list.vienTuong': return 'Sci-Fi';
			case 'auth.register.steps.genres.list.voThuat': return 'Martial Arts';
			case 'auth.register.steps.profile.title': return 'Complete Your Profile';
			case 'auth.register.steps.profile.infoTitle': return 'Profile Information';
			case 'auth.register.steps.profile.accountTitle': return 'Account Information';
			case 'auth.register.steps.profile.privacyNote': return 'Don\'t worry, only you can see your personal data. No one else will be able to see it.';
			case 'auth.register.steps.profile.photo.add': return 'Add Photo';
			case 'auth.register.steps.profile.photo.tapToAdd': return 'Tap to add profile picture';
			case 'auth.register.steps.profile.fields.fullName.label': return 'Full Name';
			case 'auth.register.steps.profile.fields.fullName.placeholder': return 'Enter your full name';
			case 'auth.register.steps.profile.fields.phoneNumber.label': return 'Phone Number';
			case 'auth.register.steps.profile.fields.phoneNumber.placeholder': return 'Enter your phone number';
			case 'auth.register.steps.profile.fields.dateOfBirth.label': return 'Date of Birth';
			case 'auth.register.steps.profile.fields.dateOfBirth.format': return 'DD/MM/YYYY';
			case 'auth.register.steps.profile.fields.country.label': return 'Country';
			case 'auth.register.steps.profile.fields.country.placeholder': return 'Enter your country';
			case 'welcome.title': return 'Welcome to NoZie 👋';
			case 'welcome.titlePrefix': return 'Welcome to ';
			case 'welcome.description': return 'Your personal movie companion. Get personalized recommendations, discover new films, and track your watchlist.';
			case 'welcome.getStarted': return 'Get Started';
			case 'welcome.continueWithGoogle': return 'Continue with Google';
			case 'welcome.iAlreadyHaveAnAccount': return 'I Already Have an Account';
			case 'welcome.slides.discover.title': return 'Discover New Movies';
			case 'welcome.slides.discover.description': return 'Explore thousands of movies from different genres. Find hidden gems and trending films that match your taste.';
			case 'welcome.slides.track.title': return 'Track Your Watchlist';
			case 'welcome.slides.track.description': return 'Save movies you want to watch, mark what you\'ve seen, and get recommendations based on your preferences.';
			case 'welcome.slides.community.title': return 'Join the Community';
			case 'welcome.slides.community.description': return 'Connect with other movie lovers, share reviews, and discover what\'s trending in the film world.';
			case 'settings.language.vietnamese': return 'Tiếng Việt';
			case 'settings.language.english': return 'English';
			case 'settings.theme.system': return 'System';
			case 'settings.theme.light': return 'Light';
			case 'settings.theme.dark': return 'Dark';
			case 'profile.header.defaultName': return 'NoZie User';
			case 'profile.header.loadError': return 'Unable to load profile';
			case 'profile.menu.paymentMethods': return 'Payment Methods';
			case 'profile.menu.personalInfo': return 'Personal Info';
			case 'profile.menu.notification': return 'Notification';
			case 'profile.menu.preferences': return 'Preferences';
			case 'profile.menu.security': return 'Security';
			case 'profile.menu.language': return 'Language';
			case 'profile.menu.helpCenter': return 'Help Center';
			case 'profile.menu.about': return 'About NoZie';
			case 'profile.menu.darkMode': return 'Dark Mode';
			case 'profile.menu.logout': return 'Logout';
			case 'profile.language.title': return 'Language';
			case 'profile.language.sectionSuggested': return 'Suggested';
			case 'profile.language.sectionOthers': return 'Other Languages';
			case 'profile.language.loadError': return ({required Object error}) => 'Failed to load languages: ${error}';
			case 'profile.language.fallback': return 'English (US)';
			case 'profile.logoutSheet.title': return 'Logout';
			case 'profile.logoutSheet.description': return 'Are you sure you want to logout from NoZie? You can log in again anytime.';
			case 'profile.helpCenter.title': return 'Help Center';
			case 'profile.helpCenter.tabs.faq': return 'FAQ';
			case 'profile.helpCenter.tabs.contact': return 'Contact us';
			case 'profile.helpCenter.categories.all': return 'All';
			case 'profile.helpCenter.categories.general': return 'General';
			case 'profile.helpCenter.categories.account': return 'Account';
			case 'profile.helpCenter.categories.service': return 'Service';
			case 'profile.helpCenter.categories.movies': return 'Movies';
			case 'profile.helpCenter.categories.ebook': return 'Ebook';
			case 'profile.helpCenter.search.hint': return 'Search';
			case 'profile.helpCenter.search.noResults': return 'No FAQs found';
			case 'profile.helpCenter.filter.clear': return 'Clear';
			case 'profile.helpCenter.faq.general.whatIsNozie.question': return 'What is Nozie?';
			case 'profile.helpCenter.faq.general.whatIsNozie.answer': return 'Nozie is your personal hub for discovering, reading, and listening to stories. Browse curated recommendations, organise your library, and stay synced across devices.';
			case 'profile.helpCenter.faq.general.syncProgress.question': return 'How do I sync reading progress across devices?';
			case 'profile.helpCenter.faq.general.syncProgress.answer': return 'Make sure you are signed in on all devices. Progress syncs automatically when the device is online; pull to refresh in Library to force a sync.';
			case 'profile.helpCenter.faq.general.formatsSupport.question': return 'What formats does Nozie support?';
			case 'profile.helpCenter.faq.general.formatsSupport.answer': return 'Nozie supports EPUB, PDF, and MP3 audiobook files. Uploaded personal files are converted automatically for best playback.';
			case 'profile.helpCenter.faq.service.purchaseEbook.question': return 'How to purchase an Ebook?';
			case 'profile.helpCenter.faq.service.purchaseEbook.answer': return 'Open the book detail page, tap the "Buy" button, choose a payment method, then confirm. Purchased titles instantly appear in your Library tab.';
			case 'profile.helpCenter.faq.service.audiobookNotPlaying.question': return 'Why is my audiobook not playing?';
			case 'profile.helpCenter.faq.service.audiobookNotPlaying.answer': return 'Ensure your device volume is up and you have a stable connection. If the issue persists, try clearing cache from Profile > Help Center and restart the app.';
			case 'profile.helpCenter.faq.service.manageNotifications.question': return 'How to manage notifications?';
			case 'profile.helpCenter.faq.service.manageNotifications.answer': return 'Go to Profile > Notification Settings to enable or disable alerts for recommendations, purchases, promotions, and more.';
			case 'profile.helpCenter.faq.service.requestRefund.question': return 'How do I request a refund?';
			case 'profile.helpCenter.faq.service.requestRefund.answer': return 'Contact support via Help Center > Contact Us, provide your order ID, and our team will review within 24 hours.';
			case 'profile.helpCenter.faq.service.purchaseEbookIssue.question': return 'Why can\'t I purchase an ebook?';
			case 'profile.helpCenter.faq.service.purchaseEbookIssue.answer': return 'Verify that you have a valid payment method added and a stable internet connection. If the issue persists, try signing out and back in before attempting the purchase again.';
			case 'profile.helpCenter.faq.service.downloadEbookIssue.question': return 'Why can\'t I download an ebook?';
			case 'profile.helpCenter.faq.service.downloadEbookIssue.answer': return 'Ensure the title is purchased and you have sufficient storage space. Downloads require Wi-Fi unless you enable cellular downloads in Preferences.';
			case 'profile.helpCenter.faq.account.addPaymentMethod.question': return 'How to add a payment method?';
			case 'profile.helpCenter.faq.account.addPaymentMethod.answer': return 'Head to Profile > Payment Methods, choose "Add New", enter your card or wallet details, and save. You can manage or remove methods anytime from the same screen.';
			case 'profile.helpCenter.faq.account.resetPassword.question': return 'How do I reset my password?';
			case 'profile.helpCenter.faq.account.resetPassword.answer': return 'Go to Login > Forgot Password, enter your email, and follow the verification steps. You can set a new password once you confirm the OTP sent to your inbox.';
			case 'profile.helpCenter.faq.account.changeLanguage.question': return 'How do I change the app language?';
			case 'profile.helpCenter.faq.account.changeLanguage.answer': return 'Navigate to Profile > Language to select your preferred language. Your choice syncs instantly across all sections of the app.';
			case 'profile.helpCenter.faq.account.deleteAccount.question': return 'How can I delete my account?';
			case 'profile.helpCenter.faq.account.deleteAccount.answer': return 'Open Settings > Security > Delete Account. Follow the instructions to confirm your identity and complete the deletion process.';
			case 'profile.helpCenter.faq.account.addPaymentMethodIssue.question': return 'Why can\'t I add a payment method?';
			case 'profile.helpCenter.faq.account.addPaymentMethodIssue.answer': return 'Check that your card details are correct and supported in your region. Some prepaid cards and virtual wallets may be restricted by your bank or country.';
			case 'profile.helpCenter.faq.ebook.downloadOffline.question': return 'How can I download ebooks for offline reading?';
			case 'profile.helpCenter.faq.ebook.downloadOffline.answer': return 'Open any purchased title, tap the download icon, and choose the device storage location. Downloads are available offline from your Library tab.';
			case 'profile.helpCenter.faq.movies.closeErabookAccount.question': return 'Why can\'t I close an account on Erabook?';
			case 'profile.helpCenter.faq.movies.closeErabookAccount.answer': return 'If you linked your Nozie account with Erabook, unlink the integration under Profile > Connected Services first. Afterwards, submit the closure request from the Erabook dashboard.';
			case 'profile.helpCenter.contacts.customerService.title': return 'Customer Service';
			case 'profile.helpCenter.contacts.customerService.subtitle': return 'support@nozie.app';
			case 'profile.helpCenter.contacts.whatsapp.title': return 'WhatsApp';
			case 'profile.helpCenter.contacts.whatsapp.subtitle': return '+1 800 123 4567';
			case 'profile.helpCenter.contacts.website.title': return 'Website';
			case 'profile.helpCenter.contacts.website.subtitle': return 'www.nozie.app/support';
			case 'profile.helpCenter.contacts.facebook.title': return 'Facebook';
			case 'profile.helpCenter.contacts.facebook.subtitle': return '@NozieOfficial';
			case 'profile.helpCenter.contacts.twitter.title': return 'Twitter';
			case 'profile.helpCenter.contacts.twitter.subtitle': return '@NozieApp';
			case 'profile.helpCenter.contacts.instagram.title': return 'Instagram';
			case 'profile.helpCenter.contacts.instagram.subtitle': return '@nozie.app';
			case 'profile.payment.title': return 'Payment Methods';
			case 'profile.payment.loadError': return ({required Object error}) => 'Failed to load payment methods: ${error}';
			case 'profile.payment.addNewMessage': return 'Add payment method tapped';
			case 'profile.payment.comingSoon': return 'More payment methods coming soon';
			case 'profile.notification.title': return 'Notification';
			case 'profile.notification.loadError': return ({required Object error}) => 'Failed to load settings: ${error}';
			case 'profile.notification.sectionTitle': return 'Notify me when...';
			case 'profile.notification.toggles.newRecommendation': return 'There is a New Recommendation';
			case 'profile.notification.toggles.newBookSeries': return 'There\'s a New Book Series';
			case 'profile.notification.toggles.authorUpdates': return 'There is an update from Authors';
			case 'profile.notification.toggles.priceDrops': return 'There are Price Drops Available';
			case 'profile.notification.toggles.purchase': return 'When I Make a Purchase';
			case 'profile.notification.toggles.appSystem': return 'Enable App System Notifications';
			case 'profile.notification.toggles.tipsServices': return 'New Tips & Services Available';
			case 'profile.notification.toggles.survey': return 'Participate in Survey';
			case 'profile.personalInfo.title': return 'Personal Info';
			case 'profile.personalInfo.loadError': return 'Failed to load profile. Please try again later.';
			case 'profile.personalInfo.success': return 'Profile updated';
			case 'profile.personalInfo.fields.fullName.label': return 'Full Name';
			case 'profile.personalInfo.fields.fullName.hint': return 'Enter full name';
			case 'profile.personalInfo.fields.username.label': return 'Username';
			case 'profile.personalInfo.fields.username.hint': return 'Enter username';
			case 'profile.personalInfo.fields.email.label': return 'Email';
			case 'profile.personalInfo.fields.email.hint': return 'Enter email address';
			case 'profile.personalInfo.fields.phone.label': return 'Phone Number';
			case 'profile.personalInfo.fields.phone.hint': return 'Enter phone number';
			case 'profile.personalInfo.fields.dob.label': return 'Date of Birth';
			case 'profile.personalInfo.fields.dob.hint': return 'DD/MM/YYYY';
			case 'profile.personalInfo.fields.country.label': return 'Country';
			case 'profile.personalInfo.fields.country.hint': return 'Select country';
			case 'profile.personalInfo.saveChanges': return 'Save Changes';
			case 'profile.preferences.title': return 'Preferences';
			case 'profile.preferences.sections.general': return 'General';
			case 'profile.preferences.sections.playback': return 'Playback';
			case 'profile.preferences.sections.video': return 'Video';
			case 'profile.preferences.sections.audio': return 'Audio';
			case 'profile.preferences.toggles.wifiOnlyDownloads': return 'Watch over Wi-Fi Only';
			case 'profile.preferences.toggles.autoPlayNextEpisode': return 'Auto Play Next Episode';
			case 'profile.preferences.toggles.continueWatching': return 'Continue Watching from Last Position';
			case 'profile.preferences.toggles.subtitlesEnabled': return 'Subtitles';
			case 'profile.preferences.toggles.autoRotateScreen': return 'Auto Rotate Screen';
			case 'profile.preferences.toggles.autoDownloadAudio': return 'Automatically Download Audio';
			case 'profile.preferences.actions.clearCache.title': return 'Clear Cache';
			case 'profile.preferences.actions.clearCache.description': return ({required Object size}) => 'Currently stored: ${size}. Removing cache will delete temporary files but keep your downloads and preferences.';
			case 'profile.preferences.actions.clearCache.button': return 'Clear Cache';
			case 'profile.preferences.actions.clearCache.success': return 'Cache cleared';
			case 'profile.preferences.actions.videoQuality.title': return 'Video Quality';
			case 'profile.preferences.actions.videoQuality.options.auto': return 'Auto';
			case 'profile.preferences.actions.videoQuality.options.hd': return 'HD';
			case 'profile.preferences.actions.videoQuality.options.fullHd': return 'Full HD';
			case 'profile.preferences.actions.audioPreference.title': return 'Audio Language / Quality';
			case 'profile.preferences.actions.audioPreference.options.systemDefault': return 'System Default';
			case 'profile.preferences.actions.audioPreference.options.englishHigh': return 'English • High Quality';
			case 'profile.preferences.actions.audioPreference.options.originalStandard': return 'Original • Standard';
			case 'profile.preferences.storageLabel.empty': return '0 MB stored';
			case 'profile.preferences.storageLabel.value': return ({required Object amount}) => '${amount} MB stored';
			case 'profile.security.title': return 'Security';
			case 'profile.security.loadError': return ({required Object error}) => 'Failed to load security settings: ${error}';
			case 'profile.security.toggles.rememberMe': return 'Remember me';
			case 'profile.security.toggles.biometricId': return 'Biometric ID';
			case 'profile.security.toggles.faceId': return 'Face ID';
			case 'profile.security.toggles.smsAuthenticator': return 'SMS Authenticator';
			case 'profile.security.toggles.googleAuthenticator': return 'Google Authenticator';
			case 'profile.security.actions.deviceManagement': return 'Device Management';
			case 'profile.security.actions.changePassword': return 'Change Password';
			case 'profile.security.actions.changePasswordMessage': return 'Change password tapped';
			case 'profile.security.actions.signOutDevice': return ({required Object name}) => 'Signed out ${name}';
			case 'profile.security.actions.signOutAll': return 'Signed out from all devices';
			case 'profile.security.deviceManagement.title': return 'Device Management';
			case 'profile.security.deviceManagement.description': return 'Manage devices that have access to your account.';
			case 'profile.security.deviceManagement.signOutAll': return 'Sign Out All Devices';
			case 'profile.security.deviceManagement.current': return 'Current';
			case 'profile.security.deviceManagement.lastActive': return ({required Object time}) => 'Last active: ${time}';
			case 'validation.general.fillAllFields': return 'Please fill in all fields.';
			case 'validation.general.required': return 'This field is required.';
			case 'validation.general.length': return ({required Object length}) => 'The length must be ${length}.';
			case 'validation.general.min': return ({required Object length}) => 'The minimum length is ${length}.';
			case 'validation.general.max': return ({required Object length}) => 'The maximum length is ${length}.';
			case 'validation.general.regex': return 'The field is invalid.';
			case 'validation.general.custom.password': return 'The password must have characters, numbers.';
			case 'validation.general.custom.username': return 'The username must only contain lowercase letters (a-z), numbers (0-9), hyphens (-), and underscores (_).';
			case 'validation.name.required': return 'Full name is required';
			case 'validation.name.minLength': return 'Full name must be at least 2 characters';
			case 'validation.phone.required': return 'Phone number is required';
			case 'validation.phone.minLength': return 'Phone number must be at least 10 digits';
			case 'validation.dateOfBirth.required': return 'Date of birth is required';
			case 'validation.country.required': return 'Country is required';
			case 'validation.username.required': return 'Username is required';
			case 'validation.username.minLength': return 'Username must be at least 3 characters';
			case 'validation.username.invalidChars': return 'Username can only contain letters, numbers, and underscores';
			case 'validation.email.required': return 'Email is required';
			case 'validation.email.invalid': return 'Please enter a valid email address';
			case 'validation.password.required': return 'Password is required';
			case 'validation.password.minLength': return 'Password must be at least 8 characters';
			case 'validation.password.complexity': return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
			case 'validation.password.confirmRequired': return 'Please confirm your password';
			case 'validation.password.mismatch': return 'Passwords do not match';
			case 'navigation.home': return 'Home';
			case 'navigation.discover': return 'Discover';
			case 'navigation.wishlist': return 'Wishlist';
			case 'navigation.purchase': return 'Purchase';
			case 'navigation.profile': return 'Profile';
			case 'search.searchMovies': return 'Search movies, TV shows, actors...';
			case 'search.popularSearches': return 'Popular Searches';
			case 'search.noResultsFound': return 'No results found';
			case 'search.tryDifferentKeywords': return 'Try different keywords or check your spelling';
			case 'search.all': return 'All';
			case 'search.movies': return 'Movies';
			case 'search.tvShows': return 'TV Shows';
			case 'search.actors': return 'Actors';
			case 'search.previousSearches': return 'Previous Searches';
			case 'search.noResults': return 'No results found';
			case 'search.showIn': return 'Show in';
			case 'search.filter.header': return 'Filter';
			case 'search.filter.reset': return 'Reset';
			case 'search.filter.apply': return 'Apply';
			case 'search.filter.sections.sort': return 'Sort';
			case 'search.filter.sections.price': return 'Price';
			case 'search.filter.sections.rating': return 'Rating';
			case 'search.filter.sections.genre': return 'Genre';
			case 'search.filter.sections.language': return 'Language';
			case 'search.filter.sections.age': return 'Age';
			case 'search.filter.sortOptions.trending': return 'Trending';
			case 'search.filter.sortOptions.newReleases': return 'New Releases';
			case 'search.filter.sortOptions.highestRating': return 'Highest Rating';
			case 'search.filter.sortOptions.lowestRating': return 'Lowest Rating';
			case 'search.filter.sortOptions.highestPrice': return 'Highest Price';
			case 'search.filter.sortOptions.lowestPrice': return 'Lowest Price';
			case 'search.filter.genres.action': return 'Action';
			case 'search.filter.genres.adventure': return 'Adventure';
			case 'search.filter.genres.romance': return 'Romance';
			case 'search.filter.genres.comics': return 'Comics';
			case 'search.filter.genres.comedy': return 'Comedy';
			case 'search.filter.genres.fantasy': return 'Fantasy';
			case 'search.filter.genres.mystery': return 'Mystery';
			case 'search.filter.genres.horror': return 'Horror';
			case 'search.filter.genres.scienceFiction': return 'Science Fiction';
			case 'search.filter.genres.thriller': return 'Thriller';
			case 'search.filter.genres.travel': return 'Travel';
			case 'search.filter.rangePrice.min': return '0';
			case 'search.filter.rangePrice.max': return '30';
			case 'search.filter.languages.english': return 'English';
			case 'search.filter.languages.vietnamese': return 'Vietnamese';
			case 'search.filter.languages.others': return 'Others';
			case 'search.filter.age.under12': return 'Age 12 & Under';
			case 'search.filter.age.above12': return '12+';
			case 'search.filter.age.above16': return '16+';
			case 'search.filter.age.above18': return '18+';
			case 'utils.itemsCount': return '{count} items';
			case 'utils.helloUser': return 'Hello, {name}!';
			case 'utils.counterText': return '';
			case 'cards.showIn': return 'Show in';
			case 'purchaseDetail.title': return 'Purchase Details';
			case 'purchaseDetail.infoTitle': return 'Purchase Information';
			case 'purchaseDetail.labels.movieId': return 'Movie ID';
			case 'purchaseDetail.labels.downloaded': return 'Downloaded';
			case 'purchaseDetail.labels.finished': return 'Finished';
			case 'purchaseDetail.labels.transactions': return 'Transactions';
			case 'purchaseDetail.labels.amount': return 'Amount';
			case 'purchaseDetail.labels.created': return 'Created';
			case 'purchaseDetail.labels.paidAt': return 'Paid At';
			case 'purchaseDetail.labels.failedAt': return 'Failed At';
			case 'purchaseDetail.labels.canceledAt': return 'Canceled At';
			case 'purchaseDetail.labels.paymentIntent': return 'Payment Intent';
			case 'purchaseDetail.labels.chargeId': return 'Charge ID';
			case 'purchaseDetail.states.succeeded': return 'Succeeded';
			case 'purchaseDetail.states.failed': return 'Failed';
			case 'purchaseDetail.states.canceled': return 'Canceled';
			case 'purchaseDetail.states.pending': return 'Pending';
			case 'purchaseDetail.empty.transactions': return 'No transactions found';
			case 'purchaseDetail.empty.purchaseNotFound': return 'Purchase not found';
			case 'purchaseDetail.error.generic': return ({required Object error}) => 'Error: ${error}';
			case 'discover.sections.topCharts': return 'Top Charts';
			case 'discover.sections.topSelling': return 'Top Selling';
			case 'discover.sections.topFree': return 'Top Free';
			case 'discover.sections.topNewReleases': return 'Top New Releases';
			case 'home.sections.recommendedForYou': return 'Recommended For You';
			case 'home.sections.yourPurchases': return 'Your Purchases';
			case 'home.sections.yourWishlist': return 'Your Wishlist';
			case 'home.sections.recentlyWatched': return 'Recently Watched';
			case 'home.sections.exploreByGenre': return 'Explore by Genre';
			case 'genre.explore.title': return 'Genre:';
			case 'genre.explore.empty': return 'No movies found for';
			case 'genre.explore.loadFailed': return 'Failed to load movies';
			case 'purchase.common.free': return 'Free';
			case 'purchase.common.purchased': return 'Purchased';
			case 'purchase.common.movieNotFound': return 'Movie not found';
			case 'purchase.common.comingSoon': return 'Coming soon';
			case 'purchase.common.errorPrefix': return 'Error:';
			case 'purchase.checkout.title': return 'Checkout';
			case 'purchase.checkout.section.movieSummary': return 'Movie Summary';
			case 'purchase.checkout.section.priceDetails': return 'Price Details';
			case 'purchase.checkout.section.paymentMethod': return 'Payment Method';
			case 'purchase.checkout.labels.price': return 'Price';
			case 'purchase.checkout.labels.total': return 'Total';
			case 'purchase.checkout.labels.visa': return 'Visa';
			case 'purchase.checkout.actions.confirm': return 'Confirm';
			case 'purchase.checkout.actions.payNow': return 'Pay Now';
			case 'purchase.checkout.actions.processing': return 'Processing...';
			case 'purchase.checkout.toasts.addedSuccess': return 'Movie added successfully! 🎬';
			case 'purchase.checkout.toasts.paymentSuccess': return 'Payment successful! 🎬';
			case 'purchase.checkout.toasts.paymentFailed': return 'Payment failed. Please try again.';
			case 'purchase.checkout.toasts.paymentCanceled': return 'Payment was canceled';
			case 'purchase.item.menu.watchNow': return 'Watch now';
			case 'purchase.item.menu.viewSeries': return 'View Series';
			case 'purchase.item.menu.purchaseDetails': return 'Purchase Details';
			case 'purchase.item.menu.aboutMovie': return 'About Movie';
			case 'purchase.item.snackbar.viewSeriesComing': return 'View series - coming soon';
			case 'purchase.notifications.successTitle': return 'Purchase Successful! 🎬';
			case 'purchase.notifications.successDescription': return 'You now own';
			case 'movie.details.notFound': return 'Movie not found';
			case 'movie.details.alreadyPurchased': return 'This movie is already in your purchased library';
			case 'movie.details.quality1080p': return '1080p';
			case 'movie.details.seriesFallback': return 'Series';
			case 'movie.ratings.title': return 'Ratings & Reviews';
			case 'movie.ratings.noReviews': return 'No reviews yet';
			case 'movie.ratings.rateThisFilm': return 'Rate this Film';
			case 'movie.ratings.purchaseRequired': return 'Purchase required to rate';
			case 'movie.ratings.writeAReview': return 'Write a Review';
			case 'movie.ratings.dialog.title': return 'Write a Review';
			case 'movie.ratings.dialog.yourRatingPrefix': return 'Your rating:';
			case 'movie.ratings.dialog.star': return 'star';
			case 'movie.ratings.dialog.stars': return 'stars';
			case 'movie.ratings.dialog.hint': return 'Write your review...';
			case 'movie.ratings.dialog.cancel': return 'Cancel';
			case 'movie.ratings.dialog.submit': return 'Submit';
			case 'movie.ratings.dialog.submitted': return 'Review submitted';
			case 'movie.info.images': return 'Images';
			case 'movie.info.cannotLoadImage': return 'Cannot load image';
			case 'movie.info.episodesList': return 'Episodes';
			case 'movie.info.language': return 'Language';
			case 'movie.info.genres': return 'Genres';
			case 'movie.info.countries': return 'Countries';
			case 'movie.info.directors': return 'Directors';
			case 'movie.info.actors': return 'Actors';
			case 'movie.info.aboutThisFilm': return 'About This Film';
			case 'movie.info.trailer': return 'Trailer';
			case 'movie.info.watchTrailer': return 'Watch trailer';
			case 'movie.info.episodePrefix': return 'Episode';
			case 'movie.info.episodesPrefix': return 'Episodes';
			case 'movie.player.noAccess': return 'You do not have access to this movie';
			case 'movie.player.videoUrlMissing': return 'Video URL not available';
			case 'movie.player.tryingFallback': return 'Trying fallback URL...';
			case 'movie.player.cannotLoadM3u8': return 'Cannot load video from m3u8 URL';
			case 'movie.player.cannotLoadBoth': return 'Cannot load video from both m3u8 and embed URL';
			case 'movie.player.unknownError': return 'Unknown error';
			case 'movie.player.cannotOpenTrailer': return 'Cannot open trailer';
			case 'movie.player.playbackSpeed': return 'Playback Speed';
			case 'movie.player.quality': return 'Quality';
			case 'movie.hero.ratings': return 'ratings';
			case 'movie.hero.reviews': return 'reviews';
			case 'movie.hero.duration': return 'duration';
			case 'movie.hero.quality': return 'quality';
			case 'movie.hero.watched': return 'watched';
			case 'movie.hero.watchNow': return 'Watch now';
			case 'movie.hero.aboutThisFilm': return 'About This Film';
			case 'movie.hero.viewMore': return 'View More';
			case 'movie.similar.title': return 'Similar Movies';
			case 'movie.report.headerTitle': return 'Report an Issue';
			case 'movie.report.headerSubtitle': return 'Help us improve the service quality';
			case 'movie.report.movieInfo': return 'Movie Information';
			case 'movie.report.labels.movieName': return 'Movie Name';
			case 'movie.report.labels.director': return 'Director';
			case 'movie.report.labels.videoUrl': return 'Video URL';
			case 'movie.report.labels.error': return 'Error';
			case 'movie.report.issueTypeLabel': return 'Issue Type *';
			case 'movie.report.descriptionLabel': return 'Detailed Description *';
			case 'movie.report.descriptionHint': return 'Describe the issue you encountered...';
			case 'movie.report.validations.selectIssue': return 'Please select an issue type';
			case 'movie.report.validations.descRequired': return 'Please enter a detailed description';
			case 'movie.report.validations.descMin': return 'Description must be at least 10 characters';
			case 'movie.report.actions.cancel': return 'Cancel';
			case 'movie.report.actions.submit': return 'Submit Report';
			case 'movie.report.actions.sending': return 'Sending...';
			case 'movie.report.success': return 'Report submitted successfully. Thank you for your feedback!';
			case 'movie.report.failurePrefix': return 'Failed to submit report:';
			case 'wishlist.common.retry': return 'Retry';
			case 'wishlist.common.errorPrefix': return 'Error:';
			case 'wishlist.common.movieNotFound': return 'Movie not found';
			case 'wishlist.item.menu.removeFromWishlist': return 'Remove from Wishlist';
			case 'wishlist.item.menu.share': return 'Share';
			case 'wishlist.item.menu.aboutMovie': return 'About Movie';
			case 'wishlist.item.snackbar.removed': return 'Removed from wishlist';
			case 'wishlist.item.snackbar.shareComing': return 'Share functionality coming soon';
			case 'wishlist.empty.title': return 'Your wishlist is empty';
			case 'wishlist.empty.subtitle': return 'Add movies you want to watch later';
			default: return null;
		}
	}
}

extension on _TranslationsVi {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'locale': return 'vi';
			case 'app.title': return 'NoZie';
			case 'common.skip': return 'Bỏ qua';
			case 'common.continueText': return 'Tiếp tục';
			case 'common.confirm': return 'Xác nhận';
			case 'common.data': return 'Dữ liệu';
			case 'common.save': return 'Lưu';
			case 'common.cancel': return 'Hủy';
			case 'common.next': return 'Tiếp theo';
			case 'common.back': return 'Quay lại';
			case 'common.done': return 'Hoàn thành';
			case 'common.empty': return 'Trống';
			case 'common.yes': return 'Có';
			case 'common.no': return 'Không';
			case 'common.addNew': return 'Thêm mới';
			case 'common.clear': return 'Xoá';
			case 'common.search': return 'Tìm kiếm';
			case 'common.loading': return 'Đang tải…';
			case 'common.signOut': return 'Đăng xuất';
			case 'common.retry': return 'Thử lại';
			case 'common.errorPrefix': return 'Lỗi:';
			case 'notification.title': return 'Thông báo';
			case 'notification.empty': return 'Chưa có thông báo nào';
			case 'notification.markAllAsRead': return 'Đánh dấu tất cả là đã đọc';
			case 'notification.newItem': return 'Thông báo mới';
			case 'notification.seeAll': return 'Xem tất cả';
			case 'notification.today': return 'Hôm nay';
			case 'notification.dayAgo': return 'Ngày trước';
			case 'notification.loadFailed': return 'Lỗi khi tải thông báo';
			case 'notification.markAllAsReadFailed': return ({required Object error}) => 'Không thể đánh dấu tất cả là đã đọc: ${error}';
			case 'auth.login': return 'Đăng nhập';
			case 'auth.signIn': return 'Đăng Nhập';
			case 'auth.signUp': return 'Đăng ký';
			case 'auth.email': return 'Email';
			case 'auth.password': return 'Mật khẩu';
			case 'auth.username': return 'Tên đăng nhập';
			case 'auth.confirmPassword': return 'Xác nhận mật khẩu';
			case 'auth.rememberMe': return 'Ghi nhớ tôi';
			case 'auth.errors.invalidCredentials': return 'Sai tên đăng nhập hoặc mật khẩu';
			case 'auth.loginScreen.title': return 'Xin chào bạn 👋';
			case 'auth.loginScreen.description': return 'Điền email/tên đăng nhập và mật khẩu để tiếp tục nha ✨';
			case 'auth.loginScreen.placeholder.email': return 'admin@ziet.dev';
			case 'auth.loginScreen.placeholder.password': return '●●●●●●●●●●●●';
			case 'auth.oauth.featureInDevelopment': return 'Tính năng đang phát triển';
			case 'auth.forgotPassword.title': return 'Quên Mật Khẩu 🔑';
			case 'auth.forgotPassword.description': return 'Nhập email của bạn, chúng tôi sẽ gửi mã OTP để xác minh ở bước tiếp theo.';
			case 'auth.forgotPassword.orContinueWith': return 'hoặc tiếp tục với';
			case 'auth.forgotPassword.otp.title': return 'OTP tới rồi nè 📩';
			case 'auth.forgotPassword.otp.description': return 'Chúng tôi đã gửi mã xác thực OTP đến email của bạn. Vui lòng kiểm tra email và nhập mã bên dưới nhé.';
			case 'auth.forgotPassword.otp.didntReceiveCode': return 'Chưa có mã?';
			case 'auth.forgotPassword.otp.resendCode': return 'Gửi lại mã ngay';
			case 'auth.forgotPassword.otp.resendAfter': return ({required Object seconds}) => 'Đợi ${seconds}s rồi gửi lại';
			case 'auth.forgotPassword.newPassword.title': return 'Tạo mật khẩu mới 🔐';
			case 'auth.forgotPassword.newPassword.description': return 'Nhập mật khẩu mới của bạn. Nếu quên, bạn sẽ cần thực hiện lại bước quên mật khẩu.';
			case 'auth.register.createAccount': return 'Tạo tài khoản';
			case 'auth.register.description': return 'Nhập tên đăng nhập, email và mật khẩu. Nếu bạn quên, bạn sẽ phải làm quên mật khẩu.';
			case 'auth.register.placeholder.username': return 'Nhập tên đăng nhập của bạn';
			case 'auth.register.placeholder.password': return 'Nhập mật khẩu của bạn';
			case 'auth.register.placeholder.email': return 'Nhập địa chỉ email của bạn';
			case 'auth.register.placeholder.confirmPassword': return 'Xác nhận mật khẩu của bạn';
			case 'auth.register.registrationSuccessful': return 'Đăng ký thành công!';
			case 'auth.register.steps.stepOf': return 'Bước {current} của {total}';
			case 'auth.register.steps.contentForStep': return 'Nội dung cho bước {step}';
			case 'auth.register.steps.gender.select': return 'Chọn giới tính của bạn';
			case 'auth.register.steps.gender.question': return 'Giới tính của bạn là gì?';
			case 'auth.register.steps.gender.description': return 'Chọn giới tính để có nội dung phù hợp hơn';
			case 'auth.register.steps.gender.options.male': return 'Nam';
			case 'auth.register.steps.gender.options.female': return 'Nữ';
			case 'auth.register.steps.gender.options.other': return 'Khác';
			case 'auth.register.steps.gender.options.preferNotToSay': return 'Không muốn nói';
			case 'auth.register.steps.gender.choices.iAmMale': return 'Tôi là nam';
			case 'auth.register.steps.gender.choices.iAmFemale': return 'Tôi là nữ';
			case 'auth.register.steps.gender.choices.ratherNotToSay': return 'Không muốn nói';
			case 'auth.register.steps.age.select': return 'Chọn độ tuổi của bạn';
			case 'auth.register.steps.age.title': return 'Chọn độ tuổi của bạn';
			case 'auth.register.steps.age.description': return 'Chọn khoảng tuổi để có nội dung phù hợp hơn';
			case 'auth.register.steps.age.ranges.age14to17': return '14-17';
			case 'auth.register.steps.age.ranges.age18to24': return '18-24';
			case 'auth.register.steps.age.ranges.age25to29': return '25-29';
			case 'auth.register.steps.age.ranges.age30to34': return '30-34';
			case 'auth.register.steps.age.ranges.age35to39': return '35-39';
			case 'auth.register.steps.age.ranges.age40to44': return '40-44';
			case 'auth.register.steps.age.ranges.age45to49': return '45-49';
			case 'auth.register.steps.age.ranges.age50plus': return '50+';
			case 'auth.register.steps.genres.select': return 'Chọn thể loại yêu thích';
			case 'auth.register.steps.genres.title': return 'Chọn thể loại phim bạn thích';
			case 'auth.register.steps.genres.description': return 'Chọn thể loại phim yêu thích để có gợi ý tốt hơn hoặc bạn có thể bỏ qua';
			case 'auth.register.steps.genres.list.amNhac': return 'Âm Nhạc';
			case 'auth.register.steps.genres.list.biAn': return 'Bí ẩn';
			case 'auth.register.steps.genres.list.chienTranh': return 'Chiến Tranh';
			case 'auth.register.steps.genres.list.chinhKich': return 'Chính kịch';
			case 'auth.register.steps.genres.list.coTrang': return 'Cổ Trang';
			case 'auth.register.steps.genres.list.giaDinh': return 'Gia Đình';
			case 'auth.register.steps.genres.list.haiHuoc': return 'Hài Hước';
			case 'auth.register.steps.genres.list.hanhDong': return 'Hành Động';
			case 'auth.register.steps.genres.list.hinhSu': return 'Hình Sự';
			case 'auth.register.steps.genres.list.hocDuong': return 'Học Đường';
			case 'auth.register.steps.genres.list.khoaHoc': return 'Khoa Học';
			case 'auth.register.steps.genres.list.kinhDi': return 'Kinh Dị';
			case 'auth.register.steps.genres.list.kinhDien': return 'Kinh Điển';
			case 'auth.register.steps.genres.list.phieuLuu': return 'Phiêu Lưu';
			case 'auth.register.steps.genres.list.phim18': return 'Phim 18+';
			case 'auth.register.steps.genres.list.shortDrama': return 'Short Drama';
			case 'auth.register.steps.genres.list.taiLieu': return 'Tài Liệu';
			case 'auth.register.steps.genres.list.tamLy': return 'Tâm Lý';
			case 'auth.register.steps.genres.list.thanThoai': return 'Thần Thoại';
			case 'auth.register.steps.genres.list.theThao': return 'Thể Thao';
			case 'auth.register.steps.genres.list.tinhCam': return 'Tình Cảm';
			case 'auth.register.steps.genres.list.vienTuong': return 'Viễn Tưởng';
			case 'auth.register.steps.genres.list.voThuat': return 'Võ Thuật';
			case 'auth.register.steps.profile.title': return 'Hoàn thành hồ sơ của bạn';
			case 'auth.register.steps.profile.infoTitle': return 'Thông tin cá nhân';
			case 'auth.register.steps.profile.accountTitle': return 'Thông tin tài khoản';
			case 'auth.register.steps.profile.privacyNote': return 'Đừng lo lắng, chỉ bạn mới có thể xem dữ liệu cá nhân của mình. Không ai khác có thể xem được.';
			case 'auth.register.steps.profile.photo.add': return 'Thêm ảnh';
			case 'auth.register.steps.profile.photo.tapToAdd': return 'Nhấn để thêm ảnh đại diện';
			case 'auth.register.steps.profile.fields.fullName.label': return 'Họ và tên';
			case 'auth.register.steps.profile.fields.fullName.placeholder': return 'Nhập họ và tên của bạn';
			case 'auth.register.steps.profile.fields.phoneNumber.label': return 'Số điện thoại';
			case 'auth.register.steps.profile.fields.phoneNumber.placeholder': return 'Nhập số điện thoại của bạn';
			case 'auth.register.steps.profile.fields.dateOfBirth.label': return 'Ngày sinh';
			case 'auth.register.steps.profile.fields.dateOfBirth.format': return 'DD/MM/YYYY';
			case 'auth.register.steps.profile.fields.country.label': return 'Quốc gia';
			case 'auth.register.steps.profile.fields.country.placeholder': return 'Nhập quốc gia của bạn';
			case 'welcome.title': return 'Chào mừng đến với NoZie 👋';
			case 'welcome.titlePrefix': return 'Chào mừng đến với ';
			case 'welcome.description': return 'Người bạn đồng hành phim của bạn. Nhận gợi ý cá nhân hóa, khám phá phim mới và theo dõi danh sách xem của bạn.';
			case 'welcome.getStarted': return 'Bắt đầu';
			case 'welcome.continueWithGoogle': return 'Tiếp tục với Google';
			case 'welcome.iAlreadyHaveAnAccount': return 'Tôi đã có tài khoản';
			case 'welcome.slides.discover.title': return 'Khám phá phim mới';
			case 'welcome.slides.discover.description': return 'Khám phá hàng nghìn bộ phim từ các thể loại khác nhau. Tìm những viên ngọc ẩn và phim xu hướng phù hợp với sở thích của bạn.';
			case 'welcome.slides.track.title': return 'Theo dõi danh sách xem';
			case 'welcome.slides.track.description': return 'Lưu phim bạn muốn xem, đánh dấu những gì bạn đã xem và nhận gợi ý dựa trên sở thích của bạn.';
			case 'welcome.slides.community.title': return 'Tham gia cộng đồng';
			case 'welcome.slides.community.description': return 'Kết nối với những người yêu phim khác, chia sẻ đánh giá và khám phá những gì đang xu hướng trong thế giới điện ảnh.';
			case 'settings.language.vietnamese': return 'Tiếng Việt';
			case 'settings.language.english': return 'English';
			case 'settings.theme.system': return 'Hệ thống';
			case 'settings.theme.light': return 'Sáng';
			case 'settings.theme.dark': return 'Tối';
			case 'profile.header.defaultName': return 'Người dùng NoZie';
			case 'profile.header.loadError': return 'Không thể tải hồ sơ';
			case 'profile.menu.paymentMethods': return 'Phương thức thanh toán';
			case 'profile.menu.personalInfo': return 'Thông tin cá nhân';
			case 'profile.menu.notification': return 'Thông báo';
			case 'profile.menu.preferences': return 'Tùy chỉnh';
			case 'profile.menu.security': return 'Bảo mật';
			case 'profile.menu.language': return 'Ngôn ngữ';
			case 'profile.menu.helpCenter': return 'Trung tâm trợ giúp';
			case 'profile.menu.about': return 'Giới thiệu về NoZie';
			case 'profile.menu.darkMode': return 'Chế độ tối';
			case 'profile.menu.logout': return 'Đăng xuất';
			case 'profile.language.title': return 'Ngôn ngữ';
			case 'profile.language.sectionSuggested': return 'Đề xuất';
			case 'profile.language.sectionOthers': return 'Ngôn ngữ khác';
			case 'profile.language.loadError': return ({required Object error}) => 'Không thể tải danh sách ngôn ngữ: ${error}';
			case 'profile.language.fallback': return 'Tiếng Anh (Mỹ)';
			case 'profile.logoutSheet.title': return 'Đăng xuất';
			case 'profile.logoutSheet.description': return 'Bạn có chắc muốn đăng xuất khỏi NoZie? Bạn có thể đăng nhập lại bất cứ lúc nào.';
			case 'profile.helpCenter.title': return 'Trung tâm trợ giúp';
			case 'profile.helpCenter.tabs.faq': return 'FAQ';
			case 'profile.helpCenter.tabs.contact': return 'Liên hệ';
			case 'profile.helpCenter.categories.all': return 'Tất cả';
			case 'profile.helpCenter.categories.general': return 'Chung';
			case 'profile.helpCenter.categories.account': return 'Tài khoản';
			case 'profile.helpCenter.categories.service': return 'Dịch vụ';
			case 'profile.helpCenter.categories.movies': return 'Phim';
			case 'profile.helpCenter.categories.ebook': return 'Sách điện tử';
			case 'profile.helpCenter.search.hint': return 'Tìm kiếm';
			case 'profile.helpCenter.search.noResults': return 'Không tìm thấy câu hỏi phù hợp';
			case 'profile.helpCenter.filter.clear': return 'Xoá';
			case 'profile.helpCenter.faq.general.whatIsNozie.question': return 'Nozie là gì?';
			case 'profile.helpCenter.faq.general.whatIsNozie.answer': return 'Nozie là trung tâm cá nhân giúp bạn khám phá, đọc và nghe sách. Dễ dàng duyệt gợi ý tuyển chọn, sắp xếp thư viện và đồng bộ trên mọi thiết bị.';
			case 'profile.helpCenter.faq.general.syncProgress.question': return 'Làm sao đồng bộ tiến độ đọc trên nhiều thiết bị?';
			case 'profile.helpCenter.faq.general.syncProgress.answer': return 'Đảm bảo bạn đã đăng nhập trên tất cả thiết bị. Tiến độ sẽ tự đồng bộ khi có kết nối; hãy kéo để làm mới trong tab Thư viện nếu muốn đồng bộ ngay.';
			case 'profile.helpCenter.faq.general.formatsSupport.question': return 'Nozie hỗ trợ định dạng nào?';
			case 'profile.helpCenter.faq.general.formatsSupport.answer': return 'Nozie hỗ trợ tệp EPUB, PDF và audiobook MP3. Các tệp cá nhân tải lên sẽ được chuyển đổi tự động để phát tốt nhất.';
			case 'profile.helpCenter.faq.service.purchaseEbook.question': return 'Làm thế nào để mua ebook?';
			case 'profile.helpCenter.faq.service.purchaseEbook.answer': return 'Mở trang chi tiết sách, nhấn "Mua", chọn phương thức thanh toán rồi xác nhận. Sách đã mua sẽ xuất hiện ngay trong tab Thư viện.';
			case 'profile.helpCenter.faq.service.audiobookNotPlaying.question': return 'Vì sao audiobook không phát?';
			case 'profile.helpCenter.faq.service.audiobookNotPlaying.answer': return 'Kiểm tra âm lượng thiết bị và kết nối ổn định. Nếu vẫn lỗi, hãy xóa bộ nhớ đệm tại Hồ sơ > Trung tâm trợ giúp rồi khởi động lại ứng dụng.';
			case 'profile.helpCenter.faq.service.manageNotifications.question': return 'Quản lý thông báo như thế nào?';
			case 'profile.helpCenter.faq.service.manageNotifications.answer': return 'Vào Hồ sơ > Cài đặt thông báo để bật hoặc tắt cảnh báo cho gợi ý, mua sắm, khuyến mãi và nhiều loại khác.';
			case 'profile.helpCenter.faq.service.requestRefund.question': return 'Làm sao yêu cầu hoàn tiền?';
			case 'profile.helpCenter.faq.service.requestRefund.answer': return 'Liên hệ hỗ trợ qua Trung tâm trợ giúp > Liên hệ, cung cấp mã đơn hàng và đội ngũ của chúng tôi sẽ phản hồi trong 24 giờ.';
			case 'profile.helpCenter.faq.service.purchaseEbookIssue.question': return 'Tại sao tôi không thể mua ebook?';
			case 'profile.helpCenter.faq.service.purchaseEbookIssue.answer': return 'Kiểm tra bạn đã thêm phương thức thanh toán hợp lệ và có kết nối ổn định. Nếu vẫn không được, hãy đăng xuất rồi đăng nhập lại trước khi thử mua.';
			case 'profile.helpCenter.faq.service.downloadEbookIssue.question': return 'Tại sao tôi không tải được ebook?';
			case 'profile.helpCenter.faq.service.downloadEbookIssue.answer': return 'Đảm bảo bạn đã mua tựa sách và còn đủ dung lượng lưu trữ. Việc tải xuống cần Wi-Fi trừ khi bạn bật tải bằng dữ liệu di động trong phần Tùy chỉnh.';
			case 'profile.helpCenter.faq.account.addPaymentMethod.question': return 'Làm sao thêm phương thức thanh toán?';
			case 'profile.helpCenter.faq.account.addPaymentMethod.answer': return 'Vào Hồ sơ > Phương thức thanh toán, chọn "Thêm mới", nhập thông tin thẻ hoặc ví rồi lưu. Bạn có thể quản lý hoặc xóa bất cứ lúc nào tại đây.';
			case 'profile.helpCenter.faq.account.resetPassword.question': return 'Làm sao đặt lại mật khẩu?';
			case 'profile.helpCenter.faq.account.resetPassword.answer': return 'Vào Đăng nhập > Quên mật khẩu, nhập email và làm theo bước xác minh. Bạn có thể đặt mật khẩu mới sau khi xác nhận OTP gửi đến hộp thư.';
			case 'profile.helpCenter.faq.account.changeLanguage.question': return 'Làm sao đổi ngôn ngữ ứng dụng?';
			case 'profile.helpCenter.faq.account.changeLanguage.answer': return 'Chuyển đến Hồ sơ > Ngôn ngữ để chọn ngôn ngữ mong muốn. Cài đặt sẽ áp dụng tức thì trên toàn ứng dụng.';
			case 'profile.helpCenter.faq.account.deleteAccount.question': return 'Làm sao xóa tài khoản?';
			case 'profile.helpCenter.faq.account.deleteAccount.answer': return 'Mở Cài đặt > Bảo mật > Xóa tài khoản. Thực hiện các bước xác minh danh tính để hoàn tất.';
			case 'profile.helpCenter.faq.account.addPaymentMethodIssue.question': return 'Tại sao tôi không thêm được phương thức thanh toán?';
			case 'profile.helpCenter.faq.account.addPaymentMethodIssue.answer': return 'Hãy kiểm tra thông tin thẻ chính xác và được hỗ trợ ở khu vực của bạn. Một số thẻ trả trước hoặc ví điện tử có thể bị hạn chế bởi ngân hàng hoặc quốc gia.';
			case 'profile.helpCenter.faq.ebook.downloadOffline.question': return 'Làm sao tải ebook để đọc offline?';
			case 'profile.helpCenter.faq.ebook.downloadOffline.answer': return 'Mở bất kỳ sách đã mua nào, nhấn biểu tượng tải xuống và chọn nơi lưu. Bản tải sẽ sẵn sàng offline trong tab Thư viện.';
			case 'profile.helpCenter.faq.movies.closeErabookAccount.question': return 'Tại sao tôi không thể đóng tài khoản trên Erabook?';
			case 'profile.helpCenter.faq.movies.closeErabookAccount.answer': return 'Nếu bạn đã liên kết Nozie với Erabook, hãy hủy liên kết tại Hồ sơ > Dịch vụ liên kết trước. Sau đó gửi yêu cầu đóng tài khoản từ bảng điều khiển Erabook.';
			case 'profile.helpCenter.contacts.customerService.title': return 'Chăm sóc khách hàng';
			case 'profile.helpCenter.contacts.customerService.subtitle': return 'support@nozie.app';
			case 'profile.helpCenter.contacts.whatsapp.title': return 'WhatsApp';
			case 'profile.helpCenter.contacts.whatsapp.subtitle': return '+1 800 123 4567';
			case 'profile.helpCenter.contacts.website.title': return 'Website';
			case 'profile.helpCenter.contacts.website.subtitle': return 'www.nozie.app/support';
			case 'profile.helpCenter.contacts.facebook.title': return 'Facebook';
			case 'profile.helpCenter.contacts.facebook.subtitle': return '@NozieOfficial';
			case 'profile.helpCenter.contacts.twitter.title': return 'Twitter';
			case 'profile.helpCenter.contacts.twitter.subtitle': return '@NozieApp';
			case 'profile.helpCenter.contacts.instagram.title': return 'Instagram';
			case 'profile.helpCenter.contacts.instagram.subtitle': return '@nozie.app';
			case 'profile.payment.title': return 'Phương thức thanh toán';
			case 'profile.payment.loadError': return ({required Object error}) => 'Không thể tải phương thức thanh toán: ${error}';
			case 'profile.payment.addNewMessage': return 'Đã chạm vào thêm phương thức thanh toán';
			case 'profile.payment.comingSoon': return 'Nozie đang phát triển thêm phương thức thanh toán khác';
			case 'profile.notification.title': return 'Thông báo';
			case 'profile.notification.loadError': return ({required Object error}) => 'Không thể tải cài đặt: ${error}';
			case 'profile.notification.sectionTitle': return 'Thông báo cho tôi khi...';
			case 'profile.notification.toggles.newRecommendation': return 'Có gợi ý mới';
			case 'profile.notification.toggles.newBookSeries': return 'Có phim mới';
			case 'profile.notification.toggles.authorUpdates': return 'Có cập nhật từ tác giả';
			case 'profile.notification.toggles.priceDrops': return 'Có khuyến mãi giảm giá';
			case 'profile.notification.toggles.purchase': return 'Khi tôi thực hiện giao dịch';
			case 'profile.notification.toggles.appSystem': return 'Bật thông báo hệ thống ứng dụng';
			case 'profile.notification.toggles.tipsServices': return 'Có mẹo và dịch vụ mới';
			case 'profile.notification.toggles.survey': return 'Tham gia khảo sát';
			case 'profile.personalInfo.title': return 'Thông tin cá nhân';
			case 'profile.personalInfo.loadError': return 'Không thể tải hồ sơ. Vui lòng thử lại sau.';
			case 'profile.personalInfo.success': return 'Cập nhật hồ sơ thành công';
			case 'profile.personalInfo.fields.fullName.label': return 'Họ và tên';
			case 'profile.personalInfo.fields.fullName.hint': return 'Nhập họ và tên';
			case 'profile.personalInfo.fields.username.label': return 'Tên đăng nhập';
			case 'profile.personalInfo.fields.username.hint': return 'Nhập tên đăng nhập';
			case 'profile.personalInfo.fields.email.label': return 'Email';
			case 'profile.personalInfo.fields.email.hint': return 'Nhập địa chỉ email';
			case 'profile.personalInfo.fields.phone.label': return 'Số điện thoại';
			case 'profile.personalInfo.fields.phone.hint': return 'Nhập số điện thoại';
			case 'profile.personalInfo.fields.dob.label': return 'Ngày sinh';
			case 'profile.personalInfo.fields.dob.hint': return 'DD/MM/YYYY';
			case 'profile.personalInfo.fields.country.label': return 'Quốc gia';
			case 'profile.personalInfo.fields.country.hint': return 'Chọn quốc gia';
			case 'profile.personalInfo.saveChanges': return 'Lưu thay đổi';
			case 'profile.preferences.title': return 'Tùy chỉnh';
			case 'profile.preferences.sections.general': return 'Chung';
			case 'profile.preferences.sections.playback': return 'Phát lại';
			case 'profile.preferences.sections.video': return 'Video';
			case 'profile.preferences.sections.audio': return 'Âm thanh';
			case 'profile.preferences.toggles.wifiOnlyDownloads': return 'Chỉ xem qua Wi-Fi';
			case 'profile.preferences.toggles.autoPlayNextEpisode': return 'Tự phát tập tiếp theo';
			case 'profile.preferences.toggles.continueWatching': return 'Tiếp tục xem từ vị trí dở';
			case 'profile.preferences.toggles.subtitlesEnabled': return 'Phụ đề';
			case 'profile.preferences.toggles.autoRotateScreen': return 'Tự xoay màn hình';
			case 'profile.preferences.toggles.autoDownloadAudio': return 'Tự động tải âm thanh';
			case 'profile.preferences.actions.clearCache.title': return 'Xóa bộ nhớ đệm';
			case 'profile.preferences.actions.clearCache.description': return ({required Object size}) => 'Đang lưu trữ: ${size}. Xóa bộ nhớ đệm sẽ loại bỏ tệp tạm nhưng giữ lại nội dung đã tải và cài đặt của bạn.';
			case 'profile.preferences.actions.clearCache.button': return 'Xóa bộ nhớ đệm';
			case 'profile.preferences.actions.clearCache.success': return 'Đã xóa bộ nhớ đệm';
			case 'profile.preferences.actions.videoQuality.title': return 'Chất lượng video';
			case 'profile.preferences.actions.videoQuality.options.auto': return 'Tự động';
			case 'profile.preferences.actions.videoQuality.options.hd': return 'HD';
			case 'profile.preferences.actions.videoQuality.options.fullHd': return 'Full HD';
			case 'profile.preferences.actions.audioPreference.title': return 'Ngôn ngữ / Chất lượng âm thanh';
			case 'profile.preferences.actions.audioPreference.options.systemDefault': return 'Theo hệ thống';
			case 'profile.preferences.actions.audioPreference.options.englishHigh': return 'Tiếng Anh • Chất lượng cao';
			case 'profile.preferences.actions.audioPreference.options.originalStandard': return 'Bản gốc • Tiêu chuẩn';
			case 'profile.preferences.storageLabel.empty': return '0 MB đã lưu';
			case 'profile.preferences.storageLabel.value': return ({required Object amount}) => '${amount} MB đã lưu';
			case 'profile.security.title': return 'Bảo mật';
			case 'profile.security.loadError': return ({required Object error}) => 'Không thể tải cài đặt bảo mật: ${error}';
			case 'profile.security.toggles.rememberMe': return 'Ghi nhớ tôi';
			case 'profile.security.toggles.biometricId': return 'Sinh trắc học';
			case 'profile.security.toggles.faceId': return 'Face ID';
			case 'profile.security.toggles.smsAuthenticator': return 'Xác thực SMS';
			case 'profile.security.toggles.googleAuthenticator': return 'Google Authenticator';
			case 'profile.security.actions.deviceManagement': return 'Quản lý thiết bị';
			case 'profile.security.actions.changePassword': return 'Đổi mật khẩu';
			case 'profile.security.actions.changePasswordMessage': return 'Đã chạm vào đổi mật khẩu';
			case 'profile.security.actions.signOutDevice': return ({required Object name}) => 'Đã đăng xuất ${name}';
			case 'profile.security.actions.signOutAll': return 'Đã đăng xuất khỏi tất cả thiết bị';
			case 'profile.security.deviceManagement.title': return 'Quản lý thiết bị';
			case 'profile.security.deviceManagement.description': return 'Quản lý các thiết bị được phép truy cập tài khoản của bạn.';
			case 'profile.security.deviceManagement.signOutAll': return 'Đăng xuất tất cả thiết bị';
			case 'profile.security.deviceManagement.current': return 'Thiết bị hiện tại';
			case 'profile.security.deviceManagement.lastActive': return ({required Object time}) => 'Hoạt động lần cuối: ${time}';
			case 'validation.general.fillAllFields': return 'Vui lòng điền đầy đủ tất cả các trường.';
			case 'validation.general.required': return 'Trường này là bắt buộc.';
			case 'validation.general.length': return ({required Object length}) => 'Độ dài phải là ${length}.';
			case 'validation.general.min': return ({required Object length}) => 'Độ dài tối thiểu là ${length}.';
			case 'validation.general.max': return ({required Object length}) => 'Độ dài tối đa là ${length}.';
			case 'validation.general.regex': return 'Trường không hợp lệ.';
			case 'validation.general.custom.password': return 'Mật khẩu phải có ký tự, số.';
			case 'validation.general.custom.username': return 'Tên người dùng chỉ được chứa chữ cái thường (a-z), số (0-9), dấu gạch ngang (-) và dấu gạch dưới (_).';
			case 'validation.name.required': return 'Họ và tên là bắt buộc';
			case 'validation.name.minLength': return 'Họ và tên phải có ít nhất 2 ký tự';
			case 'validation.phone.required': return 'Số điện thoại là bắt buộc';
			case 'validation.phone.minLength': return 'Số điện thoại phải có ít nhất 10 chữ số';
			case 'validation.dateOfBirth.required': return 'Ngày sinh là bắt buộc';
			case 'validation.country.required': return 'Quốc gia là bắt buộc';
			case 'validation.username.required': return 'Tên đăng nhập là bắt buộc';
			case 'validation.username.minLength': return 'Tên đăng nhập phải có ít nhất 3 ký tự';
			case 'validation.username.invalidChars': return 'Tên đăng nhập chỉ có thể chứa chữ cái, số và dấu gạch dưới';
			case 'validation.email.required': return 'Email là bắt buộc';
			case 'validation.email.invalid': return 'Vui lòng nhập địa chỉ email hợp lệ';
			case 'validation.password.required': return 'Mật khẩu là bắt buộc';
			case 'validation.password.minLength': return 'Mật khẩu phải có ít nhất 8 ký tự';
			case 'validation.password.complexity': return 'Mật khẩu phải chứa ít nhất một chữ hoa, một chữ thường và một số';
			case 'validation.password.confirmRequired': return 'Vui lòng xác nhận mật khẩu của bạn';
			case 'validation.password.mismatch': return 'Mật khẩu không khớp';
			case 'navigation.home': return 'Trang chủ';
			case 'navigation.discover': return 'Khám phá';
			case 'navigation.wishlist': return 'Yêu thích';
			case 'navigation.purchase': return 'Mua';
			case 'navigation.profile': return 'Hồ sơ';
			case 'search.searchMovies': return 'Tìm kiếm phim, chương trình TV, diễn viên...';
			case 'search.popularSearches': return 'Tìm kiếm phổ biến';
			case 'search.noResultsFound': return 'Không tìm thấy kết quả';
			case 'search.tryDifferentKeywords': return 'Thử từ khóa khác hoặc kiểm tra chính tả';
			case 'search.all': return 'Tất cả';
			case 'search.movies': return 'Phim';
			case 'search.tvShows': return 'Chương trình TV';
			case 'search.actors': return 'Diễn viên';
			case 'search.previousSearches': return 'Tìm kiếm trước';
			case 'search.noResults': return 'Không tìm thấy kết quả';
			case 'search.showIn': return 'Kết quả';
			case 'search.filter.header': return 'Bộ lọc';
			case 'search.filter.reset': return 'Đặt lại';
			case 'search.filter.apply': return 'Áp dụng';
			case 'search.filter.sections.sort': return 'Sắp xếp';
			case 'search.filter.sections.price': return 'Giá';
			case 'search.filter.sections.rating': return 'Đánh giá';
			case 'search.filter.sections.genre': return 'Thể loại';
			case 'search.filter.sections.language': return 'Ngôn ngữ';
			case 'search.filter.sections.age': return 'Độ tuổi';
			case 'search.filter.sortOptions.trending': return 'Xu hướng';
			case 'search.filter.sortOptions.newReleases': return 'Phát hành mới';
			case 'search.filter.sortOptions.highestRating': return 'Đánh giá cao nhất';
			case 'search.filter.sortOptions.lowestRating': return 'Đánh giá thấp nhất';
			case 'search.filter.sortOptions.highestPrice': return 'Giá cao nhất';
			case 'search.filter.sortOptions.lowestPrice': return 'Giá thấp nhất';
			case 'search.filter.genres.action': return 'Hành động';
			case 'search.filter.genres.adventure': return 'Phiêu lưu';
			case 'search.filter.genres.romance': return 'Lãng mạn';
			case 'search.filter.genres.comics': return 'Truyện tranh';
			case 'search.filter.genres.comedy': return 'Hài';
			case 'search.filter.genres.fantasy': return 'Giả tưởng';
			case 'search.filter.genres.mystery': return 'Bí ẩn';
			case 'search.filter.genres.horror': return 'Kinh dị';
			case 'search.filter.genres.scienceFiction': return 'Khoa học viễn tưởng';
			case 'search.filter.genres.thriller': return 'Giật gân';
			case 'search.filter.genres.travel': return 'Du lịch';
			case 'search.filter.rangePrice.min': return '0';
			case 'search.filter.rangePrice.max': return '500000';
			case 'search.filter.languages.english': return 'Tiếng Anh';
			case 'search.filter.languages.vietnamese': return 'Tiếng Việt';
			case 'search.filter.languages.others': return 'Khác';
			case 'search.filter.age.under12': return 'Dưới 12 tuổi';
			case 'search.filter.age.above12': return '12+';
			case 'search.filter.age.above16': return '16+';
			case 'search.filter.age.above18': return '18+';
			case 'utils.itemsCount': return '{count, plural, =0{Không có mục} =1{1 mục} other{{count} mục}}';
			case 'utils.helloUser': return 'Xin chào, {name}!';
			case 'utils.counterText': return '';
			case 'cards.showIn': return 'Hiển thị trong';
			case 'purchaseDetail.title': return 'Chi tiết giao dịch';
			case 'purchaseDetail.infoTitle': return 'Thông tin mua hàng';
			case 'purchaseDetail.labels.movieId': return 'Mã phim';
			case 'purchaseDetail.labels.downloaded': return 'Đã tải xuống';
			case 'purchaseDetail.labels.finished': return 'Đã xem xong';
			case 'purchaseDetail.labels.transactions': return 'Giao dịch';
			case 'purchaseDetail.labels.amount': return 'Số tiền';
			case 'purchaseDetail.labels.created': return 'Tạo lúc';
			case 'purchaseDetail.labels.paidAt': return 'Thanh toán lúc';
			case 'purchaseDetail.labels.failedAt': return 'Thất bại lúc';
			case 'purchaseDetail.labels.canceledAt': return 'Hủy lúc';
			case 'purchaseDetail.labels.paymentIntent': return 'Mã Payment Intent';
			case 'purchaseDetail.labels.chargeId': return 'Mã giao dịch (Charge ID)';
			case 'purchaseDetail.states.succeeded': return 'Thành công';
			case 'purchaseDetail.states.failed': return 'Thất bại';
			case 'purchaseDetail.states.canceled': return 'Đã hủy';
			case 'purchaseDetail.states.pending': return 'Đang xử lý';
			case 'purchaseDetail.empty.transactions': return 'Chưa có giao dịch nào';
			case 'purchaseDetail.empty.purchaseNotFound': return 'Không tìm thấy thông tin mua hàng';
			case 'purchaseDetail.error.generic': return ({required Object error}) => 'Lỗi: ${error}';
			case 'discover.sections.topCharts': return 'Bảng xếp hạng';
			case 'discover.sections.topSelling': return 'Bán chạy';
			case 'discover.sections.topFree': return 'Miễn phí hàng đầu';
			case 'discover.sections.topNewReleases': return 'Phát hành mới';
			case 'home.sections.recommendedForYou': return 'Gợi ý cho bạn';
			case 'home.sections.yourPurchases': return 'Giao dịch của bạn';
			case 'home.sections.yourWishlist': return 'Danh sách yêu thích';
			case 'home.sections.recentlyWatched': return 'Xem gần đây';
			case 'home.sections.exploreByGenre': return 'Khám phá theo thể loại';
			case 'genre.explore.title': return 'Thể loại:';
			case 'genre.explore.empty': return 'Không tìm thấy phim cho';
			case 'genre.explore.loadFailed': return 'Không tải được danh sách phim';
			case 'purchase.common.free': return 'Miễn phí';
			case 'purchase.common.purchased': return 'Đã mua';
			case 'purchase.common.movieNotFound': return 'Không tìm thấy phim';
			case 'purchase.common.comingSoon': return 'Sắp ra mắt';
			case 'purchase.common.errorPrefix': return 'Lỗi:';
			case 'purchase.checkout.title': return 'Thanh toán';
			case 'purchase.checkout.section.movieSummary': return 'Tóm tắt phim';
			case 'purchase.checkout.section.priceDetails': return 'Chi tiết giá';
			case 'purchase.checkout.section.paymentMethod': return 'Phương thức thanh toán';
			case 'purchase.checkout.labels.price': return 'Giá';
			case 'purchase.checkout.labels.total': return 'Tổng cộng';
			case 'purchase.checkout.labels.visa': return 'Visa';
			case 'purchase.checkout.actions.confirm': return 'Xác nhận';
			case 'purchase.checkout.actions.payNow': return 'Thanh toán ngay';
			case 'purchase.checkout.actions.processing': return 'Đang xử lý...';
			case 'purchase.checkout.toasts.addedSuccess': return 'Đã thêm phim thành công! 🎬';
			case 'purchase.checkout.toasts.paymentSuccess': return 'Thanh toán thành công! 🎬';
			case 'purchase.checkout.toasts.paymentFailed': return 'Thanh toán thất bại. Vui lòng thử lại.';
			case 'purchase.checkout.toasts.paymentCanceled': return 'Thanh toán đã bị hủy';
			case 'purchase.item.menu.watchNow': return 'Xem ngay';
			case 'purchase.item.menu.viewSeries': return 'Xem series';
			case 'purchase.item.menu.purchaseDetails': return 'Chi tiết giao dịch';
			case 'purchase.item.menu.aboutMovie': return 'Về phim';
			case 'purchase.item.snackbar.viewSeriesComing': return 'Tính năng xem series - sắp ra mắt';
			case 'purchase.notifications.successTitle': return 'Mua hàng thành công! 🎬';
			case 'purchase.notifications.successDescription': return 'Bạn đã sở hữu';
			case 'movie.details.notFound': return 'Không tìm thấy phim';
			case 'movie.details.alreadyPurchased': return 'Phim này đã có trong thư viện đã mua của bạn';
			case 'movie.details.quality1080p': return '1080p';
			case 'movie.details.seriesFallback': return 'Series';
			case 'movie.ratings.title': return 'Đánh giá & Nhận xét';
			case 'movie.ratings.noReviews': return 'Chưa có đánh giá nào';
			case 'movie.ratings.rateThisFilm': return 'Đánh giá phim này';
			case 'movie.ratings.purchaseRequired': return 'Cần mua để đánh giá';
			case 'movie.ratings.writeAReview': return 'Viết đánh giá';
			case 'movie.ratings.dialog.title': return 'Viết đánh giá';
			case 'movie.ratings.dialog.yourRatingPrefix': return 'Đánh giá của bạn:';
			case 'movie.ratings.dialog.star': return 'sao';
			case 'movie.ratings.dialog.stars': return 'sao';
			case 'movie.ratings.dialog.hint': return 'Viết đánh giá của bạn...';
			case 'movie.ratings.dialog.cancel': return 'Hủy';
			case 'movie.ratings.dialog.submit': return 'Gửi';
			case 'movie.ratings.dialog.submitted': return 'Đã gửi đánh giá';
			case 'movie.info.images': return 'Hình ảnh';
			case 'movie.info.cannotLoadImage': return 'Không thể tải ảnh';
			case 'movie.info.episodesList': return 'Danh sách tập';
			case 'movie.info.language': return 'Ngôn ngữ';
			case 'movie.info.genres': return 'Thể loại';
			case 'movie.info.countries': return 'Quốc gia';
			case 'movie.info.directors': return 'Đạo diễn';
			case 'movie.info.actors': return 'Diễn viên';
			case 'movie.info.aboutThisFilm': return 'Giới thiệu';
			case 'movie.info.trailer': return 'Trailer';
			case 'movie.info.watchTrailer': return 'Xem trailer';
			case 'movie.info.episodePrefix': return 'Tập';
			case 'movie.info.episodesPrefix': return 'Tập';
			case 'movie.player.noAccess': return 'Bạn chưa có quyền truy cập phim này';
			case 'movie.player.videoUrlMissing': return 'Không có URL video';
			case 'movie.player.tryingFallback': return 'Đang thử URL thay thế...';
			case 'movie.player.cannotLoadM3u8': return 'Không thể load video từ URL m3u8';
			case 'movie.player.cannotLoadBoth': return 'Không thể load video từ cả m3u8 và embed URL';
			case 'movie.player.unknownError': return 'Lỗi không xác định';
			case 'movie.player.cannotOpenTrailer': return 'Không mở được trailer';
			case 'movie.player.playbackSpeed': return 'Tốc độ phát';
			case 'movie.player.quality': return 'Chất lượng';
			case 'movie.hero.ratings': return 'lượt đánh giá';
			case 'movie.hero.reviews': return 'nhận xét';
			case 'movie.hero.duration': return 'thời lượng';
			case 'movie.hero.quality': return 'chất lượng';
			case 'movie.hero.watched': return 'lượt xem';
			case 'movie.hero.watchNow': return 'Xem ngay';
			case 'movie.hero.aboutThisFilm': return 'Giới thiệu';
			case 'movie.hero.viewMore': return 'Xem thêm';
			case 'movie.similar.title': return 'Phim tương tự';
			case 'movie.report.headerTitle': return 'Báo cáo vấn đề';
			case 'movie.report.headerSubtitle': return 'Giúp chúng tôi cải thiện chất lượng dịch vụ';
			case 'movie.report.movieInfo': return 'Thông tin phim';
			case 'movie.report.labels.movieName': return 'Tên phim';
			case 'movie.report.labels.director': return 'Đạo diễn';
			case 'movie.report.labels.videoUrl': return 'Video URL';
			case 'movie.report.labels.error': return 'Lỗi';
			case 'movie.report.issueTypeLabel': return 'Loại vấn đề *';
			case 'movie.report.descriptionLabel': return 'Mô tả chi tiết *';
			case 'movie.report.descriptionHint': return 'Mô tả chi tiết vấn đề bạn gặp phải...';
			case 'movie.report.validations.selectIssue': return 'Vui lòng chọn loại vấn đề';
			case 'movie.report.validations.descRequired': return 'Vui lòng nhập mô tả chi tiết';
			case 'movie.report.validations.descMin': return 'Mô tả phải có ít nhất 10 ký tự';
			case 'movie.report.actions.cancel': return 'Hủy';
			case 'movie.report.actions.submit': return 'Gửi báo cáo';
			case 'movie.report.actions.sending': return 'Đang gửi...';
			case 'movie.report.success': return 'Báo cáo đã được gửi thành công. Cảm ơn bạn đã phản hồi!';
			case 'movie.report.failurePrefix': return 'Lỗi khi gửi báo cáo:';
			case 'wishlist.common.retry': return 'Thử lại';
			case 'wishlist.common.errorPrefix': return 'Lỗi:';
			case 'wishlist.common.movieNotFound': return 'Không tìm thấy phim';
			case 'wishlist.item.menu.removeFromWishlist': return 'Xóa khỏi danh sách yêu thích';
			case 'wishlist.item.menu.share': return 'Chia sẻ';
			case 'wishlist.item.menu.aboutMovie': return 'Về phim';
			case 'wishlist.item.snackbar.removed': return 'Đã xóa khỏi danh sách yêu thích';
			case 'wishlist.item.snackbar.shareComing': return 'Tính năng chia sẻ sẽ có sớm';
			case 'wishlist.empty.title': return 'Danh sách yêu thích của bạn đang trống';
			case 'wishlist.empty.subtitle': return 'Thêm những phim bạn muốn xem sau';
			default: return null;
		}
	}
}
