import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:spaces/spaces.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Returns audio information from context.
class ImageField extends ImageExportField {
  /// Initialise this field with the predetermined and hardset values.
  ImageField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Image',
          description: 'Visual supplement. Text field can be used to enter'
              ' search terms for image sources.',
          icon: Icons.image,
        );

  /// Get the singleton instance of this field.
  static ImageField get instance => _instance;

  static final ImageField _instance = ImageField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'image';

  @override
  String? onCreatorOpenAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
  }) {
    return null;
  }

  @override
  Widget buildTopWidget({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required Orientation orientation,
  }) {
    if (isSearching) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (orientation == Orientation.landscape)
            Flexible(
              child: Container(
                color: Colors.transparent,
                height: double.infinity,
                width: double.infinity,
              ),
            )
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.transparent,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
          const Space.normal(),
          buildFooterLoading(
            appModel: appModel,
            context: context,
          ),
        ],
      );
    }

    if (!showWidget) {
      return const SizedBox.shrink();
    }

    int itemCount = currentImageSuggestions!.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (orientation == Orientation.landscape)
          Flexible(
            child: buildCarousel(
              itemCount: itemCount,
              appModel: appModel,
            ),
          )
        else
          buildCarousel(
            itemCount: itemCount,
            appModel: appModel,
          ),
        const Space.normal(),
        ValueListenableBuilder<int?>(
          valueListenable: indexNotifier,
          builder: (context, index, _) => buildFooterTextSpans(
            context: context,
            appModel: appModel,
            itemCount: itemCount,
          ),
        ),
      ],
    );
  }

  /// Build the image carousel.
  Widget buildCarousel({
    required int itemCount,
    required AppModel appModel,
  }) {
    CarouselController controller = CarouselController();

    return CarouselSlider.builder(
      itemCount: itemCount + 1,
      carouselController: controller,
      options: CarouselOptions(
        enlargeCenterPage: true,
        viewportFraction: 0.75,
        initialPage: indexNotifier.value,
        onPageChanged: (index, reason) {
          if (index == itemCount) {
            indexNotifier.value = -1;
            setSelectedSearchSuggestion(index: -1);
          } else {
            indexNotifier.value = index;
            setSelectedSearchSuggestion(index: index);
          }
        },
      ),
      itemBuilder: (context, index, realIndex) {
        if (index == itemCount) {
          return Container(
            color: appModel.isDarkMode ? Colors.white10 : Colors.black12,
          );
        }

        OverlayEntry? popup;
        ImageProvider<Object> image = currentImageSuggestions![index];

        return GestureDetector(
          onLongPress: () {
            if (index != indexNotifier.value) {
              return;
            }
            popup = OverlayEntry(
              builder: (context) => ColoredBox(
                color: Colors.black.withOpacity(0.5),
                child: buildImage(image: image, fit: BoxFit.contain),
              ),
            );
            Overlay.of(context).insert(popup!);
          },
          onLongPressEnd: (details) {
            popup?.remove();
          },
          child: Padding(
            padding: Spacing.of(context).insets.horizontal.small,
            child: buildImage(
              image: currentImageSuggestions![index],
              fit: BoxFit.fitHeight,
            ),
          ),
        );
      },
    );
  }

  /// Build the given image and fade in to load if network.
  Widget buildImage({
    required ImageProvider<Object> image,
    required BoxFit fit,
  }) {
    return FadeInImage(
      fadeInDuration: const Duration(milliseconds: 200),
      key: ValueKey(image),
      image: image,
      placeholder: MemoryImage(kTransparentImage),
      fit: fit,
    );
  }

  /// Get the footer under the carousel that returns the current image index.
  Widget buildFooterTextSpans({
    required BuildContext context,
    required AppModel appModel,
    required int itemCount,
  }) {
    double fontSize =
        (Theme.of(context).textTheme.labelMedium?.fontSize)! * 0.9;

    String imageSearchLabelBefore =
        appModel.translate('image_search_label_before');
    String imageSearchLabelMiddle =
        appModel.translate('image_search_label_middle');
    String imageSearchLabelAfter =
        appModel.translate('image_search_label_after');
    String imageSearchLabelNoneBefore =
        appModel.translate('image_search_label_none_before');
    String imageSearchLabelNoneMiddle =
        appModel.translate('image_search_label_none_middle');

    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              child: Icon(
                icon,
                size: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              padding: EdgeInsets.only(
                top: 1.25,
                right: Spacing.of(context).spaces.small,
              ),
            ),
          ),
          if (selectedIndex == -1)
            TextSpan(
              text: imageSearchLabelNoneBefore,
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          if (selectedIndex == -1)
            TextSpan(
              text: imageSearchLabelNoneMiddle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          if (selectedIndex != -1)
            TextSpan(
              text: imageSearchLabelBefore,
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          if (selectedIndex != -1)
            TextSpan(
              text: '${selectedIndex! + 1} ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          TextSpan(
            text: imageSearchLabelMiddle,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: '$itemCount ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          if (currentSearchTerm != null && currentSearchTerm!.trim().isNotEmpty)
            TextSpan(
              text: imageSearchLabelAfter,
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          if (currentSearchTerm != null && currentSearchTerm!.trim().isNotEmpty)
            TextSpan(
              text: ' ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          if (currentSearchTerm != null && currentSearchTerm!.trim().isNotEmpty)
            TextSpan(
              text: currentSearchTerm,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Get the footer under the carousel that returns the current image index.
  Widget buildFooterLoading({
    required BuildContext context,
    required AppModel appModel,
  }) {
    double fontSize =
        (Theme.of(context).textTheme.labelMedium?.fontSize)! * 0.9;

    String processingInProgress = appModel.translate('processing_in_progress');
    String searchingInProgress = appModel.translate('searching_in_progress');
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              child: Icon(
                icon,
                size: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              padding: EdgeInsets.only(
                top: 1.25,
                right: Spacing.of(context).spaces.small,
              ),
            ),
          ),
          if (currentSearchTerm != null && currentSearchTerm!.trim().isNotEmpty)
            TextSpan(
              text: searchingInProgress,
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          if (currentSearchTerm != null && currentSearchTerm!.trim().isNotEmpty)
            TextSpan(
              text: currentSearchTerm,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            )
          else
            TextSpan(
              text: processingInProgress,
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          WidgetSpan(
            child: SizedBox(
              width: 10,
              child: JumpingDotsProgressIndicator(
                color: Theme.of(context).appBarTheme.foregroundColor!,
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
