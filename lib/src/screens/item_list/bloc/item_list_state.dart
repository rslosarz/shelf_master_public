/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';

part 'item_list_state.freezed.dart';

@freezed
class ItemListState with _$ItemListState {
  const factory ItemListState.init() = ItemListInitState;

  const factory ItemListState.loaded({
    required List<Item> items,
    required SearchParams searchParams,
    required Set<Category> existingCategories,
  }) = ItemListLoadedState;

  const factory ItemListState.error() = ItemListerrorState;
}
