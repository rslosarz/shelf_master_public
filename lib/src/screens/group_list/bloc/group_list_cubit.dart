/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/category_repository.dart';
import 'package:shelf_master/src/repo/group_repository.dart';
import 'package:shelf_master/src/screens/group_list/bloc/group_list_state.dart';

class GroupListCubit extends Cubit<GroupListState> {
  final GroupRepository groupRepository;
  final CategoryRepository categoryRepository;
  final AnalyticsRepository analyticsRepository;

  GroupListCubit({
    required this.groupRepository,
    required this.categoryRepository,
    required this.analyticsRepository,
    GroupListState? initialState,
  }) : super(initialState ?? const GroupListState.init()) {
    if (initialState == null) {
      load(const SearchParams());
    }
  }

  void onSearchParamsChanged(SearchParams searchParams) {
    load(searchParams);
    analyticsRepository.setupGroupSearchParams(searchParams);
  }

  void load(SearchParams searchParams) async {
    emit(const GroupListState.init());
    final groups = groupRepository
        .getAllGroups()
        .where(
          (it) => _querySearch(it, searchParams) && _categorySearch(it, searchParams),
        )
        .toList()
      ..sort(searchParams.sortOrder.sortGroup());
    final categories = categoryRepository.getAllCategories();

    emit(
      GroupListState.loaded(
        groups: groups,
        searchParams: searchParams,
        existingCategories: categories,
      ),
    );
  }

  void refresh() {
    final currentState = state;
    if (currentState is GroupListLoadedState) {
      final searchParams = currentState.searchParams;
      load(searchParams);
    }
  }

  void removeGroup(Group group) {
    groupRepository.removeGroup(group);
    refresh();
    analyticsRepository.deleteGroup(group, '$runtimeType');
  }

  void removeGroups(Set<Group> groups) {
    for (final group in groups) {
      groupRepository.removeGroup(group);
    }
    refresh();
    analyticsRepository.deleteGroups();
  }

  bool _querySearch(Group group, SearchParams searchParams) {
    if (searchParams.query.isNotEmpty) {
      return group.name.contains(searchParams.query);
    }
    return true;
  }

  bool _categorySearch(Group group, SearchParams searchParams) {
    if (searchParams.query.isNotEmpty) {
      return searchParams.categories.every((category) => group.categories.contains(category));
    }
    return true;
  }
}
