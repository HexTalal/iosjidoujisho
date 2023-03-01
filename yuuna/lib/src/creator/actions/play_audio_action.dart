import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/dictionary.dart';

/// An enhancement used effectively as a shortcut for previewing audio.
class PlayAudioAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  PlayAudioAction()
      : super(
          uniqueKey: key,
          label: 'Play Audio',
          description:
              'Attempts to play audio based on the Audio enhancements. The auto'
              ' is the top priority.',
          icon: Icons.play_circle,
        );

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'play_audio';

  @override
  Future<void> executeAction(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel,
      required CreatorModel creatorModel,
      required DictionaryHeading heading}) async {
    _audioPlayer.stop();

    List<Enhancement> audioEnhancements = [];

    Enhancement? autoEnhancement =
        appModel.lastSelectedMapping.getAutoFieldEnhancement(
      appModel: appModel,
      field: AudioField.instance,
    );
    if (autoEnhancement != null) {
      audioEnhancements.add(autoEnhancement);
    }
    audioEnhancements.addAll(
      appModel.lastSelectedMapping.getManualFieldEnhancement(
        appModel: appModel,
        field: AudioField.instance,
      ),
    );

    if (audioEnhancements.isEmpty) {
      String noAudioEnhancements = appModel.translate('no_audio_enhancements');
      Fluttertoast.showToast(
        msg: noAudioEnhancements,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    for (Enhancement? enhancement in audioEnhancements) {
      if (enhancement == null) {
        continue;
      }

      if (enhancement is AudioEnhancement) {
        File? file = await enhancement.fetchAudio(
          appModel: appModel,
          context: context,
          term: heading.term,
          reading: heading.reading,
        );

        if (file != null) {
          await _audioPlayer.setFilePath(file.path);

          final AudioSession session = await AudioSession.instance;
          await session.configure(
            const AudioSessionConfiguration(
              avAudioSessionCategory: AVAudioSessionCategory.playback,
              avAudioSessionCategoryOptions:
                  AVAudioSessionCategoryOptions.duckOthers,
              avAudioSessionMode: AVAudioSessionMode.defaultMode,
              avAudioSessionRouteSharingPolicy:
                  AVAudioSessionRouteSharingPolicy.defaultPolicy,
              avAudioSessionSetActiveOptions:
                  AVAudioSessionSetActiveOptions.none,
              androidAudioAttributes: AndroidAudioAttributes(
                contentType: AndroidAudioContentType.music,
                usage: AndroidAudioUsage.media,
              ),
              androidAudioFocusGainType:
                  AndroidAudioFocusGainType.gainTransientMayDuck,
              androidWillPauseWhenDucked: true,
            ),
          );
          session.setActive(true);
          await _audioPlayer.play();
          session.setActive(false);
          return;
        }
      }
    }

    String noAudioEnhancements = appModel.translate('audio_unavailable');
    Fluttertoast.showToast(
      msg: noAudioEnhancements,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
