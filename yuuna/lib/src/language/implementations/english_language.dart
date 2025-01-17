import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lemmatizerx/lemmatizerx.dart';
import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';

/// Language implementation of the English language.
class EnglishLanguage extends Language {
  EnglishLanguage._privateConstructor()
      : super(
          languageName: 'English',
          languageCode: 'en',
          countryCode: 'US',
          threeLetterCode: 'eng',
          preferVerticalReading: false,
          textDirection: TextDirection.ltr,
          isSpaceDelimited: true,
          textBaseline: TextBaseline.alphabetic,
          helloWorld: 'Hello world',
          prepareSearchResults: prepareSearchResultsEnglishLanguage,
          standardFormat: MigakuFormat.instance,
          defaultFontFamily: 'Roboto',
        );

  /// Get the singleton instance of this language.
  static EnglishLanguage get instance => _instance;

  static final EnglishLanguage _instance =
      EnglishLanguage._privateConstructor();

  @override
  Future<void> prepareResources() async {}

  @override
  List<String> textToWords(String text) {
    List<String> splitText = text.splitWithDelim(RegExp(r'[-\n\r\s]+'));
    return splitText
        .mapIndexed((index, element) {
          if (index.isEven && index + 1 < splitText.length) {
            return [splitText[index], splitText[index + 1]].join();
          } else if (index + 1 == splitText.length) {
            return splitText[index];
          } else {
            return '';
          }
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

/// Top-level function for use in compute. See [Language] for details.
Future<int?> prepareSearchResultsEnglishLanguage(
    DictionarySearchParams params) async {
  final Lemmatizer lemmatizer = Lemmatizer();
  final Isar database = await Isar.open(
    globalSchemas,
    directory: params.directoryPath,
    maxSizeMiB: 8192,
  );

  int bestLength = 0;
  String searchTerm = params.searchTerm.toLowerCase().trim();

  /// Handles contractions well enough.
  searchTerm = searchTerm
      .replaceAll('won\'t', 'will not')
      .replaceAll('can\'t', 'cannot')
      .replaceAll('i\'m', 'i am')
      .replaceAll('ain\'t', 'is not')
      .replaceAll('\'ll', ' will')
      .replaceAll('n\'t', ' not')
      .replaceAll('\'ve', ' have')
      .replaceAll('\'s', ' is')
      .replaceAll('\'re', ' are')
      .replaceAll('\'d', ' would')
      .replaceAll('won’t', 'will not')
      .replaceAll('can’t', 'cannot')
      .replaceAll('i’m', 'i am')
      .replaceAll('ain’t', 'is not')
      .replaceAll('’ll', ' will')
      .replaceAll('n’t', ' not')
      .replaceAll('’ve', ' have')
      .replaceAll('’s', ' is')
      .replaceAll('’re', ' are')
      .replaceAll('’d', ' would');

  if (searchTerm.isEmpty) {
    return null;
  }

  int maximumHeadings = params.maximumDictionarySearchResults;

  Map<int, DictionaryHeading> uniqueHeadingsById = {};

  int limit() {
    return maximumHeadings - uniqueHeadingsById.length;
  }

  bool shouldSearchWildcards = params.searchWithWildcards &&
      (searchTerm.contains('*') || searchTerm.contains('?'));

  if (shouldSearchWildcards) {
    bool noExactMatches = database.dictionaryHeadings
        .where()
        .termEqualTo(searchTerm)
        .isEmptySync();

    if (noExactMatches) {
      String matchesTerm = searchTerm;

      List<DictionaryHeading> termMatchHeadings = [];

      bool questionMarkOnly = !matchesTerm.contains('*');
      String noAsterisks = searchTerm
          .replaceAll('※', '*')
          .replaceAll('？', '?')
          .replaceAll('*', '');

      if (params.maximumDictionaryTermsInResult > uniqueHeadingsById.length) {
        if (questionMarkOnly) {
          termMatchHeadings = database.dictionaryHeadings
              .where()
              .termLengthEqualTo(searchTerm.length)
              .filter()
              .termMatches(matchesTerm, caseSensitive: false)
              .and()
              .entriesIsNotEmpty()
              .limit(maximumHeadings - uniqueHeadingsById.length)
              .findAllSync();
        } else {
          termMatchHeadings = database.dictionaryHeadings
              .where()
              .termLengthGreaterThan(noAsterisks.length, include: true)
              .filter()
              .termMatches(matchesTerm, caseSensitive: false)
              .and()
              .entriesIsNotEmpty()
              .limit(maximumHeadings - uniqueHeadingsById.length)
              .findAllSync();
        }
      }

      uniqueHeadingsById.addEntries(
        termMatchHeadings.map(
          (heading) => MapEntry(heading.id, heading),
        ),
      );
    }
  } else {
    Map<int, List<DictionaryHeading>> termExactResultsByLength = {};
    Map<int, List<DictionaryHeading>> termDeinflectedResultsByLength = {};
    Map<int, List<DictionaryHeading>> termStartsWithResultsByLength = {};

    List<String> segments = searchTerm.splitWithDelim(RegExp('[ -\']'));

    if (segments.length > 20) {
      segments = segments.sublist(0, 10);
    }
    if (segments.length >= 3) {
      String firstWord = segments.removeAt(0);
      String secondWord = segments.removeAt(0);
      String thirdWord = segments.removeAt(0);
      segments = [
        if (firstWord.length > 3)
          if (firstWord.split('').length > 3) ...[
            firstWord.substring(0, firstWord.length - 3),
            firstWord[firstWord.length - 3],
            firstWord[firstWord.length - 2],
            firstWord[firstWord.length - 1],
          ] else
            ...firstWord.split('')
        else
          firstWord,
        if (secondWord.length > 3)
          if (secondWord.split('').length > 3) ...[
            secondWord.substring(0, secondWord.length - 3),
            secondWord[secondWord.length - 3],
            secondWord[secondWord.length - 2],
            secondWord[secondWord.length - 1],
          ] else
            ...secondWord.split('')
        else
          secondWord,
        if (thirdWord.length > 3)
          if (thirdWord.split('').length > 3) ...[
            thirdWord.substring(0, thirdWord.length - 3),
            thirdWord[thirdWord.length - 3],
            thirdWord[thirdWord.length - 2],
            thirdWord[thirdWord.length - 1],
          ] else
            ...thirdWord.split('')
        else
          thirdWord,
      ];
    } else {
      String firstWord = segments.removeAt(0);
      segments = [
        if (firstWord.length >= 3) ...firstWord.split('') else firstWord,
      ];
    }

    for (int i = 0; i < segments.length; i++) {
      String partialTerm = segments
          .sublist(0, segments.length - i)
          .join()
          .replaceAll(RegExp('[^a-zA-Z -]'), '');

      if (partialTerm.endsWith(' ')) {
        continue;
      }

      List<String> blocks = partialTerm.split(' ');
      String lastBlock = blocks.removeLast();

      List<String> possibleDeinflections = lemmatizer
          .lemmas(lastBlock)
          .map((lemma) => lemma.lemmas)
          .flattened
          .where((e) => e.isNotEmpty)
          .map(
            (e) => [...blocks, e].join(),
          )
          .toList();

      List<DictionaryHeading> termExactResults = [];
      List<DictionaryHeading> termDeinflectedResults = [];
      List<DictionaryHeading> termStartsWithResults = [];

      termExactResults = database.dictionaryHeadings
          .where(sort: Sort.desc)
          .termEqualTo(partialTerm)
          .limit(limit())
          .findAllSync();

      if (possibleDeinflections.isNotEmpty) {
        termDeinflectedResults = database.dictionaryHeadings
            .where()
            .anyOf<String, String>(
                possibleDeinflections, (q, term) => q.termEqualTo(term))
            .limit(limit())
            .findAllSync();
      }

      if (partialTerm.length >= 3) {
        termStartsWithResults = database.dictionaryHeadings
            .where()
            .termStartsWith(partialTerm)
            .sortByTermLength()
            .limit(limit())
            .findAllSync();
      }

      if (termExactResults.isNotEmpty) {
        termExactResultsByLength[partialTerm.length] = termExactResults;
        bestLength = partialTerm.length;
      }
      if (termDeinflectedResults.isNotEmpty) {
        termDeinflectedResultsByLength[partialTerm.length] =
            termDeinflectedResults;
        bestLength = partialTerm.length;
      }
      if (termStartsWithResults.isNotEmpty) {
        termStartsWithResultsByLength[partialTerm.length] =
            termStartsWithResults;
        bestLength = partialTerm.length;
      }
    }

    for (int length = searchTerm.length; length > 0; length--) {
      List<MapEntry<int, DictionaryHeading>> exactHeadingsToAdd = [
        ...(termExactResultsByLength[length] ?? [])
            .map((heading) => MapEntry(heading.id, heading)),
      ];

      List<MapEntry<int, DictionaryHeading>> deinflectedHeadingsToAdd = [
        ...(termDeinflectedResultsByLength[length] ?? [])
            .map((entry) => MapEntry(entry.id, entry)),
      ];

      uniqueHeadingsById.addEntries(exactHeadingsToAdd);
      uniqueHeadingsById.addEntries(deinflectedHeadingsToAdd);

      if (params.searchWithWildcards) {
        for (int length = searchTerm.length; length > 0; length--) {
          List<MapEntry<int, DictionaryHeading>> startsWithHeadingsToAdd = [
            ...(termStartsWithResultsByLength[length] ?? [])
                .map((heading) => MapEntry(heading.id, heading)),
          ];

          uniqueHeadingsById.addEntries(startsWithHeadingsToAdd);
        }
      }
    }

    if (!params.searchWithWildcards) {
      for (int length = searchTerm.length; length > 0; length--) {
        List<MapEntry<int, DictionaryHeading>> startsWithHeadingsToAdd = [
          ...(termStartsWithResultsByLength[length] ?? [])
              .map((heading) => MapEntry(heading.id, heading)),
        ];

        uniqueHeadingsById.addEntries(startsWithHeadingsToAdd);
      }
    }
  }

  List<DictionaryHeading> headings =
      uniqueHeadingsById.values.where((e) => e.entries.isNotEmpty).toList();

  if (headings.isEmpty) {
    return null;
  }

  DictionarySearchResult unsortedResult = DictionarySearchResult(
    searchTerm: searchTerm,
    bestLength: bestLength,
  );
  unsortedResult.headings.addAll(headings);

  late int resultId;
  database.writeTxnSync(() async {
    database.dictionarySearchResults.deleteBySearchTermSync(searchTerm);
    resultId = database.dictionarySearchResults.putSync(unsortedResult);
  });

  preloadResultSync(resultId);

  headings = headings.sublist(
      0, min(headings.length, params.maximumDictionaryTermsInResult));
  List<int> headingIds = headings.map((e) => e.id).toList();

  DictionarySearchResult result = DictionarySearchResult(
    id: resultId,
    searchTerm: searchTerm,
    bestLength: bestLength,
    headingIds: headingIds,
  );

  database.writeTxnSync(() async {
    resultId = database.dictionarySearchResults.putSync(result);

    int countInSameHistory = database.dictionarySearchResults.countSync();

    if (params.maximumDictionarySearchResults < countInSameHistory) {
      int surplus = countInSameHistory - params.maximumDictionarySearchResults;
      database.dictionarySearchResults
          .where()
          .limit(surplus)
          .build()
          .deleteAllSync();
    }
  });

  return resultId;
}
