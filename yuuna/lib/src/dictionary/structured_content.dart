import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

part 'structured_content.mapper.dart';

/// Used for handling nested content when decoding [StructuredContent].
class ContentHook extends MappingHook {
  /// Initialise this object.
  const ContentHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is String) {
      return StructuredContentTextNode(text: value);
    } else if (value is List) {
      return StructuredContentChildContent(
        children: value
            .map(StructuredContent.processContent)
            .whereType<StructuredContent>()
            .toList(),
      );
    }

    return value;
  }
}

/// Wraps around all types of possible structured content.
@MappableClass(generateMethods: GenerateMethods.decode)
sealed class StructuredContent with StructuredContentMappable {
  /// Initialise this object.
  const StructuredContent({this.content});

  @MappableField(hook: ContentHook())

  /// Nested content.
  final StructuredContent? content;

  /// Handles nested content.
  static StructuredContent? processContent(var content) {
    if (content is String) {
      return StructuredContentTextNode(text: content);
    } else if (content is List) {
      return StructuredContentChildContent(
          children: content
              .map(processContent)
              .whereType<StructuredContent>()
              .toList());
    } else if (content is Map<String, dynamic>) {
      return StructuredContentMapper.fromMap(content);
    }

    return null;
  }

  /// Convert this to a valid HTML node.
  dom.Node toNode();
}

/// Represents a text node.
@MappableClass(
  discriminatorValue: StructuredContentTextNode.checkType,
)
class StructuredContentTextNode extends StructuredContent
    with StructuredContentTextNodeMappable {
  /// Initialise this object.
  const StructuredContentTextNode({required this.text});

  /// Text for this node.
  final String text;

  @override
  dom.Node toNode() {
    return dom.Text(text);
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && value['text'] != null;
  }
}

/// An array of child content.
@MappableClass(discriminatorValue: StructuredContentChildContent.checkType)
class StructuredContentChildContent extends StructuredContent
    with StructuredContentChildContentMappable {
  /// Initialise this object.
  const StructuredContentChildContent({required this.children});

  /// Children to show.
  final List<StructuredContent> children;

  @override
  dom.Node toNode() {
    final node = dom.Element.tag('div');
    for (final child in children) {
      node.nodes.add(child.toNode());
    }

    return node;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is List;
  }
}

/// Represents a line break tag.
@MappableClass(discriminatorValue: StructuredContentLineBreak.checkType)
class StructuredContentLineBreak extends StructuredContent
    with StructuredContentLineBreakMappable {
  /// Initialise this object.
  StructuredContentLineBreak();

  @override
  dom.Node toNode() {
    return dom.Element.tag('br');
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && value['tag'] == 'br';
  }
}

