/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';

part 'group_detail_state.freezed.dart';

@freezed
class GroupDetailState with _$GroupDetailState {
  const factory GroupDetailState.init() = GroupDetailInitState;

  const factory GroupDetailState.loaded({
    required Group originalGroup,
    required Group currentGroup,
    required List<Item> queriedItems,
    required SearchParams searchParams,
    required Set<Category> existingCategories,
  }) = GroupDetailLoadedState;

  const factory GroupDetailState.addSuccess() = GroupDetailAddSuccessState;

  const factory GroupDetailState.notFound() = GroupDetailNotFoundState;
}
