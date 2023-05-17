/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';

part 'category_detail_state.freezed.dart';

@freezed
class CategoryDetailState with _$CategoryDetailState {
  const factory CategoryDetailState.init() = CategoryDetailInitState;

  const factory CategoryDetailState.loaded({
    required Category category,
    required String originalName,
    required List<Item> queriedItems,
    required SearchParams searchParams,
  }) = CategoryDetailLoadedState;

  const factory CategoryDetailState.addSuccess() = CategoryDetailAddSuccessState;

  const factory CategoryDetailState.notFound() = CategoryDetailNotFoundState;
}
