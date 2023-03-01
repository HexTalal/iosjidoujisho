import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog used for showing dictionary import progress when
/// importing a dictionary from the dictionary menu. See the
/// [DictionaryDialogPage].
class DictionaryDialogImportPage extends BasePage {
  /// Create an instance of this page.
  const DictionaryDialogImportPage({
    required this.progressNotifier,
    required this.currentCount,
    required this.totalCount,
    super.key,
  });

  /// A notifier for reporting text updates for the current progress text in
  /// the dialog.
  final ValueNotifier<String> progressNotifier;

  /// The count of the current dictionary being imported.
  final int currentCount;

  /// The number of dictionaries being imported.
  final int totalCount;

  @override
  BasePageState createState() => _DictionaryDialogImportPageState();
}

class _DictionaryDialogImportPageState
    extends BasePageState<DictionaryDialogImportPage> {
  String get importInProgressLabel => appModel.translate('import_in_progress');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        contentPadding: Spacing.of(context).insets.all.big,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildProgressSpinner(),
            const Space.semiBig(),
            buildProgressMessage(),
          ],
        ),
      ),
    );
  }

  Widget buildProgressSpinner() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        theme.colorScheme.primary,
      ),
    );
  }

  Widget buildProgressMessage() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Space.extraSmall(),
          Padding(
            padding: const EdgeInsets.only(left: 0.5),
            child: Text(
              widget.totalCount != 1
                  ? '${t.import_in_progress}\n${widget.currentCount} / ${widget.totalCount}'
                  : t.import_in_progress,
              style: TextStyle(
                fontSize: textTheme.bodySmall?.fontSize,
                color: theme.unselectedWidgetColor,
              ),
            ),
          ),
          const Space.small(),
          ValueListenableBuilder<String>(
            valueListenable: widget.progressNotifier,
            builder: (context, progressNotification, _) {
              return Text(
                widget.progressNotifier.value,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
      ),
    );
  }
}