/// Represents an image tag.
@MappableClass(discriminatorValue: StructuredContentImage.checkType)
class StructuredContentImage extends StructuredContent
    with StructuredContentImageMappable {
  /// Initialise this object.
  const StructuredContentImage({
    required this.path,
    this.width,
    this.height,
    this.title,
    this.alt,
    this.description,
    this.pixelated = false,
    this.imageRendering = 'auto',
    this.appearance = 'auto',
    this.background = true,
    this.collapsed = false,
    this.collapsible = true,
    this.verticalAlign,
    this.border,
    this.borderRadius,
    this.sizeUnits,
  });

  /// Path to the image file in the archive.
  final String path;

  /// Preferred width of the image.
  final double? width;

  /// Preferred height of the image.
  final double? height;

  /// Hover text for the image.
  final String? title;

  /// Alt text for the image.
  final String? alt;

  /// Description of the image.
  final String? description;

  /// Whether or not the image should appear pixelated at sizes larger than
  /// the image's native resolution.
  final bool pixelated;

  /// Controls how the image is rendered. The value of this field supersedes
  /// the pixelated field.
  final String imageRendering;

  /// Controls the appearance of the image. The "monochrome" value will mask
  /// the opaque parts of the image using the current text color.
  final String appearance;

  /// Whether or not a background color is displayed behind the image.
  final bool background;

  /// Whether or not the image is collapsed by default.
  final bool collapsed;

  /// Whether or not the image can be collapsed.
  final bool collapsible;

  /// The vertical alignment of the image.
  final String? verticalAlign;

  /// Shorthand for border width, style, and color.
  final String? border;

  /// Roundness of the corners of the image's outer border edge.
  final String? borderRadius;

  /// The units for the width and height.
  final String? sizeUnits;

  @override
  dom.Node toNode() {
    final imageNode = dom.Element.tag('img');

    final srcAttr = 'jidoujisho://$path';
    final widthAttr = (width != null) ? '$width${sizeUnits ?? ''}' : null;
    final heightAttr = (height != null) ? '$height${sizeUnits ?? ''}' : null;
    final altAttr = description;

    imageNode.attributes.addAll(
      {
        'src': srcAttr,
        if (altAttr != null) 'alt': altAttr,
        if (widthAttr != null) 'width': widthAttr,
        if (heightAttr != null) 'height': heightAttr,
      },
    );

    if (title == null) {
      return imageNode;
    } else {
      final figureNode = dom.Element.tag('figure');
      final figcaptionNode = dom.Element.tag('figcaption')
        ..append(dom.Text(title));

      figureNode
        ..append(imageNode)
        ..append(figcaptionNode);

      return figureNode;
    }
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && (value['tag'] == 'img' || value['type'] == 'image');
  }
}

/// Represents an image tag.
@MappableClass(discriminatorValue: StructuredContentLink.checkType)
class StructuredContentLink extends StructuredContent
    with StructuredContentLinkMappable {
  /// Initialise this object.
  const StructuredContentLink({
    required this.href,
    super.content,
    this.lang,
  });

  /// The URL for the link. URLs starting with a ? are treated as internal
  /// links to other dictionary content.
  final String href;

  /// Defines the language of an element in the format defined by RFC 5646.
  final String? lang;

  @override
  dom.Node toNode() {
    final linkNode = dom.Element.tag('a');

    linkNode.attributes.addAll(
      {
        'href': href,
        if (lang != null) 'lang': lang!,
      },
    );

    if (content != null) {
      linkNode.append(content!.toNode());
    }

    return linkNode;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && (value['tag'] == 'a');
  }
}

/// Generic container tags.
@MappableClass(discriminatorValue: StructuredContentContainer.checkType)
class StructuredContentContainer extends StructuredContent
    with StructuredContentContainerMappable {
  /// Initialise this object.
  const StructuredContentContainer({
    required this.tag,
    super.content,
    this.data,
    this.lang,
  });

  /// [tag] must match one of these tags.
  static List<String> validTags = [
    'ruby',
    'rt',
    'rp',
    'table',
    'thead',
    'tbody',
    'tfoot',
    'tr',
  ];

  /// Tag name. Must be any of the [validTags].
  final String tag;

  /// Additional attributes.
  final Map<String, String>? data;

  /// Defines the language of an element in the format defined by RFC 5646.
  final String? lang;

  @override
  dom.Node toNode() {
    final containerNode = dom.Element.tag(tag);

    containerNode.attributes.addAll({
      if (data != null) ...data!,
      if (lang != null) 'lang': lang!,
    });

    if (content != null) {
      containerNode.append(content!.toNode());
    }

    return containerNode;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && validTags.contains(value['tag']);
  }
}

/// Stylable generic container tags.
@MappableClass(discriminatorValue: StructuredContentStyledContainer.checkType)
class StructuredContentStyledContainer extends StructuredContent
    with StructuredContentStyledContainerMappable {
  /// Initialise this object.
  const StructuredContentStyledContainer({
    required this.tag,
    super.content,
    this.style,
    this.data,
    this.title,
    this.lang,
  });

  /// [tag] must match one of these tags.
  static List<String> validTags = [
    'span',
    'div',
    'ol',
    'ul',
    'li',
    /// FIXME: Tags found in Yomitan schema
    /// Remove once implemented
    'details',
    'summary'
  ];

  /// Tag name. Must be any of the [validTags].
  final String tag;

  /// Style for this container.
  final StructuredContentStyle? style;

  /// Additional attributes.
  final Map<String, String>? data;

  /// Hover text for the element
  final String? title;

  /// Defines the language of an element in the format defined by RFC 5646.
  final String? lang;

  @override
  dom.Node toNode() {
    final containerNode = dom.Element.tag(tag);

    containerNode.attributes.addAll({
      if (data != null) ...data!,
      if (lang != null) 'lang': lang!,
      if (style != null) 'style': style!.toInlineStyle()
    });

    if (content != null) {
      containerNode.append(content!.toNode());
    }

    return containerNode;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && validTags.contains(value['tag']);
  }
}

