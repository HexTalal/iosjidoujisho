import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/models.dart';

/// Used in a floating search bar body for showing search history items for
/// a certain collection named [uniqueKey].
class JidoujishoSearchHistory extends ConsumerStatefulWidget {
  /// Create an instance of this widget.
  const JidoujishoSearchHistory({
    required this.uniqueKey,
    required this.onSearchTermSelect,
    required this.onUpdate,
    this.searchSuggestions = const [],
    super.key,
  });

  /// The name of the collection that will be displayed.
  final String uniqueKey;

  /// An action that will be performed upon selecting a search term.
  final Function(String) onSearchTermSelect;

  /// An action that will be performed upon deleting a search term.
  final Function() onUpdate;

  /// This overrides the history display and shows search suggestions
  /// instead if non-null.
  final List<String> searchSuggestions;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _JidoujishoSearchHistoryState();
}

class _JidoujishoSearchHistoryState
    extends ConsumerState<JidoujishoSearchHistory> {
  AppModel get appModel => ref.watch(appProvider);

  @override
  Widget build(BuildContext context) {
    late List<String> searchHistory;
    if (widget.searchSuggestions.isNotEmpty) {
      searchHistory = widget.searchSuggestions;
    } else {
      searchHistory = appModel
          .getSearchHistory(historyKey: widget.uniqueKey)
          .reversed
          .toList();
    }

    return ClipRRect(
      child: Material(
        color: Colors.transparent,
        child: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: searchHistory.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Space.normal();
            }

            return buildSearchHistoryItem(
              uniqueKey: widget.uniqueKey,
              searchTerm: searchHistory[index - 1],
              onSearchTermSelect: widget.onSearchTermSelect,
            );
          },
        ),
      ),
    );
  }

  Widget buildSearchHistoryItem({
    required String uniqueKey,
    required String searchTerm,
    required Function(String) onSearchTermSelect,
  }) {
    return InkWell(
      onTap: () => onSearchTermSelect(searchTerm),
      onLongPress: () {
        if (widget.searchSuggestions.isNotEmpty) {
          return;
        }

        appModel.removeFromSearchHistory(
          historyKey: uniqueKey,
          searchTerm: searchTerm,
        );
        setState(() {});
        widget.onUpdate();
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: Spacing.of(context).spaces.normal,
          bottom: Spacing.of(context).spaces.semiBig,
          left: Spacing.of(context).spaces.big,
          right: Spacing.of(context).spaces.big,
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: Spacing.of(context).spaces.small,
              ),
              child: Icon(
                widget.searchSuggestions.isNotEmpty
                    ? Icons.search
                    : Icons.youtube_searched_for_outlined,
                size: Theme.of(context).textTheme.titleMedium?.fontSize,
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Text(
                searchTerm,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
