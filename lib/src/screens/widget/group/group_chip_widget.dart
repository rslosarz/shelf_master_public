/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/theme/app_theme.dart';

class GroupChipWidget extends StatelessWidget {
  final Group group;
  final double height;
  final VoidCallback? onRemove;

  const GroupChipWidget({
    Key? key,
    required this.group,
    required this.height,
    this.onRemove,
  }) : super(key: key);

  factory GroupChipWidget.hint({required Group group}) {
    return GroupChipWidget(group: group, height: 30);
  }

  factory GroupChipWidget.chip({required Group group, required VoidCallback onRemove}) {
    return GroupChipWidget(
      group: group,
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
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primary, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                group.name,
                style: theme.textTheme.bodySmall,
              ),
            ),
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
