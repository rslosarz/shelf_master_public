import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreviewWidget extends StatelessWidget {
  final File imageFile;
  final VoidCallback onImageAccepted;
  final VoidCallback onImageRejected;

  const ImagePreviewWidget({
    Key? key,
    required this.imageFile,
    required this.onImageAccepted,
    required this.onImageRejected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Image.file(imageFile),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onPressed: onImageAccepted,
              ),
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: onImageRejected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
