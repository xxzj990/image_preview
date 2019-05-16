import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

typedef OnLongPressHandler(String ingUrl);

class ImageView extends StatefulWidget {
  const ImageView({
    Key key,
    @required this.url,
    this.heroTag,
    this.scaleStateChangedCallback,
    this.onLongPressHandler,
  }) : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();

  final String url;

  final String heroTag;

  final PhotoViewScaleStateChangedCallback scaleStateChangedCallback;

  final OnLongPressHandler onLongPressHandler;
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return widget.url.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: widget.url,
            placeholder: (context, str) => ImageLoading(),
            errorWidget: (context, str, e) {
              return ImageError(
                msg: '$str \n $e',
              );
            },
            imageBuilder: (context, provider) {
              return _buildImageWidget(provider);
            },
          )
        : _buildImageWidget(FileImage(File.fromUri(Uri.file(widget.url))));
  }

  Widget _buildImageWidget(ImageProvider imageProvide) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      onLongPress: () {
        if (widget.onLongPressHandler != null)
          widget.onLongPressHandler(widget.url);
      },
      child: PhotoView(
        imageProvider: imageProvide,
        heroTag: widget.heroTag,
        loadingChild: ImageLoading(),
        scaleStateChangedCallback: widget.scaleStateChangedCallback,
        minScale: PhotoViewComputedScale.contained * 1.0,
        maxScale: PhotoViewComputedScale.covered * 3.0,
      ),
    );
  }
}

class ImageLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
      ),
    ));
  }
}

class ImageError extends StatelessWidget {
  final String msg;

  const ImageError({Key key, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.broken_image,
          color: Colors.red,
          size: 30,
        ),
        SizedBox(height: 10),
        Text(
          '图片加载失败',
          style: TextStyle(color: Colors.red),
        ),
        SizedBox(height: 15),
        Container(
          width: MediaQuery.of(context).size.width - 100,
          child: Text(
            msg ?? '',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ));
  }
}
