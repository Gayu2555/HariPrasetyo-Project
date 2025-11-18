import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ReusableNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;

  // ✅ Hapus height & width dari constructor
  const ReusableNetworkImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
        child: CircularProgressIndicator(
          value: downloadProgress.progress,
          color: Theme.of(context).primaryColor,
        ),
      ),
      errorWidget: (context, url, error) =>
          const Icon(UniconsLine.exclamation_circle, color: Colors.red),
    );
  }
}
