/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/sort_order.dart';

part 'search_params.freezed.dart';

@freezed
class SearchParams with _$SearchParams {
  const factory SearchParams({
    @Default('') String query,
    @Default({}) Set<Category> categories,
    @Default(SortOrder.nameDesc) SortOrder sortOrder,
  }) = _SearchParams;

  const SearchParams._();
}
