/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/screens/widget/category/categories_input.dart';
import 'package:shelf_master/src/theme/app_theme.dart';

class SearchParamsDialog extends StatefulWidget {
  final SearchParams initialSearchParams;
  final Set<Category>? availableCategories;

  const SearchParamsDialog({
    Key? key,
    required this.initialSearchParams,
    this.availableCategories,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchParamsDialogState();
  }
}

class SearchParamsDialogState extends State<SearchParamsDialog> {
  late SearchParams currentSearchParams = widget.initialSearchParams;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final categories = widget.availableCategories;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      content: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 400, maxHeight: size.height * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(context.l10n.searchParamSortOrderLabel),
            ...SortOrder.values.map(_sortOrderTile).toList(),
            const SizedBox(height: 20),
            if (categories != null) ...[
              Text(context.l10n.searchParamCategoryLabel),
              Expanded(
                child: SizedBox(
                  width: size.width * 0.8,
                  child: CategoriesInput(
                    showLabel: false,
                    canCreateCategories: false,
                    onCategoriesChanged: _onCategoriesChanged,
                    availableCategories: categories,
                    assignedCategories: currentSearchParams.categories,
                  ),
                ),
              ),
            ],
            ElevatedButton(
              onPressed: _onSearchParamsConfirmed,
              child: Center(
                child: Text(context.l10n.saveChangesCta),
              ),
            )
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    );
  }

  Widget _sortOrderTile(SortOrder sortOrder) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primary, width: 1),
        ),
        child: Row(
          children: [
            Radio<SortOrder>(
              value: sortOrder,
              groupValue: currentSearchParams.sortOrder,
              onChanged: (pickedSortOrder) {
                setState(() {
                  currentSearchParams = currentSearchParams.copyWith(sortOrder: pickedSortOrder ?? SortOrder.nameDesc);
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              sortOrder.getSortOrderLabel(context),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  void _onCategoriesChanged(Set<Category> categories) {
    currentSearchParams = currentSearchParams.copyWith(categories: categories);
  }

  void _onSearchParamsConfirmed() {
    context.pop(currentSearchParams);
  }
}
