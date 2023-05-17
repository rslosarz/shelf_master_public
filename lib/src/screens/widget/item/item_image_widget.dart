/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:io';

import 'package:flutter/material.dart';

class ItemImageWidget extends StatelessWidget {
  final double width;
  final double height;
  final String? imageUrl;
  final VoidCallback? onEditClick;

  const ItemImageWidget({
    Key? key,
    required this.width,
    required this.height,
    this.imageUrl,
    this.onEditClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onEditClick != null) {
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: _getImage(context),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                iconSize: 24,
                icon: const Icon(Icons.edit),
                onPressed: onEditClick,
              ),
            )
          ],
        ),
      );
    }

    return _getImage(context);
  }

  Widget _getImage(BuildContext context) {
    final theme = Theme.of(context);
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: width,
          height: height,
          color: theme.dialogBackgroundColor.withOpacity(1),
          child: Image.file(
            File(imageUrl!),
          ),
        ),
      );
    } else {
      return Container(
        width: width,
        height: height,
        color: theme.dialogBackgroundColor.withOpacity(1),
        child: const Center(
          child: Icon(Icons.camera_alt),
        ),
      );
    }
  }
}
