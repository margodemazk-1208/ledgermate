import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'LedgerMate'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @dataManagement.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan & Pulihkan'**
  String get dataManagement;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In id, this message translates to:
  /// **'Tampilan & Bahasa'**
  String get appearanceAndLanguage;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap (Dark Mode)'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Aplikasi'**
  String get language;

  /// No description provided for @notificationsTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi & Pengingat'**
  String get notificationsTitle;

  /// No description provided for @dailyReminder.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Catat Harian'**
  String get dailyReminder;

  /// No description provided for @limitAlert.
  ///
  /// In id, this message translates to:
  /// **'Peringatan Limit Harian'**
  String get limitAlert;

  /// No description provided for @payCycleAlert.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gajian Baru'**
  String get payCycleAlert;

  /// No description provided for @goalMilestoneAlert.
  ///
  /// In id, this message translates to:
  /// **'Milestone Target Tabungan'**
  String get goalMilestoneAlert;

  /// No description provided for @categoryManagement.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get categoryManagement;

  /// No description provided for @aboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang LedgerMate'**
  String get aboutTitle;

  /// No description provided for @appRootDataLoadErrorMessage.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data: {error}'**
  String appRootDataLoadErrorMessage(Object error);

  /// No description provided for @initialIncomeStepPeriodicTitle.
  ///
  /// In id, this message translates to:
  /// **'Gaji Siklus Ini'**
  String get initialIncomeStepPeriodicTitle;

  /// No description provided for @initialIncomeStepDailyTitle.
  ///
  /// In id, this message translates to:
  /// **'Bekel Awal Hari Ini'**
  String get initialIncomeStepDailyTitle;

  /// No description provided for @initialIncomeStepPeriodicSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan total gaji tetap untuk siklus gajian ini.'**
  String get initialIncomeStepPeriodicSubtitle;

  /// No description provided for @initialIncomeStepDailySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan uang yang sudah kamu pegang untuk mulai hari ini.'**
  String get initialIncomeStepDailySubtitle;

  /// No description provided for @initialIncomeStepEmptyAmountError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh kosong'**
  String get initialIncomeStepEmptyAmountError;

  /// No description provided for @initialIncomeStepInvalidAmountError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh negatif atau nol'**
  String get initialIncomeStepInvalidAmountError;

  /// No description provided for @initialIncomeStepPeriodicLabel.
  ///
  /// In id, this message translates to:
  /// **'Gaji tetap'**
  String get initialIncomeStepPeriodicLabel;

  /// No description provided for @initialIncomeStepDailyLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah awal'**
  String get initialIncomeStepDailyLabel;

  /// No description provided for @incomeFrequencyStepTitle.
  ///
  /// In id, this message translates to:
  /// **'Pola Pendapatanmu'**
  String get incomeFrequencyStepTitle;

  /// No description provided for @incomeFrequencyStepSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih yang paling cocok dengan cara kamu menerima uang.'**
  String get incomeFrequencyStepSubtitle;

  /// No description provided for @incomeFrequencyStepPeriodicTitle.
  ///
  /// In id, this message translates to:
  /// **'Periodik'**
  String get incomeFrequencyStepPeriodicTitle;

  /// No description provided for @incomeFrequencyStepPeriodicDescription.
  ///
  /// In id, this message translates to:
  /// **'Gajian lump-sum di tanggal tertentu — mingguan, 2 mingguan, bulanan, atau custom.'**
  String get incomeFrequencyStepPeriodicDescription;

  /// No description provided for @incomeFrequencyStepDailyTitle.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get incomeFrequencyStepDailyTitle;

  /// No description provided for @incomeFrequencyStepDailyDescription.
  ///
  /// In id, this message translates to:
  /// **'Bekel/income diterima tiap hari (termasuk jadwal nggak rata) — tanpa tanggal gajian tetap.'**
  String get incomeFrequencyStepDailyDescription;

  /// No description provided for @incomeFrequencyStepIntervalLabel.
  ///
  /// In id, this message translates to:
  /// **'Interval'**
  String get incomeFrequencyStepIntervalLabel;

  /// No description provided for @incomeFrequencyStepNextPaydayLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal income berikutnya'**
  String get incomeFrequencyStepNextPaydayLabel;

  /// No description provided for @incomeFrequencyStepPickDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get incomeFrequencyStepPickDate;

  /// No description provided for @incomeFrequencyStepIntervalWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get incomeFrequencyStepIntervalWeekly;

  /// No description provided for @incomeFrequencyStepIntervalBiweekly.
  ///
  /// In id, this message translates to:
  /// **'2 Mingguan'**
  String get incomeFrequencyStepIntervalBiweekly;

  /// No description provided for @incomeFrequencyStepIntervalMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get incomeFrequencyStepIntervalMonthly;

  /// No description provided for @incomeFrequencyStepIntervalCustom.
  ///
  /// In id, this message translates to:
  /// **'Custom'**
  String get incomeFrequencyStepIntervalCustom;

  /// No description provided for @mandatoryExpensesStepTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Wajib'**
  String get mandatoryExpensesStepTitle;

  /// No description provided for @mandatoryExpensesStepSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kos, cicilan, dll — opsional, tambahkan sebanyak yang kamu perlukan.'**
  String get mandatoryExpensesStepSubtitle;

  /// No description provided for @mandatoryExpensesStepEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran wajib ditambahkan.'**
  String get mandatoryExpensesStepEmptyMessage;

  /// No description provided for @mandatoryExpensesStepNameEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nama tidak boleh kosong'**
  String get mandatoryExpensesStepNameEmptyError;

  /// No description provided for @mandatoryExpensesStepAmountEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh kosong'**
  String get mandatoryExpensesStepAmountEmptyError;

  /// No description provided for @mandatoryExpensesStepInvalidAmountError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh negatif atau nol'**
  String get mandatoryExpensesStepInvalidAmountError;

  /// No description provided for @mandatoryExpensesStepDeleteTooltip.
  ///
  /// In id, this message translates to:
  /// **'Hapus Pengeluaran'**
  String get mandatoryExpensesStepDeleteTooltip;

  /// No description provided for @mandatoryExpensesStepNameFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama pengeluaran'**
  String get mandatoryExpensesStepNameFieldLabel;

  /// No description provided for @mandatoryExpensesStepAmountFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get mandatoryExpensesStepAmountFieldLabel;

  /// No description provided for @mandatoryExpensesStepAddButton.
  ///
  /// In id, this message translates to:
  /// **'Tambah pengeluaran'**
  String get mandatoryExpensesStepAddButton;

  /// No description provided for @walletSetupStepTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur Dompet Pertamamu'**
  String get walletSetupStepTitle;

  /// No description provided for @walletSetupStepSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Dompet tempat menyimpan uangmu (misal: Tunai, Rekening Bank, E-Wallet). Kamu bisa menambah dompet lain nanti.'**
  String get walletSetupStepSubtitle;

  /// No description provided for @walletSetupStepNameFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Dompet'**
  String get walletSetupStepNameFieldLabel;

  /// No description provided for @walletSetupStepNameFieldHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: Dompet Utama, Tunai, Rekening BCA'**
  String get walletSetupStepNameFieldHint;

  /// No description provided for @walletSetupStepNameEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nama dompet tidak boleh kosong'**
  String get walletSetupStepNameEmptyError;

  /// No description provided for @walletSetupStepIconPickerLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih Ikon Dompet'**
  String get walletSetupStepIconPickerLabel;

  /// No description provided for @walletSetupStepStartingBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo Awal'**
  String get walletSetupStepStartingBalanceLabel;

  /// No description provided for @walletSetupStepStartingBalanceHelper.
  ///
  /// In id, this message translates to:
  /// **'Saldo riil yang ada di dompet ini saat mulai menggunakan aplikasi.'**
  String get walletSetupStepStartingBalanceHelper;

  /// No description provided for @walletSetupStepNegativeBalanceError.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal tidak boleh negatif'**
  String get walletSetupStepNegativeBalanceError;

  /// No description provided for @walletSetupStepIncludeBudgetTitle.
  ///
  /// In id, this message translates to:
  /// **'Sertakan dalam Budget Harian'**
  String get walletSetupStepIncludeBudgetTitle;

  /// No description provided for @walletSetupStepIncludeBudgetSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Uang di dompet ini akan dihitung ke dalam Uang Jajan Aman Hari Ini.'**
  String get walletSetupStepIncludeBudgetSubtitle;

  /// No description provided for @onboardingScreenBackButton.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get onboardingScreenBackButton;

  /// No description provided for @onboardingScreenFinishButton.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get onboardingScreenFinishButton;

  /// No description provided for @onboardingScreenNextButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onboardingScreenNextButton;

  /// No description provided for @onboardingScreenIncompleteDataError.
  ///
  /// In id, this message translates to:
  /// **'Data belum lengkap — kembali ke langkah sebelumnya.'**
  String get onboardingScreenIncompleteDataError;

  /// No description provided for @realismWarningDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Mungkin Terlalu Berat'**
  String get realismWarningDialogTitle;

  /// No description provided for @realismWarningDialogImpactMessage.
  ///
  /// In id, this message translates to:
  /// **'Jika target ini disimpan, total alokasi tabungan harian Anda menjadi {amount}/hari.'**
  String realismWarningDialogImpactMessage(String amount);

  /// No description provided for @realismWarningDialogNegativeBudgetMessage.
  ///
  /// In id, this message translates to:
  /// **'Hal ini akan mendorong Uang Jajan Aman Hari Ini ke angka negatif: {amount}/hari.'**
  String realismWarningDialogNegativeBudgetMessage(String amount);

  /// No description provided for @realismWarningDialogHint.
  ///
  /// In id, this message translates to:
  /// **'Memperpanjang tanggal target akan menurunkan porsi tabungan harian sehingga anggaran harian tetap aman.'**
  String get realismWarningDialogHint;

  /// No description provided for @realismWarningDialogExtendButton.
  ///
  /// In id, this message translates to:
  /// **'Perpanjang tanggal target'**
  String get realismWarningDialogExtendButton;

  /// No description provided for @realismWarningDialogProceedButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjut, saya paham risikonya'**
  String get realismWarningDialogProceedButton;

  /// No description provided for @unsavedChangesGuardDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Buang Perubahan?'**
  String get unsavedChangesGuardDialogTitle;

  /// No description provided for @unsavedChangesGuardDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Kamu memiliki perubahan yang belum disimpan. Yakin ingin keluar tanpa menyimpan?'**
  String get unsavedChangesGuardDialogContent;

  /// No description provided for @unsavedChangesGuardContinueEditingButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Edit'**
  String get unsavedChangesGuardContinueEditingButton;

  /// No description provided for @unsavedChangesGuardDiscardButton.
  ///
  /// In id, this message translates to:
  /// **'Buang Perubahan'**
  String get unsavedChangesGuardDiscardButton;

  /// No description provided for @databaseErrorScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Gagal Memuat Data Lokal'**
  String get databaseErrorScreenTitle;

  /// No description provided for @databaseErrorScreenDescription.
  ///
  /// In id, this message translates to:
  /// **'LedgerMate tidak dapat membuka database lokal di perangkat ini. Ini bisa terjadi akibat penyimpanan penuh atau proses yang terganggu saat terakhir menyimpan data.'**
  String get databaseErrorScreenDescription;

  /// No description provided for @databaseErrorScreenSuggestion.
  ///
  /// In id, this message translates to:
  /// **'Coba: (1) pastikan ruang penyimpanan perangkat cukup, lalu tekan \"Coba Lagi\"; (2) jika masih gagal, restart aplikasi sepenuhnya. Data tidak akan hilang kecuali aplikasi di-uninstall.'**
  String get databaseErrorScreenSuggestion;

  /// No description provided for @databaseErrorScreenRetryButton.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get databaseErrorScreenRetryButton;

  /// No description provided for @appBottomNavHomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get appBottomNavHomeLabel;

  /// No description provided for @appBottomNavTransactionsLabel.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get appBottomNavTransactionsLabel;

  /// No description provided for @appBottomNavGoalsLabel.
  ///
  /// In id, this message translates to:
  /// **'Goals'**
  String get appBottomNavGoalsLabel;

  /// No description provided for @appBottomNavAssetsLabel.
  ///
  /// In id, this message translates to:
  /// **'Aset'**
  String get appBottomNavAssetsLabel;

  /// No description provided for @appBottomNavAnalyticsLabel.
  ///
  /// In id, this message translates to:
  /// **'Analitik'**
  String get appBottomNavAnalyticsLabel;

  /// No description provided for @appBottomNavSettingsLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get appBottomNavSettingsLabel;

  /// No description provided for @fabSpeedDialCloseBarrierLabel.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get fabSpeedDialCloseBarrierLabel;

  /// No description provided for @fabSpeedDialAddWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Tambah Dompet Baru'**
  String get fabSpeedDialAddWalletLabel;

  /// No description provided for @fabSpeedDialTransferLabel.
  ///
  /// In id, this message translates to:
  /// **'Transfer Antar Dompet'**
  String get fabSpeedDialTransferLabel;

  /// No description provided for @fabSpeedDialIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Catat Pemasukan'**
  String get fabSpeedDialIncomeLabel;

  /// No description provided for @fabSpeedDialExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Catat Pengeluaran'**
  String get fabSpeedDialExpenseLabel;

  /// No description provided for @goalsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Tabungan'**
  String get goalsScreenTitle;

  /// No description provided for @goalsScreenLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat target tabungan: {error}'**
  String goalsScreenLoadError(Object error);

  /// No description provided for @goalsScreenEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Target Tabungan'**
  String get goalsScreenEmptyTitle;

  /// No description provided for @goalsScreenEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Buat target finansial untuk melacak estimasi tercapai dan menyisihkan dana harian secara otomatis.'**
  String get goalsScreenEmptyMessage;

  /// No description provided for @goalsScreenCreateFirstButton.
  ///
  /// In id, this message translates to:
  /// **'Buat Target Pertama'**
  String get goalsScreenCreateFirstButton;

  /// No description provided for @goalsScreenActiveListHeader.
  ///
  /// In id, this message translates to:
  /// **'Daftar Target Aktif ({count})'**
  String goalsScreenActiveListHeader(int count);

  /// No description provided for @goalsScreenCompletedCountLabel.
  ///
  /// In id, this message translates to:
  /// **'{count} selesai'**
  String goalsScreenCompletedCountLabel(int count);

  /// No description provided for @goalsScreenAddGoalCardLabel.
  ///
  /// In id, this message translates to:
  /// **'Tambah Goal Baru'**
  String get goalsScreenAddGoalCardLabel;

  /// No description provided for @goalsOverviewCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Total Progres Tabungan'**
  String get goalsOverviewCardTitle;

  /// No description provided for @goalsOverviewCardCollectedLabel.
  ///
  /// In id, this message translates to:
  /// **'Terkumpul'**
  String get goalsOverviewCardCollectedLabel;

  /// No description provided for @goalsOverviewCardTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Target'**
  String get goalsOverviewCardTargetLabel;

  /// No description provided for @goalsOverviewCardDailyReserveLabel.
  ///
  /// In id, this message translates to:
  /// **'Cadangan/Hari'**
  String get goalsOverviewCardDailyReserveLabel;

  /// No description provided for @goalFormScreenEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Target Tabungan'**
  String get goalFormScreenEditTitle;

  /// No description provided for @goalFormScreenAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Target Baru'**
  String get goalFormScreenAddTitle;

  /// No description provided for @goalFormScreenNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Target'**
  String get goalFormScreenNameLabel;

  /// No description provided for @goalFormScreenNameHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: Laptop Baru, Dana Darurat'**
  String get goalFormScreenNameHint;

  /// No description provided for @goalFormScreenNameEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nama target tidak boleh kosong'**
  String get goalFormScreenNameEmptyError;

  /// No description provided for @goalFormScreenTargetAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Target Nominal'**
  String get goalFormScreenTargetAmountLabel;

  /// No description provided for @goalFormScreenTargetAmountError.
  ///
  /// In id, this message translates to:
  /// **'Target nominal harus lebih besar dari 0'**
  String get goalFormScreenTargetAmountError;

  /// No description provided for @goalFormScreenCurrentAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo Awal / Sudah Terkumpul'**
  String get goalFormScreenCurrentAmountLabel;

  /// No description provided for @goalFormScreenCurrentAmountHelper.
  ///
  /// In id, this message translates to:
  /// **'Isi jika sudah mulai menabung sebelum target ini dibuat'**
  String get goalFormScreenCurrentAmountHelper;

  /// No description provided for @goalFormScreenCurrentAmountNegativeError.
  ///
  /// In id, this message translates to:
  /// **'Saldo tidak boleh negatif'**
  String get goalFormScreenCurrentAmountNegativeError;

  /// No description provided for @goalFormScreenTargetDateTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Tanggal Tercapai'**
  String get goalFormScreenTargetDateTitle;

  /// No description provided for @goalFormScreenManualAllocationTitle.
  ///
  /// In id, this message translates to:
  /// **'Override Alokasi Harian Manual'**
  String get goalFormScreenManualAllocationTitle;

  /// No description provided for @goalFormScreenManualAllocationSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tetapkan nominal tabungan harian tetap, bukan hasil hitungan otomatis formula.'**
  String get goalFormScreenManualAllocationSubtitle;

  /// No description provided for @goalFormScreenManualAllocationFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal Alokasi Harian (Rp/hari)'**
  String get goalFormScreenManualAllocationFieldLabel;

  /// No description provided for @goalFormScreenManualAllocationHelper.
  ///
  /// In id, this message translates to:
  /// **'Nominal ini langsung menggantikan kalkulasi formula otomatis'**
  String get goalFormScreenManualAllocationHelper;

  /// No description provided for @goalFormScreenManualAllocationError.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alokasi harian yang lebih besar dari 0'**
  String get goalFormScreenManualAllocationError;

  /// No description provided for @goalFormScreenTargetAmountRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Target nominal harus lebih besar dari 0.'**
  String get goalFormScreenTargetAmountRequiredError;

  /// No description provided for @goalFormScreenTargetDateError.
  ///
  /// In id, this message translates to:
  /// **'Tanggal target harus lebih dari hari ini.'**
  String get goalFormScreenTargetDateError;

  /// No description provided for @goalFormScreenSaveSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Target tabungan berhasil disimpan'**
  String get goalFormScreenSaveSuccessToast;

  /// No description provided for @goalFormScreenSaveError.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan target: {error}'**
  String goalFormScreenSaveError(Object error);

  /// No description provided for @goalFormScreenUpdateButton.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Target'**
  String get goalFormScreenUpdateButton;

  /// No description provided for @goalFormScreenSaveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Target'**
  String get goalFormScreenSaveButton;

  /// No description provided for @goalCardDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Target?'**
  String get goalCardDeleteDialogTitle;

  /// No description provided for @goalCardDeleteDialogMessage.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus target \"{goalName}\"? Tindakan ini tidak dapat dibatalkan.'**
  String goalCardDeleteDialogMessage(String goalName);

  /// No description provided for @goalCardCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get goalCardCancelButton;

  /// No description provided for @goalCardDeleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get goalCardDeleteButton;

  /// No description provided for @goalCardTargetDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Target: {date}'**
  String goalCardTargetDateLabel(String date);

  /// No description provided for @goalCardCompletedBadge.
  ///
  /// In id, this message translates to:
  /// **'Tercapai'**
  String get goalCardCompletedBadge;

  /// No description provided for @goalCardManualOverrideBadge.
  ///
  /// In id, this message translates to:
  /// **'Override Manual'**
  String get goalCardManualOverrideBadge;

  /// No description provided for @goalCardTargetAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'{targetAmount} ({percent}%)'**
  String goalCardTargetAmountLabel(String targetAmount, int percent);

  /// No description provided for @goalCardCompletedMessage.
  ///
  /// In id, this message translates to:
  /// **'Target telah terpenuhi sepenuhnya!'**
  String get goalCardCompletedMessage;

  /// No description provided for @goalCardEstimatedCompletionMessage.
  ///
  /// In id, this message translates to:
  /// **'Estimasi tercapai: {date}'**
  String goalCardEstimatedCompletionMessage(String date);

  /// No description provided for @goalCardNoEstimateMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada estimasi (alokasi 0)'**
  String get goalCardNoEstimateMessage;

  /// No description provided for @goalCardDoneLabel.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get goalCardDoneLabel;

  /// No description provided for @goalCardDailyAllocationLabel.
  ///
  /// In id, this message translates to:
  /// **'{amount}/hari'**
  String goalCardDailyAllocationLabel(String amount);

  /// No description provided for @goalCardWithdrawButton.
  ///
  /// In id, this message translates to:
  /// **'Tarik dari Goal'**
  String get goalCardWithdrawButton;

  /// No description provided for @goalCardEditButton.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get goalCardEditButton;

  /// No description provided for @goalCardDeleteTooltip.
  ///
  /// In id, this message translates to:
  /// **'Hapus Target'**
  String get goalCardDeleteTooltip;

  /// No description provided for @withdrawDialogInvalidAmountError.
  ///
  /// In id, this message translates to:
  /// **'Nominal harus lebih besar dari 0.'**
  String get withdrawDialogInvalidAmountError;

  /// No description provided for @withdrawDialogExceedsBalanceError.
  ///
  /// In id, this message translates to:
  /// **'Nominal melebihi tabungan saat ini.'**
  String get withdrawDialogExceedsBalanceError;

  /// No description provided for @withdrawDialogConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Penarikan'**
  String get withdrawDialogConfirmTitle;

  /// No description provided for @withdrawDialogConfirmMessage.
  ///
  /// In id, this message translates to:
  /// **'Tarik {amount} dari target \"{goalName}\"?\n\nSaldo target akan berkurang dan nominal ini akan otomatis kembali ke saldo aktif periode berjalan.'**
  String withdrawDialogConfirmMessage(String amount, String goalName);

  /// No description provided for @withdrawDialogCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get withdrawDialogCancelButton;

  /// No description provided for @withdrawDialogConfirmSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Tarik Sekarang'**
  String get withdrawDialogConfirmSubmitButton;

  /// No description provided for @withdrawDialogSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Penarikan {amount} berhasil'**
  String withdrawDialogSuccessToast(String amount);

  /// No description provided for @withdrawDialogGenericError.
  ///
  /// In id, this message translates to:
  /// **'Gagal melakukan penarikan: {error}'**
  String withdrawDialogGenericError(Object error);

  /// No description provided for @withdrawDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Tarik dari Goal'**
  String get withdrawDialogTitle;

  /// No description provided for @withdrawDialogTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target: {goalName}'**
  String withdrawDialogTargetLabel(String goalName);

  /// No description provided for @withdrawDialogAvailableLabel.
  ///
  /// In id, this message translates to:
  /// **'Tersedia saat ini: {amount}'**
  String withdrawDialogAvailableLabel(String amount);

  /// No description provided for @withdrawDialogAmountFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal Penarikan'**
  String get withdrawDialogAmountFieldLabel;

  /// No description provided for @withdrawDialogInvalidAmountValidator.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nominal yang valid'**
  String get withdrawDialogInvalidAmountValidator;

  /// No description provided for @withdrawDialogExceedsBalanceValidator.
  ///
  /// In id, this message translates to:
  /// **'Melebihi saldo terkumpul'**
  String get withdrawDialogExceedsBalanceValidator;

  /// No description provided for @withdrawDialogChipAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get withdrawDialogChipAll;

  /// No description provided for @withdrawDialogSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Tarik'**
  String get withdrawDialogSubmitButton;

  /// No description provided for @assetsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Aset & Investasi'**
  String get assetsScreenTitle;

  /// No description provided for @assetsScreenAddTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tambah Aset'**
  String get assetsScreenAddTooltip;

  /// No description provided for @assetsScreenLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data aset: {error}'**
  String assetsScreenLoadError(Object error);

  /// No description provided for @assetsScreenEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Aset Terdaftar'**
  String get assetsScreenEmptyTitle;

  /// No description provided for @assetsScreenEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Pantau nilai kekayaan bersih (net-worth) Anda secara mandiri. Catat aset seperti emas, saham, reksadana, atau kripto dengan pembaruan manual 100% offline.'**
  String get assetsScreenEmptyMessage;

  /// No description provided for @assetsScreenAddFirstButton.
  ///
  /// In id, this message translates to:
  /// **'Tambah Aset Pertama'**
  String get assetsScreenAddFirstButton;

  /// No description provided for @assetsScreenPortfolioTotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Portofolio Aset'**
  String get assetsScreenPortfolioTotalLabel;

  /// No description provided for @assetsScreenAssetCountBadge.
  ///
  /// In id, this message translates to:
  /// **'{count} Aset'**
  String assetsScreenAssetCountBadge(int count);

  /// No description provided for @assetsScreenTotalPurchaseLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Modal Awal'**
  String get assetsScreenTotalPurchaseLabel;

  /// No description provided for @assetsScreenTotalGainLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Keuntungan'**
  String get assetsScreenTotalGainLabel;

  /// No description provided for @assetsScreenGainLossSummary.
  ///
  /// In id, this message translates to:
  /// **'{sign}{amount} ({sign}{percent}%)'**
  String assetsScreenGainLossSummary(
    String sign,
    String amount,
    String percent,
  );

  /// No description provided for @assetsScreenListHeader.
  ///
  /// In id, this message translates to:
  /// **'Daftar Aset ({count})'**
  String assetsScreenListHeader(int count);

  /// No description provided for @assetsScreenAddCardLabel.
  ///
  /// In id, this message translates to:
  /// **'Tambah Aset Baru'**
  String get assetsScreenAddCardLabel;

  /// No description provided for @assetCardDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Aset?'**
  String get assetCardDeleteDialogTitle;

  /// No description provided for @assetCardDeleteDialogMessage.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus aset \"{assetName}\"? Tindakan ini tidak dapat dibatalkan.'**
  String assetCardDeleteDialogMessage(String assetName);

  /// No description provided for @assetCardCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get assetCardCancelButton;

  /// No description provided for @assetCardDeleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get assetCardDeleteButton;

  /// No description provided for @assetCardEditTooltip.
  ///
  /// In id, this message translates to:
  /// **'Edit Lengkap'**
  String get assetCardEditTooltip;

  /// No description provided for @assetCardDeleteTooltip.
  ///
  /// In id, this message translates to:
  /// **'Hapus Aset'**
  String get assetCardDeleteTooltip;

  /// No description provided for @assetCardPurchaseValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Modal Awal'**
  String get assetCardPurchaseValueLabel;

  /// No description provided for @assetCardCurrentValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Nilai Sekarang'**
  String get assetCardCurrentValueLabel;

  /// No description provided for @assetCardGainLossLabel.
  ///
  /// In id, this message translates to:
  /// **'Keuntungan / Kerugian'**
  String get assetCardGainLossLabel;

  /// No description provided for @assetCardGainLossValue.
  ///
  /// In id, this message translates to:
  /// **'{sign}{amount} ({sign}{percent}%)'**
  String assetCardGainLossValue(String sign, String amount, String percent);

  /// No description provided for @assetCardLastUpdatedLabel.
  ///
  /// In id, this message translates to:
  /// **'Update: {date}'**
  String assetCardLastUpdatedLabel(String date);

  /// No description provided for @assetCardUpdateValueButton.
  ///
  /// In id, this message translates to:
  /// **'Update Nilai'**
  String get assetCardUpdateValueButton;

  /// No description provided for @assetFormScreenEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Aset'**
  String get assetFormScreenEditTitle;

  /// No description provided for @assetFormScreenAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Aset'**
  String get assetFormScreenAddTitle;

  /// No description provided for @assetFormScreenNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Aset'**
  String get assetFormScreenNameLabel;

  /// No description provided for @assetFormScreenNameHint.
  ///
  /// In id, this message translates to:
  /// **'misal: Emas Antam 10g, BBCA, Reksadana Pasar Uang'**
  String get assetFormScreenNameHint;

  /// No description provided for @assetFormScreenNameEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nama aset tidak boleh kosong.'**
  String get assetFormScreenNameEmptyError;

  /// No description provided for @assetFormScreenTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tipe Aset'**
  String get assetFormScreenTypeLabel;

  /// No description provided for @assetFormScreenTypeHint.
  ///
  /// In id, this message translates to:
  /// **'misal: Emas, Saham, Reksadana, Kripto'**
  String get assetFormScreenTypeHint;

  /// No description provided for @assetFormScreenTypeEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Tipe aset tidak boleh kosong.'**
  String get assetFormScreenTypeEmptyError;

  /// No description provided for @assetFormScreenPurchaseValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Modal Awal / Nilai Beli (Rp)'**
  String get assetFormScreenPurchaseValueLabel;

  /// No description provided for @assetFormScreenPurchaseValueEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Modal awal tidak boleh kosong.'**
  String get assetFormScreenPurchaseValueEmptyError;

  /// No description provided for @assetFormScreenPurchaseValueInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Modal awal harus lebih besar dari 0.'**
  String get assetFormScreenPurchaseValueInvalidError;

  /// No description provided for @assetFormScreenCurrentValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Nilai Sekarang (Rp)'**
  String get assetFormScreenCurrentValueLabel;

  /// No description provided for @assetFormScreenCopyFromPurchaseButton.
  ///
  /// In id, this message translates to:
  /// **'Sama dg modal'**
  String get assetFormScreenCopyFromPurchaseButton;

  /// No description provided for @assetFormScreenCurrentValueEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nilai sekarang tidak boleh kosong.'**
  String get assetFormScreenCurrentValueEmptyError;

  /// No description provided for @assetFormScreenCurrentValueNegativeError.
  ///
  /// In id, this message translates to:
  /// **'Nilai sekarang tidak boleh negatif.'**
  String get assetFormScreenCurrentValueNegativeError;

  /// No description provided for @assetFormScreenGainLossPreviewLabel.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Gain / Loss:'**
  String get assetFormScreenGainLossPreviewLabel;

  /// No description provided for @assetFormScreenOfflineNotice.
  ///
  /// In id, this message translates to:
  /// **'100% Offline. Nilai aset diperbarui secara manual oleh Anda kapan saja (D8).'**
  String get assetFormScreenOfflineNotice;

  /// No description provided for @assetFormScreenPurchaseRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Modal awal harus lebih besar dari 0.'**
  String get assetFormScreenPurchaseRequiredError;

  /// No description provided for @assetFormScreenCurrentValueRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Nilai sekarang tidak boleh kosong atau negatif.'**
  String get assetFormScreenCurrentValueRequiredError;

  /// No description provided for @assetFormScreenSaveSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Aset berhasil disimpan'**
  String get assetFormScreenSaveSuccessToast;

  /// No description provided for @assetFormScreenSaveError.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan aset: {error}'**
  String assetFormScreenSaveError(Object error);

  /// No description provided for @assetFormScreenSaveChangesButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get assetFormScreenSaveChangesButton;

  /// No description provided for @assetFormScreenAddButton.
  ///
  /// In id, this message translates to:
  /// **'Tambah Aset'**
  String get assetFormScreenAddButton;

  /// No description provided for @assetFormScreenTypeGold.
  ///
  /// In id, this message translates to:
  /// **'Emas'**
  String get assetFormScreenTypeGold;

  /// No description provided for @assetFormScreenTypeStocks.
  ///
  /// In id, this message translates to:
  /// **'Saham'**
  String get assetFormScreenTypeStocks;

  /// No description provided for @assetFormScreenTypeMutualFund.
  ///
  /// In id, this message translates to:
  /// **'Reksadana'**
  String get assetFormScreenTypeMutualFund;

  /// No description provided for @assetFormScreenTypeCrypto.
  ///
  /// In id, this message translates to:
  /// **'Kripto'**
  String get assetFormScreenTypeCrypto;

  /// No description provided for @assetFormScreenTypeProperty.
  ///
  /// In id, this message translates to:
  /// **'Properti'**
  String get assetFormScreenTypeProperty;

  /// No description provided for @assetFormScreenTypeDeposit.
  ///
  /// In id, this message translates to:
  /// **'Deposito'**
  String get assetFormScreenTypeDeposit;

  /// No description provided for @assetFormScreenTypeOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get assetFormScreenTypeOther;

  /// No description provided for @updateValueDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Update Nilai Aset'**
  String get updateValueDialogTitle;

  /// No description provided for @updateValueDialogTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tipe: {type}'**
  String updateValueDialogTypeLabel(String type);

  /// No description provided for @updateValueDialogPurchaseValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Modal Awal'**
  String get updateValueDialogPurchaseValueLabel;

  /// No description provided for @updateValueDialogPreviousValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Nilai Sebelumnya'**
  String get updateValueDialogPreviousValueLabel;

  /// No description provided for @updateValueDialogLastUpdatedLabel.
  ///
  /// In id, this message translates to:
  /// **'Terakhir diperbarui: {date}'**
  String updateValueDialogLastUpdatedLabel(String date);

  /// No description provided for @updateValueDialogNewValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Nilai Sekarang Baru'**
  String get updateValueDialogNewValueLabel;

  /// No description provided for @updateValueDialogEmptyValueError.
  ///
  /// In id, this message translates to:
  /// **'Nilai aset tidak boleh kosong.'**
  String get updateValueDialogEmptyValueError;

  /// No description provided for @updateValueDialogNegativeValueError.
  ///
  /// In id, this message translates to:
  /// **'Nilai tidak boleh negatif.'**
  String get updateValueDialogNegativeValueError;

  /// No description provided for @updateValueDialogRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Nilai aset tidak boleh kosong atau negatif.'**
  String get updateValueDialogRequiredError;

  /// No description provided for @updateValueDialogNewGainLossLabel.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Gain / Loss Baru:'**
  String get updateValueDialogNewGainLossLabel;

  /// No description provided for @updateValueDialogChangeFromPreviousLabel.
  ///
  /// In id, this message translates to:
  /// **'Perubahan dari sebelumnya: {sign}{amount}'**
  String updateValueDialogChangeFromPreviousLabel(String sign, String amount);

  /// No description provided for @updateValueDialogGenericError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memperbarui nilai: {error}'**
  String updateValueDialogGenericError(Object error);

  /// No description provided for @updateValueDialogSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Nilai aset berhasil diperbarui'**
  String get updateValueDialogSuccessToast;

  /// No description provided for @updateValueDialogCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get updateValueDialogCancelButton;

  /// No description provided for @updateValueDialogSaveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Pembaruan'**
  String get updateValueDialogSaveButton;

  /// No description provided for @analyticsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Visual Analitik'**
  String get analyticsScreenTitle;

  /// No description provided for @analyticsScreenThemeToggleToLight.
  ///
  /// In id, this message translates to:
  /// **'Beralih ke mode terang'**
  String get analyticsScreenThemeToggleToLight;

  /// No description provided for @analyticsScreenThemeToggleToDark.
  ///
  /// In id, this message translates to:
  /// **'Beralih ke mode gelap'**
  String get analyticsScreenThemeToggleToDark;

  /// No description provided for @analyticsScreenLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat analitik: {error}'**
  String analyticsScreenLoadError(Object error);

  /// No description provided for @analyticsScreenTrendLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat tren: {error}'**
  String analyticsScreenTrendLoadError(Object error);

  /// No description provided for @analyticsScreenFilterDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get analyticsScreenFilterDaily;

  /// No description provided for @analyticsScreenFilterWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get analyticsScreenFilterWeekly;

  /// No description provided for @analyticsScreenFilterMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get analyticsScreenFilterMonthly;

  /// No description provided for @analyticsEmptyStateDefaultMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi pada periode ini.'**
  String get analyticsEmptyStateDefaultMessage;

  /// No description provided for @analyticsEmptyStateDefaultSubmessage.
  ///
  /// In id, this message translates to:
  /// **'Catat pengeluaran atau pemasukan untuk melihat visualisasi grafik dan tren keuangan.'**
  String get analyticsEmptyStateDefaultSubmessage;

  /// No description provided for @analyticsEmptyStateRecordButton.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get analyticsEmptyStateRecordButton;

  /// No description provided for @incomeExpenseRatioCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Keuangan Periode'**
  String get incomeExpenseRatioCardTitle;

  /// No description provided for @incomeExpenseRatioCardTotalIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Pemasukan'**
  String get incomeExpenseRatioCardTotalIncomeLabel;

  /// No description provided for @incomeExpenseRatioCardTotalExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Pengeluaran'**
  String get incomeExpenseRatioCardTotalExpenseLabel;

  /// No description provided for @incomeExpenseRatioCardNetSavingsLabel.
  ///
  /// In id, this message translates to:
  /// **'Tabungan Bersih'**
  String get incomeExpenseRatioCardNetSavingsLabel;

  /// No description provided for @incomeExpenseRatioCardExpenseRatioLabel.
  ///
  /// In id, this message translates to:
  /// **'Rasio Pengeluaran'**
  String get incomeExpenseRatioCardExpenseRatioLabel;

  /// No description provided for @categoryBreakdownCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Proporsi Pengeluaran per Kategori'**
  String get categoryBreakdownCardTitle;

  /// No description provided for @categoryBreakdownCardTotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total: {amount}'**
  String categoryBreakdownCardTotalLabel(String amount);

  /// No description provided for @categoryBreakdownCardShowPieTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan diagram lingkaran (Pie)'**
  String get categoryBreakdownCardShowPieTooltip;

  /// No description provided for @categoryBreakdownCardShowBarTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan diagram batang (Bar)'**
  String get categoryBreakdownCardShowBarTooltip;

  /// No description provided for @categoryBreakdownCardEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pengeluaran tercatat pada periode ini.'**
  String get categoryBreakdownCardEmptyMessage;

  /// No description provided for @categoryBreakdownCardTransactionCountLabel.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String categoryBreakdownCardTransactionCountLabel(int count);

  /// No description provided for @monthOverMonthSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Tren Bulan-ke-Bulan (MoM)'**
  String get monthOverMonthSectionTitle;

  /// No description provided for @monthOverMonthSectionComparisonLabel.
  ///
  /// In id, this message translates to:
  /// **'{currMonth} vs {prevMonth}'**
  String monthOverMonthSectionComparisonLabel(
    String currMonth,
    String prevMonth,
  );

  /// No description provided for @monthOverMonthSectionLastMonthLegend.
  ///
  /// In id, this message translates to:
  /// **'Bulan Lalu'**
  String get monthOverMonthSectionLastMonthLegend;

  /// No description provided for @monthOverMonthSectionThisMonthLegend.
  ///
  /// In id, this message translates to:
  /// **'Bulan Ini'**
  String get monthOverMonthSectionThisMonthLegend;

  /// No description provided for @monthOverMonthSectionEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum cukup data transaksi untuk perbandingan bulan-ke-bulan.'**
  String get monthOverMonthSectionEmptyMessage;

  /// No description provided for @monthOverMonthSectionCategoryComparisonTitle.
  ///
  /// In id, this message translates to:
  /// **'Perbandingan Pengeluaran per Kategori'**
  String get monthOverMonthSectionCategoryComparisonTitle;

  /// No description provided for @monthOverMonthSectionTooltipLabel.
  ///
  /// In id, this message translates to:
  /// **'{categoryName} ({period})\n{amount}'**
  String monthOverMonthSectionTooltipLabel(
    String categoryName,
    String period,
    String amount,
  );

  /// No description provided for @monthOverMonthSectionExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get monthOverMonthSectionExpenseLabel;

  /// No description provided for @monthOverMonthSectionIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get monthOverMonthSectionIncomeLabel;

  /// No description provided for @monthOverMonthSectionNewBadge.
  ///
  /// In id, this message translates to:
  /// **'Baru'**
  String get monthOverMonthSectionNewBadge;

  /// No description provided for @monthOverMonthSectionPreviousAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Lalu: {amount}'**
  String monthOverMonthSectionPreviousAmountLabel(String amount);

  /// No description provided for @walletsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola Dompet'**
  String get walletsScreenTitle;

  /// No description provided for @walletsScreenTransferTooltip.
  ///
  /// In id, this message translates to:
  /// **'Transfer Antar Dompet'**
  String get walletsScreenTransferTooltip;

  /// No description provided for @walletsScreenTotalBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Saldo (Kekayaan Bersih)'**
  String get walletsScreenTotalBalanceLabel;

  /// No description provided for @walletsScreenTotalBalanceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Total akumulasi dari {count} dompet & rekening aktif.'**
  String walletsScreenTotalBalanceSubtitle(int count);

  /// No description provided for @walletsScreenTransferButton.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get walletsScreenTransferButton;

  /// No description provided for @walletsScreenAddButton.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get walletsScreenAddButton;

  /// No description provided for @walletsScreenListTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Dompet ({count})'**
  String walletsScreenListTitle(int count);

  /// No description provided for @walletsScreenEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada dompet terdaftar.'**
  String get walletsScreenEmptyTitle;

  /// No description provided for @walletsScreenEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan dompet pertamamu untuk mulai mencatat.'**
  String get walletsScreenEmptyMessage;

  /// No description provided for @walletsScreenLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat daftar dompet: {error}'**
  String walletsScreenLoadError(Object error);

  /// No description provided for @walletsScreenDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Dompet?'**
  String get walletsScreenDeleteDialogTitle;

  /// No description provided for @walletsScreenDeleteDialogMessage.
  ///
  /// In id, this message translates to:
  /// **'Apakah kamu yakin ingin menghapus dompet \"{name}\"?\n\nCatatan: Dompet tidak dapat dihapus jika masih memiliki transaksi atau transfer terkait.'**
  String walletsScreenDeleteDialogMessage(String name);

  /// No description provided for @walletsScreenCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get walletsScreenCancelButton;

  /// No description provided for @walletsScreenDeleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get walletsScreenDeleteButton;

  /// No description provided for @walletsScreenDeleteSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Dompet \"{name}\" berhasil dihapus.'**
  String walletsScreenDeleteSuccessToast(String name);

  /// No description provided for @walletsScreenDeleteRejectedTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Ditolak'**
  String get walletsScreenDeleteRejectedTitle;

  /// No description provided for @walletsScreenDeleteFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Gagal Menghapus Dompet'**
  String get walletsScreenDeleteFailedTitle;

  /// No description provided for @walletsScreenUnderstoodButton.
  ///
  /// In id, this message translates to:
  /// **'Mengerti'**
  String get walletsScreenUnderstoodButton;

  /// No description provided for @walletCardIncludedInBudgetBadge.
  ///
  /// In id, this message translates to:
  /// **'Ikut Budget Harian'**
  String get walletCardIncludedInBudgetBadge;

  /// No description provided for @walletCardExcludedFromBudgetBadge.
  ///
  /// In id, this message translates to:
  /// **'Di luar Budget'**
  String get walletCardExcludedFromBudgetBadge;

  /// No description provided for @walletCardCurrentBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo saat ini'**
  String get walletCardCurrentBalanceLabel;

  /// No description provided for @walletCardTransferMenuItem.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get walletCardTransferMenuItem;

  /// No description provided for @walletCardEditMenuItem.
  ///
  /// In id, this message translates to:
  /// **'Edit Dompet'**
  String get walletCardEditMenuItem;

  /// No description provided for @walletCardDeleteMenuItem.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get walletCardDeleteMenuItem;

  /// No description provided for @walletFormScreenEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Dompet'**
  String get walletFormScreenEditTitle;

  /// No description provided for @walletFormScreenAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Dompet'**
  String get walletFormScreenAddTitle;

  /// No description provided for @walletFormScreenNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Dompet'**
  String get walletFormScreenNameLabel;

  /// No description provided for @walletFormScreenNameHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: BCA, Tunai, Gopay, Bibit'**
  String get walletFormScreenNameHint;

  /// No description provided for @walletFormScreenNameRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Nama dompet tidak boleh kosong'**
  String get walletFormScreenNameRequiredError;

  /// No description provided for @walletFormScreenIconPickerLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih Ikon'**
  String get walletFormScreenIconPickerLabel;

  /// No description provided for @walletFormScreenStartingBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo Awal'**
  String get walletFormScreenStartingBalanceLabel;

  /// No description provided for @walletFormScreenStartingBalanceHelper.
  ///
  /// In id, this message translates to:
  /// **'Saldo saat dompet pertama kali dibuat/dihitung (whole Rupiah).'**
  String get walletFormScreenStartingBalanceHelper;

  /// No description provided for @walletFormScreenStartingBalanceNegativeError.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal tidak boleh negatif'**
  String get walletFormScreenStartingBalanceNegativeError;

  /// No description provided for @walletFormScreenIncludeBudgetToggleTitle.
  ///
  /// In id, this message translates to:
  /// **'Hitung dalam Budget Harian'**
  String get walletFormScreenIncludeBudgetToggleTitle;

  /// No description provided for @walletFormScreenIncludeBudgetToggleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Jika aktif, transaksi di dompet ini akan memengaruhi sisa uang jajan harianmu. Matikan untuk dompet tabungan/investasi.'**
  String get walletFormScreenIncludeBudgetToggleSubtitle;

  /// No description provided for @walletFormScreenSaveSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Dompet berhasil disimpan'**
  String get walletFormScreenSaveSuccessToast;

  /// No description provided for @walletFormScreenSaveChangesButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get walletFormScreenSaveChangesButton;

  /// No description provided for @walletFormScreenCreateButton.
  ///
  /// In id, this message translates to:
  /// **'Buat Dompet'**
  String get walletFormScreenCreateButton;

  /// No description provided for @transferFormScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer Antar Dompet'**
  String get transferFormScreenTitle;

  /// No description provided for @transferFormScreenMissingWalletsError.
  ///
  /// In id, this message translates to:
  /// **'Pilih dompet asal dan tujuan transfer.'**
  String get transferFormScreenMissingWalletsError;

  /// No description provided for @transferFormScreenSameWalletError.
  ///
  /// In id, this message translates to:
  /// **'Dompet asal dan tujuan tidak boleh sama.'**
  String get transferFormScreenSameWalletError;

  /// No description provided for @transferFormScreenZeroAmountError.
  ///
  /// In id, this message translates to:
  /// **'Nominal transfer harus lebih besar dari nol.'**
  String get transferFormScreenZeroAmountError;

  /// No description provided for @transferFormScreenSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Transfer {amount} berhasil diproses'**
  String transferFormScreenSuccessToast(String amount);

  /// No description provided for @transferFormScreenNeedMoreWalletsTitle.
  ///
  /// In id, this message translates to:
  /// **'Butuh minimal 2 dompet untuk melakukan transfer.'**
  String get transferFormScreenNeedMoreWalletsTitle;

  /// No description provided for @transferFormScreenNeedMoreWalletsMessage.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan dompet lain terlebih dahulu di menu Kelola Dompet.'**
  String get transferFormScreenNeedMoreWalletsMessage;

  /// No description provided for @transferFormScreenSourceWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Dari Dompet (Sumber)'**
  String get transferFormScreenSourceWalletLabel;

  /// No description provided for @transferFormScreenTargetWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Ke Dompet (Tujuan)'**
  String get transferFormScreenTargetWalletLabel;

  /// No description provided for @transferFormScreenAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal Transfer'**
  String get transferFormScreenAmountLabel;

  /// No description provided for @transferFormScreenAmountZeroError.
  ///
  /// In id, this message translates to:
  /// **'Nominal transfer harus lebih besar dari nol'**
  String get transferFormScreenAmountZeroError;

  /// No description provided for @transferFormScreenDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Transfer'**
  String get transferFormScreenDateLabel;

  /// No description provided for @transferFormScreenNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (Opsional)'**
  String get transferFormScreenNotesLabel;

  /// No description provided for @transferFormScreenNotesHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: Tarik tunai dari ATM, Top up GoPay'**
  String get transferFormScreenNotesHint;

  /// No description provided for @transferFormScreenSubmitButton.
  ///
  /// In id, this message translates to:
  /// **'Transfer Sekarang'**
  String get transferFormScreenSubmitButton;

  /// No description provided for @transferFormScreenLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat dompet: {error}'**
  String transferFormScreenLoadError(Object error);

  /// No description provided for @transactionsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Transaksi'**
  String get transactionsScreenTitle;

  /// No description provided for @transactionsScreenEmptyFilterMessage.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi untuk filter ini.'**
  String get transactionsScreenEmptyFilterMessage;

  /// No description provided for @transactionsScreenLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat transaksi: {error}'**
  String transactionsScreenLoadError(Object error);

  /// No description provided for @transactionsScreenEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Transaksi'**
  String get transactionsScreenEmptyTitle;

  /// No description provided for @transactionsScreenEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Catat pengeluaran atau pemasukan pertamamu dengan tombol di bawah.'**
  String get transactionsScreenEmptyMessage;

  /// No description provided for @transactionsScreenEmptyAddButton.
  ///
  /// In id, this message translates to:
  /// **'Tambah Transaksi Pertama'**
  String get transactionsScreenEmptyAddButton;

  /// No description provided for @transactionsScreenFilterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get transactionsScreenFilterAll;

  /// No description provided for @transactionsScreenFilterIncome.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get transactionsScreenFilterIncome;

  /// No description provided for @transactionsScreenFilterExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get transactionsScreenFilterExpense;

  /// No description provided for @transactionFormScreenEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Transaksi'**
  String get transactionFormScreenEditTitle;

  /// No description provided for @transactionFormScreenAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get transactionFormScreenAddTitle;

  /// No description provided for @transactionFormScreenTransferAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'NOMINAL TRANSFER'**
  String get transactionFormScreenTransferAmountLabel;

  /// No description provided for @transactionFormScreenAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'JUMLAH'**
  String get transactionFormScreenAmountLabel;

  /// No description provided for @transactionFormScreenAmountEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh kosong'**
  String get transactionFormScreenAmountEmptyError;

  /// No description provided for @transactionFormScreenAmountInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh nol atau negatif'**
  String get transactionFormScreenAmountInvalidError;

  /// No description provided for @transactionFormScreenSourceWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Dari Dompet (Sumber)'**
  String get transactionFormScreenSourceWalletLabel;

  /// No description provided for @transactionFormScreenTargetWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Ke Dompet (Tujuan)'**
  String get transactionFormScreenTargetWalletLabel;

  /// No description provided for @transactionFormScreenSourceWalletLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat dompet: {error}'**
  String transactionFormScreenSourceWalletLoadError(Object error);

  /// No description provided for @transactionFormScreenTargetWalletLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat dompet tujuan: {error}'**
  String transactionFormScreenTargetWalletLoadError(Object error);

  /// No description provided for @transactionFormScreenWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Dompet'**
  String get transactionFormScreenWalletLabel;

  /// No description provided for @transactionFormScreenCategoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get transactionFormScreenCategoryLabel;

  /// No description provided for @transactionFormScreenCategoryLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kategori: {error}'**
  String transactionFormScreenCategoryLoadError(Object error);

  /// No description provided for @transactionFormScreenDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get transactionFormScreenDateLabel;

  /// No description provided for @transactionFormScreenNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get transactionFormScreenNotesLabel;

  /// No description provided for @transactionFormScreenSaveSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil disimpan'**
  String get transactionFormScreenSaveSuccessToast;

  /// No description provided for @transactionFormScreenSaveChangesButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get transactionFormScreenSaveChangesButton;

  /// No description provided for @transactionFormScreenSaveNewButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Transaksi'**
  String get transactionFormScreenSaveNewButton;

  /// No description provided for @transactionFormScreenDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Transaksi?'**
  String get transactionFormScreenDeleteDialogTitle;

  /// No description provided for @transactionFormScreenDeleteDialogMessage.
  ///
  /// In id, this message translates to:
  /// **'Apakah kamu yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.'**
  String get transactionFormScreenDeleteDialogMessage;

  /// No description provided for @transactionFormScreenCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get transactionFormScreenCancelButton;

  /// No description provided for @transactionFormScreenDeleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get transactionFormScreenDeleteButton;

  /// No description provided for @transactionFormScreenDeleteTransactionButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus Transaksi'**
  String get transactionFormScreenDeleteTransactionButton;

  /// No description provided for @transactionFormScreenDeleteLockedButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus Transaksi (Terkunci)'**
  String get transactionFormScreenDeleteLockedButton;

  /// No description provided for @transactionFormScreenDeleteLockedNotice.
  ///
  /// In id, this message translates to:
  /// **'Hanya transaksi bertanggal hari ini yang dapat dihapus. Transaksi lampau tidak dapat dihapus untuk menjaga integritas histori.'**
  String get transactionFormScreenDeleteLockedNotice;

  /// No description provided for @transactionFormScreenTypeExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get transactionFormScreenTypeExpenseLabel;

  /// No description provided for @transactionFormScreenTypeIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get transactionFormScreenTypeIncomeLabel;

  /// No description provided for @transactionFormScreenTypeTransferLabel.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get transactionFormScreenTypeTransferLabel;

  /// No description provided for @transactionFormScreenInvalidTransferError.
  ///
  /// In id, this message translates to:
  /// **'Mohon masukkan nominal dan pilih dompet asal & tujuan yang berbeda.'**
  String get transactionFormScreenInvalidTransferError;

  /// No description provided for @transactionFormScreenInvalidRegularError.
  ///
  /// In id, this message translates to:
  /// **'Mohon masukkan jumlah dan pilih kategori.'**
  String get transactionFormScreenInvalidRegularError;

  /// No description provided for @homeScreenLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat budget: {error}'**
  String homeScreenLoadError(Object error);

  /// No description provided for @homeScreenModePeriodicBadge.
  ///
  /// In id, this message translates to:
  /// **'Mode Periodik'**
  String get homeScreenModePeriodicBadge;

  /// No description provided for @homeScreenModeDailyBadge.
  ///
  /// In id, this message translates to:
  /// **'Mode Harian (Bekel)'**
  String get homeScreenModeDailyBadge;

  /// No description provided for @homeScreenTotalSaldoLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Saldo'**
  String get homeScreenTotalSaldoLabel;

  /// No description provided for @homeScreenDailyAllowanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Jatah Hari Ini'**
  String get homeScreenDailyAllowanceLabel;

  /// No description provided for @homeScreenSubtitleRemainingDays.
  ///
  /// In id, this message translates to:
  /// **'Sisa {days} hari sampai jadwal payday berikutnya'**
  String homeScreenSubtitleRemainingDays(int days);

  /// No description provided for @homeScreenSubtitleCarryOver.
  ///
  /// In id, this message translates to:
  /// **'Akumulasi carry-over kemarin & bekel hari ini'**
  String get homeScreenSubtitleCarryOver;

  /// No description provided for @homeScreenCycleExpiredPeriodicTitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gajian Berakhir'**
  String get homeScreenCycleExpiredPeriodicTitle;

  /// No description provided for @homeScreenCycleExpiredDailyTitle.
  ///
  /// In id, this message translates to:
  /// **'Rollover Harian Dibutuhkan'**
  String get homeScreenCycleExpiredDailyTitle;

  /// No description provided for @homeScreenCycleExpiredPeriodicMessage.
  ///
  /// In id, this message translates to:
  /// **'Jadwal gajian telah tercapai. Mulai siklus baru untuk memperbarui Uang Jajan Aman.'**
  String get homeScreenCycleExpiredPeriodicMessage;

  /// No description provided for @homeScreenCycleExpiredDailyMessage.
  ///
  /// In id, this message translates to:
  /// **'Hari baru telah tiba. Konfirmasi carry-over saldo untuk memulai hari ini.'**
  String get homeScreenCycleExpiredDailyMessage;

  /// No description provided for @homeScreenStartNewCycleButton.
  ///
  /// In id, this message translates to:
  /// **'Mulai Siklus Baru'**
  String get homeScreenStartNewCycleButton;

  /// No description provided for @homeScreenRolloverTodayButton.
  ///
  /// In id, this message translates to:
  /// **'Rollover Hari Ini'**
  String get homeScreenRolloverTodayButton;

  /// No description provided for @homeScreenBreakdownTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian Perhitungan'**
  String get homeScreenBreakdownTitle;

  /// No description provided for @homeScreenRemainingCycleBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Sisa Saldo Siklus'**
  String get homeScreenRemainingCycleBalanceLabel;

  /// No description provided for @homeScreenGrossDailyAllowanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Jatah Kotor / Hari'**
  String get homeScreenGrossDailyAllowanceLabel;

  /// No description provided for @homeScreenGoalSavingsDailyLabel.
  ///
  /// In id, this message translates to:
  /// **'Tabungan Goal / Hari'**
  String get homeScreenGoalSavingsDailyLabel;

  /// No description provided for @homeScreenYesterdayCarryOverLabel.
  ///
  /// In id, this message translates to:
  /// **'Saldo Carry-Over Kemarin'**
  String get homeScreenYesterdayCarryOverLabel;

  /// No description provided for @homeScreenTodayAllowanceInLabel.
  ///
  /// In id, this message translates to:
  /// **'Bekel Masuk Hari Ini'**
  String get homeScreenTodayAllowanceInLabel;

  /// No description provided for @homeScreenMandatoryExpenseTodayLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Wajib Hari Ini'**
  String get homeScreenMandatoryExpenseTodayLabel;

  /// No description provided for @homeScreenRecordedExpenseTodayLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Dicatat Hari Ini'**
  String get homeScreenRecordedExpenseTodayLabel;

  /// No description provided for @homeScreenTransactionSummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian Transaksi'**
  String get homeScreenTransactionSummaryTitle;

  /// No description provided for @homeScreenViewAllLink.
  ///
  /// In id, this message translates to:
  /// **'Lihat Selengkapnya'**
  String get homeScreenViewAllLink;

  /// No description provided for @homeScreenTransactionSummaryLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat ringkasan transaksi.'**
  String get homeScreenTransactionSummaryLoadError;

  /// No description provided for @homeScreenNoTransactionsYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi tercatat.'**
  String get homeScreenNoTransactionsYet;

  /// No description provided for @homeScreenIncomeColumnLabel.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get homeScreenIncomeColumnLabel;

  /// No description provided for @homeScreenExpenseColumnLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get homeScreenExpenseColumnLabel;

  /// No description provided for @homeScreenNoneYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada'**
  String get homeScreenNoneYet;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsScreenTitle;

  /// No description provided for @settingsScreenPreferencesTitle.
  ///
  /// In id, this message translates to:
  /// **'Tampilan & Bahasa'**
  String get settingsScreenPreferencesTitle;

  /// No description provided for @settingsScreenPreferencesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kustomisasi tema dan bahasa antarmuka'**
  String get settingsScreenPreferencesSubtitle;

  /// No description provided for @settingsScreenDarkModeTitle.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap (Dark Mode)'**
  String get settingsScreenDarkModeTitle;

  /// No description provided for @settingsScreenDarkModeActiveSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tema gelap aktif (rekomendasi OLED)'**
  String get settingsScreenDarkModeActiveSubtitle;

  /// No description provided for @settingsScreenLightModeActiveSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tema terang aktif'**
  String get settingsScreenLightModeActiveSubtitle;

  /// No description provided for @settingsScreenLanguageTitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Aplikasi'**
  String get settingsScreenLanguageTitle;

  /// No description provided for @settingsScreenLanguageIndonesianActiveSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia (Aktif)'**
  String get settingsScreenLanguageIndonesianActiveSubtitle;

  /// No description provided for @settingsScreenLanguageEnglishActiveSubtitle.
  ///
  /// In id, this message translates to:
  /// **'English (Active)'**
  String get settingsScreenLanguageEnglishActiveSubtitle;

  /// No description provided for @settingsScreenLanguageIndonesianOption.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get settingsScreenLanguageIndonesianOption;

  /// No description provided for @settingsScreenLanguageEnglishOption.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get settingsScreenLanguageEnglishOption;

  /// No description provided for @settingsScreenNotificationsTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi & Pengingat'**
  String get settingsScreenNotificationsTitle;

  /// No description provided for @settingsScreenNotificationsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'100% Offline via Alarm Manager lokal'**
  String get settingsScreenNotificationsSubtitle;

  /// No description provided for @settingsScreenDailyReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Catat Harian'**
  String get settingsScreenDailyReminderTitle;

  /// No description provided for @settingsScreenDailyReminderSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Setiap hari pukul {time} WIB (ketuk jam untuk mengubah)'**
  String settingsScreenDailyReminderSubtitle(String time);

  /// No description provided for @settingsScreenChangeTimeButton.
  ///
  /// In id, this message translates to:
  /// **'Ubah Jam ({time})'**
  String settingsScreenChangeTimeButton(String time);

  /// No description provided for @settingsScreenLimitAlertTitle.
  ///
  /// In id, this message translates to:
  /// **'Peringatan Limit Anggaran'**
  String get settingsScreenLimitAlertTitle;

  /// No description provided for @settingsScreenLimitAlertSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pemberitahuan real-time saat uang jajan aman hari ini mendekati 0 atau minus.'**
  String get settingsScreenLimitAlertSubtitle;

  /// No description provided for @settingsScreenPayCycleTitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gajian Baru'**
  String get settingsScreenPayCycleTitle;

  /// No description provided for @settingsScreenPayCycleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pemberitahuan saat memasuki tanggal gajian atau siklus baru.'**
  String get settingsScreenPayCycleSubtitle;

  /// No description provided for @settingsScreenGoalMilestoneTitle.
  ///
  /// In id, this message translates to:
  /// **'Milestone Target Tabungan'**
  String get settingsScreenGoalMilestoneTitle;

  /// No description provided for @settingsScreenGoalMilestoneSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pemberitahuan saat progres goal mencapai 25%, 50%, 75%, dan 100%.'**
  String get settingsScreenGoalMilestoneSubtitle;

  /// No description provided for @settingsScreenAboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang LedgerMate'**
  String get settingsScreenAboutTitle;

  /// No description provided for @settingsScreenVersionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi {version}+{buildNumber} (100% Offline, Tanpa Server)'**
  String settingsScreenVersionLabel(String version, String buildNumber);

  /// No description provided for @settingsScreenVersionLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat versi...'**
  String get settingsScreenVersionLoading;

  /// No description provided for @settingsScreenVersionFallback.
  ///
  /// In id, this message translates to:
  /// **'100% Offline, Tanpa Server'**
  String get settingsScreenVersionFallback;

  /// No description provided for @settingsScreenAboutDescription.
  ///
  /// In id, this message translates to:
  /// **'LedgerMate adalah pelacak anggaran harian pintar berbasis offline-first. Seluruh data keuangan Anda tersimpan secara lokal di perangkat Anda menggunakan Isar Database.'**
  String get settingsScreenAboutDescription;

  /// No description provided for @categoryManagementCardAddDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kategori Baru'**
  String get categoryManagementCardAddDialogTitle;

  /// No description provided for @categoryManagementCardNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Kategori'**
  String get categoryManagementCardNameLabel;

  /// No description provided for @categoryManagementCardNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Investasi, Zakat, Liburan'**
  String get categoryManagementCardNameHint;

  /// No description provided for @categoryManagementCardCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get categoryManagementCardCancelButton;

  /// No description provided for @categoryManagementCardSaveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get categoryManagementCardSaveButton;

  /// No description provided for @categoryManagementCardEditDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Nama Kategori'**
  String get categoryManagementCardEditDialogTitle;

  /// No description provided for @categoryManagementCardDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Kategori?'**
  String get categoryManagementCardDeleteDialogTitle;

  /// No description provided for @categoryManagementCardDeleteDialogMessage.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus kategori \"{name}\"?'**
  String categoryManagementCardDeleteDialogMessage(String name);

  /// No description provided for @categoryManagementCardDeleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get categoryManagementCardDeleteButton;

  /// No description provided for @categoryManagementCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get categoryManagementCardTitle;

  /// No description provided for @categoryManagementCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori bawaan & kustom untuk transaksi'**
  String get categoryManagementCardSubtitle;

  /// No description provided for @categoryManagementCardAddTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kategori'**
  String get categoryManagementCardAddTooltip;

  /// No description provided for @categoryManagementCardLoadingDefaults.
  ///
  /// In id, this message translates to:
  /// **'Memuat kategori default...'**
  String get categoryManagementCardLoadingDefaults;

  /// No description provided for @categoryManagementCardDefaultBadge.
  ///
  /// In id, this message translates to:
  /// **'Bawaan'**
  String get categoryManagementCardDefaultBadge;

  /// No description provided for @categoryManagementCardEditTooltip.
  ///
  /// In id, this message translates to:
  /// **'Ubah Nama'**
  String get categoryManagementCardEditTooltip;

  /// No description provided for @categoryManagementCardDeleteTooltip.
  ///
  /// In id, this message translates to:
  /// **'Hapus Kategori'**
  String get categoryManagementCardDeleteTooltip;

  /// No description provided for @categoryManagementCardLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kategori: {error}'**
  String categoryManagementCardLoadError(Object error);

  /// No description provided for @mandatoryExpensesCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Wajib'**
  String get mandatoryExpensesCardTitle;

  /// No description provided for @mandatoryExpensesCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran tetap & rutin untuk alokasi anggaran'**
  String get mandatoryExpensesCardSubtitle;

  /// No description provided for @mandatoryExpensesCardAddTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tambah Pengeluaran Wajib'**
  String get mandatoryExpensesCardAddTooltip;

  /// No description provided for @mandatoryExpensesCardEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran wajib ditambahkan.'**
  String get mandatoryExpensesCardEmptyMessage;

  /// No description provided for @mandatoryExpensesCardAddDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Pengeluaran Wajib'**
  String get mandatoryExpensesCardAddDialogTitle;

  /// No description provided for @mandatoryExpensesCardEditDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Pengeluaran Wajib'**
  String get mandatoryExpensesCardEditDialogTitle;

  /// No description provided for @mandatoryExpensesCardDeleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Pengeluaran Wajib?'**
  String get mandatoryExpensesCardDeleteDialogTitle;

  /// No description provided for @mandatoryExpensesCardDeleteDialogMessage.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus \"{name}\"?'**
  String mandatoryExpensesCardDeleteDialogMessage(String name);

  /// No description provided for @mandatoryExpensesCardDeleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get mandatoryExpensesCardDeleteButton;

  /// No description provided for @mandatoryExpensesCardCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get mandatoryExpensesCardCancelButton;

  /// No description provided for @mandatoryExpensesCardSaveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get mandatoryExpensesCardSaveButton;

  /// No description provided for @mandatoryExpensesCardNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Pengeluaran'**
  String get mandatoryExpensesCardNameLabel;

  /// No description provided for @mandatoryExpensesCardNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Sewa Kos, Listrik, Wi-Fi'**
  String get mandatoryExpensesCardNameHint;

  /// No description provided for @mandatoryExpensesCardAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get mandatoryExpensesCardAmountLabel;

  /// No description provided for @mandatoryExpensesCardEditTooltip.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get mandatoryExpensesCardEditTooltip;

  /// No description provided for @mandatoryExpensesCardDeleteTooltip.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get mandatoryExpensesCardDeleteTooltip;

  /// No description provided for @mandatoryExpensesCardNameEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nama tidak boleh kosong'**
  String get mandatoryExpensesCardNameEmptyError;

  /// No description provided for @mandatoryExpensesCardAmountEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh kosong'**
  String get mandatoryExpensesCardAmountEmptyError;

  /// No description provided for @mandatoryExpensesCardAmountInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh negatif atau nol'**
  String get mandatoryExpensesCardAmountInvalidError;

  /// No description provided for @walletsManagementCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola Dompet & Rekening'**
  String get walletsManagementCardTitle;

  /// No description provided for @walletsManagementCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Atur dompet, rekening bank, saldo awal & transfer'**
  String get walletsManagementCardSubtitle;

  /// No description provided for @walletsManagementCardOpenTooltip.
  ///
  /// In id, this message translates to:
  /// **'Buka Kelola Dompet'**
  String get walletsManagementCardOpenTooltip;

  /// No description provided for @dataManagementCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan & Pulihkan Data'**
  String get dataManagementCardTitle;

  /// No description provided for @dataManagementCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Format JSON & CSV (100% Offline, FR-08)'**
  String get dataManagementCardSubtitle;

  /// No description provided for @dataManagementCardDescription.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan seluruh database secara berkala atau pindahkan data finansial ke perangkat baru tanpa koneksi server.'**
  String get dataManagementCardDescription;

  /// No description provided for @dataManagementCardProcessingMessage.
  ///
  /// In id, this message translates to:
  /// **'Sedang memproses data...'**
  String get dataManagementCardProcessingMessage;

  /// No description provided for @dataManagementCardExportSuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Berhasil!'**
  String get dataManagementCardExportSuccessTitle;

  /// No description provided for @dataManagementCardExportJsonTitle.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan Database (JSON)'**
  String get dataManagementCardExportJsonTitle;

  /// No description provided for @dataManagementCardExportJsonSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan semua koleksi (profil, gajian, kategori, transaksi, goals, aset) ke file JSON.'**
  String get dataManagementCardExportJsonSubtitle;

  /// No description provided for @dataManagementCardExportJsonButton.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan (JSON)'**
  String get dataManagementCardExportJsonButton;

  /// No description provided for @dataManagementCardExportJsonSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'File cadangan tersimpan di:\n{path}'**
  String dataManagementCardExportJsonSuccessToast(String path);

  /// No description provided for @dataManagementCardExportCsvTitle.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Riwayat Transaksi (CSV)'**
  String get dataManagementCardExportCsvTitle;

  /// No description provided for @dataManagementCardExportCsvSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Format tabel CSV RFC 4180 dengan header berbahasa Indonesia untuk spreadsheet.'**
  String get dataManagementCardExportCsvSubtitle;

  /// No description provided for @dataManagementCardExportCsvButton.
  ///
  /// In id, this message translates to:
  /// **'Ekspor CSV'**
  String get dataManagementCardExportCsvButton;

  /// No description provided for @dataManagementCardExportCsvSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Tabel transaksi CSV tersimpan di:\n{path}'**
  String dataManagementCardExportCsvSuccessToast(String path);

  /// No description provided for @dataManagementCardRestoreTitle.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan Data (JSON)'**
  String get dataManagementCardRestoreTitle;

  /// No description provided for @dataManagementCardRestoreSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih file .json cadangan untuk mengembalikan seluruh database ke kondisi tersimpan.'**
  String get dataManagementCardRestoreSubtitle;

  /// No description provided for @dataManagementCardRestoreButton.
  ///
  /// In id, this message translates to:
  /// **'Pilih File Cadangan'**
  String get dataManagementCardRestoreButton;

  /// No description provided for @dataManagementCardRestoreSuccessToast.
  ///
  /// In id, this message translates to:
  /// **'Database lokal berhasil dipulihkan dari cadangan.'**
  String get dataManagementCardRestoreSuccessToast;

  /// No description provided for @restoreConfirmationDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Pemulihan Data'**
  String get restoreConfirmationDialogTitle;

  /// No description provided for @restoreConfirmationDialogWarningMessage.
  ///
  /// In id, this message translates to:
  /// **'PERHATIAN: Pemulihan akan menghapus dan menimpa SELURUH data lokal saat ini. Tindakan ini tidak dapat dibatalkan.'**
  String get restoreConfirmationDialogWarningMessage;

  /// No description provided for @restoreConfirmationDialogSummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Data Cadangan:'**
  String get restoreConfirmationDialogSummaryTitle;

  /// No description provided for @restoreConfirmationDialogBackupTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Waktu Cadangan'**
  String get restoreConfirmationDialogBackupTimeLabel;

  /// No description provided for @restoreConfirmationDialogUserProfileLabel.
  ///
  /// In id, this message translates to:
  /// **'Profil Pengguna'**
  String get restoreConfirmationDialogUserProfileLabel;

  /// No description provided for @restoreConfirmationDialogAvailableValue.
  ///
  /// In id, this message translates to:
  /// **'Tersedia'**
  String get restoreConfirmationDialogAvailableValue;

  /// No description provided for @restoreConfirmationDialogNotAvailableValue.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada'**
  String get restoreConfirmationDialogNotAvailableValue;

  /// No description provided for @restoreConfirmationDialogPayCycleLabel.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gaji'**
  String get restoreConfirmationDialogPayCycleLabel;

  /// No description provided for @restoreConfirmationDialogPayCycleCountValue.
  ///
  /// In id, this message translates to:
  /// **'{count} data'**
  String restoreConfirmationDialogPayCycleCountValue(int count);

  /// No description provided for @restoreConfirmationDialogCategoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get restoreConfirmationDialogCategoryLabel;

  /// No description provided for @restoreConfirmationDialogCategoryCountValue.
  ///
  /// In id, this message translates to:
  /// **'{count} kategori'**
  String restoreConfirmationDialogCategoryCountValue(int count);

  /// No description provided for @restoreConfirmationDialogTransactionLabel.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Transaksi'**
  String get restoreConfirmationDialogTransactionLabel;

  /// No description provided for @restoreConfirmationDialogTransactionCountValue.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String restoreConfirmationDialogTransactionCountValue(int count);

  /// No description provided for @restoreConfirmationDialogGoalLabel.
  ///
  /// In id, this message translates to:
  /// **'Target Finansial (Goals)'**
  String get restoreConfirmationDialogGoalLabel;

  /// No description provided for @restoreConfirmationDialogGoalCountValue.
  ///
  /// In id, this message translates to:
  /// **'{count} target'**
  String restoreConfirmationDialogGoalCountValue(int count);

  /// No description provided for @restoreConfirmationDialogAssetLabel.
  ///
  /// In id, this message translates to:
  /// **'Aset / Investasi'**
  String get restoreConfirmationDialogAssetLabel;

  /// No description provided for @restoreConfirmationDialogAssetCountValue.
  ///
  /// In id, this message translates to:
  /// **'{count} aset'**
  String restoreConfirmationDialogAssetCountValue(int count);

  /// No description provided for @restoreConfirmationDialogCancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get restoreConfirmationDialogCancelButton;

  /// No description provided for @restoreConfirmationDialogConfirmButton.
  ///
  /// In id, this message translates to:
  /// **'Timpa & Pulihkan'**
  String get restoreConfirmationDialogConfirmButton;

  /// No description provided for @payCycleTransitionScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Transisi Siklus'**
  String get payCycleTransitionScreenTitle;

  /// No description provided for @payCycleTransitionScreenLoadProfileError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat profil: {error}'**
  String payCycleTransitionScreenLoadProfileError(Object error);

  /// No description provided for @payCycleTransitionScreenProfileNotFound.
  ///
  /// In id, this message translates to:
  /// **'Profil tidak ditemukan.'**
  String get payCycleTransitionScreenProfileNotFound;

  /// No description provided for @payCycleTransitionScreenSalaryEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Gaji siklus baru tidak boleh kosong'**
  String get payCycleTransitionScreenSalaryEmptyError;

  /// No description provided for @payCycleTransitionScreenSalaryInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Gaji harus lebih besar dari nol'**
  String get payCycleTransitionScreenSalaryInvalidError;

  /// No description provided for @payCycleTransitionScreenExpenseNameEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nama pengeluaran tidak boleh kosong'**
  String get payCycleTransitionScreenExpenseNameEmptyError;

  /// No description provided for @payCycleTransitionScreenAmountEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tidak boleh kosong'**
  String get payCycleTransitionScreenAmountEmptyError;

  /// No description provided for @payCycleTransitionScreenAmountInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Jumlah harus lebih besar dari nol'**
  String get payCycleTransitionScreenAmountInvalidError;

  /// No description provided for @payCycleTransitionScreenIncompleteDataError.
  ///
  /// In id, this message translates to:
  /// **'Harap lengkapi semua data yang diperlukan.'**
  String get payCycleTransitionScreenIncompleteDataError;

  /// No description provided for @payCycleTransitionHeaderPeriodicTitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gajian Baru'**
  String get payCycleTransitionHeaderPeriodicTitle;

  /// No description provided for @payCycleTransitionHeaderDailyTitle.
  ///
  /// In id, this message translates to:
  /// **'Rollover Harian'**
  String get payCycleTransitionHeaderDailyTitle;

  /// No description provided for @payCycleTransitionHeaderPeriodicMessage.
  ///
  /// In id, this message translates to:
  /// **'Siklus sebelumnya telah berakhir. Masukkan gaji dan pengeluaran wajib siklus baru secara manual (BR-02: tidak ada template otomatis).'**
  String get payCycleTransitionHeaderPeriodicMessage;

  /// No description provided for @payCycleTransitionHeaderDailyMessage.
  ///
  /// In id, this message translates to:
  /// **'Hari baru telah tiba. Konfirmasi sisa saldo kemarin dan masukkan bekel serta pengeluaran wajib hari ini (BR-02: re-input manual tiap periode).'**
  String get payCycleTransitionHeaderDailyMessage;

  /// No description provided for @payCycleTransitionIntervalDateTitle.
  ///
  /// In id, this message translates to:
  /// **'Interval & Tanggal Gajian Berikutnya'**
  String get payCycleTransitionIntervalDateTitle;

  /// No description provided for @payCycleTransitionPickPaydayButton.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal gajian'**
  String get payCycleTransitionPickPaydayButton;

  /// No description provided for @payCycleTransitionPaydaySelectedButton.
  ///
  /// In id, this message translates to:
  /// **'Gajian: {date}'**
  String payCycleTransitionPaydaySelectedButton(String date);

  /// No description provided for @payCycleTransitionIntervalWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get payCycleTransitionIntervalWeekly;

  /// No description provided for @payCycleTransitionIntervalBiweekly.
  ///
  /// In id, this message translates to:
  /// **'2 Mingguan'**
  String get payCycleTransitionIntervalBiweekly;

  /// No description provided for @payCycleTransitionIntervalMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get payCycleTransitionIntervalMonthly;

  /// No description provided for @payCycleTransitionIntervalCustom.
  ///
  /// In id, this message translates to:
  /// **'Custom'**
  String get payCycleTransitionIntervalCustom;

  /// No description provided for @payCycleTransitionSalaryLabel.
  ///
  /// In id, this message translates to:
  /// **'Gaji Siklus Ini (Wajib diisi)'**
  String get payCycleTransitionSalaryLabel;

  /// No description provided for @payCycleTransitionSalaryHelper.
  ///
  /// In id, this message translates to:
  /// **'Sesuai BR-02: masukkan nominal gaji baru secara manual.'**
  String get payCycleTransitionSalaryHelper;

  /// No description provided for @payCycleTransitionCarryOverTitle.
  ///
  /// In id, this message translates to:
  /// **'Saldo Carry-Over dari Kemarin'**
  String get payCycleTransitionCarryOverTitle;

  /// No description provided for @payCycleTransitionCarryOverMessage.
  ///
  /// In id, this message translates to:
  /// **'Sisa Uang Jajan Aman kemarin terakumulasi otomatis ke saldo hari ini.'**
  String get payCycleTransitionCarryOverMessage;

  /// No description provided for @payCycleTransitionBekelLabel.
  ///
  /// In id, this message translates to:
  /// **'Bekel Hari Ini (Opsional)'**
  String get payCycleTransitionBekelLabel;

  /// No description provided for @payCycleTransitionBekelHelper.
  ///
  /// In id, this message translates to:
  /// **'Kosongkan atau isi 0 jika hari ini tidak ada uang saku baru.'**
  String get payCycleTransitionBekelHelper;

  /// No description provided for @payCycleTransitionExpensesPeriodicTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Wajib Siklus Ini'**
  String get payCycleTransitionExpensesPeriodicTitle;

  /// No description provided for @payCycleTransitionExpensesDailyTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Wajib Hari Ini'**
  String get payCycleTransitionExpensesDailyTitle;

  /// No description provided for @payCycleTransitionExpensesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Opsional — per BR-02, daftar pengeluaran wajib diinput manual tiap periode (tidak dicopy dari siklus lama).'**
  String get payCycleTransitionExpensesSubtitle;

  /// No description provided for @payCycleTransitionExpensesEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran wajib ditambahkan.'**
  String get payCycleTransitionExpensesEmptyMessage;

  /// No description provided for @payCycleTransitionRemoveExpenseTooltip.
  ///
  /// In id, this message translates to:
  /// **'Hapus Pengeluaran'**
  String get payCycleTransitionRemoveExpenseTooltip;

  /// No description provided for @payCycleTransitionExpenseNameFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama pengeluaran (mis. Kos, Cicilan)'**
  String get payCycleTransitionExpenseNameFieldLabel;

  /// No description provided for @payCycleTransitionExpenseAmountFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal pengeluaran'**
  String get payCycleTransitionExpenseAmountFieldLabel;

  /// No description provided for @payCycleTransitionAddExpenseButton.
  ///
  /// In id, this message translates to:
  /// **'Tambah Pengeluaran Wajib'**
  String get payCycleTransitionAddExpenseButton;

  /// No description provided for @payCycleTransitionStartNewCycleButton.
  ///
  /// In id, this message translates to:
  /// **'Mulai Siklus Baru'**
  String get payCycleTransitionStartNewCycleButton;

  /// No description provided for @payCycleTransitionStartTodayButton.
  ///
  /// In id, this message translates to:
  /// **'Mulai Hari Ini'**
  String get payCycleTransitionStartTodayButton;

  /// No description provided for @currencyPrefix.
  ///
  /// In id, this message translates to:
  /// **'Rp '**
  String get currencyPrefix;

  /// No description provided for @currencyHintZero.
  ///
  /// In id, this message translates to:
  /// **'Rp 0'**
  String get currencyHintZero;

  /// No description provided for @notificationChannelDailyReminder.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Harian'**
  String get notificationChannelDailyReminder;

  /// No description provided for @notificationChannelDailyReminderDescription.
  ///
  /// In id, this message translates to:
  /// **'Pengingat harian untuk mencatat transaksi keuangan'**
  String get notificationChannelDailyReminderDescription;

  /// No description provided for @notificationDailyReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Saatnya Catat Keuangan!'**
  String get notificationDailyReminderTitle;

  /// No description provided for @notificationDailyReminderBody.
  ///
  /// In id, this message translates to:
  /// **'Jangan lupa mencatat pengeluaran dan pemasukan hari ini di LedgerMate.'**
  String get notificationDailyReminderBody;

  /// No description provided for @notificationChannelLimitAlert.
  ///
  /// In id, this message translates to:
  /// **'Peringatan Limit Anggaran'**
  String get notificationChannelLimitAlert;

  /// No description provided for @notificationChannelLimitAlertDescription.
  ///
  /// In id, this message translates to:
  /// **'Pemberitahuan saat budget harian habis atau mendekati 0'**
  String get notificationChannelLimitAlertDescription;

  /// No description provided for @notificationLimitAlertTitle.
  ///
  /// In id, this message translates to:
  /// **'Peringatan: Limit Harian Terlampaui!'**
  String get notificationLimitAlertTitle;

  /// No description provided for @notificationLimitAlertBody.
  ///
  /// In id, this message translates to:
  /// **'Uang jajan aman hari ini tersisa {amount}. Tahan pengeluaran non-esensial.'**
  String notificationLimitAlertBody(String amount);

  /// No description provided for @notificationChannelPayCycle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gajian'**
  String get notificationChannelPayCycle;

  /// No description provided for @notificationChannelPayCycleDescription.
  ///
  /// In id, this message translates to:
  /// **'Pemberitahuan awal atau berakhirnya siklus gajian'**
  String get notificationChannelPayCycleDescription;

  /// No description provided for @notificationChannelGoalMilestone.
  ///
  /// In id, this message translates to:
  /// **'Target Finansial (Goals)'**
  String get notificationChannelGoalMilestone;

  /// No description provided for @notificationChannelGoalMilestoneDescription.
  ///
  /// In id, this message translates to:
  /// **'Pemberitahuan pencapaian milestone target tabungan'**
  String get notificationChannelGoalMilestoneDescription;

  /// No description provided for @notificationGoalMilestoneTitle.
  ///
  /// In id, this message translates to:
  /// **'Milestone Target Tercapai! 🎉'**
  String get notificationGoalMilestoneTitle;

  /// No description provided for @notificationGoalMilestoneBody.
  ///
  /// In id, this message translates to:
  /// **'Target \"{goalName}\" telah mencapai {percent}%! Tetap konsisten menabung!'**
  String notificationGoalMilestoneBody(String goalName, int percent);

  /// No description provided for @notificationPayCyclePeriodicStartTitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Baru Dimulai'**
  String get notificationPayCyclePeriodicStartTitle;

  /// No description provided for @notificationPayCycleDailyStartTitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Harian Baru'**
  String get notificationPayCycleDailyStartTitle;

  /// No description provided for @notificationPayCyclePeriodicStartBody.
  ///
  /// In id, this message translates to:
  /// **'Siklus baru aktif hingga {day}/{month}/{year}. Budget harian telah disesuaikan.'**
  String notificationPayCyclePeriodicStartBody(int day, int month, int year);

  /// No description provided for @notificationPayCycleDailyStartBody.
  ///
  /// In id, this message translates to:
  /// **'Bekel harian telah dicatat. Uang jajan aman siap digunakan hari ini.'**
  String get notificationPayCycleDailyStartBody;

  /// No description provided for @notificationPayCycleExpiredTitle.
  ///
  /// In id, this message translates to:
  /// **'Siklus Gajian Telah Tiba!'**
  String get notificationPayCycleExpiredTitle;

  /// No description provided for @notificationPayCycleExpiredBody.
  ///
  /// In id, this message translates to:
  /// **'Waktunya perbarui gaji dan pengeluaran wajib untuk memulai siklus baru.'**
  String get notificationPayCycleExpiredBody;

  /// No description provided for @walletIconCash.
  ///
  /// In id, this message translates to:
  /// **'Dompet / Tunai'**
  String get walletIconCash;

  /// No description provided for @walletIconBank.
  ///
  /// In id, this message translates to:
  /// **'Bank / Rekening'**
  String get walletIconBank;

  /// No description provided for @walletIconCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu Debit / Kredit'**
  String get walletIconCard;

  /// No description provided for @walletIconEwallet.
  ///
  /// In id, this message translates to:
  /// **'E-Wallet'**
  String get walletIconEwallet;

  /// No description provided for @walletIconSavings.
  ///
  /// In id, this message translates to:
  /// **'Tabungan'**
  String get walletIconSavings;

  /// No description provided for @walletIconPayments.
  ///
  /// In id, this message translates to:
  /// **'Kas / Uang'**
  String get walletIconPayments;

  /// No description provided for @walletIconInvestment.
  ///
  /// In id, this message translates to:
  /// **'Investasi / Valas'**
  String get walletIconInvestment;

  /// No description provided for @walletIconBusiness.
  ///
  /// In id, this message translates to:
  /// **'Bisnis / Toko'**
  String get walletIconBusiness;

  /// No description provided for @defaultCategoryFood.
  ///
  /// In id, this message translates to:
  /// **'Makan'**
  String get defaultCategoryFood;

  /// No description provided for @defaultCategoryTransport.
  ///
  /// In id, this message translates to:
  /// **'Transport'**
  String get defaultCategoryTransport;

  /// No description provided for @defaultCategoryEntertainment.
  ///
  /// In id, this message translates to:
  /// **'Hiburan'**
  String get defaultCategoryEntertainment;

  /// No description provided for @defaultCategoryBills.
  ///
  /// In id, this message translates to:
  /// **'Tagihan'**
  String get defaultCategoryBills;

  /// No description provided for @defaultCategoryOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get defaultCategoryOther;

  /// No description provided for @transactionTypeTransferLabel.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get transactionTypeTransferLabel;

  /// No description provided for @transactionCategoryFallback.
  ///
  /// In id, this message translates to:
  /// **'Kategori #{id}'**
  String transactionCategoryFallback(int id);

  /// No description provided for @monthJanuary.
  ///
  /// In id, this message translates to:
  /// **'Januari'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In id, this message translates to:
  /// **'Februari'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In id, this message translates to:
  /// **'Maret'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In id, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In id, this message translates to:
  /// **'Mei'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In id, this message translates to:
  /// **'Juni'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In id, this message translates to:
  /// **'Juli'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In id, this message translates to:
  /// **'Agustus'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In id, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In id, this message translates to:
  /// **'Oktober'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In id, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In id, this message translates to:
  /// **'Desember'**
  String get monthDecember;

  /// No description provided for @analyticsDateRangeDaily.
  ///
  /// In id, this message translates to:
  /// **'{day} {month} {year}'**
  String analyticsDateRangeDaily(int day, String month, int year);

  /// No description provided for @analyticsDateRangeWeekly.
  ///
  /// In id, this message translates to:
  /// **'{startDay} {startMonth} - {endDay} {endMonth} {year}'**
  String analyticsDateRangeWeekly(
    int startDay,
    String startMonth,
    int endDay,
    String endMonth,
    int year,
  );

  /// No description provided for @analyticsDateRangeMonthly.
  ///
  /// In id, this message translates to:
  /// **'{month} {year}'**
  String analyticsDateRangeMonthly(String month, int year);

  /// No description provided for @analyticsCategoryFallback.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get analyticsCategoryFallback;

  /// No description provided for @assetValidationPurchaseValuePositive.
  ///
  /// In id, this message translates to:
  /// **'Nilai beli/modal awal harus lebih besar dari 0.'**
  String get assetValidationPurchaseValuePositive;

  /// No description provided for @assetValidationCurrentValueNotNegative.
  ///
  /// In id, this message translates to:
  /// **'Nilai sekarang tidak boleh negatif.'**
  String get assetValidationCurrentValueNotNegative;

  /// No description provided for @goalValidationNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama target tidak boleh kosong.'**
  String get goalValidationNameRequired;

  /// No description provided for @goalValidationTargetPositive.
  ///
  /// In id, this message translates to:
  /// **'Target nominal harus lebih besar dari 0.'**
  String get goalValidationTargetPositive;

  /// No description provided for @goalValidationCurrentNotNegative.
  ///
  /// In id, this message translates to:
  /// **'Saldo saat ini tidak boleh negatif.'**
  String get goalValidationCurrentNotNegative;

  /// No description provided for @goalValidationDailyAllocationPositive.
  ///
  /// In id, this message translates to:
  /// **'Alokasi harian manual harus lebih besar dari 0.'**
  String get goalValidationDailyAllocationPositive;

  /// No description provided for @goalValidationWithdrawPositive.
  ///
  /// In id, this message translates to:
  /// **'Nominal penarikan harus lebih besar dari 0.'**
  String get goalValidationWithdrawPositive;

  /// No description provided for @goalValidationWithdrawExceedsBalance.
  ///
  /// In id, this message translates to:
  /// **'Nominal penarikan melebihi saldo tabungan saat ini.'**
  String get goalValidationWithdrawExceedsBalance;

  /// No description provided for @goalWithdrawTransactionNote.
  ///
  /// In id, this message translates to:
  /// **'Tarik dari goal: {goalName}'**
  String goalWithdrawTransactionNote(String goalName);

  /// No description provided for @walletValidationHasTransactions.
  ///
  /// In id, this message translates to:
  /// **'Dompet tidak dapat dihapus karena masih memiliki transaksi terkait. Pindahkan atau hapus transaksi terlebih dahulu.'**
  String get walletValidationHasTransactions;

  /// No description provided for @walletValidationMinimumOne.
  ///
  /// In id, this message translates to:
  /// **'Minimal harus ada 1 dompet aktif di aplikasi.'**
  String get walletValidationMinimumOne;

  /// No description provided for @walletValidationNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama dompet tidak boleh kosong.'**
  String get walletValidationNameRequired;

  /// No description provided for @walletValidationStartingBalanceNotNegative.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal tidak boleh negatif.'**
  String get walletValidationStartingBalanceNotNegative;

  /// No description provided for @walletValidationTransferAmountPositive.
  ///
  /// In id, this message translates to:
  /// **'Nominal transfer harus lebih besar dari nol.'**
  String get walletValidationTransferAmountPositive;

  /// No description provided for @settingsCategoryDeleteInUseError.
  ///
  /// In id, this message translates to:
  /// **'Kategori tidak dapat dihapus karena masih digunakan oleh transaksi.'**
  String get settingsCategoryDeleteInUseError;

  /// No description provided for @defaultWalletName.
  ///
  /// In id, this message translates to:
  /// **'Dompet Utama'**
  String get defaultWalletName;

  /// No description provided for @payCycleBekelTransactionNote.
  ///
  /// In id, this message translates to:
  /// **'Bekel hari ini'**
  String get payCycleBekelTransactionNote;

  /// No description provided for @withdrawDialogChip25.
  ///
  /// In id, this message translates to:
  /// **'25%'**
  String get withdrawDialogChip25;

  /// No description provided for @withdrawDialogChip50.
  ///
  /// In id, this message translates to:
  /// **'50%'**
  String get withdrawDialogChip50;

  /// No description provided for @transferWalletDropdownItem.
  ///
  /// In id, this message translates to:
  /// **'{name} ({balance})'**
  String transferWalletDropdownItem(String name, String balance);

  /// No description provided for @homeScreenDateFormatLocale.
  ///
  /// In id, this message translates to:
  /// **'id_ID'**
  String get homeScreenDateFormatLocale;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
