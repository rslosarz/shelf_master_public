/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/category_repository.dart';
import 'package:shelf_master/src/repo/group_repository.dart';
import 'package:shelf_master/src/repo/internal_storage_repository.dart';
import 'package:shelf_master/src/repo/item_repository.dart';
import 'package:shelf_master/src/screens/item_detail/bloc/item_detail_state.dart';

class ItemDetailCubit extends Cubit<ItemDetailState> {
  final String? itemId;
  final String? requestedGroupId;
  final String? requestedCategoryId;
  final ItemRepository itemRepository;
  final GroupRepository groupRepository;
  final CategoryRepository categoryRepository;
  final InternalStorageRepository internalStorageRepository;
  final AnalyticsRepository analyticsRepository;

  ItemDetailCubit({
    this.itemId,
    this.requestedGroupId,
    this.requestedCategoryId,
    required this.itemRepository,
    required this.groupRepository,
    required this.categoryRepository,
    required this.internalStorageRepository,
    required this.analyticsRepository,
    ItemDetailState? initialState,
  }) : super(initialState ?? const ItemDetailState.init()) {
    if (initialState == null) {
      load();
    }
  }

  void load() async {
    if (itemId != null) {
      _loadPreviewMode();
    } else {
      _loadNewItemMode();
    }
  }

  void _loadPreviewMode() {
    final item = itemRepository.getItem(itemId!);
    final selectedGroups = groupRepository.getItemGroups(itemId!);
    if (item != null) {
      final availableCategories = categoryRepository.getAllCategories();
      final availableGroups = groupRepository.getAllGroups();
      emit(
        ItemDetailState.loaded(
          originalItem: item,
          currentItem: item,
          originalGroups: selectedGroups,
          selectedGroups: selectedGroups,
          availableGroups: availableGroups,
          availableCategories: availableCategories,
        ),
      );
    } else {
      emit(const ItemDetailState.noItem());
    }
  }

  void _loadNewItemMode() {
    final availableCategories = categoryRepository.getAllCategories();
    final availableGroups = groupRepository.getAllGroups();
    final requestedGroup = requestedGroupId != null ? groupRepository.getGroup(requestedGroupId!) : null;
    final requestedCategory = requestedCategoryId != null ? categoryRepository.getCategory(requestedCategoryId!) : null;
    final newItem = Item.newEntity();
    final currentItem = requestedCategory != null ? newItem.copyWith(categories: {requestedCategory}) : newItem;
    final selectedGroups = [if (requestedGroup != null) requestedGroup];
    emit(
      ItemDetailState.loaded(
        originalItem: newItem,
        currentItem: currentItem,
        originalGroups: selectedGroups,
        selectedGroups: selectedGroups,
        availableGroups: availableGroups,
        availableCategories: availableCategories,
      ),
    );
  }

  void onNameChanged(String name) {
    final currentState = state;
    if (currentState is ItemDetailLoadedState) {
      emit(
        currentState.copyWith(currentItem: currentState.currentItem.copyWith(name: name)),
      );
    }
  }

  void onSpeechRecognitionResult(String result) {
    analyticsRepository.speechRecognitionResult(result);
    final currentState = state;
    if (currentState is ItemDetailLoadedState) {
      final categories = _extractCategories(result, currentState.availableCategories);
      final name = _extractName(result);
      if (categories.isNotEmpty) {
        onCategoriesChanged(categories, name: name);
      } else if (name != null) {
        emit(
          currentState.copyWith(currentItem: currentState.currentItem.copyWith(name: name)),
        );
      }
    }
  }

  String? _extractName(String result) {
    if (result.contains('name') || result.contains('nazwa')) {
      final tokens = result.split(' ');
      final indexOfName = tokens.indexWhere((element) => element == 'name' || element == 'nazwa');
      final indexOfCategory = tokens.indexWhere((element) => element == 'category' || element == 'kategoria');
      if (indexOfCategory > 0 && indexOfName < indexOfCategory) {
        final nameTokens = tokens.getRange(indexOfName + 1, indexOfCategory).toList();
        return nameTokens.join(' ');
      } else {
        final nameTokens = tokens.getRange(indexOfName + 1, tokens.length).toList();
        return nameTokens.join(' ');
      }
    } else {
      return null;
    }
  }

