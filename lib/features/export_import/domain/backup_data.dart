// Domain models and serialization for LedgerMate manual backup/restore (FR-08).
import '../../../core/database/asset.dart';
import '../../../core/database/category.dart';
import '../../../core/database/financial_goal.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;

/// Exception thrown when an import payload fails validation.
class BackupValidationException implements Exception {
  const BackupValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Metadata summary of a backup file, used to present verification details
/// to the user before executing an import / replace operation.
class BackupSummary {
  const BackupSummary({
    required this.exportedAt,
    required this.hasProfile,
    required this.payCycleCount,
    required this.categoryCount,
    required this.transactionCount,
    required this.goalCount,
    required this.assetCount,
  });

  final DateTime exportedAt;
  final bool hasProfile;
  final int payCycleCount;
  final int categoryCount;
  final int transactionCount;
  final int goalCount;
  final int assetCount;

  int get totalRecords =>
      (hasProfile ? 1 : 0) +
      payCycleCount +
      categoryCount +
      transactionCount +
      goalCount +
      assetCount;
}

/// In-memory representation of an entire LedgerMate database snapshot.
class BackupData {
  const BackupData({
    required this.exportedAt,
    required this.profiles,
    required this.payCycles,
    required this.categories,
    required this.transactions,
    required this.financialGoals,
    required this.assets,
    this.version = currentVersion,
    this.app = appIdentifier,
  });

  static const int currentVersion = 1;
  static const String appIdentifier = 'LedgerMate';

  final int version;
  final String app;
  final DateTime exportedAt;
  final List<LocalProfile> profiles;
  final List<PayCycle> payCycles;
  final List<Category> categories;
  final List<db.Transaction> transactions;
  final List<FinancialGoal> financialGoals;
  final List<Asset> assets;

  BackupSummary get summary => BackupSummary(
    exportedAt: exportedAt,
    hasProfile: profiles.isNotEmpty,
    payCycleCount: payCycles.length,
    categoryCount: categories.length,
    transactionCount: transactions.length,
    goalCount: financialGoals.length,
    assetCount: assets.length,
  );

  Map<String, dynamic> toJson() {
    return {
      'app': app,
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      'data': {
        'profiles': profiles.map(_profileToJson).toList(),
        'payCycles': payCycles.map(_payCycleToJson).toList(),
        'categories': categories.map(_categoryToJson).toList(),
        'transactions': transactions.map(_transactionToJson).toList(),
        'financialGoals': financialGoals.map(_goalToJson).toList(),
        'assets': assets.map(_assetToJson).toList(),
      },
    };
  }

  static BackupData fromJson(Map<String, dynamic> json) {
    final app = json['app'];
    if (app != appIdentifier) {
      throw const BackupValidationException(
        'File cadangan tidak valid: bukan file backup dari aplikasi LedgerMate.',
      );
    }

    final version = json['version'];
    if (version == null || version is! int || version > currentVersion) {
      throw BackupValidationException(
        'Versi format file cadangan ($version) tidak didukung oleh versi aplikasi ini.',
      );
    }

    final rawExportedAt = json['exportedAt'];
    if (rawExportedAt == null || rawExportedAt is! String) {
      throw const BackupValidationException(
        'File cadangan tidak memiliki stempel waktu pembuatan (exportedAt).',
      );
    }
    final DateTime exportedAt;
    try {
      exportedAt = DateTime.parse(rawExportedAt);
    } catch (_) {
      throw const BackupValidationException(
        'Format tanggal exportedAt tidak valid.',
      );
    }

    final data = json['data'];
    if (data == null || data is! Map<String, dynamic>) {
      throw const BackupValidationException(
        'Struktur data cadangan rusak: blok data tidak ditemukan.',
      );
    }

    final profiles = _parseList(data, 'profiles', _profileFromJson);
    final payCycles = _parseList(data, 'payCycles', _payCycleFromJson);
    final categories = _parseList(data, 'categories', _categoryFromJson);
    final transactions = _parseList(data, 'transactions', _transactionFromJson);
    final goals = _parseList(data, 'financialGoals', _goalFromJson);
    final assets = _parseList(data, 'assets', _assetFromJson);

    return BackupData(
      version: version,
      app: app as String,
      exportedAt: exportedAt,
      profiles: profiles,
      payCycles: payCycles,
      categories: categories,
      transactions: transactions,
      financialGoals: goals,
      assets: assets,
    );
  }

