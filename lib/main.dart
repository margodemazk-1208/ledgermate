import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/database/isar_provider.dart';

/// Boots Isar before the widget tree builds — M1 explicitly left this
/// unwired ("left for the milestone that first needs the DB live
/// — likely M2 onboarding", see `core/database/isar_provider.dart`). The
/// real app's storage directory comes from `path_provider`'s
/// `getApplicationDocumentsDirectory()` per that file's own doc comment.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final directory = await getApplicationDocumentsDirectory();
  final isar = await openLedgerMateIsar(directory: directory.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const LedgerMateApp(),
    ),
  );
}
