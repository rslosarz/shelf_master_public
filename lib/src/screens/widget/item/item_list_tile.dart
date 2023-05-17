/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/screens/widget/category/item_category_label.dart';
import 'package:shelf_master/src/screens/widget/item/item_image_widget.dart';
import 'package:shelf_master/src/theme/app_theme.dart';

class ItemListTile extends StatelessWidget {
  final Item item;
  final VoidCallback onClick;
  final Future<bool> Function() onRemoveRequest;
  final VoidCallback onRemoved;
  final void Function(bool?)? onSelection;
  final VoidCallback? onLongClick;
  final bool isSelectionMode;
  final bool isSelected;

  const ItemListTile({
    Key? key,
    required this.item,
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
      key: ValueKey(item.imageKey()),
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
            child: _buildSelectionVariant(context),
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
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Hero(
              tag: item.imageHeroCategory(),
              child: GestureDetector(
                onTap: () {
                  if (item.image != null) {
                    showImageViewer(
                      context,
                      FileImage(File(item.image!)),
                      immersive: false,
                      doubleTapZoomable: true,
                    );
                  }
                },
                child: ItemImageWidget(
                  width: 100,
                  height: 100,
                  imageUrl: item.image,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? '...',
                      style: theme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 2,
                          runSpacing: 4,
                          children: item.categories.map((category) => ItemCategoryLabel(category: category)).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
