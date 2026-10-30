// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'LedgerMate';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get dataManagement => 'Cadangkan & Pulihkan';

  @override
  String get appearanceAndLanguage => 'Tampilan & Bahasa';

  @override
  String get darkMode => 'Mode Gelap (Dark Mode)';

  @override
  String get language => 'Bahasa Aplikasi';

  @override
  String get notificationsTitle => 'Notifikasi & Pengingat';

  @override
  String get dailyReminder => 'Pengingat Catat Harian';

  @override
  String get limitAlert => 'Peringatan Limit Harian';

  @override
  String get payCycleAlert => 'Siklus Gajian Baru';

  @override
  String get goalMilestoneAlert => 'Milestone Target Tabungan';

  @override
  String get categoryManagement => 'Kelola Kategori';

  @override
  String get aboutTitle => 'Tentang LedgerMate';

  @override
  String appRootDataLoadErrorMessage(Object error) {
    return 'Gagal memuat data: $error';
  }

  @override
  String get initialIncomeStepPeriodicTitle => 'Gaji Siklus Ini';

  @override
  String get initialIncomeStepDailyTitle => 'Bekel Awal Hari Ini';

  @override
  String get initialIncomeStepPeriodicSubtitle =>
      'Masukkan total gaji tetap untuk siklus gajian ini.';

  @override
  String get initialIncomeStepDailySubtitle =>
      'Masukkan uang yang sudah kamu pegang untuk mulai hari ini.';

  @override
  String get initialIncomeStepEmptyAmountError => 'Jumlah tidak boleh kosong';

  @override
  String get initialIncomeStepInvalidAmountError =>
      'Jumlah tidak boleh negatif atau nol';

  @override
  String get initialIncomeStepPeriodicLabel => 'Gaji tetap';

  @override
  String get initialIncomeStepDailyLabel => 'Jumlah awal';

  @override
  String get incomeFrequencyStepTitle => 'Pola Pendapatanmu';

  @override
  String get incomeFrequencyStepSubtitle =>
      'Pilih yang paling cocok dengan cara kamu menerima uang.';

  @override
  String get incomeFrequencyStepPeriodicTitle => 'Periodik';

  @override
  String get incomeFrequencyStepPeriodicDescription =>
      'Gajian lump-sum di tanggal tertentu — mingguan, 2 mingguan, bulanan, atau custom.';

  @override
  String get incomeFrequencyStepDailyTitle => 'Harian';

  @override
  String get incomeFrequencyStepDailyDescription =>
      'Bekel/income diterima tiap hari (termasuk jadwal nggak rata) — tanpa tanggal gajian tetap.';

  @override
  String get incomeFrequencyStepIntervalLabel => 'Interval';

  @override
  String get incomeFrequencyStepNextPaydayLabel => 'Tanggal income berikutnya';

  @override
  String get incomeFrequencyStepPickDate => 'Pilih tanggal';

  @override
  String get incomeFrequencyStepIntervalWeekly => 'Mingguan';

  @override
  String get incomeFrequencyStepIntervalBiweekly => '2 Mingguan';

  @override
  String get incomeFrequencyStepIntervalMonthly => 'Bulanan';

  @override
  String get incomeFrequencyStepIntervalCustom => 'Custom';

  @override
  String get mandatoryExpensesStepTitle => 'Pengeluaran Wajib';

  @override
  String get mandatoryExpensesStepSubtitle =>
      'Kos, cicilan, dll — opsional, tambahkan sebanyak yang kamu perlukan.';

  @override
  String get mandatoryExpensesStepEmptyMessage =>
      'Belum ada pengeluaran wajib ditambahkan.';

  @override
  String get mandatoryExpensesStepNameEmptyError => 'Nama tidak boleh kosong';

  @override
  String get mandatoryExpensesStepAmountEmptyError =>
      'Jumlah tidak boleh kosong';

  @override
  String get mandatoryExpensesStepInvalidAmountError =>
      'Jumlah tidak boleh negatif atau nol';

  @override
  String get mandatoryExpensesStepDeleteTooltip => 'Hapus Pengeluaran';

  @override
  String get mandatoryExpensesStepNameFieldLabel => 'Nama pengeluaran';

  @override
  String get mandatoryExpensesStepAmountFieldLabel => 'Jumlah';

  @override
  String get mandatoryExpensesStepAddButton => 'Tambah pengeluaran';

  @override
  String get walletSetupStepTitle => 'Atur Dompet Pertamamu';

  @override
  String get walletSetupStepSubtitle =>
      'Dompet tempat menyimpan uangmu (misal: Tunai, Rekening Bank, E-Wallet). Kamu bisa menambah dompet lain nanti.';

  @override
  String get walletSetupStepNameFieldLabel => 'Nama Dompet';

  @override
  String get walletSetupStepNameFieldHint =>
      'Misal: Dompet Utama, Tunai, Rekening BCA';

  @override
  String get walletSetupStepNameEmptyError => 'Nama dompet tidak boleh kosong';

  @override
  String get walletSetupStepIconPickerLabel => 'Pilih Ikon Dompet';

  @override
  String get walletSetupStepStartingBalanceLabel => 'Saldo Awal';

  @override
  String get walletSetupStepStartingBalanceHelper =>
      'Saldo riil yang ada di dompet ini saat mulai menggunakan aplikasi.';

  @override
  String get walletSetupStepNegativeBalanceError =>
      'Saldo awal tidak boleh negatif';

  @override
  String get walletSetupStepIncludeBudgetTitle =>
      'Sertakan dalam Budget Harian';

  @override
  String get walletSetupStepIncludeBudgetSubtitle =>
      'Uang di dompet ini akan dihitung ke dalam Uang Jajan Aman Hari Ini.';

  @override
  String get onboardingScreenBackButton => 'Kembali';

  @override
  String get onboardingScreenFinishButton => 'Selesai';

  @override
  String get onboardingScreenNextButton => 'Lanjut';

  @override
  String get onboardingScreenIncompleteDataError =>
      'Data belum lengkap — kembali ke langkah sebelumnya.';

  @override
  String get realismWarningDialogTitle => 'Target Mungkin Terlalu Berat';

  @override
  String realismWarningDialogImpactMessage(String amount) {
    return 'Jika target ini disimpan, total alokasi tabungan harian Anda menjadi $amount/hari.';
  }

  @override
  String realismWarningDialogNegativeBudgetMessage(String amount) {
    return 'Hal ini akan mendorong Uang Jajan Aman Hari Ini ke angka negatif: $amount/hari.';
  }

  @override
  String get realismWarningDialogHint =>
      'Memperpanjang tanggal target akan menurunkan porsi tabungan harian sehingga anggaran harian tetap aman.';

  @override
  String get realismWarningDialogExtendButton => 'Perpanjang tanggal target';

  @override
  String get realismWarningDialogProceedButton =>
      'Lanjut, saya paham risikonya';

  @override
  String get unsavedChangesGuardDialogTitle => 'Buang Perubahan?';

  @override
  String get unsavedChangesGuardDialogContent =>
      'Kamu memiliki perubahan yang belum disimpan. Yakin ingin keluar tanpa menyimpan?';

  @override
  String get unsavedChangesGuardContinueEditingButton => 'Lanjut Edit';

  @override
  String get unsavedChangesGuardDiscardButton => 'Buang Perubahan';

  @override
  String get databaseErrorScreenTitle => 'Gagal Memuat Data Lokal';

  @override
  String get databaseErrorScreenDescription =>
      'LedgerMate tidak dapat membuka database lokal di perangkat ini. Ini bisa terjadi akibat penyimpanan penuh atau proses yang terganggu saat terakhir menyimpan data.';

  @override
  String get databaseErrorScreenSuggestion =>
      'Coba: (1) pastikan ruang penyimpanan perangkat cukup, lalu tekan \"Coba Lagi\"; (2) jika masih gagal, restart aplikasi sepenuhnya. Data tidak akan hilang kecuali aplikasi di-uninstall.';

  @override
  String get databaseErrorScreenRetryButton => 'Coba Lagi';

  @override
  String get appBottomNavHomeLabel => 'Home';

  @override
  String get appBottomNavTransactionsLabel => 'Transaksi';

  @override
  String get appBottomNavGoalsLabel => 'Goals';

  @override
  String get appBottomNavAssetsLabel => 'Aset';

  @override
  String get appBottomNavAnalyticsLabel => 'Analitik';

  @override
  String get appBottomNavSettingsLabel => 'Pengaturan';

  @override
  String get fabSpeedDialCloseBarrierLabel => 'Tutup';

  @override
  String get fabSpeedDialAddWalletLabel => 'Tambah Dompet Baru';

  @override
  String get fabSpeedDialTransferLabel => 'Transfer Antar Dompet';

  @override
  String get fabSpeedDialIncomeLabel => 'Catat Pemasukan';

  @override
  String get fabSpeedDialExpenseLabel => 'Catat Pengeluaran';

  @override
  String get goalsScreenTitle => 'Target Tabungan';

  @override
  String goalsScreenLoadError(Object error) {
    return 'Gagal memuat target tabungan: $error';
  }

  @override
  String get goalsScreenEmptyTitle => 'Belum Ada Target Tabungan';

  @override
  String get goalsScreenEmptyMessage =>
      'Buat target finansial untuk melacak estimasi tercapai dan menyisihkan dana harian secara otomatis.';

  @override
  String get goalsScreenCreateFirstButton => 'Buat Target Pertama';

  @override
  String goalsScreenActiveListHeader(int count) {
    return 'Daftar Target Aktif ($count)';
  }

  @override
  String goalsScreenCompletedCountLabel(int count) {
    return '$count selesai';
  }

  @override
  String get goalsScreenAddGoalCardLabel => 'Tambah Goal Baru';

  @override
  String get goalsOverviewCardTitle => 'Total Progres Tabungan';

  @override
  String get goalsOverviewCardCollectedLabel => 'Terkumpul';

  @override
  String get goalsOverviewCardTargetLabel => 'Total Target';

  @override
  String get goalsOverviewCardDailyReserveLabel => 'Cadangan/Hari';

  @override
  String get goalFormScreenEditTitle => 'Edit Target Tabungan';

  @override
  String get goalFormScreenAddTitle => 'Tambah Target Baru';

  @override
  String get goalFormScreenNameLabel => 'Nama Target';

  @override
  String get goalFormScreenNameHint => 'Misal: Laptop Baru, Dana Darurat';

  @override
  String get goalFormScreenNameEmptyError => 'Nama target tidak boleh kosong';

  @override
  String get goalFormScreenTargetAmountLabel => 'Target Nominal';

  @override
  String get goalFormScreenTargetAmountError =>
      'Target nominal harus lebih besar dari 0';

  @override
  String get goalFormScreenCurrentAmountLabel => 'Saldo Awal / Sudah Terkumpul';

  @override
  String get goalFormScreenCurrentAmountHelper =>
      'Isi jika sudah mulai menabung sebelum target ini dibuat';

  @override
  String get goalFormScreenCurrentAmountNegativeError =>
      'Saldo tidak boleh negatif';

  @override
  String get goalFormScreenTargetDateTitle => 'Target Tanggal Tercapai';

  @override
  String get goalFormScreenManualAllocationTitle =>
      'Override Alokasi Harian Manual';

  @override
  String get goalFormScreenManualAllocationSubtitle =>
      'Tetapkan nominal tabungan harian tetap, bukan hasil hitungan otomatis formula.';

  @override
  String get goalFormScreenManualAllocationFieldLabel =>
      'Nominal Alokasi Harian (Rp/hari)';

  @override
  String get goalFormScreenManualAllocationHelper =>
      'Nominal ini langsung menggantikan kalkulasi formula otomatis';

  @override
  String get goalFormScreenManualAllocationError =>
      'Masukkan alokasi harian yang lebih besar dari 0';

  @override
  String get goalFormScreenTargetAmountRequiredError =>
      'Target nominal harus lebih besar dari 0.';

  @override
  String get goalFormScreenTargetDateError =>
      'Tanggal target harus lebih dari hari ini.';

  @override
  String get goalFormScreenSaveSuccessToast =>
      'Target tabungan berhasil disimpan';

  @override
  String goalFormScreenSaveError(Object error) {
    return 'Gagal menyimpan target: $error';
  }

  @override
  String get goalFormScreenUpdateButton => 'Perbarui Target';

  @override
  String get goalFormScreenSaveButton => 'Simpan Target';

  @override
  String get goalCardDeleteDialogTitle => 'Hapus Target?';

  @override
  String goalCardDeleteDialogMessage(String goalName) {
    return 'Apakah Anda yakin ingin menghapus target \"$goalName\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get goalCardCancelButton => 'Batal';

  @override
  String get goalCardDeleteButton => 'Hapus';

  @override
  String goalCardTargetDateLabel(String date) {
    return 'Target: $date';
  }

  @override
  String get goalCardCompletedBadge => 'Tercapai';

  @override
  String get goalCardManualOverrideBadge => 'Override Manual';

  @override
  String goalCardTargetAmountLabel(String targetAmount, int percent) {
    return '$targetAmount ($percent%)';
  }

  @override
  String get goalCardCompletedMessage => 'Target telah terpenuhi sepenuhnya!';

  @override
  String goalCardEstimatedCompletionMessage(String date) {
    return 'Estimasi tercapai: $date';
  }

  @override
  String get goalCardNoEstimateMessage => 'Belum ada estimasi (alokasi 0)';

  @override
  String get goalCardDoneLabel => 'Selesai';

  @override
  String goalCardDailyAllocationLabel(String amount) {
    return '$amount/hari';
  }

  @override
  String get goalCardWithdrawButton => 'Tarik dari Goal';

  @override
  String get goalCardEditButton => 'Edit';

  @override
  String get goalCardDeleteTooltip => 'Hapus Target';

  @override
  String get withdrawDialogInvalidAmountError =>
      'Nominal harus lebih besar dari 0.';

  @override
  String get withdrawDialogExceedsBalanceError =>
      'Nominal melebihi tabungan saat ini.';

  @override
  String get withdrawDialogConfirmTitle => 'Konfirmasi Penarikan';

  @override
  String withdrawDialogConfirmMessage(String amount, String goalName) {
    return 'Tarik $amount dari target \"$goalName\"?\n\nSaldo target akan berkurang dan nominal ini akan otomatis kembali ke saldo aktif periode berjalan.';
  }

  @override
  String get withdrawDialogCancelButton => 'Batal';

  @override
  String get withdrawDialogConfirmSubmitButton => 'Tarik Sekarang';

  @override
  String withdrawDialogSuccessToast(String amount) {
    return 'Penarikan $amount berhasil';
  }

  @override
  String withdrawDialogGenericError(Object error) {
    return 'Gagal melakukan penarikan: $error';
  }

  @override
  String get withdrawDialogTitle => 'Tarik dari Goal';

  @override
  String withdrawDialogTargetLabel(String goalName) {
    return 'Target: $goalName';
  }

  @override
  String withdrawDialogAvailableLabel(String amount) {
    return 'Tersedia saat ini: $amount';
  }

  @override
  String get withdrawDialogAmountFieldLabel => 'Nominal Penarikan';

  @override
  String get withdrawDialogInvalidAmountValidator =>
      'Masukkan nominal yang valid';

  @override
  String get withdrawDialogExceedsBalanceValidator =>
      'Melebihi saldo terkumpul';

  @override
  String get withdrawDialogChipAll => 'Semua';

  @override
  String get withdrawDialogSubmitButton => 'Lanjut Tarik';

  @override
  String get assetsScreenTitle => 'Aset & Investasi';

  @override
  String get assetsScreenAddTooltip => 'Tambah Aset';

  @override
  String assetsScreenLoadError(Object error) {
    return 'Gagal memuat data aset: $error';
  }

  @override
  String get assetsScreenEmptyTitle => 'Belum Ada Aset Terdaftar';

  @override
  String get assetsScreenEmptyMessage =>
      'Pantau nilai kekayaan bersih (net-worth) Anda secara mandiri. Catat aset seperti emas, saham, reksadana, atau kripto dengan pembaruan manual 100% offline.';

  @override
  String get assetsScreenAddFirstButton => 'Tambah Aset Pertama';

  @override
  String get assetsScreenPortfolioTotalLabel => 'Total Portofolio Aset';

  @override
  String assetsScreenAssetCountBadge(int count) {
    return '$count Aset';
  }

  @override
  String get assetsScreenTotalPurchaseLabel => 'Total Modal Awal';

  @override
  String get assetsScreenTotalGainLabel => 'Total Keuntungan';

  @override
  String assetsScreenGainLossSummary(
    String sign,
    String amount,
    String percent,
  ) {
    return '$sign$amount ($sign$percent%)';
  }

  @override
  String assetsScreenListHeader(int count) {
    return 'Daftar Aset ($count)';
  }

  @override
  String get assetsScreenAddCardLabel => 'Tambah Aset Baru';

  @override
  String get assetCardDeleteDialogTitle => 'Hapus Aset?';

  @override
  String assetCardDeleteDialogMessage(String assetName) {
    return 'Apakah Anda yakin ingin menghapus aset \"$assetName\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get assetCardCancelButton => 'Batal';

  @override
  String get assetCardDeleteButton => 'Hapus';

  @override
  String get assetCardEditTooltip => 'Edit Lengkap';

  @override
  String get assetCardDeleteTooltip => 'Hapus Aset';

  @override
  String get assetCardPurchaseValueLabel => 'Modal Awal';

  @override
  String get assetCardCurrentValueLabel => 'Nilai Sekarang';

  @override
  String get assetCardGainLossLabel => 'Keuntungan / Kerugian';

  @override
  String assetCardGainLossValue(String sign, String amount, String percent) {
    return '$sign$amount ($sign$percent%)';
  }

  @override
  String assetCardLastUpdatedLabel(String date) {
    return 'Update: $date';
  }

  @override
  String get assetCardUpdateValueButton => 'Update Nilai';

  @override
  String get assetFormScreenEditTitle => 'Edit Aset';

  @override
  String get assetFormScreenAddTitle => 'Tambah Aset';

  @override
  String get assetFormScreenNameLabel => 'Nama Aset';

  @override
  String get assetFormScreenNameHint =>
      'misal: Emas Antam 10g, BBCA, Reksadana Pasar Uang';

  @override
  String get assetFormScreenNameEmptyError => 'Nama aset tidak boleh kosong.';

  @override
  String get assetFormScreenTypeLabel => 'Tipe Aset';

  @override
  String get assetFormScreenTypeHint => 'misal: Emas, Saham, Reksadana, Kripto';

  @override
  String get assetFormScreenTypeEmptyError => 'Tipe aset tidak boleh kosong.';

  @override
  String get assetFormScreenPurchaseValueLabel =>
      'Modal Awal / Nilai Beli (Rp)';

  @override
  String get assetFormScreenPurchaseValueEmptyError =>
      'Modal awal tidak boleh kosong.';

  @override
  String get assetFormScreenPurchaseValueInvalidError =>
      'Modal awal harus lebih besar dari 0.';

  @override
  String get assetFormScreenCurrentValueLabel => 'Nilai Sekarang (Rp)';

  @override
  String get assetFormScreenCopyFromPurchaseButton => 'Sama dg modal';

  @override
  String get assetFormScreenCurrentValueEmptyError =>
      'Nilai sekarang tidak boleh kosong.';

  @override
  String get assetFormScreenCurrentValueNegativeError =>
      'Nilai sekarang tidak boleh negatif.';

  @override
  String get assetFormScreenGainLossPreviewLabel => 'Estimasi Gain / Loss:';

  @override
  String get assetFormScreenOfflineNotice =>
      '100% Offline. Nilai aset diperbarui secara manual oleh Anda kapan saja (D8).';

  @override
  String get assetFormScreenPurchaseRequiredError =>
      'Modal awal harus lebih besar dari 0.';

  @override
  String get assetFormScreenCurrentValueRequiredError =>
      'Nilai sekarang tidak boleh kosong atau negatif.';

  @override
  String get assetFormScreenSaveSuccessToast => 'Aset berhasil disimpan';

  @override
  String assetFormScreenSaveError(Object error) {
    return 'Gagal menyimpan aset: $error';
  }

  @override
  String get assetFormScreenSaveChangesButton => 'Simpan Perubahan';

  @override
  String get assetFormScreenAddButton => 'Tambah Aset';

  @override
  String get assetFormScreenTypeGold => 'Emas';

  @override
  String get assetFormScreenTypeStocks => 'Saham';

  @override
  String get assetFormScreenTypeMutualFund => 'Reksadana';

  @override
  String get assetFormScreenTypeCrypto => 'Kripto';

  @override
  String get assetFormScreenTypeProperty => 'Properti';

  @override
  String get assetFormScreenTypeDeposit => 'Deposito';

  @override
  String get assetFormScreenTypeOther => 'Lainnya';

  @override
  String get updateValueDialogTitle => 'Update Nilai Aset';

  @override
  String updateValueDialogTypeLabel(String type) {
    return 'Tipe: $type';
  }

  @override
  String get updateValueDialogPurchaseValueLabel => 'Modal Awal';

  @override
  String get updateValueDialogPreviousValueLabel => 'Nilai Sebelumnya';

  @override
  String updateValueDialogLastUpdatedLabel(String date) {
    return 'Terakhir diperbarui: $date';
  }

  @override
  String get updateValueDialogNewValueLabel => 'Nilai Sekarang Baru';

  @override
  String get updateValueDialogEmptyValueError =>
      'Nilai aset tidak boleh kosong.';

  @override
  String get updateValueDialogNegativeValueError =>
      'Nilai tidak boleh negatif.';

  @override
  String get updateValueDialogRequiredError =>
      'Nilai aset tidak boleh kosong atau negatif.';

  @override
  String get updateValueDialogNewGainLossLabel => 'Estimasi Gain / Loss Baru:';

  @override
  String updateValueDialogChangeFromPreviousLabel(String sign, String amount) {
    return 'Perubahan dari sebelumnya: $sign$amount';
  }

  @override
  String updateValueDialogGenericError(Object error) {
    return 'Gagal memperbarui nilai: $error';
  }

  @override
  String get updateValueDialogSuccessToast => 'Nilai aset berhasil diperbarui';

  @override
  String get updateValueDialogCancelButton => 'Batal';

  @override
  String get updateValueDialogSaveButton => 'Simpan Pembaruan';

  @override
  String get analyticsScreenTitle => 'Visual Analitik';

  @override
  String get analyticsScreenThemeToggleToLight => 'Beralih ke mode terang';

  @override
  String get analyticsScreenThemeToggleToDark => 'Beralih ke mode gelap';

  @override
  String analyticsScreenLoadError(Object error) {
    return 'Gagal memuat analitik: $error';
  }

  @override
  String analyticsScreenTrendLoadError(Object error) {
    return 'Gagal memuat tren: $error';
  }

  @override
  String get analyticsScreenFilterDaily => 'Harian';

  @override
  String get analyticsScreenFilterWeekly => 'Mingguan';

  @override
  String get analyticsScreenFilterMonthly => 'Bulanan';

  @override
  String get analyticsEmptyStateDefaultMessage =>
      'Belum ada transaksi pada periode ini.';

  @override
  String get analyticsEmptyStateDefaultSubmessage =>
      'Catat pengeluaran atau pemasukan untuk melihat visualisasi grafik dan tren keuangan.';

  @override
  String get analyticsEmptyStateRecordButton => 'Catat Transaksi';

  @override
  String get incomeExpenseRatioCardTitle => 'Ringkasan Keuangan Periode';

  @override
  String get incomeExpenseRatioCardTotalIncomeLabel => 'Total Pemasukan';

  @override
  String get incomeExpenseRatioCardTotalExpenseLabel => 'Total Pengeluaran';

  @override
  String get incomeExpenseRatioCardNetSavingsLabel => 'Tabungan Bersih';

  @override
  String get incomeExpenseRatioCardExpenseRatioLabel => 'Rasio Pengeluaran';

  @override
  String get categoryBreakdownCardTitle => 'Proporsi Pengeluaran per Kategori';

  @override
  String categoryBreakdownCardTotalLabel(String amount) {
    return 'Total: $amount';
  }

  @override
  String get categoryBreakdownCardShowPieTooltip =>
      'Tampilkan diagram lingkaran (Pie)';

  @override
  String get categoryBreakdownCardShowBarTooltip =>
      'Tampilkan diagram batang (Bar)';

  @override
  String get categoryBreakdownCardEmptyMessage =>
      'Tidak ada pengeluaran tercatat pada periode ini.';

  @override
  String categoryBreakdownCardTransactionCountLabel(int count) {
    return '$count transaksi';
  }

  @override
  String get monthOverMonthSectionTitle => 'Tren Bulan-ke-Bulan (MoM)';

  @override
  String monthOverMonthSectionComparisonLabel(
    String currMonth,
    String prevMonth,
  ) {
    return '$currMonth vs $prevMonth';
  }

  @override
  String get monthOverMonthSectionLastMonthLegend => 'Bulan Lalu';

  @override
  String get monthOverMonthSectionThisMonthLegend => 'Bulan Ini';

  @override
  String get monthOverMonthSectionEmptyMessage =>
      'Belum cukup data transaksi untuk perbandingan bulan-ke-bulan.';

  @override
  String get monthOverMonthSectionCategoryComparisonTitle =>
      'Perbandingan Pengeluaran per Kategori';

  @override
  String monthOverMonthSectionTooltipLabel(
    String categoryName,
    String period,
    String amount,
  ) {
    return '$categoryName ($period)\n$amount';
  }

  @override
  String get monthOverMonthSectionExpenseLabel => 'Pengeluaran';

  @override
  String get monthOverMonthSectionIncomeLabel => 'Pemasukan';

  @override
  String get monthOverMonthSectionNewBadge => 'Baru';

  @override
  String monthOverMonthSectionPreviousAmountLabel(String amount) {
    return 'Lalu: $amount';
  }

  @override
  String get walletsScreenTitle => 'Kelola Dompet';

  @override
  String get walletsScreenTransferTooltip => 'Transfer Antar Dompet';

  @override
  String get walletsScreenTotalBalanceLabel => 'Total Saldo (Kekayaan Bersih)';

  @override
  String walletsScreenTotalBalanceSubtitle(int count) {
    return 'Total akumulasi dari $count dompet & rekening aktif.';
  }

  @override
  String get walletsScreenTransferButton => 'Transfer';

  @override
  String get walletsScreenAddButton => 'Tambah';

  @override
  String walletsScreenListTitle(int count) {
    return 'Daftar Dompet ($count)';
  }

  @override
  String get walletsScreenEmptyTitle => 'Belum ada dompet terdaftar.';

  @override
  String get walletsScreenEmptyMessage =>
      'Tambahkan dompet pertamamu untuk mulai mencatat.';

  @override
  String walletsScreenLoadError(Object error) {
    return 'Gagal memuat daftar dompet: $error';
  }

  @override
  String get walletsScreenDeleteDialogTitle => 'Hapus Dompet?';

  @override
  String walletsScreenDeleteDialogMessage(String name) {
    return 'Apakah kamu yakin ingin menghapus dompet \"$name\"?\n\nCatatan: Dompet tidak dapat dihapus jika masih memiliki transaksi atau transfer terkait.';
  }

  @override
  String get walletsScreenCancelButton => 'Batal';

  @override
  String get walletsScreenDeleteButton => 'Hapus';

  @override
  String walletsScreenDeleteSuccessToast(String name) {
    return 'Dompet \"$name\" berhasil dihapus.';
  }

  @override
  String get walletsScreenDeleteRejectedTitle => 'Hapus Ditolak';

  @override
  String get walletsScreenDeleteFailedTitle => 'Gagal Menghapus Dompet';

  @override
  String get walletsScreenUnderstoodButton => 'Mengerti';

  @override
  String get walletCardIncludedInBudgetBadge => 'Ikut Budget Harian';

  @override
  String get walletCardExcludedFromBudgetBadge => 'Di luar Budget';

  @override
  String get walletCardCurrentBalanceLabel => 'Saldo saat ini';

  @override
  String get walletCardTransferMenuItem => 'Transfer';

  @override
  String get walletCardEditMenuItem => 'Edit Dompet';

  @override
  String get walletCardDeleteMenuItem => 'Hapus';

  @override
  String get walletFormScreenEditTitle => 'Edit Dompet';

  @override
  String get walletFormScreenAddTitle => 'Tambah Dompet';

  @override
  String get walletFormScreenNameLabel => 'Nama Dompet';

  @override
  String get walletFormScreenNameHint => 'Misal: BCA, Tunai, Gopay, Bibit';

  @override
  String get walletFormScreenNameRequiredError =>
      'Nama dompet tidak boleh kosong';

  @override
  String get walletFormScreenIconPickerLabel => 'Pilih Ikon';

  @override
  String get walletFormScreenStartingBalanceLabel => 'Saldo Awal';

  @override
  String get walletFormScreenStartingBalanceHelper =>
      'Saldo saat dompet pertama kali dibuat/dihitung (whole Rupiah).';

  @override
  String get walletFormScreenStartingBalanceNegativeError =>
      'Saldo awal tidak boleh negatif';

  @override
  String get walletFormScreenIncludeBudgetToggleTitle =>
      'Hitung dalam Budget Harian';

  @override
  String get walletFormScreenIncludeBudgetToggleSubtitle =>
      'Jika aktif, transaksi di dompet ini akan memengaruhi sisa uang jajan harianmu. Matikan untuk dompet tabungan/investasi.';

  @override
  String get walletFormScreenSaveSuccessToast => 'Dompet berhasil disimpan';

  @override
  String get walletFormScreenSaveChangesButton => 'Simpan Perubahan';

  @override
  String get walletFormScreenCreateButton => 'Buat Dompet';

  @override
  String get transferFormScreenTitle => 'Transfer Antar Dompet';

  @override
  String get transferFormScreenMissingWalletsError =>
      'Pilih dompet asal dan tujuan transfer.';

  @override
  String get transferFormScreenSameWalletError =>
      'Dompet asal dan tujuan tidak boleh sama.';

  @override
  String get transferFormScreenZeroAmountError =>
      'Nominal transfer harus lebih besar dari nol.';

  @override
  String transferFormScreenSuccessToast(String amount) {
    return 'Transfer $amount berhasil diproses';
  }

  @override
  String get transferFormScreenNeedMoreWalletsTitle =>
      'Butuh minimal 2 dompet untuk melakukan transfer.';

  @override
  String get transferFormScreenNeedMoreWalletsMessage =>
      'Tambahkan dompet lain terlebih dahulu di menu Kelola Dompet.';

  @override
  String get transferFormScreenSourceWalletLabel => 'Dari Dompet (Sumber)';

  @override
  String get transferFormScreenTargetWalletLabel => 'Ke Dompet (Tujuan)';

  @override
  String get transferFormScreenAmountLabel => 'Nominal Transfer';

  @override
  String get transferFormScreenAmountZeroError =>
      'Nominal transfer harus lebih besar dari nol';

  @override
  String get transferFormScreenDateLabel => 'Tanggal Transfer';

  @override
  String get transferFormScreenNotesLabel => 'Catatan (Opsional)';

  @override
  String get transferFormScreenNotesHint =>
      'Misal: Tarik tunai dari ATM, Top up GoPay';

  @override
  String get transferFormScreenSubmitButton => 'Transfer Sekarang';

  @override
  String transferFormScreenLoadError(Object error) {
    return 'Gagal memuat dompet: $error';
  }

  @override
  String get transactionsScreenTitle => 'Daftar Transaksi';

  @override
  String get transactionsScreenEmptyFilterMessage =>
      'Tidak ada transaksi untuk filter ini.';

  @override
  String transactionsScreenLoadError(Object error) {
    return 'Gagal memuat transaksi: $error';
  }

  @override
  String get transactionsScreenEmptyTitle => 'Belum Ada Transaksi';

  @override
  String get transactionsScreenEmptyMessage =>
      'Catat pengeluaran atau pemasukan pertamamu dengan tombol di bawah.';

  @override
  String get transactionsScreenEmptyAddButton => 'Tambah Transaksi Pertama';

  @override
  String get transactionsScreenFilterAll => 'Semua';

  @override
  String get transactionsScreenFilterIncome => 'Pemasukan';

  @override
  String get transactionsScreenFilterExpense => 'Pengeluaran';

  @override
  String get transactionFormScreenEditTitle => 'Edit Transaksi';

  @override
  String get transactionFormScreenAddTitle => 'Catat Transaksi';

  @override
  String get transactionFormScreenTransferAmountLabel => 'NOMINAL TRANSFER';

  @override
  String get transactionFormScreenAmountLabel => 'JUMLAH';

  @override
  String get transactionFormScreenAmountEmptyError =>
      'Jumlah tidak boleh kosong';

  @override
  String get transactionFormScreenAmountInvalidError =>
      'Jumlah tidak boleh nol atau negatif';

  @override
  String get transactionFormScreenSourceWalletLabel => 'Dari Dompet (Sumber)';

  @override
  String get transactionFormScreenTargetWalletLabel => 'Ke Dompet (Tujuan)';

  @override
  String transactionFormScreenSourceWalletLoadError(Object error) {
    return 'Gagal memuat dompet: $error';
  }

  @override
  String transactionFormScreenTargetWalletLoadError(Object error) {
    return 'Gagal memuat dompet tujuan: $error';
  }

  @override
  String get transactionFormScreenWalletLabel => 'Dompet';

  @override
  String get transactionFormScreenCategoryLabel => 'Kategori';

  @override
  String transactionFormScreenCategoryLoadError(Object error) {
    return 'Gagal memuat kategori: $error';
  }

  @override
  String get transactionFormScreenDateLabel => 'Tanggal';

  @override
  String get transactionFormScreenNotesLabel => 'Catatan (opsional)';

  @override
  String get transactionFormScreenSaveSuccessToast =>
      'Transaksi berhasil disimpan';

  @override
  String get transactionFormScreenSaveChangesButton => 'Simpan Perubahan';

  @override
  String get transactionFormScreenSaveNewButton => 'Simpan Transaksi';

  @override
  String get transactionFormScreenDeleteDialogTitle => 'Hapus Transaksi?';

  @override
  String get transactionFormScreenDeleteDialogMessage =>
      'Apakah kamu yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get transactionFormScreenCancelButton => 'Batal';

  @override
  String get transactionFormScreenDeleteButton => 'Hapus';

  @override
  String get transactionFormScreenDeleteTransactionButton => 'Hapus Transaksi';

  @override
  String get transactionFormScreenDeleteLockedButton =>
      'Hapus Transaksi (Terkunci)';

  @override
  String get transactionFormScreenDeleteLockedNotice =>
      'Hanya transaksi bertanggal hari ini yang dapat dihapus. Transaksi lampau tidak dapat dihapus untuk menjaga integritas histori.';

  @override
  String get transactionFormScreenTypeExpenseLabel => 'Pengeluaran';

  @override
  String get transactionFormScreenTypeIncomeLabel => 'Pemasukan';

  @override
  String get transactionFormScreenTypeTransferLabel => 'Transfer';

  @override
  String get transactionFormScreenInvalidTransferError =>
      'Mohon masukkan nominal dan pilih dompet asal & tujuan yang berbeda.';

  @override
  String get transactionFormScreenInvalidRegularError =>
      'Mohon masukkan jumlah dan pilih kategori.';

  @override
  String homeScreenLoadError(Object error) {
    return 'Gagal memuat budget: $error';
  }

  @override
  String get homeScreenModePeriodicBadge => 'Mode Periodik';

  @override
  String get homeScreenModeDailyBadge => 'Mode Harian (Bekel)';

  @override
  String get homeScreenTotalSaldoLabel => 'Total Saldo';

  @override
  String get homeScreenDailyAllowanceLabel => 'Jatah Hari Ini';

  @override
  String homeScreenSubtitleRemainingDays(int days) {
    return 'Sisa $days hari sampai jadwal payday berikutnya';
  }

  @override
  String get homeScreenSubtitleCarryOver =>
      'Akumulasi carry-over kemarin & bekel hari ini';

  @override
  String get homeScreenCycleExpiredPeriodicTitle => 'Siklus Gajian Berakhir';

  @override
  String get homeScreenCycleExpiredDailyTitle => 'Rollover Harian Dibutuhkan';

  @override
  String get homeScreenCycleExpiredPeriodicMessage =>
      'Jadwal gajian telah tercapai. Mulai siklus baru untuk memperbarui Uang Jajan Aman.';

  @override
  String get homeScreenCycleExpiredDailyMessage =>
      'Hari baru telah tiba. Konfirmasi carry-over saldo untuk memulai hari ini.';

  @override
  String get homeScreenStartNewCycleButton => 'Mulai Siklus Baru';

  @override
  String get homeScreenRolloverTodayButton => 'Rollover Hari Ini';

  @override
  String get homeScreenBreakdownTitle => 'Rincian Perhitungan';

  @override
  String get homeScreenRemainingCycleBalanceLabel => 'Sisa Saldo Siklus';

  @override
  String get homeScreenGrossDailyAllowanceLabel => 'Jatah Kotor / Hari';

  @override
  String get homeScreenGoalSavingsDailyLabel => 'Tabungan Goal / Hari';

  @override
  String get homeScreenYesterdayCarryOverLabel => 'Saldo Carry-Over Kemarin';

  @override
  String get homeScreenTodayAllowanceInLabel => 'Bekel Masuk Hari Ini';

  @override
  String get homeScreenMandatoryExpenseTodayLabel =>
      'Pengeluaran Wajib Hari Ini';

  @override
  String get homeScreenRecordedExpenseTodayLabel =>
      'Pengeluaran Dicatat Hari Ini';

  @override
  String get homeScreenTransactionSummaryTitle => 'Rincian Transaksi';

  @override
  String get homeScreenViewAllLink => 'Lihat Selengkapnya';

  @override
  String get homeScreenTransactionSummaryLoadError =>
      'Gagal memuat ringkasan transaksi.';

  @override
  String get homeScreenNoTransactionsYet => 'Belum ada transaksi tercatat.';

  @override
  String get homeScreenIncomeColumnLabel => 'Pemasukan';

  @override
  String get homeScreenExpenseColumnLabel => 'Pengeluaran';

  @override
  String get homeScreenNoneYet => 'Belum ada';

  @override
  String get settingsScreenTitle => 'Pengaturan';

  @override
  String get settingsScreenPreferencesTitle => 'Tampilan & Bahasa';

  @override
  String get settingsScreenPreferencesSubtitle =>
      'Kustomisasi tema dan bahasa antarmuka';

  @override
  String get settingsScreenDarkModeTitle => 'Mode Gelap (Dark Mode)';

  @override
  String get settingsScreenDarkModeActiveSubtitle =>
      'Tema gelap aktif (rekomendasi OLED)';

  @override
  String get settingsScreenLightModeActiveSubtitle => 'Tema terang aktif';

  @override
  String get settingsScreenLanguageTitle => 'Bahasa Aplikasi';

  @override
  String get settingsScreenLanguageIndonesianActiveSubtitle =>
      'Bahasa Indonesia (Aktif)';

  @override
  String get settingsScreenLanguageEnglishActiveSubtitle => 'English (Active)';

  @override
  String get settingsScreenLanguageIndonesianOption => 'Bahasa Indonesia';

  @override
  String get settingsScreenLanguageEnglishOption => 'English';

  @override
  String get settingsScreenNotificationsTitle => 'Notifikasi & Pengingat';

  @override
  String get settingsScreenNotificationsSubtitle =>
      '100% Offline via Alarm Manager lokal';

  @override
  String get settingsScreenDailyReminderTitle => 'Pengingat Catat Harian';

  @override
  String settingsScreenDailyReminderSubtitle(String time) {
    return 'Setiap hari pukul $time WIB (ketuk jam untuk mengubah)';
  }

  @override
  String settingsScreenChangeTimeButton(String time) {
    return 'Ubah Jam ($time)';
  }

  @override
  String get settingsScreenLimitAlertTitle => 'Peringatan Limit Anggaran';

  @override
  String get settingsScreenLimitAlertSubtitle =>
      'Pemberitahuan real-time saat uang jajan aman hari ini mendekati 0 atau minus.';

  @override
  String get settingsScreenPayCycleTitle => 'Siklus Gajian Baru';

  @override
  String get settingsScreenPayCycleSubtitle =>
      'Pemberitahuan saat memasuki tanggal gajian atau siklus baru.';

  @override
  String get settingsScreenGoalMilestoneTitle => 'Milestone Target Tabungan';

  @override
  String get settingsScreenGoalMilestoneSubtitle =>
      'Pemberitahuan saat progres goal mencapai 25%, 50%, 75%, dan 100%.';

  @override
  String get settingsScreenAboutTitle => 'Tentang LedgerMate';

  @override
  String settingsScreenVersionLabel(String version, String buildNumber) {
    return 'Versi $version+$buildNumber (100% Offline, Tanpa Server)';
  }

  @override
  String get settingsScreenVersionLoading => 'Memuat versi...';

  @override
  String get settingsScreenVersionFallback => '100% Offline, Tanpa Server';

  @override
  String get settingsScreenAboutDescription =>
      'LedgerMate adalah pelacak anggaran harian pintar berbasis offline-first. Seluruh data keuangan Anda tersimpan secara lokal di perangkat Anda menggunakan Isar Database.';

  @override
  String get categoryManagementCardAddDialogTitle => 'Tambah Kategori Baru';

  @override
  String get categoryManagementCardNameLabel => 'Nama Kategori';

  @override
  String get categoryManagementCardNameHint =>
      'Contoh: Investasi, Zakat, Liburan';

  @override
  String get categoryManagementCardCancelButton => 'Batal';

  @override
  String get categoryManagementCardSaveButton => 'Simpan';

  @override
  String get categoryManagementCardEditDialogTitle => 'Ubah Nama Kategori';

  @override
  String get categoryManagementCardDeleteDialogTitle => 'Hapus Kategori?';

  @override
  String categoryManagementCardDeleteDialogMessage(String name) {
    return 'Apakah Anda yakin ingin menghapus kategori \"$name\"?';
  }

  @override
  String get categoryManagementCardDeleteButton => 'Hapus';

  @override
  String get categoryManagementCardTitle => 'Kelola Kategori';

  @override
  String get categoryManagementCardSubtitle =>
      'Kategori bawaan & kustom untuk transaksi';

  @override
  String get categoryManagementCardAddTooltip => 'Tambah Kategori';

  @override
  String get categoryManagementCardLoadingDefaults =>
      'Memuat kategori default...';

  @override
  String get categoryManagementCardDefaultBadge => 'Bawaan';

  @override
  String get categoryManagementCardEditTooltip => 'Ubah Nama';

  @override
  String get categoryManagementCardDeleteTooltip => 'Hapus Kategori';

  @override
  String categoryManagementCardLoadError(Object error) {
    return 'Gagal memuat kategori: $error';
  }

  @override
  String get mandatoryExpensesCardTitle => 'Pengeluaran Wajib';

  @override
  String get mandatoryExpensesCardSubtitle =>
      'Pengeluaran tetap & rutin untuk alokasi anggaran';

  @override
  String get mandatoryExpensesCardAddTooltip => 'Tambah Pengeluaran Wajib';

  @override
  String get mandatoryExpensesCardEmptyMessage =>
      'Belum ada pengeluaran wajib ditambahkan.';

  @override
  String get mandatoryExpensesCardAddDialogTitle => 'Tambah Pengeluaran Wajib';

  @override
  String get mandatoryExpensesCardEditDialogTitle => 'Ubah Pengeluaran Wajib';

  @override
  String get mandatoryExpensesCardDeleteDialogTitle =>
      'Hapus Pengeluaran Wajib?';

  @override
  String mandatoryExpensesCardDeleteDialogMessage(String name) {
    return 'Apakah Anda yakin ingin menghapus \"$name\"?';
  }

  @override
  String get mandatoryExpensesCardDeleteButton => 'Hapus';

  @override
  String get mandatoryExpensesCardCancelButton => 'Batal';

  @override
  String get mandatoryExpensesCardSaveButton => 'Simpan';

  @override
  String get mandatoryExpensesCardNameLabel => 'Nama Pengeluaran';

  @override
  String get mandatoryExpensesCardNameHint =>
      'Contoh: Sewa Kos, Listrik, Wi-Fi';

  @override
  String get mandatoryExpensesCardAmountLabel => 'Jumlah';

  @override
  String get mandatoryExpensesCardEditTooltip => 'Ubah';

  @override
  String get mandatoryExpensesCardDeleteTooltip => 'Hapus';

  @override
  String get mandatoryExpensesCardNameEmptyError => 'Nama tidak boleh kosong';

  @override
  String get mandatoryExpensesCardAmountEmptyError =>
      'Jumlah tidak boleh kosong';

  @override
  String get mandatoryExpensesCardAmountInvalidError =>
      'Jumlah tidak boleh negatif atau nol';

  @override
  String get walletsManagementCardTitle => 'Kelola Dompet & Rekening';

  @override
  String get walletsManagementCardSubtitle =>
      'Atur dompet, rekening bank, saldo awal & transfer';

  @override
  String get walletsManagementCardOpenTooltip => 'Buka Kelola Dompet';

  @override
  String get dataManagementCardTitle => 'Cadangkan & Pulihkan Data';

  @override
  String get dataManagementCardSubtitle =>
      'Format JSON & CSV (100% Offline, FR-08)';

  @override
  String get dataManagementCardDescription =>
      'Cadangkan seluruh database secara berkala atau pindahkan data finansial ke perangkat baru tanpa koneksi server.';

  @override
  String get dataManagementCardProcessingMessage => 'Sedang memproses data...';

  @override
  String get dataManagementCardExportSuccessTitle => 'Ekspor Berhasil!';

  @override
  String get dataManagementCardExportJsonTitle => 'Cadangkan Database (JSON)';

  @override
  String get dataManagementCardExportJsonSubtitle =>
      'Simpan semua koleksi (profil, gajian, kategori, transaksi, goals, aset) ke file JSON.';

  @override
  String get dataManagementCardExportJsonButton => 'Cadangkan (JSON)';

  @override
  String dataManagementCardExportJsonSuccessToast(String path) {
    return 'File cadangan tersimpan di:\n$path';
  }

  @override
  String get dataManagementCardExportCsvTitle =>
      'Ekspor Riwayat Transaksi (CSV)';

  @override
  String get dataManagementCardExportCsvSubtitle =>
      'Format tabel CSV RFC 4180 dengan header berbahasa Indonesia untuk spreadsheet.';

  @override
  String get dataManagementCardExportCsvButton => 'Ekspor CSV';

  @override
  String dataManagementCardExportCsvSuccessToast(String path) {
    return 'Tabel transaksi CSV tersimpan di:\n$path';
  }

  @override
  String get dataManagementCardRestoreTitle => 'Pulihkan Data (JSON)';

  @override
  String get dataManagementCardRestoreSubtitle =>
      'Pilih file .json cadangan untuk mengembalikan seluruh database ke kondisi tersimpan.';

  @override
  String get dataManagementCardRestoreButton => 'Pilih File Cadangan';

  @override
  String get dataManagementCardRestoreSuccessToast =>
      'Database lokal berhasil dipulihkan dari cadangan.';

  @override
  String get restoreConfirmationDialogTitle => 'Konfirmasi Pemulihan Data';

  @override
  String get restoreConfirmationDialogWarningMessage =>
      'PERHATIAN: Pemulihan akan menghapus dan menimpa SELURUH data lokal saat ini. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get restoreConfirmationDialogSummaryTitle =>
      'Ringkasan Data Cadangan:';

  @override
  String get restoreConfirmationDialogBackupTimeLabel => 'Waktu Cadangan';

  @override
  String get restoreConfirmationDialogUserProfileLabel => 'Profil Pengguna';

  @override
  String get restoreConfirmationDialogAvailableValue => 'Tersedia';

  @override
  String get restoreConfirmationDialogNotAvailableValue => 'Tidak Ada';

  @override
  String get restoreConfirmationDialogPayCycleLabel => 'Siklus Gaji';

  @override
  String restoreConfirmationDialogPayCycleCountValue(int count) {
    return '$count data';
  }

  @override
  String get restoreConfirmationDialogCategoryLabel => 'Kategori';

  @override
  String restoreConfirmationDialogCategoryCountValue(int count) {
    return '$count kategori';
  }

  @override
  String get restoreConfirmationDialogTransactionLabel => 'Riwayat Transaksi';

  @override
  String restoreConfirmationDialogTransactionCountValue(int count) {
    return '$count transaksi';
  }

  @override
  String get restoreConfirmationDialogGoalLabel => 'Target Finansial (Goals)';

  @override
  String restoreConfirmationDialogGoalCountValue(int count) {
    return '$count target';
  }

  @override
  String get restoreConfirmationDialogAssetLabel => 'Aset / Investasi';

  @override
  String restoreConfirmationDialogAssetCountValue(int count) {
    return '$count aset';
  }

  @override
  String get restoreConfirmationDialogCancelButton => 'Batal';

  @override
  String get restoreConfirmationDialogConfirmButton => 'Timpa & Pulihkan';

  @override
  String get payCycleTransitionScreenTitle => 'Transisi Siklus';

  @override
  String payCycleTransitionScreenLoadProfileError(Object error) {
    return 'Gagal memuat profil: $error';
  }

  @override
  String get payCycleTransitionScreenProfileNotFound =>
      'Profil tidak ditemukan.';

  @override
  String get payCycleTransitionScreenSalaryEmptyError =>
      'Gaji siklus baru tidak boleh kosong';

  @override
  String get payCycleTransitionScreenSalaryInvalidError =>
      'Gaji harus lebih besar dari nol';

  @override
  String get payCycleTransitionScreenExpenseNameEmptyError =>
      'Nama pengeluaran tidak boleh kosong';

  @override
  String get payCycleTransitionScreenAmountEmptyError =>
      'Jumlah tidak boleh kosong';

  @override
  String get payCycleTransitionScreenAmountInvalidError =>
      'Jumlah harus lebih besar dari nol';

  @override
  String get payCycleTransitionScreenIncompleteDataError =>
      'Harap lengkapi semua data yang diperlukan.';

  @override
  String get payCycleTransitionHeaderPeriodicTitle => 'Siklus Gajian Baru';

  @override
  String get payCycleTransitionHeaderDailyTitle => 'Rollover Harian';

  @override
  String get payCycleTransitionHeaderPeriodicMessage =>
      'Siklus sebelumnya telah berakhir. Masukkan gaji dan pengeluaran wajib siklus baru secara manual (BR-02: tidak ada template otomatis).';

  @override
  String get payCycleTransitionHeaderDailyMessage =>
      'Hari baru telah tiba. Konfirmasi sisa saldo kemarin dan masukkan bekel serta pengeluaran wajib hari ini (BR-02: re-input manual tiap periode).';

  @override
  String get payCycleTransitionIntervalDateTitle =>
      'Interval & Tanggal Gajian Berikutnya';

  @override
  String get payCycleTransitionPickPaydayButton => 'Pilih tanggal gajian';

  @override
  String payCycleTransitionPaydaySelectedButton(String date) {
    return 'Gajian: $date';
  }

  @override
  String get payCycleTransitionIntervalWeekly => 'Mingguan';

  @override
  String get payCycleTransitionIntervalBiweekly => '2 Mingguan';

  @override
  String get payCycleTransitionIntervalMonthly => 'Bulanan';

  @override
  String get payCycleTransitionIntervalCustom => 'Custom';

  @override
  String get payCycleTransitionSalaryLabel => 'Gaji Siklus Ini (Wajib diisi)';

  @override
  String get payCycleTransitionSalaryHelper =>
      'Sesuai BR-02: masukkan nominal gaji baru secara manual.';

  @override
  String get payCycleTransitionCarryOverTitle =>
      'Saldo Carry-Over dari Kemarin';

  @override
  String get payCycleTransitionCarryOverMessage =>
      'Sisa Uang Jajan Aman kemarin terakumulasi otomatis ke saldo hari ini.';

  @override
  String get payCycleTransitionBekelLabel => 'Bekel Hari Ini (Opsional)';

  @override
  String get payCycleTransitionBekelHelper =>
      'Kosongkan atau isi 0 jika hari ini tidak ada uang saku baru.';

  @override
  String get payCycleTransitionExpensesPeriodicTitle =>
      'Pengeluaran Wajib Siklus Ini';

  @override
  String get payCycleTransitionExpensesDailyTitle =>
      'Pengeluaran Wajib Hari Ini';

  @override
  String get payCycleTransitionExpensesSubtitle =>
      'Opsional — per BR-02, daftar pengeluaran wajib diinput manual tiap periode (tidak dicopy dari siklus lama).';

  @override
  String get payCycleTransitionExpensesEmptyMessage =>
      'Belum ada pengeluaran wajib ditambahkan.';

  @override
  String get payCycleTransitionRemoveExpenseTooltip => 'Hapus Pengeluaran';

  @override
  String get payCycleTransitionExpenseNameFieldLabel =>
      'Nama pengeluaran (mis. Kos, Cicilan)';

  @override
  String get payCycleTransitionExpenseAmountFieldLabel => 'Nominal pengeluaran';

  @override
  String get payCycleTransitionAddExpenseButton => 'Tambah Pengeluaran Wajib';

  @override
  String get payCycleTransitionStartNewCycleButton => 'Mulai Siklus Baru';

  @override
  String get payCycleTransitionStartTodayButton => 'Mulai Hari Ini';

  @override
  String get currencyPrefix => 'Rp ';

  @override
  String get currencyHintZero => 'Rp 0';

  @override
  String get notificationChannelDailyReminder => 'Pengingat Harian';

  @override
  String get notificationChannelDailyReminderDescription =>
      'Pengingat harian untuk mencatat transaksi keuangan';

  @override
  String get notificationDailyReminderTitle => 'Saatnya Catat Keuangan!';

  @override
  String get notificationDailyReminderBody =>
      'Jangan lupa mencatat pengeluaran dan pemasukan hari ini di LedgerMate.';

  @override
  String get notificationChannelLimitAlert => 'Peringatan Limit Anggaran';

  @override
  String get notificationChannelLimitAlertDescription =>
      'Pemberitahuan saat budget harian habis atau mendekati 0';

  @override
  String get notificationLimitAlertTitle =>
      'Peringatan: Limit Harian Terlampaui!';

  @override
  String notificationLimitAlertBody(String amount) {
    return 'Uang jajan aman hari ini tersisa $amount. Tahan pengeluaran non-esensial.';
  }

  @override
  String get notificationChannelPayCycle => 'Siklus Gajian';

  @override
  String get notificationChannelPayCycleDescription =>
      'Pemberitahuan awal atau berakhirnya siklus gajian';

  @override
  String get notificationChannelGoalMilestone => 'Target Finansial (Goals)';

  @override
  String get notificationChannelGoalMilestoneDescription =>
      'Pemberitahuan pencapaian milestone target tabungan';

  @override
  String get notificationGoalMilestoneTitle => 'Milestone Target Tercapai! 🎉';

  @override
  String notificationGoalMilestoneBody(String goalName, int percent) {
    return 'Target \"$goalName\" telah mencapai $percent%! Tetap konsisten menabung!';
  }

  @override
  String get notificationPayCyclePeriodicStartTitle => 'Siklus Baru Dimulai';

  @override
  String get notificationPayCycleDailyStartTitle => 'Siklus Harian Baru';

  @override
  String notificationPayCyclePeriodicStartBody(int day, int month, int year) {
    return 'Siklus baru aktif hingga $day/$month/$year. Budget harian telah disesuaikan.';
  }

  @override
  String get notificationPayCycleDailyStartBody =>
      'Bekel harian telah dicatat. Uang jajan aman siap digunakan hari ini.';

  @override
  String get notificationPayCycleExpiredTitle => 'Siklus Gajian Telah Tiba!';

  @override
  String get notificationPayCycleExpiredBody =>
      'Waktunya perbarui gaji dan pengeluaran wajib untuk memulai siklus baru.';

  @override
  String get walletIconCash => 'Dompet / Tunai';

  @override
  String get walletIconBank => 'Bank / Rekening';

  @override
  String get walletIconCard => 'Kartu Debit / Kredit';

  @override
  String get walletIconEwallet => 'E-Wallet';

  @override
  String get walletIconSavings => 'Tabungan';

  @override
  String get walletIconPayments => 'Kas / Uang';

  @override
  String get walletIconInvestment => 'Investasi / Valas';

  @override
  String get walletIconBusiness => 'Bisnis / Toko';

  @override
  String get defaultCategoryFood => 'Makan';

  @override
  String get defaultCategoryTransport => 'Transport';

  @override
  String get defaultCategoryEntertainment => 'Hiburan';

  @override
  String get defaultCategoryBills => 'Tagihan';

  @override
  String get defaultCategoryOther => 'Lainnya';

  @override
  String get transactionTypeTransferLabel => 'Transfer';

  @override
  String transactionCategoryFallback(int id) {
    return 'Kategori #$id';
  }

  @override
  String get monthJanuary => 'Januari';

  @override
  String get monthFebruary => 'Februari';

  @override
  String get monthMarch => 'Maret';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'Mei';

  @override
  String get monthJune => 'Juni';

  @override
  String get monthJuly => 'Juli';

  @override
  String get monthAugust => 'Agustus';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'Oktober';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'Desember';

  @override
  String analyticsDateRangeDaily(int day, String month, int year) {
    return '$day $month $year';
  }

  @override
  String analyticsDateRangeWeekly(
    int startDay,
    String startMonth,
    int endDay,
    String endMonth,
    int year,
  ) {
    return '$startDay $startMonth - $endDay $endMonth $year';
  }

  @override
  String analyticsDateRangeMonthly(String month, int year) {
    return '$month $year';
  }

  @override
  String get analyticsCategoryFallback => 'Lainnya';

  @override
  String get assetValidationPurchaseValuePositive =>
      'Nilai beli/modal awal harus lebih besar dari 0.';

  @override
  String get assetValidationCurrentValueNotNegative =>
      'Nilai sekarang tidak boleh negatif.';

  @override
  String get goalValidationNameRequired => 'Nama target tidak boleh kosong.';

  @override
  String get goalValidationTargetPositive =>
      'Target nominal harus lebih besar dari 0.';

  @override
  String get goalValidationCurrentNotNegative =>
      'Saldo saat ini tidak boleh negatif.';

  @override
  String get goalValidationDailyAllocationPositive =>
      'Alokasi harian manual harus lebih besar dari 0.';

  @override
  String get goalValidationWithdrawPositive =>
      'Nominal penarikan harus lebih besar dari 0.';

  @override
  String get goalValidationWithdrawExceedsBalance =>
      'Nominal penarikan melebihi saldo tabungan saat ini.';

  @override
  String goalWithdrawTransactionNote(String goalName) {
    return 'Tarik dari goal: $goalName';
  }

  @override
  String get walletValidationHasTransactions =>
      'Dompet tidak dapat dihapus karena masih memiliki transaksi terkait. Pindahkan atau hapus transaksi terlebih dahulu.';

  @override
  String get walletValidationMinimumOne =>
      'Minimal harus ada 1 dompet aktif di aplikasi.';

  @override
  String get walletValidationNameRequired => 'Nama dompet tidak boleh kosong.';

  @override
  String get walletValidationStartingBalanceNotNegative =>
      'Saldo awal tidak boleh negatif.';

  @override
  String get walletValidationTransferAmountPositive =>
      'Nominal transfer harus lebih besar dari nol.';

  @override
  String get settingsCategoryDeleteInUseError =>
      'Kategori tidak dapat dihapus karena masih digunakan oleh transaksi.';

  @override
  String get defaultWalletName => 'Dompet Utama';

  @override
  String get payCycleBekelTransactionNote => 'Bekel hari ini';

  @override
  String get withdrawDialogChip25 => '25%';

  @override
  String get withdrawDialogChip50 => '50%';

  @override
  String transferWalletDropdownItem(String name, String balance) {
    return '$name ($balance)';
  }

  @override
  String get homeScreenDateFormatLocale => 'id_ID';
}
