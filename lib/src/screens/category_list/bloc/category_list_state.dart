/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/search_params.dart';

part 'category_list_state.freezed.dart';

@freezed
class CategoryListState with _$CategoryListState {
  const factory CategoryListState.init() = CategoryListInitState;

  const factory CategoryListState.loaded({
    required List<Category> categories,
    required SearchParams searchParams,
  }) = CategoryListLoadedState;

  const factory CategoryListState.error() = CategoryListerrorState;
}
