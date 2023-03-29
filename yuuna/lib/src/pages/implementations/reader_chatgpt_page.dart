import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_chatgpt_api/flutter_chatgpt_api.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderChatgptSource] which allows the user to interact with the
/// ChatGPT service.
class ReaderChatgptPage extends BaseSourcePage {
  /// Create an instance of this tab page.
  const ReaderChatgptPage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderChatgptPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderChatgptPageState extends BaseSourcePageState<ReaderChatgptPage> {
  ReaderChatgptSource get source => ReaderChatgptSource.instance;

  final ScrollController _scrollController =
      ReaderMediaType.instance.scrollController;
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;

  ChatGPTApi? _api;

  final ValueNotifier<String> _progressNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return ref.watch(accessCookieProvider).when(
          data: (accessCookie) {
            return ref.watch(clearanceCookieProvider).when(
                  data: (clearanceCookie) {
                    if (accessCookie == null || clearanceCookie == null) {
                      return buildNoAccessToken();
                    } else {
                      _api ??= ChatGPTApi(
                        sessionToken: accessCookie.value,
                        clearanceToken: clearanceCookie.value,
                      );

                      source.prepareMessageAccessToken();

                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent);
                        }
                      });

                      return Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                if (source.messages.isEmpty)
                                  buildEmpty()
                                else
                                  GestureDetector(
                                    onTap: clearDictionaryResult,
                                    child: buildMessageBuilder(),
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
                          ),
                          buildTextField(),
                          SizedBox(height: getBottomInsets() * 0.85)
                        ],
                      );
                    }
                  },
                  error: (error, stack) =>
                      buildError(error: error, stack: stack),
                  loading: buildLoading,
                );
          },
          error: (error, stack) => buildError(error: error, stack: stack),
          loading: buildLoading,
        );
  }

  Widget buildEmpty() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.chat_outlined,
        message: t.no_messages,
      ),
    );
  }

  double getBottomInsets() {
    if (MediaQuery.of(context).viewInsets.bottom >
        MediaQuery.of(context).viewPadding.bottom) {
      return MediaQuery.of(context).viewInsets.bottom -
          MediaQuery.of(context).viewPadding.bottom;
    }
    return 0;
  }

  Widget buildTextField() {
    return Padding(
      padding: Spacing.of(context).insets.all.normal,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        readOnly: _isLoading,
        decoration: InputDecoration(
          hintText: t.enter_message,
          suffixIcon: _isLoading
              ? SizedBox(
                  height: Spacing.of(context).spaces.extraBig,
                  width: Spacing.of(context).spaces.extraBig,
                  child: Padding(
                    padding: Spacing.of(context).insets.all.semiBig,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary),
                    ),
                  ),
                )
              : JidoujishoIconButton(
                  icon: Icons.send,
                  tooltip: t.send,
                  onTap: () => onSubmitted(_controller.text),
                ),
        ),
        onTap: clearDictionaryResult,
        onSubmitted: onSubmitted,
      ),
    );
  }

  void onSubmitted(String input) async {
    String text = input.trim();
    if (text.isEmpty) {
      return;
    }

    _controller.clear();
    _progressNotifier.value = '';

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    setState(() {
      source.messages.add(
        ChatMessage(
          text: text,
          chatMessageType: ChatMessageType.user,
        ),
      );
      _isLoading = true;
    });

    await source.prepareMessageAccessToken();

    try {
      final response = await _api!.sendMessage(
        accessToken: source.messageAccessToken!,
        message: text,
        onProgress: (progress) {
          _progressNotifier.value = progress.message;
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        },
        conversationId: source.lastResponse?.conversationId,
        parentMessageId: source.lastResponse?.messageId,
      );

      source.lastResponse = response;

      source.messages.add(
        ChatMessage(
          text: response.message.trim(),
          chatMessageType: ChatMessageType.bot,
        ),
      );
    } catch (e) {
      if (source.messageAccessToken == null) {
        CookieManager.instance().deleteCookies(
          url: Uri.parse('https://chat.openai.com/'),
          domain: 'openai.com',
        );

        ref.refresh(accessCookieProvider);
        ref.refresh(clearanceCookieProvider);
      }
    } finally {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildNoAccessToken() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.login,
        message: t.access_token_missing_expired,
      ),
    );
  }

  Widget buildMessageBuilder() {
    List<ChatMessage> messages = source.messages.toList();
    return RawScrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 3,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        controller: _scrollController,
        itemCount: _isLoading ? messages.length + 1 : messages.length,
        itemBuilder: (context, index) {
          if (index == messages.length) {
            return ValueListenableBuilder(
              valueListenable: _progressNotifier,
              builder: (context, value, child) {
                return buildMessage(
                  isBot: true,
                  isLoading: true,
                  text: _progressNotifier.value,
                );
              },
            );
          }

          ChatMessage message = messages[index];

          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 60 : 0),
            child: buildMessage(
              text: message.text,
              isBot: message.chatMessageType == ChatMessageType.bot,
              isLoading: false,
            ),
          );
        },
      ),
    );
  }

  JidoujishoSelectableTextController? _lastTappedController;

  @override
  void clearDictionaryResult() {
    super.clearDictionaryResult();
    _lastTappedController?.clearSelection();
    source.clearCurrentSentence();
  }

  List<InlineSpan> getTextSpans({
    required JidoujishoSelectableTextController controller,
    required String text,
  }) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
          text: character,
          style: const TextStyle(fontSize: 18),
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) async {
              _lastTappedController?.clearSelection();
              _lastTappedController = controller;

              bool wholeWordCondition = controller.selection.start <= index &&
                  controller.selection.end > index;

              if (wholeWordCondition && currentResult != null) {
                clearDictionaryResult();
                return;
              }

              source.setCurrentSentence(text);

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

              if (character.trim().isNotEmpty) {
                bool isSpaceDelimited =
                    appModel.targetLanguage.isSpaceDelimited;
                int whitespaceOffset =
                    searchTerm.length - searchTerm.trimLeft().length;
                int offsetIndex = appModel.targetLanguage
                        .getStartingIndex(text: text, index: index) +
                    whitespaceOffset;
                int length = appModel.targetLanguage
                    .textToWords(searchTerm)
                    .firstWhere((e) => e.trim().isNotEmpty)
                    .length;

                controller.setSelection(
                  offsetIndex,
                  offsetIndex + length,
                );

                searchDictionaryResult(
                  searchTerm: searchTerm,
                  position: position,
                ).then((result) {
                  int length = isSpaceDelimited
                      ? appModel.targetLanguage
                          .textToWords(searchTerm)
                          .firstWhere((e) => e.trim().isNotEmpty)
                          .length
                      : max(1, currentResult?.bestLength ?? 0);

                  controller.setSelection(offsetIndex, offsetIndex + length);
                });
              } else {
                clearDictionaryResult();
              }

              FocusScope.of(context).unfocus();
            },
        ),
      );
    });

    return spans;
  }

  Widget buildMessage({
    required String text,
    required bool isBot,
    required bool isLoading,
  }) {
    final JidoujishoSelectableTextController controller =
        JidoujishoSelectableTextController();

    return Padding(
      padding: EdgeInsets.only(
        top: Spacing.of(context).spaces.extraSmall,
        left: Spacing.of(context).spaces.normal,
        right: Spacing.of(context).spaces.normal,
      ),
      child: Card(
        color: isBot ? Colors.red.withOpacity(0.5) : null,
        child: Padding(
          padding: Spacing.of(context).insets.all.normal,
          child: isLoading && text.isEmpty
              ? JumpingDotsProgressIndicator(
                  fontSize: theme.textTheme.bodyMedium!.fontSize!,
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                )
              : Row(
                  children: [
                    Expanded(
                      child: JidoujishoSelectableText.rich(
                        TextSpan(children: [
                          ...getTextSpans(
                            controller: controller,
                            text: text,
                          ),
                          if (isLoading)
                            WidgetSpan(
                              child: SizedBox(
                                width: theme.textTheme.bodyMedium!.fontSize,
                                child: JumpingDotsProgressIndicator(
                                  fontSize:
                                      theme.textTheme.bodyMedium!.fontSize!,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor!,
                                ),
                              ),
                            ),
                        ]),
                        selectionControls: JidoujishoTextSelectionControls(
                          searchAction: (selection) async {
                            source.setCurrentSentence(text);
                            await appModel.openRecursiveDictionarySearch(
                              searchTerm: selection,
                              killOnPop: false,
                            );
                            source.clearCurrentSentence();
                          },
                          searchActionLabel: t.search,
                          stashAction: onContextStash,
                          stashActionLabel: t.stash,
                          creatorAction: (selection) async {
                            launchCreator(term: selection, sentence: text);
                          },
                          creatorActionLabel: t.creator,
                          allowCopy: true,
                          allowSelectAll: false,
                          allowCut: true,
                          allowPaste: true,
                        ),
                        controller: controller,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    buildTextSegmentButton(text),
                    buildCardCreatorButton(text),
                  ],
                ),
        ),
        shape: const RoundedRectangleBorder(),
      ),
    );
  }

  Widget buildTextSegmentButton(String message) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.text_segmentation,
        icon: Icons.account_tree,
        onTap: () async {
          appModel.openTextSegmentationDialog(
            sourceText: message,
            onSearch: (selection, items) async {
              source.setCurrentSentence(message);
              await appModel.openRecursiveDictionarySearch(
                searchTerm: selection,
                killOnPop: false,
              );
              source.clearCurrentSentence();
            },
            onSelect: (selection, items) {
              appModel.openCreator(
                creatorFieldValues: CreatorFieldValues(
                  textValues: {
                    TermField.instance: selection,
                    SentenceField.instance: message,
                  },
                ),
                killOnPop: false,
                ref: ref,
              );
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  void onContextSearch(String searchTerm, {String? sentence}) async {}

  Widget buildCardCreatorButton(String message) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.card_creator,
        icon: Icons.note_add,
        onTap: () async {
          launchCreator(term: '', sentence: message);
        },
      ),
    );
  }

  void launchCreator({required String term, required String sentence}) async {
    await appModel.openCreator(
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: sentence,
          TermField.instance: term,
        },
      ),
      killOnPop: false,
      ref: ref,
    );
  }
}
