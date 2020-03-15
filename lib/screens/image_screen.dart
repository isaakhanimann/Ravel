import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageScreen extends StatelessWidget {
  final String url;

  ImageScreen({@required this.url});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Center(
        child: Hero(
          tag: url,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.fill,
            placeholder: (context, url) => CupertinoActivityIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