/// Table tags.
@MappableClass(discriminatorValue: StructuredContentTableElement.checkType)
class StructuredContentTableElement extends StructuredContent
    with StructuredContentTableElementMappable {
  /// Initialise this object.
  const StructuredContentTableElement({
    required this.tag,
    super.content,
    this.style,
    this.data,
    this.colSpan,
    this.rowSpan,
    this.lang,
  });

  /// [tag] must match one of these tags.
  static List<String> validTags = [
    'td',
    'th',
  ];

  /// Tag name. Must be any of the [validTags].
  final String tag;

  /// Style for this node.
  final StructuredContentStyle? style;

  /// Additional attributes.
  final Map<String, String>? data;

  /// Column span.
  final int? colSpan;

  /// Row span.
  final int? rowSpan;

  /// Defines the language of an element in the format defined by RFC 5646.
  final String? lang;

  @override
  dom.Node toNode() {
    final node = dom.Element.tag(tag);

    node.attributes.addAll({
      if (data != null) ...data!,
      if (lang != null) 'lang': lang!,
      if (style != null) 'style': style!.toInlineStyle(),
      if (colSpan != null) 'colspan': colSpan!.toString(),
      if (rowSpan != null) 'rowSpan': rowSpan!.toString(),
    });

    if (content != null) {
      node.append(content!.toNode());
    }

    return node;
  }

  /// Discriminator logic.
  static bool checkType(value) {
    return value is Map && validTags.contains(value['tag']);
  }
}

/// Used to resolve [StructuredContentStyle.textDecorationLine] which can be
/// a [List] or a [String].
class TextDecorationLineHooker extends MappingHook {
  /// Initialise this object.
  const TextDecorationLineHooker();

  @override
  Object? beforeDecode(Object? value) {
    if (value is String) {
      return [value];
    }

    return value;
  }
}

/// Style for a [StructuredContent].
@MappableClass()
class StructuredContentStyle with StructuredContentStyleMappable {
  /// Initialise this object.
  const StructuredContentStyle({
    this.fontStyle = 'normal',
    this.fontWeight = 'normal',
    this.fontSize = 'medium',
    // FIXME: Placeholder
    this.color = 'currentColor',
    this.background = 'transparent',
    this.backgroundColor = 'transparent',
    this.textDecorationLine = const [],
    this.textDecorationStyle = const [],
    // FIXME: Placeholder
    this.textDecorationColor = 'currentColor',
    this.borderColor = 'currentColor',
    this.borderStyle = 'none',
    this.borderRadius = '0',
    this.borderWidth = '0',
    this.clipPath = 'none',
    // FIXME: These two don't implement v3 schema
    this.verticalAlign = 'baseline',
    this.textAlign = 'start',
    // FIXME: Placeholders
    this.textEmphasis = 'none',
    this.textShadow = 'none',
    this.margin = '0',
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.padding = '0',
    this.paddingTop = '0',
    this.paddingLeft = '0',
    this.paddingRight = '0',
    this.paddingBottom = '0',
    this.wordBreak = const [],
    this.whiteSpace = 'normal',
    this.cursor = 'auto',
    this.listStyleType = 'disc',
  });

  /// Valid list types.
  static List<String> validListStyleTypes =
      ListStyleType.values.map((e) => e.counterStyle).toList();

  static List<String> validWordBreaks = [
    'normal',
    'break-all',
    'keep-all',
  ];

