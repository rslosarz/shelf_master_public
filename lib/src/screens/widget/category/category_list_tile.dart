/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/theme/app_theme.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;
  final VoidCallback onClick;
  final Future<bool> Function() onRemoveRequest;
  final VoidCallback onRemoved;

  const CategoryListTile({
    Key? key,
    required this.category,
    required this.onClick,
    required this.onRemoveRequest,
    required this.onRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Slidable(
      key: ValueKey(category.categoryKey()),
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
          onTap: onClick.call,
          child: Ink(
            child: Card(
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
                            category.name,
                            style: theme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
