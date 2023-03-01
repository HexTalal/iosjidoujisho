import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/models.dart';
import 'package:quiver/iterables.dart';

/// FNV-1a 64bit hash algorithm optimized for Dart Strings.
/// This is used to generate integer IDs that can be hard assigned to entities
/// with string IDs with microscopically low collision. This allows for example,
/// a [DictionaryHeading]'s ID to always be determinable by its composite
/// parameters.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

/// Performed in another isolate with compute. This is a top-level utility
/// function that makes use of Isar allowing instances to be opened through
/// multiple isolates. The function for preparing entries and tags according to
/// the [DictionaryFormat] is also done in the same isolate, to remove having
/// to communicate potentially hundreds of thousands of entries to another
/// newly opened isolate.
Future<void> depositDictionaryDataHelper(PrepareDictionaryParams params) async {
  try {
    /// Create a new instance of Isar as this is a different isolate.
    final Isar database = await Isar.open(
      globalSchemas,
      maxSizeMiB: 4096,
    );

    /// Perform format-specific entity generation.
    List<DictionaryTag> tags =
        await params.dictionaryFormat.prepareTags(params);
    Map<DictionaryHeading, List<DictionaryPitch>> pitchesByHeading =
        await params.dictionaryFormat.preparePitches(params);
    Map<DictionaryHeading, List<DictionaryFrequency>> frequenciesByHeading =
        await params.dictionaryFormat.prepareFrequencies(params);
    Map<DictionaryHeading, List<DictionaryEntry>> entriesByHeading =
        await params.dictionaryFormat.prepareEntries(params);

    /// For each entity type, assign heading and dictionary so that there are
    /// links and backlinks.
    for (DictionaryTag tag in tags) {
      tag.dictionary.value = params.dictionary;
    }
    Map<int, DictionaryTag> tagsByHash =
        Map.fromEntries(tags.map((tag) => MapEntry(tag.isarId, tag)));

    /// This section is for linking heading and entry tags into their actual
    /// entities, via the tag names they have. The tag names themselves will
    /// not be imported to the database to save space, but will be accessible
    /// via links.
    for (MapEntry<DictionaryHeading, List<DictionaryEntry>> entriesForHeading
        in entriesByHeading.entries) {
      for (DictionaryEntry entryForHeading in entriesForHeading.value) {
        entryForHeading.heading.value = entriesForHeading.key;
        entryForHeading.dictionary.value = params.dictionary;

        List<DictionaryTag> entryTags = entryForHeading.entryTagNames
            .map((name) {
              int dictionaryId = entryForHeading.dictionary.value!.id;
              int hash =
                  DictionaryTag.hash(dictionaryId: dictionaryId, name: name);
              return tagsByHash[hash];
            })
            .whereNotNull()
            .toList();
        List<DictionaryTag> headingTags = entryForHeading.headingTagNames
            .map((name) {
              int dictionaryId = entryForHeading.dictionary.value!.id;
              int hash =
                  DictionaryTag.hash(dictionaryId: dictionaryId, name: name);
              return tagsByHash[hash];
            })
            .whereNotNull()
            .toList();

        entryForHeading.tags.addAll(entryTags);
        entryForHeading.heading.value!.tags.addAll(headingTags);
      }
    }
    for (MapEntry<DictionaryHeading, List<DictionaryPitch>> pitchesForHeading
        in pitchesByHeading.entries) {
      for (DictionaryPitch pitchForHeading in pitchesForHeading.value) {
        pitchForHeading.heading.value = pitchesForHeading.key;
        pitchForHeading.dictionary.value = params.dictionary;
      }
    }
    for (MapEntry<DictionaryHeading,
            List<DictionaryFrequency>> frequenciesByHeading
        in frequenciesByHeading.entries) {
      for (DictionaryFrequency frequencyForHeading
          in frequenciesByHeading.value) {
        frequencyForHeading.heading.value = frequenciesByHeading.key;
        frequencyForHeading.dictionary.value = params.dictionary;
      }
    }

    /// Write as one transaction. If anything fails, no changes should occur.
    database.writeTxnSync(() {
      /// Write the [Dictionary] entity.
      database.dictionarys.putSync(params.dictionary);

      /// Write [DictionaryTag] entities.
      int tagCount = 0;
      int tagTotal = tags.length;
      database.dictionaryTags.putAllSync(tags);
      partition<DictionaryTag>(tags, 10000).forEach((batch) {
        database.dictionaryTags.putAllSync(batch);
        tagCount += batch.length;
        params.send(t.import_write_tag(count: tagCount, total: tagTotal));
      });

      /// Write [DictionaryPitch] entities.
      int pitchCount = 0;
      int pitchTotal = pitchesByHeading.values.map((e) => e.length).sum;
      partition<MapEntry<DictionaryHeading, List<DictionaryPitch>>>(
              pitchesByHeading.entries, 10000)
          .forEach((batch) {
        for (MapEntry<DictionaryHeading,
            List<DictionaryPitch>> pitchesForHeading in batch) {
          DictionaryHeading heading = pitchesForHeading.key;
          List<DictionaryPitch> pitches = pitchesForHeading.value;

          database.dictionaryHeadings.putSync(heading);
          database.dictionaryPitchs.putAllSync(pitches);
          pitchCount += pitches.length;
        }

        params.send(t.import_write_pitch(count: pitchCount, total: pitchTotal));
      });

      /// Write [DictionaryFrequency] entities.
      int frequencyCount = 0;
      int frequencyTotal = frequenciesByHeading.values.map((e) => e.length).sum;
      partition<MapEntry<DictionaryHeading, List<DictionaryFrequency>>>(
              frequenciesByHeading.entries, 10000)
          .forEach((batch) {
        for (MapEntry<DictionaryHeading,
            List<DictionaryFrequency>> frequenciesForHeading in batch) {
          DictionaryHeading heading = frequenciesForHeading.key;
          List<DictionaryFrequency> frequencies = frequenciesForHeading.value;

          database.dictionaryHeadings.putSync(heading);
          database.dictionaryFrequencys.putAllSync(frequencies);
          frequencyCount += frequencies.length;
        }

        params.send(t.import_write_frequency(
            count: frequencyCount, total: frequencyTotal));
      });

      /// Write [DictionaryEntry] entities.
      int entryCount = 0;
      int entryTotal = entriesByHeading.values.map((e) => e.length).sum;
      partition<MapEntry<DictionaryHeading, List<DictionaryEntry>>>(
              entriesByHeading.entries, 10000)
          .forEach((batch) {
        for (MapEntry<DictionaryHeading,
            List<DictionaryEntry>> entriesForHeading in batch) {
          DictionaryHeading heading = entriesForHeading.key;
          List<DictionaryEntry> entries = entriesForHeading.value;

          database.dictionaryHeadings.putSync(heading);
          database.dictionaryEntrys.putAllSync(entries);
          entryCount += entries.length;
        }

        params.send(t.import_write_entry(count: entryCount, total: entryTotal));
      });
    });
  } catch (e, stackTrace) {
    params.send(stackTrace);
    params.send(e);
  }
}

