/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/theme/app_theme.dart';
import 'package:shelf_master/src/theme/color_util.dart';

class ItemCategoryLabel extends StatelessWidget {
  final Category category;

  const ItemCategoryLabel({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorUtil.hexToColor(category.colorHex),
            ),
          ),
          const SizedBox(width: 2),
          Text(category.name, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
