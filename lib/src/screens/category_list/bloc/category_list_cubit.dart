/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/category_repository.dart';
import 'package:shelf_master/src/screens/category_list/bloc/category_list_state.dart';

class CategoryListCubit extends Cubit<CategoryListState> {
  final CategoryRepository categoryRepository;
  final AnalyticsRepository analyticsRepository;

  CategoryListCubit({
    required this.categoryRepository,
    required this.analyticsRepository,
    CategoryListState? initialState,
  }) : super(initialState ?? const CategoryListState.init()) {
    if (initialState == null) {
      load(const SearchParams());
    }
  }

  void onSearchParamsChanged(SearchParams searchParams) {
    load(searchParams);
    analyticsRepository.setupCategorySearchParams(searchParams);
  }

  void load(SearchParams searchParams) async {
    emit(const CategoryListState.init());
    final categories = categoryRepository
        .getAllCategories()
        .where(
          (it) => _querySearch(it, searchParams),
        )
        .toList()
      ..sort(searchParams.sortOrder.sortCategory());

    emit(
      CategoryListState.loaded(
        categories: categories,
        searchParams: searchParams,
      ),
    );
  }

  void refresh() {
    final currentState = state;
    if (currentState is CategoryListLoadedState) {
      final searchParams = currentState.searchParams;
      load(searchParams);
    }
  }

  void removeCategory(Category category) {
    categoryRepository.removeCategory(category);
    refresh();
    analyticsRepository.deleteCategory(category, '$runtimeType');
  }

  bool _querySearch(Category category, SearchParams searchParams) {
    if (searchParams.query.isNotEmpty) {
      return category.name.contains(searchParams.query);
    }
    return true;
  }
}