  static List<T> _parseList<T>(
    Map<String, dynamic> data,
    String key,
    T Function(Map<String, dynamic>) parser,
  ) {
    final rawList = data[key];
    if (rawList == null) return [];
    if (rawList is! List) {
      throw BackupValidationException(
        'Struktur $key tidak valid: diharapkan array data.',
      );
    }
    final result = <T>[];
    for (var i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item is! Map<String, dynamic>) {
        throw BackupValidationException(
          'Item ke-$i pada $key bukan objek JSON yang valid.',
        );
      }
      result.add(parser(item));
    }
    return result;
  }

  // --------------------------------------------------------------------------
  // LocalProfile (PRD §8)
  // --------------------------------------------------------------------------
  static Map<String, dynamic> _profileToJson(LocalProfile p) {
    return {
      'id': p.id,
      'fixedSalary': p.fixedSalary,
      'incomeFrequency': p.incomeFrequency.name,
      'nextPaydayDate': p.nextPaydayDate?.toIso8601String(),
      'incomeIntervalType': p.incomeIntervalType?.name,
      'carryOverBalance': p.carryOverBalance,
      'mandatoryExpenses': p.mandatoryExpenses
          .map((e) => {'name': e.name, 'amount': e.amount})
          .toList(),
      'language': p.language.name,
      'theme': p.theme.name,
      'notifDailyReminderEnabled': p.notifDailyReminderEnabled,
      'notifDailyReminderTime': p.notifDailyReminderTime,
      'notifLimitAlertEnabled': p.notifLimitAlertEnabled,
      'notifPayCycleEnabled': p.notifPayCycleEnabled,
      'notifGoalMilestoneEnabled': p.notifGoalMilestoneEnabled,
      'onboardingComplete': p.onboardingComplete,
      'lastRolloverDate': p.lastRolloverDate?.toIso8601String(),
    };
  }

  static LocalProfile _profileFromJson(Map<String, dynamic> m) {
    final p = LocalProfile();
    if (m['id'] is int) p.id = m['id'] as int;
    p.fixedSalary = _asInt(m, 'fixedSalary', 'LocalProfile', min: 0);

    final freqStr = m['incomeFrequency'] as String?;
    p.incomeFrequency = IncomeFrequency.values.firstWhere(
      (e) => e.name == freqStr,
      orElse: () => IncomeFrequency.periodic,
    );

    if (m['nextPaydayDate'] != null) {
      p.nextPaydayDate = _asDateTime(m, 'nextPaydayDate', 'LocalProfile');
    }

    final intervalStr = m['incomeIntervalType'] as String?;
    if (intervalStr != null) {
      p.incomeIntervalType = IncomeIntervalType.values.firstWhere(
        (e) => e.name == intervalStr,
        orElse: () => IncomeIntervalType.monthly,
      );
    }

    p.carryOverBalance = _asInt(m, 'carryOverBalance', 'LocalProfile', min: 0);

    final rawMandatory = m['mandatoryExpenses'];
    if (rawMandatory is List) {
      p.mandatoryExpenses = rawMandatory.map((raw) {
        if (raw is! Map) {
          throw const BackupValidationException(
            'MandatoryExpenseItem pada profil tidak valid.',
          );
        }
        final item = MandatoryExpenseItem();
        item.name = (raw['name'] ?? '').toString();
        item.amount = (raw['amount'] is int) ? raw['amount'] as int : 0;
        return item;
      }).toList();
    }

    final langStr = m['language'] as String?;
    p.language = AppLanguage.values.firstWhere(
      (e) => e.name == langStr,
      orElse: () => AppLanguage.id,
    );

    final themeStr = m['theme'] as String?;
    p.theme = AppThemeSetting.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => AppThemeSetting.dark,
    );

