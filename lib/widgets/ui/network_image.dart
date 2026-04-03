import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  if (url.toLowerCase().endsWith('.svg')) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: placeholder != null
          ? (context) => placeholder(context, url)
          : null,
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

/// Returns true if the URL points to an SVG image.
bool isSvgUrl(String url) => url.toLowerCase().endsWith('.svg');
