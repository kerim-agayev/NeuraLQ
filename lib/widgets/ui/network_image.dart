import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Returns true if the URL points to an SVG image.
/// Handles query parameters: ".svg?q=80" → true
bool isSvgUrl(String url) {
  final path = Uri.tryParse(url)?.path ?? url;
  return path.toLowerCase().endsWith('.svg');
}

/// Renders a network image, automatically using SvgPicture for .svg URLs
/// and CachedNetworkImage for raster formats (JPG, PNG, WebP).
Widget networkImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  Widget Function(BuildContext, String)? placeholder,
  Widget Function(BuildContext, String, Object)? errorWidget,
}) {
  if (isSvgUrl(url)) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: placeholder != null
          ? (context) => placeholder(context, url)
          : null,
      errorBuilder: (context, error, stackTrace) {
        if (errorWidget != null) {
          return errorWidget(context, url, error);
        }
        return const SizedBox.shrink();
      },
    );
  }
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    placeholder: placeholder != null
        ? (context, url) => placeholder(context, url)
        : null,
    errorWidget: errorWidget,
  );
}
