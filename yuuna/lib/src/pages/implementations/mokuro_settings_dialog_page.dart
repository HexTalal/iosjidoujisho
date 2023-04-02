import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing Mokuro reader web settings.
class MokuroSettingsDialogPage extends BasePage {
  /// Create an instance of this page.
  const MokuroSettingsDialogPage({super.key});

  @override
  BasePageState createState() => _DictionaryDialogPageState();
}

class _DictionaryDialogPageState extends BasePageState {
  ReaderMokuroSource get source => ReaderMokuroSource.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildCloseButton(),
      ];

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget buildContent() {
    ScrollController contentController = ScrollController();

    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thickness: 3,
        thumbVisibility: true,
        controller: contentController,
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildHighlightOnTapSwitch(),
              buildEnablePageTurningSwitch(),
              buildInvertPageTurningSwitch(),
              buildExtendPageSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEnablePageTurningSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(source.volumePageTurningEnabled);

    return Row(
      children: [
        Expanded(
          child: Text(t.volume_button_page_turning),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleVolumePageTurningEnabled();
                _notifier.value = source.volumePageTurningEnabled;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildInvertPageTurningSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(source.volumePageTurningInverted);

    return Row(
      children: [
        Expanded(
          child: Text(t.invert_volume_buttons),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleVolumePageTurningInverted();
                _notifier.value = source.volumePageTurningInverted;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildExtendPageSwitch() {
    ValueNotifier<bool> _notifier =
        ValueNotifier<bool>(source.extendPageBeyondNavigationBar);

    return Row(
      children: [
        Expanded(
          child: Text(t.extend_page_beyond_navbar),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleExtendPageBeyondNavigationBar();
                _notifier.value = source.extendPageBeyondNavigationBar;
              },
            );
          },
        )
      ],
    );
  }

  Widget buildHighlightOnTapSwitch() {
    ValueNotifier<bool> _notifier = ValueNotifier<bool>(source.highlightOnTap);

    return Row(
      children: [
        Expanded(
          child: Text(t.highlight_on_tap),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _notifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              onChanged: (value) {
                source.toggleHighlightOnTap();
                _notifier.value = source.highlightOnTap;
              },
            );
          },
        )
      ],
    );
  }
}
