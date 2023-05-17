/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/theme/app_theme.dart';
import 'package:shelf_master/src/theme/color_util.dart';

class CategoryChipWidget extends StatelessWidget {
  final Category category;
  final double height;
  final VoidCallback? onRemove;

  const CategoryChipWidget({
    Key? key,
    required this.category,
    required this.height,
    this.onRemove,
  }) : super(key: key);

  factory CategoryChipWidget.hint({required Category category}) {
    return CategoryChipWidget(category: category, height: 30);
  }

  factory CategoryChipWidget.chip({required Category category, required VoidCallback onRemove}) {
    return CategoryChipWidget(
      category: category,
      height: 46,
      onRemove: onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primary, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Container(
              width: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorUtil.hexToColor(category.colorHex),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (onRemove != null)
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: onRemove,
                icon: const Icon(Icons.clear),
              ),
          ],
        ),
      ),
    );
  }
}
