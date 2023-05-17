/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';

class AnalyticsRepository {
  void logException({
    required String reason,
    required Object exception,
    StackTrace? trace,
  }) {
    FirebaseCrashlytics.instance.recordError(exception, trace, reason: reason);
  }

  void createItem(Item item) {
    FirebaseAnalytics.instance.logEvent(
      name: 'create_item',
      parameters: item.toParameters(),
    );
  }

  void createGroupInItemDetail(Group group) {
    final params = group.toParameters();
    FirebaseAnalytics.instance.logEvent(
      name: 'create_group_item_detail',
      parameters: params,
    );
  }

  void createGroup(Group group) {
    FirebaseAnalytics.instance.logEvent(
      name: 'create_group',
      parameters: group.toParameters(),
    );
  }

  void createCategoryInItemDetail(Category category) {
    FirebaseAnalytics.instance.logEvent(
      name: 'create_category_item_detail',
      parameters: category.toParameters(),
    );
  }

  void createCategory(Category category) {
    FirebaseAnalytics.instance.logEvent(
      name: 'create_category',
      parameters: category.toParameters(),
    );
  }

  void deleteGroupRequest() {
    FirebaseAnalytics.instance.logEvent(
      name: 'delete_group_request',
    );
  }

  void deleteGroup(Group group, String location) {
    FirebaseAnalytics.instance.logEvent(
      name: 'delete_group',
      parameters: group.toParameters()..addAll({_EventParameters.location: location}),
    );
  }

  void deleteGroups() {
    FirebaseAnalytics.instance.logEvent(
      name: 'delete_groups',
    );
  }

  void deleteItemRequest() {
    FirebaseAnalytics.instance.logEvent(
      name: 'delete_item_request',
    );
  }

  void deleteItem(Item item, String location) {
    FirebaseAnalytics.instance.logEvent(
      name: 'delete_item',
      parameters: item.toParameters()..addAll({_EventParameters.location: location}),
    );
  }

  void deleteItems() {
    FirebaseAnalytics.instance.logEvent(
      name: 'delete_items',
    );
  }

  void deleteCategoryRequest() {
    FirebaseAnalytics.instance.logEvent(
      name: 'delete_category_request',
    );
  }

  void deleteCategory(Category category, String location) {
    FirebaseAnalytics.instance.logEvent(
      name: 'delete_category',
      parameters: category.toParameters()..addAll({_EventParameters.location: location}),
    );
  }

  void editItem(Item item) {
    FirebaseAnalytics.instance.logEvent(
      name: 'edit_item',
      parameters: item.toParameters(),
    );
  }

  void editGroup(Group group) {
    FirebaseAnalytics.instance.logEvent(
      name: 'edit_group',
      parameters: group.toParameters(),
    );
  }

  void editCategory(Category category) {
    FirebaseAnalytics.instance.logEvent(
      name: 'edit_category',
      parameters: category.toParameters(),
    );
  }

  void selectGroupsModeOn() {
    FirebaseAnalytics.instance.logEvent(
      name: 'select_groups_mode_on',
    );
  }

  void selectItemsModeOn() {
    FirebaseAnalytics.instance.logEvent(
      name: 'select_items_mode_on',
    );
  }

  void setupGroupSearchParams(SearchParams searchParams) {
    FirebaseAnalytics.instance.logEvent(
      name: 'setup_group_search_params',
      parameters: searchParams.toParameters(),
    );
  }

  void setupItemSearchParams(SearchParams searchParams) {
    FirebaseAnalytics.instance.logEvent(
      name: 'setup_item_search_params',
      parameters: searchParams.toParameters(),
    );
  }

  void setupCategorySearchParams(SearchParams searchParams) {
    FirebaseAnalytics.instance.logEvent(
      name: 'setup_category_search_params',
      parameters: searchParams.toParameters(),
    );
  }

  void onQrCodeScanned(String path) {
    FirebaseAnalytics.instance.logEvent(
      name: 'select_items_mode_on',
      parameters: {
        _EventParameters.path: path,
      },
    );
  }

  void onQrCodeGroupLabel(int amount) {
    FirebaseAnalytics.instance.logEvent(
      name: 'qr_code_group_label',
      parameters: {
        _EventParameters.groupLabelsAmount: amount,
      },
    );
  }

  void onQrCodeItemLabel(int amount) {
    FirebaseAnalytics.instance.logEvent(
      name: 'qr_code_item_label',
      parameters: {
        _EventParameters.itemLabelsAmount: amount,
      },
    );
  }

  void itemDetailDeeplink(String itemId) {
    FirebaseAnalytics.instance.logEvent(
      name: 'item_detail_deeplink',
      parameters: {
        _EventParameters.id: itemId,
      },
    );
  }

  void groupDetailDeeplink(String groupId) {
    FirebaseAnalytics.instance.logEvent(
      name: 'group_detail_deeplink',
      parameters: {
        _EventParameters.id: groupId,
      },
    );
  }

  void speechRecognitionTurnedOn() {
    FirebaseAnalytics.instance.logEvent(
      name: 'speech_recognition_start',
    );
  }

  void speechRecognitionResult(String result) {
    FirebaseAnalytics.instance.logEvent(
      name: 'speech_recognition_result',
      parameters: {
        _EventParameters.result: result,
      },
    );
  }
}

extension on Category {
  Map<String, dynamic> toParameters() {
    return {
      _EventParameters.objectName: name,
    };
  }
}

extension on Item {
  Map<String, dynamic> toParameters() {
    return {
      _EventParameters.objectName: name,
      _EventParameters.imageAdded: (image != null && image!.isNotEmpty).toString(),
      _EventParameters.categoriesAssigned: categories.isNotEmpty.toString(),
    };
  }
}

extension on Group {
  Map<String, dynamic> toParameters() {
    return {
      _EventParameters.objectName: name,
      _EventParameters.locationDscAdded: (locationDsc != null && locationDsc!.isNotEmpty).toString(),
      _EventParameters.itemsAssigned: (items.isNotEmpty).toString(),
    };
  }
}

extension on SearchParams {
  Map<String, dynamic> toParameters() {
    return {
      _EventParameters.query: query,
      _EventParameters.sortOrder: sortOrder.toString(),
      _EventParameters.categoriesSearch: categories.isNotEmpty.toString(),
    };
  }
}

class _EventParameters {
  static const location = 'location';
  static const objectName = 'name';
  static const imageAdded = 'image_added';
  static const locationDscAdded = 'location_dsc_added';
  static const categoriesAssigned = 'categories_assigned';
  static const itemsAssigned = 'items_assigned';
  static const path = 'path';
  static const id = 'id';
  static const query = 'query';
  static const sortOrder = 'sort_order';
  static const categoriesSearch = 'categories_search';
  static const groupLabelsAmount = 'group_labels_amount';
  static const itemLabelsAmount = 'item_labels_amount';
  static const result = 'result';

  const _EventParameters._();
}
