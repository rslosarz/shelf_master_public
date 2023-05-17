/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/group_repository.dart';
import 'package:shelf_master/src/repo/item_repository.dart';
import 'package:shelf_master/src/screens/group_detail/bloc/group_detail_state.dart';

class GroupDetailCubit extends Cubit<GroupDetailState> {
  final String? groupId;
  final ItemRepository itemRepository;
  final GroupRepository groupRepository;
  final AnalyticsRepository analyticsRepository;

  GroupDetailCubit({
    this.groupId,
    required this.itemRepository,
    required this.groupRepository,
    required this.analyticsRepository,
    GroupDetailState? initialState,
  }) : super(initialState ?? const GroupDetailState.init()) {
    if (initialState == null) {
      load();
    }
  }

  void load({
    SearchParams searchParams = const SearchParams(),
  }) {
    if (groupId != null) {
      _loadPreviewMode(searchParams: searchParams);
    } else {
      _loadNewItemMode(searchParams: searchParams);
    }
  }

  void refresh() {
    final currentState = state;
    if (currentState is GroupDetailLoadedState) {
      final searchParams = currentState.searchParams;
      load(searchParams: searchParams);
    }
  }

  void _loadPreviewMode({
    required SearchParams searchParams,
  }) {
    emit(const GroupDetailState.init());
    final group = groupRepository.getGroup(groupId!);
    if (group != null) {
      final queriedItems = group.items
          .where((item) => _querySearch(item, searchParams) && _categorySearch(item, searchParams))
          .toList()
        ..sort(searchParams.sortOrder.sortItem());
      final categories = group.items.map((group) => group.categories).flattened.toSet();
      emit(
        GroupDetailState.loaded(
          originalGroup: group,
          currentGroup: group,
          queriedItems: queriedItems,
          searchParams: searchParams,
          existingCategories: categories,
        ),
      );
    } else {
      emit(const GroupDetailState.notFound());
    }
  }

  void _loadNewItemMode({
    required SearchParams searchParams,
  }) {
    final newGroup = Group.newEntity(name: '');
    emit(
      GroupDetailState.loaded(
        currentGroup: newGroup,
        originalGroup: newGroup,
        queriedItems: [],
        searchParams: searchParams,
        existingCategories: {},
      ),
    );
  }

  bool _querySearch(Item item, SearchParams searchParams) {
    if (searchParams.query.isNotEmpty && item.name != null) {
      return item.name!.contains(searchParams.query);
    }
    return true;
  }

  bool _categorySearch(Item item, SearchParams searchParams) {
    if (searchParams.categories.isNotEmpty) {
      return searchParams.categories.every((category) => item.categories.contains(category));
    }
    return true;
  }

  void onNameChanged(String name) {
    final currentState = state;
    if (currentState is GroupDetailLoadedState) {
      emit(
        currentState.copyWith(currentGroup: currentState.currentGroup.copyWith(name: name)),
      );
    }
  }

  void onLocationChanged(String location) {
    final currentState = state;
    if (currentState is GroupDetailLoadedState) {
      emit(
        currentState.copyWith(currentGroup: currentState.currentGroup.copyWith(locationDsc: location)),
      );
    }
  }

  void onSaveChanges() async {
    final currentState = state;
    if (currentState is GroupDetailLoadedState) {
      final currentGroup = currentState.currentGroup;
      if (groupId == null) {
        _addGroup(currentGroup);
        analyticsRepository.createGroup(currentGroup);
      } else {
        _editGroup(currentGroup);
        analyticsRepository.editGroup(currentGroup);
      }
    }
  }

  void _addGroup(Group group) {
    groupRepository.addGroup(group);
    emit(const GroupDetailState.addSuccess());
  }

  void _editGroup(Group group) {
    final oldGroup = groupRepository.getGroup(group.id);
    if (oldGroup != group) {
      groupRepository.editGroup(group);
      load();
    }
  }

  void removeItem(Item item) {
    itemRepository.removeItem(item);
    refresh();
    analyticsRepository.deleteItem(item, '$runtimeType');
  }
}
