import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/media/sources/reader_clipboard_source.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderClipboardPage] which shows the content of the current
/// clipboard as selectable text.
class ReaderClipboardPage extends BaseSourcePage {
  /// Create an instance of this tab page.
  const ReaderClipboardPage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderClipboardPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderClipboardPageState<ReaderClipboardPage>
    extends BaseSourcePageState {
  String get noTextInClipboard => appModel.translate('no_text_in_clipboard');

  Orientation? lastOrientation;

  ReaderClipboardSource get source => ReaderClipboardSource.instance;

  /// Allows programmatic changing of the current text selection.
  final SelectableTextController _selectableTextController =
      SelectableTextController();

  @override
  Widget build(BuildContext context) {
    String text = ref.watch(clipboardProvider);
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation != lastOrientation) {
      clearDictionaryResult();
      lastOrientation = orientation;
    }

    if (text.trim().isEmpty) {
      return buildPlaceholder();
    }

    return GestureDetector(
      onTap: clearDictionaryResult,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            primary: false,
            child: Padding(
              padding: Spacing.of(context).insets.horizontal.extraBig,
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const Space.extraBig(),
                  const Space.big(),
                  buildText(text),
                  const Space.big(),
                  Container(height: MediaQuery.of(context).size.height / 2)
                ],
              ),
            ),
          ),
          Column(
            children: [
              const Space.extraBig(),
              Expanded(
                child: buildDictionary(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.paste,
        message: noTextInClipboard,
      ),
    );
  }

  String _currentSelection = '';
  final FocusNode _focusNode = FocusNode(skipTraversal: true);

  Widget buildText(String text) {
    return SelectableText.rich(
      TextSpan(children: getSubtitleSpans(text)),
      focusNode: _focusNode,
      controller: _selectableTextController,
      selectionControls: selectionControls,
      onSelectionChanged: (selection, cause) {
        String textSelection = selection.textInside(text);
        _currentSelection = textSelection;
      },
    );
  }

  final ScrollController _scrollController = ScrollController();

  List<InlineSpan> getSubtitleSpans(String text) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
          text: character,
          style: const TextStyle(fontSize: 22),
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) async {
              double x = details.globalPosition.dx;
              double y = details.globalPosition.dy;

              late JidoujishoPopupPosition position;
              if (MediaQuery.of(context).orientation == Orientation.portrait) {
                if (y < MediaQuery.of(context).size.height / 2) {
                  position = JidoujishoPopupPosition.bottomHalf;
                } else {
                  position = JidoujishoPopupPosition.topHalf;
                }
              } else {
                if (x < MediaQuery.of(context).size.width / 2) {
                  position = JidoujishoPopupPosition.rightHalf;
                } else {
                  position = JidoujishoPopupPosition.leftHalf;
                }
              }

              String searchTerm =
                  appModel.targetLanguage.getSearchTermFromIndex(
                text: text,
                index: index,
              );

              if (_currentSelection.isEmpty && character.trim().isNotEmpty) {
                bool isSpaceDelimited =
                    appModel.targetLanguage.isSpaceDelimited;
                int whitespaceOffset =
                    searchTerm.length - searchTerm.trimLeft().length;
                int offsetIndex = index + whitespaceOffset;
                int length = appModel.targetLanguage
                    .textToWords(searchTerm)
                    .firstWhere((e) => e.trim().isNotEmpty)
                    .length;

                _selectableTextController.setSelection(
                  offsetIndex,
                  offsetIndex + length,
                );

                searchDictionaryResult(
                  searchTerm: searchTerm,
                  position: position,
                ).then((result) {
                  source.setCurrentSentence(
                    appModel.targetLanguage.getSentenceFromParagraph(
                        paragraph: text, index: index),
                  );

                  int length = isSpaceDelimited
                      ? appModel.targetLanguage
                          .textToWords(searchTerm)
                          .firstWhere((e) => e.trim().isNotEmpty)
                          .length
                      : max(1, currentResult?.bestLength ?? 0);

                  _selectableTextController.setSelection(
                      offsetIndex, offsetIndex + length);
                });
              } else {
                clearDictionaryResult();
                _currentSelection = '';
              }

              FocusScope.of(context).unfocus();
            },
        ),
      );
    });

    return spans;
  }

  @override
  void clearDictionaryResult() {
    super.clearDictionaryResult();
    _selectableTextController.clearSelection();
    source.clearCurrentSentence();
  }

  void creatorAction(String text) async {
    await appModel.openCreator(
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: text,
        },
      ),
      killOnPop: false,
      ref: ref,
    );
  }

  @override
  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        searchAction: onContextSearch,
        searchActionLabel: searchLabel,
        stashAction: onContextStash,
        stashActionLabel: stashLabel,
        creatorActionLabel: creatorLabel,
        creatorAction: creatorAction,
        allowCopy: true,
        allowSelectAll: false,
        allowCut: true,
        allowPaste: true,
      );
}
