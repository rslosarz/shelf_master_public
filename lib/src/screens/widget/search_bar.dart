/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/screens/keys.dart';
import 'package:shelf_master/src/screens/widget/search_params_dialog.dart';
import 'package:shelf_master/src/theme/debouncer.dart';

class SearchBar extends StatefulWidget {
  final SearchParams initialSearchParams;
  final Set<Category>? availableCategories;
  final void Function(SearchParams) onSearchParamsChanged;

  const SearchBar({
    Key? key,
    this.initialSearchParams = const SearchParams(),
    this.availableCategories,
    required this.onSearchParamsChanged,
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late SearchParams currentSearchParams;
  final queryController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    currentSearchParams = widget.initialSearchParams;
    queryController.text = currentSearchParams.query;
    queryController.addListener(() {
      _debouncer.run(() {
        _onQueryChanged(queryController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextField(
                controller: queryController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  hintText: context.l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _searchParamsButton(),
          ],
        ),
      ),
    );
  }

  Widget _searchParamsButton() {
    return ElevatedButton(
      key: Keys.searchParamsKey,
      onPressed: _showSearchParamsDialog,
      child: const Center(
        child: Icon(Icons.filter_alt_sharp),
      ),
    );
  }

  void _showSearchParamsDialog() async {
    final updatedParams = await showDialog<SearchParams?>(
      context: context,
      builder: (context) => SearchParamsDialog(
        initialSearchParams: currentSearchParams,
        availableCategories: widget.availableCategories,
      ),
    );

    if (updatedParams != null) {
      _onSearchParamsChanged(updatedParams);
    }
  }

  void _onQueryChanged(String? value) {
    _onSearchParamsChanged(currentSearchParams.copyWith(query: value ?? ''));
  }

  void _onSearchParamsChanged(SearchParams newSearchParams) {
    currentSearchParams = newSearchParams;
    widget.onSearchParamsChanged(newSearchParams);
  }
}
