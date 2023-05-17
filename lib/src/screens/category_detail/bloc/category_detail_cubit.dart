/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/category_repository.dart';
import 'package:shelf_master/src/repo/item_repository.dart';
import 'package:shelf_master/src/screens/category_detail/bloc/category_detail_state.dart';

class CategoryDetailCubit extends Cubit<CategoryDetailState> {
  final String? categoryId;
  final ItemRepository itemRepository;
  final CategoryRepository categoryRepository;
  final AnalyticsRepository analyticsRepository;

  CategoryDetailCubit({
    this.categoryId,
    required this.itemRepository,
    required this.categoryRepository,
    required this.analyticsRepository,
    CategoryDetailState? initialState,
  }) : super(initialState ?? const CategoryDetailState.init()) {
    if (initialState == null) {
      load();
    }
  }

  void load({
    SearchParams searchParams = const SearchParams(),
  }) {
    if (categoryId != null) {
      _loadPreviewMode(searchParams: searchParams);
    } else {
      _loadNewItemMode(searchParams: searchParams);
    }
  }

  void refresh() {
    final currentState = state;
    if (currentState is CategoryDetailLoadedState) {
      final searchParams = currentState.searchParams;
      load(searchParams: searchParams);
    }
  }

  void _loadPreviewMode({
    required SearchParams searchParams,
  }) {
    emit(const CategoryDetailState.init());
    final category = categoryRepository.getCategory(categoryId!);
    if (category != null) {
      final queriedItems = itemRepository
          .getAllItemsWithCategory(categoryId!)
          .where((item) => _querySearch(item, searchParams))
          .toList()
        ..sort(searchParams.sortOrder.sortItem());
      emit(
        CategoryDetailState.loaded(
          category: category,
          originalName: category.name,
          queriedItems: queriedItems,
          searchParams: searchParams,
        ),
      );
    } else {
      emit(const CategoryDetailState.notFound());
    }
  }

  void _loadNewItemMode({
    required SearchParams searchParams,
  }) {
    emit(
      CategoryDetailState.loaded(
        category: Category.newEntity(name: ''),
        originalName: '',
        queriedItems: [],
        searchParams: searchParams,
      ),
    );
  }

  void onNameChanged(String name) {
    final currentState = state;
    if (currentState is CategoryDetailLoadedState) {
      emit(
        currentState.copyWith(category: currentState.category.copyWith(name: name)),
      );
    }
  }

  void onSaveChanges() async {
    final currentState = state;
    if (currentState is CategoryDetailLoadedState) {
      final currentCategory = currentState.category;
      if (categoryId == null) {
        _addCategory(currentCategory);
        analyticsRepository.createCategory(currentCategory);
      } else {
        _editCategory(currentCategory);
        analyticsRepository.editCategory(currentCategory);
      }
    }
  }

  bool _querySearch(Item item, SearchParams searchParams) {
    if (searchParams.query.isNotEmpty && item.name != null) {
      return item.name!.contains(searchParams.query);
    }
    return true;
  }

  void _addCategory(Category category) {
    categoryRepository.addCategory(category);
    emit(const CategoryDetailState.addSuccess());
  }

  void _editCategory(Category category) {
    final oldCategory = categoryRepository.getCategory(category.id);
    if (oldCategory != category) {
      categoryRepository.editCategory(category);
      load();
    }
  }

  void removeItem(Item item) {
    itemRepository.removeItem(item);
    refresh();
    analyticsRepository.deleteItem(item, '$runtimeType');
  }
}
