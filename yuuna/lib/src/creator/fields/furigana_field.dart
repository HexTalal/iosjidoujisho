import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';

/// Returns the formatted furigana HTML of a [DictionaryHeading].
class FuriganaField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  FuriganaField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Furigana',
          description: 'Pre-fills HTML to export for furigana. See '
              ' documentation for required CSS.',
          icon: Icons.data_array,
        );

  /// Get the singleton instance of this field.
  static FuriganaField get instance => _instance;

  static final FuriganaField _instance = FuriganaField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'furigana';

  @override
  String? onCreatorOpenAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
  }) {
    List<RubyTextData>? rubyDatas = JapaneseLanguage.instance.fetchFurigana(
      heading: heading,
    );

    if (rubyDatas == null) {
      return '';
    }

    StringBuffer buffer = StringBuffer();
    for (RubyTextData rubyData in rubyDatas) {
      buffer.write(rubyData.text);
      if (rubyData.ruby != null && rubyData.ruby!.trim().isNotEmpty) {
        buffer.write('[${rubyData.ruby}]');
      } else {
        buffer.write('[ ]');
      }
    }

    return buffer.toString();
  }
}