/// Performed in another isolate with compute. This is a top-level utility
/// function that makes use of Isar allowing instances to be opened through
/// multiple isolates.
Future<void> preloadResult(int id) async {
  /// Create a new instance of Isar as this is a different isolate.
  final Isar database = await Isar.open(
    globalSchemas,
    maxSizeMiB: 4096,
  );
  DictionarySearchResult result = database.dictionarySearchResults.getSync(id)!;

  result.headings.loadSync();
  for (DictionaryHeading heading in result.headings) {
    heading.entries.loadSync();
    for (DictionaryEntry entry in heading.entries) {
      entry.dictionary.loadSync();
      entry.tags.loadSync();
    }
    heading.pitches.loadSync();
    heading.frequencies.loadSync();
    heading.tags.loadSync();
  }
}

/// Add a [DictionarySearchResult] to the dictionary history. If the maximum value
/// is exceed, the dictionary history is cut down to the newest values.
Future<void> updateDictionaryHistoryHelper(
  UpdateDictionaryHistoryParams params,
) async {
  final Isar database = await Isar.open(
    globalSchemas,
    maxSizeMiB: 4096,
  );

  DictionarySearchResult result =
      database.dictionarySearchResults.getSync(params.resultId)!;

  database.writeTxnSync(() {
    result.scrollPosition = params.newPosition;
    database.dictionarySearchResults.putSync(result);
  });
}