  /// [textDecorationStyle] must match one of these styles.
  static List<String> validTextDecorationStyles = [
    'solid',
    'double',
    'dotted',
    'dashed',
    'wavy'
  ];

  /// Equivalent to 'font-style'.
  final String fontStyle;

  /// Equivalent to 'font-weight'.
  final String fontWeight;

  /// Equivalent to 'font-size'.
  final String fontSize;

  /// Equivalent to 'color'.
  final String color;

  /// Equivalent to 'background'.
  final String background;

  /// Equivalent to 'background-color'.
  final String backgroundColor;

  /// Equivalent to 'text-decoration-line'.
  @MappableField(hook: TextDecorationLineHooker())
  final List<String> textDecorationLine;

  /// Equivalent to 'text-decoration-style'.
  /// Must be one of [validTextDecorationStyles].
  final List<String> textDecorationStyle;

  /// Equivalent to 'text-decoration-color'.
  final String textDecorationColor;

  /// Equivalent to 'border-color'.
  final String borderColor;

  /// Equivalent to 'border-style'.
  final String borderStyle;

  /// Equivalent to 'border-radius'.
  final String borderRadius;

  /// Equivalent to 'border-width'.
  final String borderWidth;

  /// Equivalent to 'clip-path'.
  final String clipPath;

  /// Equivalent to 'vertical-align'.
  final String verticalAlign;

  /// Equivalent to 'text-align'.
  final String textAlign;

  /// Equivalent to 'text-emphasis'.
  final String textEmphasis;

  /// Equivalent to 'text-shadow'.
  final String textShadow;

  /// Equivalent to 'margin'.
  final String margin;

  /// TODO: Can either be number or string
  /// Equivalent to 'margin-top'.
  final double marginTop;

  /// Equivalent to 'margin-left'.
  final double marginLeft;

  /// Equivalent to 'margin-right'.
  final double marginRight;

  /// Equivalent to 'margin-bottom'.
  final double marginBottom;

  /// Equivalent to 'padding'.
  final String padding;

  /// Equivalent to 'padding-top'.
  final String paddingTop;

  /// Equivalent to 'padding-left'.
  final String paddingLeft;

  /// Equivalent to 'padding-right'.
  final String paddingRight;

  /// Equivalent to 'padding-bottom'.
  final String paddingBottom;

  /// Equivalent to 'word-break'.
  final List<String> wordBreak;

  /// Equivalent to 'white-space'.
  final String whiteSpace;

  /// Equivalent to 'cursor'.
  final String cursor;

  /// Equivalent to 'list-style-type'.
  final String listStyleType;

  /// Convert this into a usable data map.
  String toInlineStyle() {
    final attributes = {
      'font-style': fontStyle,
      'font-weight': fontWeight,
      'font-size': fontSize,
      'color': color,
      'background': background,
      'background-color': backgroundColor,
      'text-decoration-line': textDecorationLine.join(' '),
      'text-decoration-style': textDecorationStyle,
      'text-decoration-color': textDecorationColor,
      'border-color': borderColor,
      'border-style': borderStyle,
      'border-radius': borderRadius,
      'border-width': borderWidth,
      'clip-path': clipPath,
      'vertical-align': verticalAlign,
      'text-align': textAlign,
      'text-emphasis': textEmphasis,
      'text-shadow': textShadow,
      'margin': margin,
      'margin-top': marginTop.toString(),
      'margin-left': marginLeft.toString(),
      'margin-right': marginRight.toString(),
      'margin-bottom': marginBottom.toString(),
      'padding': padding,
      'padding-top': paddingTop,
      'padding-left': paddingLeft,
      'padding-right': paddingRight,
      'padding-bottom': paddingBottom,
      'word-break': wordBreak.join(' '),
      'white-space': whiteSpace,
      'cursor': cursor,
      'list-style-type': listStyleType == 'disc' ||
              (!validListStyleTypes.contains(listStyleType))
          ? 'square'
          : listStyleType
    };

    final style = attributes.entries.map((e) => '${e.key}:${e.value};').join();
    return style;
  }
}
