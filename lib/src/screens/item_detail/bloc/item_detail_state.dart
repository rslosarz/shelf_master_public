/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';

part 'item_detail_state.freezed.dart';

@freezed
class ItemDetailState with _$ItemDetailState {
  const factory ItemDetailState.init() = ItemDetailInitState;

  const factory ItemDetailState.loaded({
    required Item originalItem,
    required Item currentItem,
    required List<Group> originalGroups,
    required List<Group> selectedGroups,
    required List<Group> availableGroups,
    required Set<Category> availableCategories,
  }) = ItemDetailLoadedState;

  const factory ItemDetailState.addSuccess() = ItemDetailAddSuccessState;

  const factory ItemDetailState.noItem() = ItemDetailNoItemState;
}