    p.notifDailyReminderEnabled = m['notifDailyReminderEnabled'] is bool
        ? m['notifDailyReminderEnabled'] as bool
        : true;
    p.notifDailyReminderTime = _asInt(
      m,
      'notifDailyReminderTime',
      'LocalProfile',
      fallback: 21 * 60,
    );
    p.notifLimitAlertEnabled = m['notifLimitAlertEnabled'] is bool
        ? m['notifLimitAlertEnabled'] as bool
        : true;
    p.notifPayCycleEnabled = m['notifPayCycleEnabled'] is bool
        ? m['notifPayCycleEnabled'] as bool
        : true;
    p.notifGoalMilestoneEnabled = m['notifGoalMilestoneEnabled'] is bool
        ? m['notifGoalMilestoneEnabled'] as bool
        : true;
    p.onboardingComplete = m['onboardingComplete'] is bool
        ? m['onboardingComplete'] as bool
        : true;

    if (m['lastRolloverDate'] != null) {
      p.lastRolloverDate = _asDateTime(m, 'lastRolloverDate', 'LocalProfile');
    }

    return p;
  }

  // --------------------------------------------------------------------------
  // PayCycle (PRD §8)
  // --------------------------------------------------------------------------
  static Map<String, dynamic> _payCycleToJson(PayCycle c) {
    return {
      'id': c.id,
      'startDate': c.startDate.toIso8601String(),
      'paydayDate': c.paydayDate.toIso8601String(),
      'fixedSalary': c.fixedSalary,
      'variableIncomeTotal': c.variableIncomeTotal,
      'mandatoryExpenses': c.mandatoryExpenses
          .map((e) => {'name': e.name, 'amount': e.amount})
          .toList(),
    };
  }

  static PayCycle _payCycleFromJson(Map<String, dynamic> m) {
    final c = PayCycle();
    if (m['id'] is int) c.id = m['id'] as int;
    c.startDate = _asDateTime(m, 'startDate', 'PayCycle');
    c.paydayDate = _asDateTime(m, 'paydayDate', 'PayCycle');
    c.fixedSalary = _asInt(m, 'fixedSalary', 'PayCycle', min: 0);
    c.variableIncomeTotal = _asInt(
      m,
      'variableIncomeTotal',
      'PayCycle',
      min: 0,
    );

    final rawMandatory = m['mandatoryExpenses'];
    if (rawMandatory is List) {
      c.mandatoryExpenses = rawMandatory.map((raw) {
        if (raw is! Map) {
          throw const BackupValidationException(
            'MandatoryExpenseItem pada PayCycle tidak valid.',
          );
        }
        final item = MandatoryExpenseItem();
        item.name = (raw['name'] ?? '').toString();
        item.amount = (raw['amount'] is int) ? raw['amount'] as int : 0;
        return item;
      }).toList();
    }
    return c;
  }

  // --------------------------------------------------------------------------
  // Category (PRD §8)
  // --------------------------------------------------------------------------
  static Map<String, dynamic> _categoryToJson(Category cat) {
    return {'id': cat.id, 'name': cat.name, 'isDefault': cat.isDefault};
  }

  static Category _categoryFromJson(Map<String, dynamic> m) {
    final cat = Category();
    if (m['id'] is int) cat.id = m['id'] as int;
    cat.name = _asString(m, 'name', 'Category');
    cat.isDefault = m['isDefault'] is bool ? m['isDefault'] as bool : false;
    return cat;
  }

  // --------------------------------------------------------------------------
  // Transaction (PRD §8)
  // --------------------------------------------------------------------------
  static Map<String, dynamic> _transactionToJson(db.Transaction tx) {
    return {
      'id': tx.id,
      'type': tx.type.name,
      'amount': tx.amount,
      'categoryId': tx.categoryId,
      'date': tx.date.toIso8601String(),
      'notes': tx.notes,
      'payCycleId': tx.payCycleId,
    };
  }

  static db.Transaction _transactionFromJson(Map<String, dynamic> m) {
    final tx = db.Transaction();
    if (m['id'] is int) tx.id = m['id'] as int;

    final typeStr = m['type'] as String?;
    if (typeStr == null ||
        !db.TransactionType.values.any((e) => e.name == typeStr)) {
      throw BackupValidationException('Tipe transaksi tidak valid: $typeStr');
    }
    tx.type = db.TransactionType.values.firstWhere((e) => e.name == typeStr);
    tx.amount = _asInt(m, 'amount', 'Transaction', min: 0);
    tx.categoryId = _asInt(m, 'categoryId', 'Transaction');
    tx.date = _asDateTime(m, 'date', 'Transaction');
    tx.notes = m['notes']?.toString();
    tx.payCycleId = m['payCycleId'] is int ? m['payCycleId'] as int : null;
    return tx;
  }

  // --------------------------------------------------------------------------
  // FinancialGoal (PRD §8)
  // --------------------------------------------------------------------------
  static Map<String, dynamic> _goalToJson(FinancialGoal g) {
    return {
      'id': g.id,
      'goalName': g.goalName,
      'targetAmount': g.targetAmount,
      'currentAmount': g.currentAmount,
      'targetDate': g.targetDate.toIso8601String(),
      'manualDailyAllocation': g.manualDailyAllocation,
    };
  }

  static FinancialGoal _goalFromJson(Map<String, dynamic> m) {
    final g = FinancialGoal();
    if (m['id'] is int) g.id = m['id'] as int;
    g.goalName = _asString(m, 'goalName', 'FinancialGoal');
    g.targetAmount = _asInt(m, 'targetAmount', 'FinancialGoal', min: 0);
    g.currentAmount = _asInt(m, 'currentAmount', 'FinancialGoal', min: 0);
    g.targetDate = _asDateTime(m, 'targetDate', 'FinancialGoal');
    g.manualDailyAllocation = m['manualDailyAllocation'] is int
        ? m['manualDailyAllocation'] as int
        : null;
    return g;
  }

  // --------------------------------------------------------------------------
  // Asset (PRD §8)
  // --------------------------------------------------------------------------
  static Map<String, dynamic> _assetToJson(Asset a) {
    return {
      'id': a.id,
      'assetName': a.assetName,
      'assetType': a.assetType,
      'purchaseValue': a.purchaseValue,
      'currentValue': a.currentValue,
      'lastUpdatedAt': a.lastUpdatedAt.toIso8601String(),
    };
  }

  static Asset _assetFromJson(Map<String, dynamic> m) {
    final a = Asset();
    if (m['id'] is int) a.id = m['id'] as int;
    a.assetName = _asString(m, 'assetName', 'Asset');
    a.assetType = _asString(m, 'assetType', 'Asset');
    a.purchaseValue = _asInt(m, 'purchaseValue', 'Asset', min: 0);
    a.currentValue = _asInt(m, 'currentValue', 'Asset', min: 0);
    a.lastUpdatedAt = _asDateTime(m, 'lastUpdatedAt', 'Asset');
    return a;
  }

  // --------------------------------------------------------------------------
  // Validation primitives
  // --------------------------------------------------------------------------
  static int _asInt(
    Map<String, dynamic> m,
    String key,
    String entityName, {
    int? min,
    int? fallback,
  }) {
    final val = m[key];
    if (val is int) {
      if (min != null && val < min) {
        throw BackupValidationException(
          'Nilai $key pada $entityName ($val) tidak boleh kurang dari $min.',
        );
      }
      return val;
    }
    if (fallback != null) return fallback;
    throw BackupValidationException(
      'Bidang $key pada $entityName wajib berupa bilangan bulat (int).',
    );
  }

  static String _asString(
    Map<String, dynamic> m,
    String key,
    String entityName,
  ) {
    final val = m[key];
    if (val is String && val.isNotEmpty) return val;
    throw BackupValidationException(
      'Bidang $key pada $entityName wajib diisi teks yang valid.',
    );
  }

  static DateTime _asDateTime(
    Map<String, dynamic> m,
    String key,
    String entityName,
  ) {
    final val = m[key];
    if (val is String) {
      try {
        return DateTime.parse(val);
      } catch (_) {
        throw BackupValidationException(
          'Format tanggal $key pada $entityName tidak valid: $val',
        );
      }
    }
    throw BackupValidationException(
      'Bidang $key pada $entityName wajib berupa format tanggal ISO 8601.',
    );
  }
}
