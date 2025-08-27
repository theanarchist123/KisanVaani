import 'package:flutter/material.dart';

/// A collection of layout helper utilities to prevent overflow issues
class LayoutHelpers {
  /// Wraps a widget with safe constraints to prevent overflow
  static Widget safeContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: padding,
          margin: margin,
          decoration: decoration,
          width: width != null ? width.clamp(0.0, constraints.maxWidth) : null,
          height: height != null ? height.clamp(0.0, constraints.maxHeight) : null,
          alignment: alignment,
          child: child,
        );
      },
    );
  }

  /// Creates a responsive Row that wraps to avoid overflow
  static Widget responsiveRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If screen is narrow, use Column instead of Row
        if (constraints.maxWidth < 400) {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            textDirection: textDirection,
            verticalDirection: verticalDirection,
            textBaseline: textBaseline,
            children: children,
          );
        }
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children.map((child) => Flexible(child: child)).toList(),
        );
      },
    );
  }

  /// Creates a Text widget with safe overflow handling
  static Widget safeText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign? textAlign,
    TextDirection? textDirection,
    double? textScaleFactor,
    bool softWrap = true,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      softWrap: softWrap,
    );
  }

  /// Creates a Container with responsive width
  static Widget responsiveContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
    double? minWidth,
    double? maxWidth,
    double? height,
    AlignmentGeometry? alignment,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = constraints.maxWidth;
        
        if (minWidth != null && containerWidth < minWidth) {
          containerWidth = minWidth;
        }
        if (maxWidth != null && containerWidth > maxWidth) {
          containerWidth = maxWidth;
        }

        return Container(
          width: containerWidth,
          height: height,
          padding: padding,
          margin: margin,
          decoration: decoration,
          alignment: alignment,
          child: child,
        );
      },
    );
  }

  /// Creates a ListView with proper overflow handling
  static Widget safeListView({
    required List<Widget> children,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: padding,
      children: children,
    );
  }

  /// Creates a Column with safe overflow handling
  static Widget safeColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    bool scrollable = false,
  }) {
    if (scrollable) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children,
        ),
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }

  /// Creates a Card with responsive width
  static Widget responsiveCard({
    required Widget child,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    bool borderOnForeground = true,
    EdgeInsetsGeometry? margin,
    Clip? clipBehavior,
    bool semanticContainer = true,
    double? maxWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth;
        if (maxWidth != null && cardWidth > maxWidth) {
          cardWidth = maxWidth;
        }

        return SizedBox(
          width: cardWidth,
          child: Card(
            color: color,
            elevation: elevation,
            shape: shape,
            borderOnForeground: borderOnForeground,
            margin: margin,
            clipBehavior: clipBehavior,
            semanticContainer: semanticContainer,
            child: child,
          ),
        );
      },
    );
  }

  /// Creates a responsive grid
  static Widget responsiveGrid({
    required List<Widget> children,
    int? crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = crossAxisCount ?? 
          (constraints.maxWidth > 600 ? 3 : 
           constraints.maxWidth > 400 ? 2 : 1);

        return GridView.builder(
          padding: padding,
          physics: physics ?? const NeverScrollableScrollPhysics(),
          shrinkWrap: shrinkWrap,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  /// Creates a Wrap widget for overflow-safe layouts
  static Widget safeWrap({
    required List<Widget> children,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
  }) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      children: children,
    );
  }

  /// Calculates responsive font size based on screen width
  static double responsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375.0; // Base width (iPhone SE)
    return (baseSize * scaleFactor).clamp(baseSize * 0.8, baseSize * 1.3);
  }

  /// Gets responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context, {
    double base = 16.0,
    double? horizontal,
    double? vertical,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = screenWidth > 600 ? 1.2 : 
                   screenWidth > 400 ? 1.0 : 0.8;
    
    return EdgeInsets.symmetric(
      horizontal: (horizontal ?? base) * factor,
      vertical: (vertical ?? base) * factor,
    );
  }
}

/// Extension on Widget for easy overflow prevention
extension LayoutExtensions on Widget {
  /// Wraps the widget with Expanded to prevent overflow in Flex layouts
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Wraps the widget with Flexible to allow it to shrink in Flex layouts
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) => 
    Flexible(flex: flex, fit: fit, child: this);

  /// Wraps the widget with SingleChildScrollView for vertical scrolling
  Widget scrollable({
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
  }) => SingleChildScrollView(
    physics: physics ?? const BouncingScrollPhysics(),
    padding: padding,
    child: this,
  );

  /// Wraps the widget with SafeArea
  Widget safeArea({
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
  }) => SafeArea(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    child: this,
  );

  /// Adds responsive margins
  Widget responsiveMargin(BuildContext context, {
    double base = 8.0,
    double? horizontal,
    double? vertical,
  }) {
    final padding = LayoutHelpers.responsivePadding(
      context,
      base: base,
      horizontal: horizontal,
      vertical: vertical,
    );
    return Container(
      margin: padding,
      child: this,
    );
  }

  /// Adds responsive padding
  Widget responsivePadding(BuildContext context, {
    double base = 16.0,
    double? horizontal,
    double? vertical,
  }) {
    final padding = LayoutHelpers.responsivePadding(
      context,
      base: base,
      horizontal: horizontal,
      vertical: vertical,
    );
    return Padding(
      padding: padding,
      child: this,
    );
  }
}
