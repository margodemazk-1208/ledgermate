// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LedgerMate';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get dataManagement => 'Backup & Restore';

  @override
  String get appearanceAndLanguage => 'Appearance & Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'App Language';

  @override
  String get notificationsTitle => 'Notifications & Reminders';

  @override
  String get dailyReminder => 'Daily Logging Reminder';

  @override
  String get limitAlert => 'Daily Limit Exceeded Alert';

  @override
  String get payCycleAlert => 'New Pay Cycle Alert';

  @override
  String get goalMilestoneAlert => 'Goal Milestone Alert';

  @override
  String get categoryManagement => 'Manage Categories';

  @override
  String get aboutTitle => 'About LedgerMate';

  @override
  String appRootDataLoadErrorMessage(Object error) {
    return 'Failed to load data: $error';
  }

  @override
  String get initialIncomeStepPeriodicTitle => 'This Cycle\'s Salary';

  @override
  String get initialIncomeStepDailyTitle => 'Today\'s Starting Allowance';

  @override
  String get initialIncomeStepPeriodicSubtitle =>
      'Enter the total fixed salary for this pay cycle.';

  @override
  String get initialIncomeStepDailySubtitle =>
      'Enter the money you already have to start today.';

  @override
  String get initialIncomeStepEmptyAmountError => 'Amount cannot be empty';

  @override
  String get initialIncomeStepInvalidAmountError =>
      'Amount cannot be negative or zero';

  @override
  String get initialIncomeStepPeriodicLabel => 'Fixed salary';

  @override
  String get initialIncomeStepDailyLabel => 'Initial amount';

  @override
  String get incomeFrequencyStepTitle => 'Your Income Pattern';

  @override
  String get incomeFrequencyStepSubtitle =>
      'Choose whichever best matches how you receive money.';

  @override
  String get incomeFrequencyStepPeriodicTitle => 'Periodic';

  @override
  String get incomeFrequencyStepPeriodicDescription =>
      'A lump-sum payday on a specific date — weekly, biweekly, monthly, or custom.';

  @override
  String get incomeFrequencyStepDailyTitle => 'Daily';

  @override
  String get incomeFrequencyStepDailyDescription =>
      'Allowance/income received every day (including irregular schedules) — with no fixed payday.';

  @override
  String get incomeFrequencyStepIntervalLabel => 'Interval';

  @override
  String get incomeFrequencyStepNextPaydayLabel => 'Next income date';

  @override
  String get incomeFrequencyStepPickDate => 'Pick a date';

  @override
  String get incomeFrequencyStepIntervalWeekly => 'Weekly';

  @override
  String get incomeFrequencyStepIntervalBiweekly => 'Biweekly';

  @override
  String get incomeFrequencyStepIntervalMonthly => 'Monthly';

  @override
  String get incomeFrequencyStepIntervalCustom => 'Custom';

  @override
  String get mandatoryExpensesStepTitle => 'Mandatory Expenses';

  @override
  String get mandatoryExpensesStepSubtitle =>
      'Rent, installments, etc — optional, add as many as you need.';

  @override
  String get mandatoryExpensesStepEmptyMessage =>
      'No mandatory expenses added yet.';

  @override
  String get mandatoryExpensesStepNameEmptyError => 'Name cannot be empty';

  @override
  String get mandatoryExpensesStepAmountEmptyError => 'Amount cannot be empty';

  @override
  String get mandatoryExpensesStepInvalidAmountError =>
      'Amount cannot be negative or zero';

  @override
  String get mandatoryExpensesStepDeleteTooltip => 'Delete Expense';

  @override
  String get mandatoryExpensesStepNameFieldLabel => 'Expense name';

  @override
  String get mandatoryExpensesStepAmountFieldLabel => 'Amount';

  @override
  String get mandatoryExpensesStepAddButton => 'Add expense';

  @override
  String get walletSetupStepTitle => 'Set Up Your First Wallet';

  @override
  String get walletSetupStepSubtitle =>
      'A wallet to hold your money (e.g. Cash, Bank Account, E-Wallet). You can add more wallets later.';

  @override
  String get walletSetupStepNameFieldLabel => 'Wallet Name';

  @override
  String get walletSetupStepNameFieldHint =>
      'e.g. Main Wallet, Cash, BCA Account';

  @override
  String get walletSetupStepNameEmptyError => 'Wallet name cannot be empty';

  @override
  String get walletSetupStepIconPickerLabel => 'Choose Wallet Icon';

  @override
  String get walletSetupStepStartingBalanceLabel => 'Starting Balance';

  @override
  String get walletSetupStepStartingBalanceHelper =>
      'The real balance currently in this wallet when you start using the app.';

  @override
  String get walletSetupStepNegativeBalanceError =>
      'Starting balance cannot be negative';

  @override
  String get walletSetupStepIncludeBudgetTitle => 'Include in Daily Budget';

  @override
  String get walletSetupStepIncludeBudgetSubtitle =>
      'Money in this wallet will be counted into today\'s Safe Allowance (BR-04).';

  @override
  String get onboardingScreenBackButton => 'Back';

  @override
  String get onboardingScreenFinishButton => 'Finish';

  @override
  String get onboardingScreenNextButton => 'Next';

  @override
  String get onboardingScreenIncompleteDataError =>
      'Data is incomplete — go back to the previous step.';

  @override
  String get realismWarningDialogTitle => 'This Target Might Be Too Heavy';

  @override
  String realismWarningDialogImpactMessage(String amount) {
    return 'If this target is saved, your total daily savings allocation becomes $amount/day.';
  }

  @override
  String realismWarningDialogNegativeBudgetMessage(String amount) {
    return 'This will push today\'s Safe Allowance into negative territory: $amount/day.';
  }

  @override
  String get realismWarningDialogHint =>
      'Extending the target date will lower the daily savings portion so your daily budget stays safe.';

  @override
  String get realismWarningDialogExtendButton => 'Extend target date';

  @override
  String get realismWarningDialogProceedButton =>
      'Proceed, I understand the risk';

  @override
  String get unsavedChangesGuardDialogTitle => 'Discard Changes?';

  @override
  String get unsavedChangesGuardDialogContent =>
      'You have unsaved changes. Are you sure you want to leave without saving?';

  @override
  String get unsavedChangesGuardContinueEditingButton => 'Continue Editing';

  @override
  String get unsavedChangesGuardDiscardButton => 'Discard Changes';

  @override
  String get databaseErrorScreenTitle => 'Failed to Load Local Data';

  @override
  String get databaseErrorScreenDescription =>
      'LedgerMate could not open the local database on this device. This can happen if storage is full or a process was interrupted while last saving data.';

  @override
  String get databaseErrorScreenSuggestion =>
      'Try: (1) make sure your device has enough free storage, then press \"Try Again\"; (2) if it still fails, fully restart the app. Your data will not be lost unless the app is uninstalled.';

  @override
  String get databaseErrorScreenRetryButton => 'Try Again';

  @override
  String get appBottomNavHomeLabel => 'Home';

  @override
  String get appBottomNavTransactionsLabel => 'Transactions';

  @override
  String get appBottomNavGoalsLabel => 'Goals';

  @override
  String get appBottomNavAssetsLabel => 'Assets';

  @override
  String get appBottomNavAnalyticsLabel => 'Analytics';

  @override
  String get appBottomNavSettingsLabel => 'Settings';

  @override
  String get fabSpeedDialCloseBarrierLabel => 'Close';

  @override
  String get fabSpeedDialAddAssetLabel => 'Add New Asset';

  @override
  String get fabSpeedDialAddGoalLabel => 'Add New Goal';

  @override
  String get fabSpeedDialTransferLabel => 'Transfer Between Wallets';

  @override
  String get fabSpeedDialIncomeLabel => 'Record Income';

  @override
  String get fabSpeedDialExpenseLabel => 'Record Expense';

  @override
  String get goalsScreenTitle => 'Savings Goals';

  @override
  String goalsScreenLoadError(Object error) {
    return 'Failed to load savings goals: $error';
  }

  @override
  String get goalsScreenEmptyTitle => 'No Savings Goals Yet';

  @override
  String get goalsScreenEmptyMessage =>
      'Create a financial goal to track your estimated completion date and automatically set aside daily savings.';

  @override
  String get goalsScreenCreateFirstButton => 'Create First Goal';

  @override
  String goalsScreenActiveListHeader(int count) {
    return 'Active Goals List ($count)';
  }

  @override
  String goalsScreenCompletedCountLabel(int count) {
    return '$count completed';
  }

  @override
  String get goalsScreenAddGoalCardLabel => 'Add New Goal';

  @override
  String get goalsOverviewCardTitle => 'Total Savings Progress';

  @override
  String get goalsOverviewCardCollectedLabel => 'Collected';

  @override
  String get goalsOverviewCardTargetLabel => 'Total Target';

  @override
  String get goalsOverviewCardDailyReserveLabel => 'Reserve/Day';

  @override
  String get goalFormScreenEditTitle => 'Edit Savings Goal';

  @override
  String get goalFormScreenAddTitle => 'Add New Goal';

  @override
  String get goalFormScreenNameLabel => 'Goal Name';

  @override
  String get goalFormScreenNameHint => 'e.g. New Laptop, Emergency Fund';

  @override
  String get goalFormScreenNameEmptyError => 'Goal name cannot be empty';

  @override
  String get goalFormScreenTargetAmountLabel => 'Target Amount';

  @override
  String get goalFormScreenTargetAmountError =>
      'Target amount must be greater than 0';

  @override
  String get goalFormScreenCurrentAmountLabel =>
      'Starting Balance / Already Saved';

  @override
  String get goalFormScreenCurrentAmountHelper =>
      'Fill in if you already started saving before this goal was created';

  @override
  String get goalFormScreenCurrentAmountNegativeError =>
      'Balance cannot be negative';

  @override
  String get goalFormScreenTargetDateTitle => 'Target Completion Date';

  @override
  String get goalFormScreenManualAllocationTitle =>
      'Manual Daily Allocation Override';

  @override
  String get goalFormScreenManualAllocationSubtitle =>
      'Set a fixed daily savings amount instead of the automatic formula calculation.';

  @override
  String get goalFormScreenManualAllocationFieldLabel =>
      'Daily Allocation Amount (Rp/day)';

  @override
  String get goalFormScreenManualAllocationHelper =>
      'This amount directly replaces the automatic formula calculation';

  @override
  String get goalFormScreenManualAllocationError =>
      'Enter a daily allocation greater than 0';

  @override
  String get goalFormScreenTargetAmountRequiredError =>
      'Target amount must be greater than 0.';

  @override
  String get goalFormScreenTargetDateError =>
      'Target date must be after today.';

  @override
  String get goalFormScreenSaveSuccessToast =>
      'Savings goal saved successfully';

  @override
  String goalFormScreenSaveError(Object error) {
    return 'Failed to save goal: $error';
  }

  @override
  String get goalFormScreenUpdateButton => 'Update Goal';

  @override
  String get goalFormScreenSaveButton => 'Save Goal';

  @override
  String get goalCardDeleteDialogTitle => 'Delete Goal?';

  @override
  String goalCardDeleteDialogMessage(String goalName) {
    return 'Are you sure you want to delete the goal \"$goalName\"? This action cannot be undone.';
  }

  @override
  String get goalCardCancelButton => 'Cancel';

  @override
  String get goalCardDeleteButton => 'Delete';

  @override
  String goalCardTargetDateLabel(String date) {
    return 'Target: $date';
  }

  @override
  String get goalCardCompletedBadge => 'Achieved';

  @override
  String get goalCardManualOverrideBadge => 'Manual Override';

  @override
  String goalCardTargetAmountLabel(String targetAmount, int percent) {
    return '$targetAmount ($percent%)';
  }

  @override
  String get goalCardCompletedMessage => 'The goal has been fully achieved!';

  @override
  String goalCardEstimatedCompletionMessage(String date) {
    return 'Estimated completion: $date';
  }

  @override
  String get goalCardNoEstimateMessage => 'No estimate yet (0 allocation)';

  @override
  String get goalCardDoneLabel => 'Done';

  @override
  String goalCardDailyAllocationLabel(String amount) {
    return '$amount/day';
  }

  @override
  String get goalCardWithdrawButton => 'Withdraw from Goal';

  @override
  String get goalCardEditButton => 'Edit';

  @override
  String get goalCardDeleteTooltip => 'Delete Goal';

  @override
  String get withdrawDialogInvalidAmountError =>
      'Amount must be greater than 0.';

  @override
  String get withdrawDialogExceedsBalanceError =>
      'Amount exceeds current savings.';

  @override
  String get withdrawDialogConfirmTitle => 'Confirm Withdrawal';

  @override
  String withdrawDialogConfirmMessage(String amount, String goalName) {
    return 'Withdraw $amount from the goal \"$goalName\"?\n\nThe goal\'s balance will decrease and this amount will automatically return to the current period\'s active balance.';
  }

  @override
  String get withdrawDialogCancelButton => 'Cancel';

  @override
  String get withdrawDialogConfirmSubmitButton => 'Withdraw Now';

  @override
  String withdrawDialogSuccessToast(String amount) {
    return 'Withdrawal of $amount successful';
  }

  @override
  String withdrawDialogGenericError(Object error) {
    return 'Failed to withdraw: $error';
  }

  @override
  String get withdrawDialogTitle => 'Withdraw from Goal';

  @override
  String withdrawDialogTargetLabel(String goalName) {
    return 'Goal: $goalName';
  }

  @override
  String withdrawDialogAvailableLabel(String amount) {
    return 'Currently available: $amount';
  }

  @override
  String get withdrawDialogAmountFieldLabel => 'Withdrawal Amount';

  @override
  String get withdrawDialogInvalidAmountValidator => 'Enter a valid amount';

  @override
  String get withdrawDialogExceedsBalanceValidator =>
      'Exceeds collected balance';

  @override
  String get withdrawDialogChipAll => 'All';

  @override
  String get withdrawDialogSubmitButton => 'Continue Withdrawal';

  @override
  String get assetsScreenTitle => 'Assets & Investments';

  @override
  String get assetsScreenAddTooltip => 'Add Asset';

  @override
  String assetsScreenLoadError(Object error) {
    return 'Failed to load asset data: $error';
  }

  @override
  String get assetsScreenEmptyTitle => 'No Assets Registered Yet';

  @override
  String get assetsScreenEmptyMessage =>
      'Track your net worth independently. Record assets like gold, stocks, mutual funds, or crypto with 100% offline manual updates.';

  @override
  String get assetsScreenAddFirstButton => 'Add First Asset';

  @override
  String get assetsScreenPortfolioTotalLabel => 'Total Asset Portfolio';

  @override
  String assetsScreenAssetCountBadge(int count) {
    return '$count Assets';
  }

  @override
  String get assetsScreenTotalPurchaseLabel => 'Total Initial Capital';

  @override
  String get assetsScreenTotalGainLabel => 'Total Gain';

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
    return 'Asset List ($count)';
  }

  @override
  String get assetsScreenAddCardLabel => 'Add New Asset';

  @override
  String get assetCardDeleteDialogTitle => 'Delete Asset?';

  @override
  String assetCardDeleteDialogMessage(String assetName) {
    return 'Are you sure you want to delete the asset \"$assetName\"? This action cannot be undone.';
  }

  @override
  String get assetCardCancelButton => 'Cancel';

  @override
  String get assetCardDeleteButton => 'Delete';

  @override
  String get assetCardEditTooltip => 'Full Edit';

  @override
  String get assetCardDeleteTooltip => 'Delete Asset';

  @override
  String get assetCardPurchaseValueLabel => 'Initial Capital';

  @override
  String get assetCardCurrentValueLabel => 'Current Value';

  @override
  String get assetCardGainLossLabel => 'Gain / Loss';

  @override
  String assetCardGainLossValue(String sign, String amount, String percent) {
    return '$sign$amount ($sign$percent%)';
  }

  @override
  String assetCardLastUpdatedLabel(String date) {
    return 'Updated: $date';
  }

  @override
  String get assetCardUpdateValueButton => 'Update Value';

  @override
  String get assetFormScreenEditTitle => 'Edit Asset';

  @override
  String get assetFormScreenAddTitle => 'Add Asset';

  @override
  String get assetFormScreenNameLabel => 'Asset Name';

  @override
  String get assetFormScreenNameHint =>
      'e.g. 10g Antam Gold, BBCA, Money Market Fund';

  @override
  String get assetFormScreenNameEmptyError => 'Asset name cannot be empty.';

  @override
  String get assetFormScreenTypeLabel => 'Asset Type';

  @override
  String get assetFormScreenTypeHint =>
      'e.g. Gold, Stocks, Mutual Fund, Crypto';

  @override
  String get assetFormScreenTypeEmptyError => 'Asset type cannot be empty.';

  @override
  String get assetFormScreenPurchaseValueLabel =>
      'Initial Capital / Purchase Value (Rp)';

  @override
  String get assetFormScreenPurchaseValueEmptyError =>
      'Initial capital cannot be empty.';

  @override
  String get assetFormScreenPurchaseValueInvalidError =>
      'Initial capital must be greater than 0.';

  @override
  String get assetFormScreenCurrentValueLabel => 'Current Value (Rp)';

  @override
  String get assetFormScreenCopyFromPurchaseButton => 'Same as capital';

  @override
  String get assetFormScreenCurrentValueEmptyError =>
      'Current value cannot be empty.';

  @override
  String get assetFormScreenCurrentValueNegativeError =>
      'Current value cannot be negative.';

  @override
  String get assetFormScreenGainLossPreviewLabel => 'Estimated Gain / Loss:';

  @override
  String get assetFormScreenOfflineNotice =>
      '100% Offline. Asset values are updated manually by you at any time (D8).';

  @override
  String get assetFormScreenPurchaseRequiredError =>
      'Initial capital must be greater than 0.';

  @override
  String get assetFormScreenCurrentValueRequiredError =>
      'Current value cannot be empty or negative.';

  @override
  String get assetFormScreenSaveSuccessToast => 'Asset saved successfully';

  @override
  String assetFormScreenSaveError(Object error) {
    return 'Failed to save asset: $error';
  }

  @override
  String get assetFormScreenSaveChangesButton => 'Save Changes';

  @override
  String get assetFormScreenAddButton => 'Add Asset';

  @override
  String get assetFormScreenTypeGold => 'Gold';

  @override
  String get assetFormScreenTypeStocks => 'Stocks';

  @override
  String get assetFormScreenTypeMutualFund => 'Mutual Fund';

  @override
  String get assetFormScreenTypeCrypto => 'Crypto';

  @override
  String get assetFormScreenTypeProperty => 'Property';

  @override
  String get assetFormScreenTypeDeposit => 'Deposit';

  @override
  String get assetFormScreenTypeOther => 'Other';

  @override
  String get updateValueDialogTitle => 'Update Asset Value';

  @override
  String updateValueDialogTypeLabel(String type) {
    return 'Type: $type';
  }

  @override
  String get updateValueDialogPurchaseValueLabel => 'Initial Capital';

  @override
  String get updateValueDialogPreviousValueLabel => 'Previous Value';

  @override
  String updateValueDialogLastUpdatedLabel(String date) {
    return 'Last updated: $date';
  }

  @override
  String get updateValueDialogNewValueLabel => 'New Current Value';

  @override
  String get updateValueDialogEmptyValueError => 'Asset value cannot be empty.';

  @override
  String get updateValueDialogNegativeValueError => 'Value cannot be negative.';

  @override
  String get updateValueDialogRequiredError =>
      'Asset value cannot be empty or negative.';

  @override
  String get updateValueDialogNewGainLossLabel => 'New Estimated Gain / Loss:';

  @override
  String updateValueDialogChangeFromPreviousLabel(String sign, String amount) {
    return 'Change from previous: $sign$amount';
  }

  @override
  String updateValueDialogGenericError(Object error) {
    return 'Failed to update value: $error';
  }

  @override
  String get updateValueDialogSuccessToast =>
      'Asset value updated successfully';

  @override
  String get updateValueDialogCancelButton => 'Cancel';

  @override
  String get updateValueDialogSaveButton => 'Save Update';

  @override
  String get analyticsScreenTitle => 'Visual Analytics';

  @override
  String get analyticsScreenThemeToggleToLight => 'Switch to light mode';

  @override
  String get analyticsScreenThemeToggleToDark => 'Switch to dark mode';

  @override
  String analyticsScreenLoadError(Object error) {
    return 'Failed to load analytics: $error';
  }

  @override
  String analyticsScreenTrendLoadError(Object error) {
    return 'Failed to load trend: $error';
  }

  @override
  String get analyticsScreenFilterDaily => 'Daily';

  @override
  String get analyticsScreenFilterWeekly => 'Weekly';

  @override
  String get analyticsScreenFilterMonthly => 'Monthly';

  @override
  String get analyticsEmptyStateDefaultMessage =>
      'No transactions in this period yet.';

  @override
  String get analyticsEmptyStateDefaultSubmessage =>
      'Record an expense or income to see chart visualizations and financial trends.';

  @override
  String get analyticsEmptyStateRecordButton => 'Record Transaction';

  @override
  String get incomeExpenseRatioCardTitle => 'Period Financial Summary';

  @override
  String get incomeExpenseRatioCardTotalIncomeLabel => 'Total Income';

  @override
  String get incomeExpenseRatioCardTotalExpenseLabel => 'Total Expense';

  @override
  String get incomeExpenseRatioCardNetSavingsLabel => 'Net Savings';

  @override
  String get incomeExpenseRatioCardExpenseRatioLabel => 'Expense Ratio';

  @override
  String get categoryBreakdownCardTitle => 'Expense Proportion by Category';

  @override
  String categoryBreakdownCardTotalLabel(String amount) {
    return 'Total: $amount';
  }

  @override
  String get categoryBreakdownCardShowPieTooltip => 'Show pie chart';

  @override
  String get categoryBreakdownCardShowBarTooltip => 'Show bar chart';

  @override
  String get categoryBreakdownCardEmptyMessage =>
      'No expenses recorded in this period.';

  @override
  String categoryBreakdownCardTransactionCountLabel(int count) {
    return '$count transactions';
  }

  @override
  String get monthOverMonthSectionTitle => 'Month-over-Month Trend (MoM)';

  @override
  String monthOverMonthSectionComparisonLabel(
    String currMonth,
    String prevMonth,
  ) {
    return '$currMonth vs $prevMonth';
  }

  @override
  String get monthOverMonthSectionLastMonthLegend => 'Last Month';

  @override
  String get monthOverMonthSectionThisMonthLegend => 'This Month';

  @override
  String get monthOverMonthSectionEmptyMessage =>
      'Not enough transaction data yet for a month-over-month comparison.';

  @override
  String get monthOverMonthSectionCategoryComparisonTitle =>
      'Expense Comparison by Category';

  @override
  String monthOverMonthSectionTooltipLabel(
    String categoryName,
    String period,
    String amount,
  ) {
    return '$categoryName ($period)\n$amount';
  }

  @override
  String get monthOverMonthSectionExpenseLabel => 'Expense';

  @override
  String get monthOverMonthSectionIncomeLabel => 'Income';

  @override
  String get monthOverMonthSectionNewBadge => 'New';

  @override
  String monthOverMonthSectionPreviousAmountLabel(String amount) {
    return 'Previous: $amount';
  }

  @override
  String get walletsScreenTitle => 'Manage Wallets';

  @override
  String get walletsScreenTransferTooltip => 'Transfer Between Wallets';

  @override
  String get walletsScreenTotalBalanceLabel => 'Total Balance (Net Worth)';

  @override
  String walletsScreenTotalBalanceSubtitle(int count) {
    return 'Total accumulated from $count active wallets & accounts.';
  }

  @override
  String get walletsScreenTransferButton => 'Transfer';

  @override
  String get walletsScreenAddButton => 'Add';

  @override
  String walletsScreenListTitle(int count) {
    return 'Wallet List ($count)';
  }

  @override
  String get walletsScreenEmptyTitle => 'No wallets registered yet.';

  @override
  String get walletsScreenEmptyMessage =>
      'Add your first wallet to start recording.';

  @override
  String walletsScreenLoadError(Object error) {
    return 'Failed to load wallet list: $error';
  }

  @override
  String get walletsScreenDeleteDialogTitle => 'Delete Wallet?';

  @override
  String walletsScreenDeleteDialogMessage(String name) {
    return 'Are you sure you want to delete the wallet \"$name\"?\n\nNote: A wallet cannot be deleted if it still has related transactions or transfers.';
  }

  @override
  String get walletsScreenCancelButton => 'Cancel';

  @override
  String get walletsScreenDeleteButton => 'Delete';

  @override
  String walletsScreenDeleteSuccessToast(String name) {
    return 'Wallet \"$name\" deleted successfully.';
  }

  @override
  String get walletsScreenDeleteRejectedTitle => 'Delete Rejected';

  @override
  String get walletsScreenDeleteFailedTitle => 'Failed to Delete Wallet';

  @override
  String get walletsScreenUnderstoodButton => 'Got it';

  @override
  String get walletCardIncludedInBudgetBadge => 'Included in Daily Budget';

  @override
  String get walletCardExcludedFromBudgetBadge => 'Outside Budget';

  @override
  String get walletCardCurrentBalanceLabel => 'Current balance';

  @override
  String get walletCardTransferMenuItem => 'Transfer';

  @override
  String get walletCardEditMenuItem => 'Edit Wallet';

  @override
  String get walletCardDeleteMenuItem => 'Delete';

  @override
  String get walletFormScreenEditTitle => 'Edit Wallet';

  @override
  String get walletFormScreenAddTitle => 'Add Wallet';

  @override
  String get walletFormScreenNameLabel => 'Wallet Name';

  @override
  String get walletFormScreenNameHint => 'E.g.: BCA, Cash, Gopay, Bibit';

  @override
  String get walletFormScreenNameRequiredError => 'Wallet name cannot be empty';

  @override
  String get walletFormScreenIconPickerLabel => 'Choose Icon';

  @override
  String get walletFormScreenStartingBalanceLabel => 'Starting Balance';

  @override
  String get walletFormScreenStartingBalanceHelper =>
      'Balance when the wallet was first created/counted (whole Rupiah).';

  @override
  String get walletFormScreenStartingBalanceNegativeError =>
      'Starting balance cannot be negative';

  @override
  String get walletFormScreenIncludeBudgetToggleTitle =>
      'Count in Daily Budget';

  @override
  String get walletFormScreenIncludeBudgetToggleSubtitle =>
      'If enabled, transactions in this wallet will affect your remaining daily allowance (BR-04). Turn off for savings/investment wallets.';

  @override
  String get walletFormScreenSaveSuccessToast => 'Wallet saved successfully';

  @override
  String get walletFormScreenSaveChangesButton => 'Save Changes';

  @override
  String get walletFormScreenCreateButton => 'Create Wallet';

  @override
  String get transferFormScreenTitle => 'Transfer Between Wallets';

  @override
  String get transferFormScreenMissingWalletsError =>
      'Select source and target wallets for the transfer.';

  @override
  String get transferFormScreenSameWalletError =>
      'Source and target wallets cannot be the same.';

  @override
  String get transferFormScreenZeroAmountError =>
      'Transfer amount must be greater than zero.';

  @override
  String transferFormScreenSuccessToast(String amount) {
    return 'Transfer $amount processed successfully';
  }

  @override
  String get transferFormScreenNeedMoreWalletsTitle =>
      'Need at least 2 wallets to make a transfer.';

  @override
  String get transferFormScreenNeedMoreWalletsMessage =>
      'Add another wallet first in the Manage Wallets menu.';

  @override
  String get transferFormScreenSourceWalletLabel => 'From Wallet (Source)';

  @override
  String get transferFormScreenTargetWalletLabel => 'To Wallet (Target)';

  @override
  String get transferFormScreenAmountLabel => 'Transfer Amount';

  @override
  String get transferFormScreenAmountZeroError =>
      'Transfer amount must be greater than zero';

  @override
  String get transferFormScreenDateLabel => 'Transfer Date';

  @override
  String get transferFormScreenNotesLabel => 'Notes (Optional)';

  @override
  String get transferFormScreenNotesHint =>
      'E.g.: ATM cash withdrawal, GoPay top up';

  @override
  String get transferFormScreenSubmitButton => 'Transfer Now';

  @override
  String transferFormScreenLoadError(Object error) {
    return 'Failed to load wallets: $error';
  }

  @override
  String get transactionsScreenTitle => 'Transaction List';

  @override
  String get transactionsScreenEmptyFilterMessage =>
      'No transactions match this filter.';

  @override
  String transactionsScreenLoadError(Object error) {
    return 'Failed to load transactions: $error';
  }

  @override
  String get transactionsScreenEmptyTitle => 'No Transactions Yet';

  @override
  String get transactionsScreenEmptyMessage =>
      'Record your first expense or income using the button below.';

  @override
  String get transactionsScreenEmptyAddButton => 'Add First Transaction';

  @override
  String get transactionsScreenFilterAll => 'All';

  @override
  String get transactionsScreenFilterIncome => 'Income';

  @override
  String get transactionsScreenFilterExpense => 'Expense';

  @override
  String get transactionFormScreenEditTitle => 'Edit Transaction';

  @override
  String get transactionFormScreenAddTitle => 'Record Transaction';

  @override
  String get transactionFormScreenTransferAmountLabel => 'TRANSFER AMOUNT';

  @override
  String get transactionFormScreenAmountLabel => 'AMOUNT';

  @override
  String get transactionFormScreenAmountEmptyError => 'Amount cannot be empty';

  @override
  String get transactionFormScreenAmountInvalidError =>
      'Amount cannot be zero or negative';

  @override
  String get transactionFormScreenSourceWalletLabel => 'From Wallet (Source)';

  @override
  String get transactionFormScreenTargetWalletLabel => 'To Wallet (Target)';

  @override
  String transactionFormScreenSourceWalletLoadError(Object error) {
    return 'Failed to load wallets: $error';
  }

  @override
  String transactionFormScreenTargetWalletLoadError(Object error) {
    return 'Failed to load target wallet: $error';
  }

  @override
  String get transactionFormScreenWalletLabel => 'Wallet';

  @override
  String get transactionFormScreenCategoryLabel => 'Category';

  @override
  String transactionFormScreenCategoryLoadError(Object error) {
    return 'Failed to load categories: $error';
  }

  @override
  String get transactionFormScreenDateLabel => 'Date';

  @override
  String get transactionFormScreenNotesLabel => 'Notes (optional)';

  @override
  String get transactionFormScreenSaveSuccessToast =>
      'Transaction saved successfully';

  @override
  String get transactionFormScreenSaveChangesButton => 'Save Changes';

  @override
  String get transactionFormScreenSaveNewButton => 'Save Transaction';

  @override
  String get transactionFormScreenDeleteDialogTitle => 'Delete Transaction?';

  @override
  String get transactionFormScreenDeleteDialogMessage =>
      'Are you sure you want to delete this transaction? This action cannot be undone.';

  @override
  String get transactionFormScreenCancelButton => 'Cancel';

  @override
  String get transactionFormScreenDeleteButton => 'Delete';

  @override
  String get transactionFormScreenDeleteTransactionButton =>
      'Delete Transaction';

  @override
  String get transactionFormScreenDeleteLockedButton =>
      'Delete Transaction (Locked)';

  @override
  String get transactionFormScreenDeleteLockedNotice =>
      'Only transactions dated today can be deleted. Past transactions cannot be deleted to preserve history integrity (FR-03).';

  @override
  String get transactionFormScreenTypeExpenseLabel => 'Expense';

  @override
  String get transactionFormScreenTypeIncomeLabel => 'Income';

  @override
  String get transactionFormScreenTypeTransferLabel => 'Transfer';

  @override
  String get transactionFormScreenInvalidTransferError =>
      'Please enter an amount and select different source & target wallets.';

  @override
  String get transactionFormScreenInvalidRegularError =>
      'Please enter an amount and select a category.';

  @override
  String homeScreenLoadError(Object error) {
    return 'Failed to load budget: $error';
  }

  @override
  String get homeScreenModePeriodicBadge => 'Periodic Mode';

  @override
  String get homeScreenModeDailyBadge => 'Daily Mode (Allowance)';

  @override
  String get homeScreenTotalSaldoLabel => 'Total Balance';

  @override
  String get homeScreenDailyAllowanceLabel => 'Today\'s Allowance';

  @override
  String homeScreenSubtitleRemainingDays(int days) {
    return '$days days left until the next payday';
  }

  @override
  String get homeScreenSubtitleCarryOver =>
      'Accumulated carry-over from yesterday & today\'s allowance';

  @override
  String get homeScreenCycleExpiredPeriodicTitle => 'Pay Cycle Ended';

  @override
  String get homeScreenCycleExpiredDailyTitle => 'Daily Rollover Needed';

  @override
  String get homeScreenCycleExpiredPeriodicMessage =>
      'Payday has arrived. Start a new cycle to update your Safe Spend amount.';

  @override
  String get homeScreenCycleExpiredDailyMessage =>
      'A new day has arrived. Confirm the balance carry-over to start today.';

  @override
  String get homeScreenStartNewCycleButton => 'Start New Cycle';

  @override
  String get homeScreenRolloverTodayButton => 'Roll Over Today';

  @override
  String get homeScreenBreakdownTitle => 'Calculation Breakdown';

  @override
  String get homeScreenRemainingCycleBalanceLabel => 'Remaining Cycle Balance';

  @override
  String get homeScreenGrossDailyAllowanceLabel => 'Gross Allowance / Day';

  @override
  String get homeScreenGoalSavingsDailyLabel => 'Goal Savings / Day';

  @override
  String get homeScreenYesterdayCarryOverLabel =>
      'Yesterday\'s Carry-Over Balance';

  @override
  String get homeScreenTodayAllowanceInLabel => 'Today\'s Allowance In';

  @override
  String get homeScreenMandatoryExpenseTodayLabel => 'Mandatory Expense Today';

  @override
  String get homeScreenRecordedExpenseTodayLabel => 'Recorded Expense Today';

  @override
  String get homeScreenTransactionSummaryTitle => 'Transaction Summary';

  @override
  String get homeScreenViewAllLink => 'View All';

  @override
  String get homeScreenTransactionSummaryLoadError =>
      'Failed to load transaction summary.';

  @override
  String get homeScreenNoTransactionsYet => 'No transactions recorded yet.';

  @override
  String get homeScreenIncomeColumnLabel => 'Income';

  @override
  String get homeScreenExpenseColumnLabel => 'Expense';

  @override
  String get homeScreenNoneYet => 'None yet';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsScreenPreferencesTitle => 'Appearance & Language';

  @override
  String get settingsScreenPreferencesSubtitle =>
      'Customize the interface theme and language';

  @override
  String get settingsScreenDarkModeTitle => 'Dark Mode';

  @override
  String get settingsScreenDarkModeActiveSubtitle =>
      'Dark theme active (OLED recommended)';

  @override
  String get settingsScreenLightModeActiveSubtitle => 'Light theme active';

  @override
  String get settingsScreenLanguageTitle => 'App Language';

  @override
  String get settingsScreenLanguageIndonesianActiveSubtitle =>
      'Indonesian (Active)';

  @override
  String get settingsScreenLanguageEnglishActiveSubtitle => 'English (Active)';

  @override
  String get settingsScreenLanguageIndonesianOption => 'Indonesian';

  @override
  String get settingsScreenLanguageEnglishOption => 'English';

  @override
  String get settingsScreenNotificationsTitle => 'Notifications & Reminders';

  @override
  String get settingsScreenNotificationsSubtitle =>
      '100% Offline via local Alarm Manager';

  @override
  String get settingsScreenDailyReminderTitle => 'Daily Recording Reminder';

  @override
  String settingsScreenDailyReminderSubtitle(String time) {
    return 'Every day at $time (tap the clock to change)';
  }

  @override
  String settingsScreenChangeTimeButton(String time) {
    return 'Change Time ($time)';
  }

  @override
  String get settingsScreenLimitAlertTitle => 'Budget Limit Alert';

  @override
  String get settingsScreenLimitAlertSubtitle =>
      'Real-time notification when today\'s safe spending gets close to 0 or negative.';

  @override
  String get settingsScreenPayCycleTitle => 'New Pay Cycle';

  @override
  String get settingsScreenPayCycleSubtitle =>
      'Notification when entering a payday or new cycle.';

  @override
  String get settingsScreenGoalMilestoneTitle => 'Savings Goal Milestone';

  @override
  String get settingsScreenGoalMilestoneSubtitle =>
      'Notification when goal progress reaches 25%, 50%, 75%, and 100%.';

  @override
  String get settingsScreenAboutTitle => 'About LedgerMate';

  @override
  String settingsScreenVersionLabel(String version, String buildNumber) {
    return 'Version $version+$buildNumber (100% Offline, No Server)';
  }

  @override
  String get settingsScreenVersionLoading => 'Loading version...';

  @override
  String get settingsScreenVersionFallback => '100% Offline, No Server';

  @override
  String get settingsScreenAboutDescription =>
      'LedgerMate is a smart offline-first daily budget tracker. All your financial data is stored locally on your device using the Isar Database.';

  @override
  String get categoryManagementCardAddDialogTitle => 'Add New Category';

  @override
  String get categoryManagementCardNameLabel => 'Category Name';

  @override
  String get categoryManagementCardNameHint =>
      'E.g.: Investment, Charity, Vacation';

  @override
  String get categoryManagementCardCancelButton => 'Cancel';

  @override
  String get categoryManagementCardSaveButton => 'Save';

  @override
  String get categoryManagementCardEditDialogTitle => 'Rename Category';

  @override
  String get categoryManagementCardDeleteDialogTitle => 'Delete Category?';

  @override
  String categoryManagementCardDeleteDialogMessage(String name) {
    return 'Are you sure you want to delete the category \"$name\"?';
  }

  @override
  String get categoryManagementCardDeleteButton => 'Delete';

  @override
  String get categoryManagementCardTitle => 'Manage Categories';

  @override
  String get categoryManagementCardSubtitle =>
      'Default & custom categories for transactions';

  @override
  String get categoryManagementCardAddTooltip => 'Add Category';

  @override
  String get categoryManagementCardLoadingDefaults =>
      'Loading default categories...';

  @override
  String get categoryManagementCardDefaultBadge => 'Default';

  @override
  String get categoryManagementCardEditTooltip => 'Rename';

  @override
  String get categoryManagementCardDeleteTooltip => 'Delete Category';

  @override
  String categoryManagementCardLoadError(Object error) {
    return 'Failed to load categories: $error';
  }

  @override
  String get walletsManagementCardTitle => 'Manage Wallets & Accounts';

  @override
  String get walletsManagementCardSubtitle =>
      'Manage wallets, bank accounts, starting balance & transfers';

  @override
  String get walletsManagementCardOpenTooltip => 'Open Manage Wallets';

  @override
  String get dataManagementCardTitle => 'Backup & Restore Data';

  @override
  String get dataManagementCardSubtitle =>
      'JSON & CSV Format (100% Offline, FR-08)';

  @override
  String get dataManagementCardDescription =>
      'Back up the entire database periodically or move your financial data to a new device without a server connection.';

  @override
  String get dataManagementCardProcessingMessage => 'Processing data...';

  @override
  String get dataManagementCardExportSuccessTitle => 'Export Successful!';

  @override
  String get dataManagementCardExportJsonTitle => 'Back Up Database (JSON)';

  @override
  String get dataManagementCardExportJsonSubtitle =>
      'Save all collections (profile, pay cycles, categories, transactions, goals, assets) to a JSON file.';

  @override
  String get dataManagementCardExportJsonButton => 'Back Up (JSON)';

  @override
  String dataManagementCardExportJsonSuccessToast(String path) {
    return 'Backup file saved at:\n$path';
  }

  @override
  String get dataManagementCardExportCsvTitle =>
      'Export Transaction History (CSV)';

  @override
  String get dataManagementCardExportCsvSubtitle =>
      'RFC 4180 CSV table format with Indonesian-language headers for spreadsheets.';

  @override
  String get dataManagementCardExportCsvButton => 'Export CSV';

  @override
  String dataManagementCardExportCsvSuccessToast(String path) {
    return 'CSV transaction table saved at:\n$path';
  }

  @override
  String get dataManagementCardRestoreTitle => 'Restore Data (JSON)';

  @override
  String get dataManagementCardRestoreSubtitle =>
      'Select a .json backup file to restore the entire database to its saved state.';

  @override
  String get dataManagementCardRestoreButton => 'Select Backup File';

  @override
  String get dataManagementCardRestoreSuccessToast =>
      'Local database successfully restored from backup.';

  @override
  String get restoreConfirmationDialogTitle => 'Confirm Data Restore';

  @override
  String get restoreConfirmationDialogWarningMessage =>
      'WARNING: Restoring will delete and overwrite ALL current local data. This action cannot be undone.';

  @override
  String get restoreConfirmationDialogSummaryTitle => 'Backup Data Summary:';

  @override
  String get restoreConfirmationDialogBackupTimeLabel => 'Backup Time';

  @override
  String get restoreConfirmationDialogUserProfileLabel => 'User Profile';

  @override
  String get restoreConfirmationDialogAvailableValue => 'Available';

  @override
  String get restoreConfirmationDialogNotAvailableValue => 'Not Available';

  @override
  String get restoreConfirmationDialogPayCycleLabel => 'Pay Cycles';

  @override
  String restoreConfirmationDialogPayCycleCountValue(int count) {
    return '$count records';
  }

  @override
  String get restoreConfirmationDialogCategoryLabel => 'Categories';

  @override
  String restoreConfirmationDialogCategoryCountValue(int count) {
    return '$count categories';
  }

  @override
  String get restoreConfirmationDialogTransactionLabel => 'Transaction History';

  @override
  String restoreConfirmationDialogTransactionCountValue(int count) {
    return '$count transactions';
  }

  @override
  String get restoreConfirmationDialogGoalLabel => 'Financial Goals';

  @override
  String restoreConfirmationDialogGoalCountValue(int count) {
    return '$count goals';
  }

  @override
  String get restoreConfirmationDialogAssetLabel => 'Assets / Investments';

  @override
  String restoreConfirmationDialogAssetCountValue(int count) {
    return '$count assets';
  }

  @override
  String get restoreConfirmationDialogCancelButton => 'Cancel';

  @override
  String get restoreConfirmationDialogConfirmButton => 'Overwrite & Restore';

  @override
  String get payCycleTransitionScreenTitle => 'Cycle Transition';

  @override
  String payCycleTransitionScreenLoadProfileError(Object error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get payCycleTransitionScreenProfileNotFound => 'Profile not found.';

  @override
  String get payCycleTransitionScreenSalaryEmptyError =>
      'New cycle salary cannot be empty';

  @override
  String get payCycleTransitionScreenSalaryInvalidError =>
      'Salary must be greater than zero';

  @override
  String get payCycleTransitionScreenExpenseNameEmptyError =>
      'Expense name cannot be empty';

  @override
  String get payCycleTransitionScreenAmountEmptyError =>
      'Amount cannot be empty';

  @override
  String get payCycleTransitionScreenAmountInvalidError =>
      'Amount must be greater than zero';

  @override
  String get payCycleTransitionScreenIncompleteDataError =>
      'Please complete all required data.';

  @override
  String get payCycleTransitionHeaderPeriodicTitle => 'New Pay Cycle';

  @override
  String get payCycleTransitionHeaderDailyTitle => 'Daily Rollover';

  @override
  String get payCycleTransitionHeaderPeriodicMessage =>
      'The previous cycle has ended. Manually enter the new cycle\'s salary and mandatory expenses (BR-02: no automatic templates).';

  @override
  String get payCycleTransitionHeaderDailyMessage =>
      'A new day has arrived. Confirm yesterday\'s remaining balance and enter today\'s allowance and mandatory expenses (BR-02: manual re-entry every period).';

  @override
  String get payCycleTransitionIntervalDateTitle =>
      'Next Payday Interval & Date';

  @override
  String get payCycleTransitionPickPaydayButton => 'Select payday date';

  @override
  String payCycleTransitionPaydaySelectedButton(String date) {
    return 'Payday: $date';
  }

  @override
  String get payCycleTransitionIntervalWeekly => 'Weekly';

  @override
  String get payCycleTransitionIntervalBiweekly => 'Biweekly';

  @override
  String get payCycleTransitionIntervalMonthly => 'Monthly';

  @override
  String get payCycleTransitionIntervalCustom => 'Custom';

  @override
  String get payCycleTransitionSalaryLabel => 'This Cycle\'s Salary (Required)';

  @override
  String get payCycleTransitionSalaryHelper =>
      'Per BR-02: manually enter the new salary amount.';

  @override
  String get payCycleTransitionCarryOverTitle =>
      'Carry-Over Balance from Yesterday';

  @override
  String get payCycleTransitionCarryOverMessage =>
      'Yesterday\'s remaining Safe Spend amount automatically accumulates into today\'s balance (BR-01).';

  @override
  String get payCycleTransitionBekelLabel => 'Today\'s Allowance (Optional)';

  @override
  String get payCycleTransitionBekelHelper =>
      'Leave empty or enter 0 if there\'s no new allowance today.';

  @override
  String get payCycleTransitionExpensesPeriodicTitle =>
      'This Cycle\'s Mandatory Expenses';

  @override
  String get payCycleTransitionExpensesDailyTitle =>
      'Today\'s Mandatory Expenses';

  @override
  String get payCycleTransitionExpensesSubtitle =>
      'Optional — per BR-02, the mandatory expenses list is manually entered every period (not copied from the old cycle).';

  @override
  String get payCycleTransitionExpensesEmptyMessage =>
      'No mandatory expenses added yet.';

  @override
  String get payCycleTransitionRemoveExpenseTooltip => 'Remove Expense';

  @override
  String get payCycleTransitionExpenseNameFieldLabel =>
      'Expense name (e.g. Rent, Installment)';

  @override
  String get payCycleTransitionExpenseAmountFieldLabel => 'Expense amount';

  @override
  String get payCycleTransitionAddExpenseButton => 'Add Mandatory Expense';

  @override
  String get payCycleTransitionStartNewCycleButton => 'Start New Cycle';

  @override
  String get payCycleTransitionStartTodayButton => 'Start Today';

  @override
  String get currencyPrefix => 'Rp ';

  @override
  String get currencyHintZero => 'Rp 0';

  @override
  String get notificationChannelDailyReminder => 'Daily Reminder';

  @override
  String get notificationChannelDailyReminderDescription =>
      'Daily reminder to log financial transactions';

  @override
  String get notificationDailyReminderTitle => 'Time to Log Your Finances!';

  @override
  String get notificationDailyReminderBody =>
      'Don\'t forget to log today\'s expenses and income in LedgerMate.';

  @override
  String get notificationChannelLimitAlert => 'Budget Limit Alert';

  @override
  String get notificationChannelLimitAlertDescription =>
      'Notification when daily budget is depleted or near zero';

  @override
  String get notificationLimitAlertTitle => 'Warning: Daily Limit Exceeded!';

  @override
  String notificationLimitAlertBody(String amount) {
    return 'Today\'s safe spending money remaining: $amount. Hold off on non-essential spending.';
  }

  @override
  String get notificationChannelPayCycle => 'Pay Cycle';

  @override
  String get notificationChannelPayCycleDescription =>
      'Notification for pay cycle start or expiry';

  @override
  String get notificationChannelGoalMilestone => 'Financial Goals';

  @override
  String get notificationChannelGoalMilestoneDescription =>
      'Notification for savings goal milestone achievements';

  @override
  String get notificationGoalMilestoneTitle => 'Goal Milestone Reached! 🎉';

  @override
  String notificationGoalMilestoneBody(String goalName, int percent) {
    return 'Goal \"$goalName\" has reached $percent%! Keep saving consistently!';
  }

  @override
  String get notificationPayCyclePeriodicStartTitle => 'New Cycle Started';

  @override
  String get notificationPayCycleDailyStartTitle => 'New Daily Cycle';

  @override
  String notificationPayCyclePeriodicStartBody(int day, int month, int year) {
    return 'New cycle active until $day/$month/$year. Daily budget has been adjusted.';
  }

  @override
  String get notificationPayCycleDailyStartBody =>
      'Daily allowance has been recorded. Safe spending money is ready for today.';

  @override
  String get notificationPayCycleExpiredTitle => 'Pay Cycle Has Arrived!';

  @override
  String get notificationPayCycleExpiredBody =>
      'Time to update your salary and mandatory expenses to start a new cycle.';

  @override
  String get walletIconCash => 'Wallet / Cash';

  @override
  String get walletIconBank => 'Bank / Account';

  @override
  String get walletIconCard => 'Debit / Credit Card';

  @override
  String get walletIconEwallet => 'E-Wallet';

  @override
  String get walletIconSavings => 'Savings';

  @override
  String get walletIconPayments => 'Cash / Money';

  @override
  String get walletIconInvestment => 'Investment / Forex';

  @override
  String get walletIconBusiness => 'Business / Store';

  @override
  String get defaultCategoryFood => 'Food';

  @override
  String get defaultCategoryTransport => 'Transport';

  @override
  String get defaultCategoryEntertainment => 'Entertainment';

  @override
  String get defaultCategoryBills => 'Bills';

  @override
  String get defaultCategoryOther => 'Other';

  @override
  String get transactionTypeTransferLabel => 'Transfer';

  @override
  String transactionCategoryFallback(int id) {
    return 'Category #$id';
  }

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

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
  String get analyticsCategoryFallback => 'Other';

  @override
  String get assetValidationPurchaseValuePositive =>
      'Purchase value/initial capital must be greater than 0.';

  @override
  String get assetValidationCurrentValueNotNegative =>
      'Current value cannot be negative.';

  @override
  String get goalValidationNameRequired => 'Goal name cannot be empty.';

  @override
  String get goalValidationTargetPositive =>
      'Target amount must be greater than 0.';

  @override
  String get goalValidationCurrentNotNegative =>
      'Current balance cannot be negative.';

  @override
  String get goalValidationDailyAllocationPositive =>
      'Manual daily allocation must be greater than 0.';

  @override
  String get goalValidationWithdrawPositive =>
      'Withdrawal amount must be greater than 0.';

  @override
  String get goalValidationWithdrawExceedsBalance =>
      'Withdrawal amount exceeds current savings balance.';

  @override
  String goalWithdrawTransactionNote(String goalName) {
    return 'Withdraw from goal: $goalName';
  }

  @override
  String get walletValidationHasTransactions =>
      'Wallet cannot be deleted because it still has linked transactions. Move or delete the transactions first.';

  @override
  String get walletValidationMinimumOne =>
      'There must be at least 1 active wallet in the app.';

  @override
  String get walletValidationNameRequired => 'Wallet name cannot be empty.';

  @override
  String get walletValidationStartingBalanceNotNegative =>
      'Starting balance cannot be negative.';

  @override
  String get walletValidationTransferAmountPositive =>
      'Transfer amount must be greater than zero.';

  @override
  String get settingsCategoryDeleteInUseError =>
      'Category cannot be deleted because it is still used by transactions.';

  @override
  String get defaultWalletName => 'Main Wallet';

  @override
  String get payCycleBekelTransactionNote => 'Today\'s allowance';

  @override
  String get withdrawDialogChip25 => '25%';

  @override
  String get withdrawDialogChip50 => '50%';

  @override
  String transferWalletDropdownItem(String name, String balance) {
    return '$name ($balance)';
  }

  @override
  String get homeScreenDateFormatLocale => 'en_US';
}
