import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A source for the [ViewerMediaType], which handles primarily image-based
/// media.
abstract class ViewerMediaSource extends MediaSource {
  /// Initialise a media source.
  ViewerMediaSource({
    required super.uniqueKey,
    required super.sourceName,
    required super.description,
    required super.icon,
    required super.implementsSearch,
    required super.implementsHistory,
  }) : super(
          mediaType: ViewerMediaType.instance,
        );

  @override
  double get aspectRatio => 2 / 3;

  /// The body widget to show in the tab when this source's media type and this
  /// source is selected.
  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const HistoryViewerPage();
  }
}
