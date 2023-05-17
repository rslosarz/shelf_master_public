/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/category_repository.dart';
import 'package:shelf_master/src/repo/item_repository.dart';
import 'package:shelf_master/src/screens/item_list/bloc/item_list_state.dart';

class ItemListCubit extends Cubit<ItemListState> {
  final ItemRepository itemRepository;
  final CategoryRepository categoryRepository;
  final AnalyticsRepository analyticsRepository;

  ItemListCubit({
    required this.itemRepository,
    required this.categoryRepository,
    required this.analyticsRepository,
    ItemListState? initialState,
  }) : super(initialState ?? const ItemListState.init()) {
    if (initialState == null) {
      load(const SearchParams());
    }
  }

  void onSearchParamsChanged(SearchParams searchParams) {
    load(searchParams);
    analyticsRepository.setupItemSearchParams(searchParams);
  }

  void load(SearchParams searchParams) async {
    emit(const ItemListState.init());
    final items = itemRepository
        .getAllItems()
        .where((it) => _querySearch(it, searchParams) && _categorySearch(it, searchParams))
        .toList()
      ..sort(searchParams.sortOrder.sortItem());
    final categories = categoryRepository.getAllCategories();

    emit(
      ItemListState.loaded(
        items: items,
        searchParams: searchParams,
        existingCategories: categories,
      ),
    );
  }

  void refresh() {
    final currentState = state;
    if (currentState is ItemListLoadedState) {
      final searchParams = currentState.searchParams;
      load(searchParams);
    }
  }

  void removeItem(Item item) {
    itemRepository.removeItem(item);
    refresh();
    analyticsRepository.deleteItem(item, '$runtimeType');
  }

  void removeItems(Set<Item> items) {
    for (final item in items) {
      itemRepository.removeItem(item);
    }
    refresh();
    analyticsRepository.deleteItems();
  }

  bool _querySearch(Item item, SearchParams searchParams) {
    if (searchParams.query.isNotEmpty && item.name != null) {
      return item.name!.contains(searchParams.query);
    }
    return true;
  }

  bool _categorySearch(Item item, SearchParams searchParams) {
    if (searchParams.categories.isNotEmpty) {
      return searchParams.categories.every((category) => item.categories.contains(category));
    }
    return true;
  }
}
