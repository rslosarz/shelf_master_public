/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/search_params.dart';

part 'group_list_state.freezed.dart';

@freezed
class GroupListState with _$GroupListState {
  const factory GroupListState.init() = GroupListInitState;

  const factory GroupListState.loaded({
    required List<Group> groups,
    required SearchParams searchParams,
    required Set<Category> existingCategories,
  }) = GroupListLoadedState;

  const factory GroupListState.error() = GroupListErrorState;
}