  Set<Category> _extractCategories(String result, Set<Category> availableCategories) {
    if (result.contains('category') || result.contains('kategoria')) {
      final tokens = result.split(' ');
      final indexOfName = tokens.indexWhere((element) => element == 'name' || element == 'nazwa');
      final indexOfCategory = tokens.indexWhere((element) => element == 'category' || element == 'kategoria');
      if (indexOfName < indexOfCategory) {
        final categoryTokens = tokens.getRange(indexOfCategory + 1, tokens.length).toList();
        return _detectCategories(categoryTokens, availableCategories);
      } else {
        return {};
      }
    } else {
      return {};
    }
  }

  Set<Category> _detectCategories(List<String> categoryTokens, Set<Category> availableCategories) {
    var fullQuery = categoryTokens.join(' ');
    final returnList = <Category>{};

    for (final category in availableCategories) {
      if (fullQuery.contains(category.name)) {
        returnList.add(category);
        fullQuery = fullQuery.replaceFirst(category.name, '');
      }
    }

    final leftTokens = fullQuery.split(' ');
    for (final token in leftTokens) {
      if (token.isNotEmpty && token != ' ') {
        returnList.add(Category.newEntity(name: token));
      }
    }

    return returnList;
  }

  void onImageChanged(File? image) async {
    final currentState = state;
    if (currentState is ItemDetailLoadedState) {
      final currentItemId = currentState.currentItem.id;

      final imageCacheDir = image?.parent;
      if (image == null) {
        await internalStorageRepository.removeItemImage(currentItemId);
      } else {
        await internalStorageRepository.saveItemImage(currentItemId, image);
      }
      await internalStorageRepository.clearCacheFromImages(imageCacheDir);

      emit(
        currentState.copyWith(
          currentItem: currentState.currentItem.copyWith(
            image: await internalStorageRepository.getItemImagePath(currentItemId),
          ),
        ),
      );
    }
  }

  void onCategoriesChanged(Set<Category> categories, {String? name}) {
    final currentState = state;
    if (currentState is ItemDetailLoadedState) {
      final availableCategories = currentState.availableCategories;
      final currentlyAssigned = currentState.currentItem.categories;
      final newCategory = categories.firstWhereOrNull((category) {
        return !currentlyAssigned.contains(category) && !availableCategories.contains(category);
      });
      if (newCategory != null) {
        analyticsRepository.createCategoryInItemDetail(newCategory);
      }

      if (name != null) {
        emit(
          currentState.copyWith(currentItem: currentState.currentItem.copyWith(name: name, categories: categories)),
        );
      } else {
        emit(
          currentState.copyWith(currentItem: currentState.currentItem.copyWith(categories: categories)),
        );
      }
    }
  }

  void onGroupsChanged(List<Group> groups) {
    final currentState = state;
    if (currentState is ItemDetailLoadedState) {
      final availableGroups = currentState.availableGroups;
      final currentlyAssignedGroups = currentState.selectedGroups;
      final newGroup = groups.firstWhereOrNull((group) {
        return !currentlyAssignedGroups.contains(group) && !availableGroups.contains(group);
      });
      if (newGroup != null) {
        analyticsRepository.createGroupInItemDetail(newGroup);
      }
      emit(
        currentState.copyWith(selectedGroups: groups),
      );
    }
  }

  void onSaveChanges() async {
    final currentState = state;
    if (currentState is ItemDetailLoadedState) {
      final currentItem = currentState.currentItem;
      final groups = currentState.selectedGroups;

      if (itemId == null) {
        _addItem(currentItem, groups);
        analyticsRepository.createItem(currentItem);
      } else {
        _editItem(currentItem, groups);
        analyticsRepository.editItem(currentItem);
      }
    }
  }

  void _addItem(Item item, List<Group> groups) {
    final newItem = itemRepository.addItem(item);
    groupRepository.assignItemToGroups(itemId: newItem.id, groups: groups);
    emit(const ItemDetailState.addSuccess());
  }

  void _editItem(Item item, List<Group> groups) {
    final oldItem = itemRepository.getItem(item.id);
    final oldGroups = groupRepository.getItemGroups(item.id);
    if (oldItem != item) {
      itemRepository.editItem(item);
      load();
    } else if (oldGroups != groups) {
      groupRepository.assignItemToGroups(itemId: item.id, groups: groups);
      load();
    }
  }
}
