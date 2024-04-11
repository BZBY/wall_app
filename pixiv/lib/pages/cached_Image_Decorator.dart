import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImageDecorator extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const CachedImageDecorator({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
