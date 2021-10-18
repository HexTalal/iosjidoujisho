import 'dart:convert';

import 'package:chisa/media/histories/default_media_history.dart';
import 'package:chisa/media/history_items/dictionary_media_history_item.dart';

class DictionaryMediaHistory extends DefaultMediaHistory {
  DictionaryMediaHistory({
    required sharedPreferences,
    required prefsDirectory,
    maxItemCount = 50,
  }) : super(
          prefsDirectory: prefsDirectory,
          sharedPreferences: sharedPreferences,
        );

  Future<void> addDictionaryItem(DictionaryMediaHistoryItem item) async {
    List<DictionaryMediaHistoryItem> history = getDictionaryItems();

    history.removeWhere((historyItem) => item.key == historyItem.key);
    history.add(item);

    if (history.length >= maxItemCount) {
      history = history.sublist(history.length - maxItemCount);
    }

    await setItems(history);
  }

  Future<void> removeDictionaryItem(String key) async {
    List<DictionaryMediaHistoryItem> history = getDictionaryItems();

    history.removeWhere((historyItem) => key == historyItem.key);
    await setItems(history);
  }

  List<DictionaryMediaHistoryItem> getDictionaryItems() {
    String jsonList = sharedPreferences.getString(prefsDirectory) ?? '[]';

    List<dynamic> serialisedItems = (jsonDecode(jsonList) as List<dynamic>);

    List<DictionaryMediaHistoryItem> history = [];
    for (var serialisedItem in serialisedItems) {
      DictionaryMediaHistoryItem entry =
          DictionaryMediaHistoryItem.fromJson(serialisedItem);
      history.add(entry);
    }

    return history;
  }

  Future<void> setDictionaryItems(
      List<DictionaryMediaHistoryItem> items) async {
    List<String> serialisedItems = [];
    for (DictionaryMediaHistoryItem item in items) {
      serialisedItems.add(
        item.toJson(),
      );
    }

    await sharedPreferences.setString(
      prefsDirectory,
      jsonEncode(serialisedItems),
    );
  }
}
