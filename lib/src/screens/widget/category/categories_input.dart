/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/screens/widget/category/category_chip_widget.dart';

class CategoriesInput extends StatefulWidget {
  final void Function(Set<Category>) onCategoriesChanged;
  final Set<Category> availableCategories;
  final Set<Category> assignedCategories;
  final bool showLabel;
  final bool canCreateCategories;

  const CategoriesInput({
    Key? key,
    required this.onCategoriesChanged,
    required this.availableCategories,
    required this.assignedCategories,
    this.showLabel = true,
    this.canCreateCategories = true,
  }) : super(key: key);

  @override
  State<CategoriesInput> createState() => _CategoriesInputState();
}

class _CategoriesInputState extends State<CategoriesInput> {
  late Set<Category> selectedCategories = Set.from(widget.assignedCategories);
  TextEditingController? textEditingController;

  @override
  void didUpdateWidget(CategoriesInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedCategories = Set.from(widget.assignedCategories);
  }

  void _removeCategory(Category category) {
    setState(() {
      selectedCategories.remove(category);
    });
    widget.onCategoriesChanged(selectedCategories);
  }

  void _addCategory(Category selectedCategory) {
    setState(() {
      selectedCategories.add(selectedCategory);
    });
    widget.onCategoriesChanged(selectedCategories);
    textEditingController?.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(context.l10n.assignedCategoriesLabel),
          Autocomplete<Category>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<Category>.empty();
              }
              return widget.availableCategories.where(
                (category) => category.name.isNotEmpty && category.name.contains(textEditingValue.text.toLowerCase()),
              );
            },
            optionsViewBuilder: _optionsViewBuilder,
            displayStringForOption: (category) => category.name,
            onSelected: _addCategory,
            fieldViewBuilder: _widgetLayout,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: selectedCategories
                  .map(
                    (category) => CategoryChipWidget.chip(
                      category: category,
                      onRemove: () => _removeCategory(category),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetLayout(BuildContext context, TextEditingController ttec, FocusNode tfn, VoidCallback onFieldSubmitted) {
    textEditingController = ttec;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _inputField(ttec, tfn, onFieldSubmitted),
      ],
    );
  }

  Widget _inputField(TextEditingController ttec, FocusNode tfn, VoidCallback onFieldSubmitted) {
    return TextField(
      controller: ttec,
      focusNode: tfn,
      decoration: InputDecoration(
        helperText: context.l10n.enterCategoryHint,
        hintText: selectedCategories.isNotEmpty ? '' : context.l10n.enterCategoryHint,
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          final pickedCategory = widget.availableCategories.where((e) => e.name == value).firstOrNull;
          onFieldSubmitted();
          if (pickedCategory != null) {
            _addCategory(pickedCategory);
          } else if (widget.canCreateCategories) {
            _addCategory(Category.newEntity(name: value));
          }
        }
      },
    );
  }

  Widget _optionsViewBuilder(
      BuildContext context, AutocompleteOnSelected<Category> onSelected, Iterable<Category> options) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.0)),
        ),
        child: SizedBox(
          height: 82.0 * options.length,
          width: size.width * 0.4,
          child: Card(
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                shrinkWrap: false,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CategoryChipWidget.hint(category: option),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
