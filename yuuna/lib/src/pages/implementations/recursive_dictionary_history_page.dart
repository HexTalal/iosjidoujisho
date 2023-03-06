import 'package:flutter/material.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page shown to view a result in dictionary history.
class RecursiveDictionaryHistoryPage extends BasePage {
  /// Create an instance of this page.
  const RecursiveDictionaryHistoryPage({
    required this.result,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionarySearchResult result;

  @override
  BasePageState<RecursiveDictionaryHistoryPage> createState() =>
      _RecursiveDictionaryHistoryPageState();
}

class _RecursiveDictionaryHistoryPageState
    extends BasePageState<RecursiveDictionaryHistoryPage> {
  String get backLabel => appModel.translate('back');
  String get dictionariesLabel => appModel.translate('dictionaries');
  String get searchEllipsisLabel => appModel.translate('search_ellipsis');
  String get noDictionariesLabel =>
      appModel.translate('dictionaries_menu_empty');
  String get noSearchResultsLabel => appModel.translate('no_search_results');
  String get enterSearchTermLabel => appModel.translate('enter_search_term');
  String get clearLabel => appModel.translate('clear');

  Map<String, Dictionary>? dictionaryMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(),
      body: DictionaryResultPage(
        result: widget.result,
        onSearch: onSearch,
        onStash: onStash,
        updateHistory: false,
      ),
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: JidoujishoMarquee(
            text: widget.result.searchTerm.replaceAll('\n', ' '),
            style: TextStyle(
              fontSize: textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildBackButton(),
      title: buildTitle(),
      titleSpacing: 8,
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: backLabel,
      icon: Icons.arrow_back,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  void onSearch(String searchTerm) {
    appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
  }

  void onStash(String searchTerm) {
    appModel.addToStash(terms: [searchTerm]);
  }
}
