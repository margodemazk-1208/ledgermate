// Shared "discard changes?" confirmation for forms with unsaved edits
// (M19/D18) — pop-on-back previously discarded silently with no warning.
// Lives in `core/presentation/widgets/` per `docs/ARCHITECTURE.md`'s
// shared-widget convention so every CRUD form uses the same dialog/copy
// instead of each screen inventing its own.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart' show AppLocalizations;

/// Shows a confirmation dialog asking the user whether to discard unsaved
/// changes. Returns `true` if the user chose to discard (i.e. the caller
/// should proceed with popping), `false`/`null` otherwise.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      key: const ValueKey('discard_changes_dialog'),
      title: Text(l10n.unsavedChangesGuardDialogTitle),
      content: Text(l10n.unsavedChangesGuardDialogContent),
      actions: [
        TextButton(
          key: const ValueKey('discard_changes_cancel_button'),
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.unsavedChangesGuardContinueEditingButton),
        ),
        FilledButton(
          key: const ValueKey('discard_changes_confirm_button'),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.unsavedChangesGuardDiscardButton),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Wraps [child] with a [PopScope] that intercepts back-navigation (system
/// back gesture/button AND any programmatic `Navigator.pop`) while
/// [isDirty] returns true, showing [confirmDiscardChanges] before actually
/// popping. Forms call [allowPop] right before a successful save/delete so
/// the subsequent `Navigator.pop()` isn't itself re-intercepted.
class UnsavedChangesGuard extends StatefulWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.isDirty,
    required this.child,
  });

  /// Polled on every pop attempt rather than cached, so the guard always
  /// reflects the form's current dirty state.
  final bool Function() isDirty;
  final Widget child;

  @override
  State<UnsavedChangesGuard> createState() => _UnsavedChangesGuardState();
}

class _UnsavedChangesGuardState extends State<UnsavedChangesGuard> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isDirty(),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await confirmDiscardChanges(context);
        if (shouldDiscard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: widget.child,
    );
  }
}
