/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/screens/widget/category/item_category_label.dart';
import 'package:shelf_master/src/theme/app_theme.dart';

class GroupListTile extends StatelessWidget {
  final Group group;
  final VoidCallback onClick;
  final Future<bool> Function() onRemoveRequest;
  final VoidCallback onRemoved;
  final void Function(bool?)? onSelection;
  final VoidCallback? onLongClick;
  final bool isSelectionMode;
  final bool isSelected;

  const GroupListTile({
    Key? key,
    required this.group,
    required this.onClick,
    required this.onRemoveRequest,
    required this.onRemoved,
    this.onLongClick,
    this.onSelection,
    this.isSelectionMode = false,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(group.groupKey()),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: onRemoved,
          confirmDismiss: onRemoveRequest,
        ),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final removeConfirmed = await onRemoveRequest();
              if (removeConfirmed) {
                onRemoved();
              }
            },
            backgroundColor: AppTheme.delete,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: context.l10n.deleteCta,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onClick,
          onLongPress: onLongClick,
          child: Ink(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildSelectionVariant(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionVariant(BuildContext context) {
    if (isSelectionMode) {
      return Row(
        children: [
          Checkbox(value: isSelected, onChanged: onSelection),
          Expanded(child: _buildItemContent(context)),
        ],
      );
    } else {
      return _buildItemContent(context);
    }
  }

  Widget _buildItemContent(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: theme.titleLarge,
                  ),
                  if (group.locationDsc != null && group.locationDsc!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      group.locationDsc!,
                      style: theme.titleMedium,
                    ),
                  ],
                  const Spacer(),
                  Wrap(
                    children: group.categories
                        .map(
                          (category) => ItemCategoryLabel(category: category),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
