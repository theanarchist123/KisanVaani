import 'package:flutter/material.dart';

class LayoutHelpers {
  /// Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return const EdgeInsets.all(8.0);  // Mobile
    } else if (screenWidth < 1024) {
      return const EdgeInsets.all(16.0); // Tablet
    } else {
      return const EdgeInsets.all(24.0); // Desktop
    }
  }

  /// Get cross axis count for grid based on screen size
  static int getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2; // Mobile
    } else if (screenWidth < 1024) {
      return 3; // Tablet
    } else {
      return 4; // Desktop
    }
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSize * 0.9; // Smaller on mobile
    } else if (screenWidth < 1024) {
      return baseSize; // Base size on tablet
    } else {
      return baseSize * 1.1; // Larger on desktop
    }
  }

  /// Creates a Text widget with safe overflow handling
  static Widget safeText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines ?? 2,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }

  /// Creates a Column with safe overflow handling and spacing
  static Widget safeColumn({
    required List<Widget> children,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisAlignment? mainAxisAlignment,
    MainAxisSize? mainAxisSize,
    double? spacing,
  }) {
    List<Widget> spacedChildren = children;
    if (spacing != null && spacing > 0) {
      spacedChildren = [];
      for (int i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i < children.length - 1) {
          spacedChildren.add(SizedBox(height: spacing));
        }
      }
    }
    
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      mainAxisSize: mainAxisSize ?? MainAxisSize.min,
      children: spacedChildren,
    );
  }

  /// Creates a Row with responsive behavior
  static Widget responsiveRow({
    required List<Widget> children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisSize? mainAxisSize,
    bool wrapOnSmallScreen = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (wrapOnSmallScreen && constraints.maxWidth < 600) {
          // Convert Expanded widgets to regular widgets for Wrap
          final wrappedChildren = children.map((child) {
            if (child is Expanded) {
              return Flexible(child: child.child);
            }
            return child;
          }).toList();
          
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: wrappedChildren,
          );
        }
        return Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
          mainAxisSize: mainAxisSize ?? MainAxisSize.max,
          children: children,
        );
      },
    );
  }

  /// Creates a Card with responsive width and padding
  static Widget responsiveCard({
    required Widget child,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    bool borderOnForeground = true,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Clip? clipBehavior,
    bool semanticContainer = true,
    double? maxWidth,
  }) {
    Widget cardChild = child;
    if (padding != null) {
      cardChild = Padding(padding: padding, child: child);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = maxWidth ?? constraints.maxWidth;
        return SizedBox(
          width: cardWidth > constraints.maxWidth ? constraints.maxWidth : cardWidth,
          child: Card(
            color: color,
            elevation: elevation,
            shape: shape,
            borderOnForeground: borderOnForeground,
            margin: margin,
            clipBehavior: clipBehavior,
            semanticContainer: semanticContainer,
            child: cardChild,
          ),
        );
      },
    );
  }

  /// Creates a responsive grid delegate
  static SliverGridDelegate responsiveGridDelegate(BuildContext context, {
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) {
    final crossAxisCount = getCrossAxisCount(context);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio ?? 1.0,
      crossAxisSpacing: crossAxisSpacing ?? 8.0,
      mainAxisSpacing: mainAxisSpacing ?? 8.0,
    );
  }

  /// Creates a Grid with responsive behavior
  static Widget responsiveGrid({
    required List<Widget> children,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    ScrollPhysics? physics,
    bool shrinkWrap = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: getCrossAxisCount(context),
          childAspectRatio: childAspectRatio ?? 1.0,
          crossAxisSpacing: crossAxisSpacing ?? 8.0,
          mainAxisSpacing: mainAxisSpacing ?? 8.0,
          physics: physics,
          shrinkWrap: shrinkWrap,
          children: children,
        );
      },
    );
  }

  /// Creates a Wrap with safe spacing
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
    Clip clipBehavior = Clip.none,
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
      clipBehavior: clipBehavior,
      children: children,
    );
  }

  /// Safe container with responsive constraints
  static Widget safeContainer({
    required Widget child,
    double? maxWidth,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Decoration? decoration,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: maxWidth != null 
            ? (maxWidth > constraints.maxWidth ? constraints.maxWidth : maxWidth)
            : null,
          height: maxHeight != null 
            ? (maxHeight > constraints.maxHeight ? constraints.maxHeight : maxHeight)
            : null,
          padding: padding,
          margin: margin,
          color: color,
          decoration: decoration,
          child: child,
        );
      },
    );
  }

  /// Create responsive container (alias for safeContainer)
  static Widget responsiveContainer({
    required Widget child,
    double? maxWidth,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Decoration? decoration,
  }) {
    return safeContainer(
      child: child,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
    );
  }
}
