/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:collection/collection.dart';
import 'package:realm/realm.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/schema.dart';

class GroupRepository {
  final Realm realm;

  GroupRepository({required this.realm});

  List<Group> getAllGroups() {
    return realm.all<GroupSchema>().map(Group.fromSchema).toList();
  }

  List<Group> getItemGroups(String itemId) {
    return _getItemSchema(itemId)?.groups.map(Group.fromSchema).toList() ?? [];
  }

  Group? getGroup(String id) {
    return realm.all<GroupSchema>().where((it) => it.id.hexString == id).map(Group.fromSchema).firstOrNull;
  }

  List<Group> getGroupsById(List<String> ids) {
    return realm.all<GroupSchema>().where((it) => ids.contains(it.id.hexString)).map(Group.fromSchema).toList();
  }

  GroupSchema? _getGroupSchema(String id) {
    return realm.all<GroupSchema>().where((it) => it.id.hexString == id).firstOrNull;
  }

  Group addGroup(Group group) {
    final groupSchema = _addGroupSchema(group);
    return Group.fromSchema(groupSchema);
  }

  GroupSchema _addGroupSchema(Group group) {
    final groupSchema = GroupSchema(
      ObjectId.fromHexString(group.id),
      group.name,
      locationDsc: group.locationDsc,
      items: [],
    );
    realm.write(() => realm.add(groupSchema));
    return groupSchema;
  }

  void removeGroup(Group group) {
    final groupSchema = _getGroupSchema(group.id)!;

    realm.write(() {
      realm.delete(groupSchema);
    });
  }

  Group editGroup(Group group) {
    final groupSchema = _getGroupSchema(group.id)!;

    realm.write(() {
      groupSchema.name = group.name;
      groupSchema.locationDsc = group.locationDsc;
      _assignItemsToGroup(groupSchema: groupSchema, items: group.items);
    });
    return Group.fromSchema(groupSchema);
  }

  void assignItemToGroups({required String itemId, required List<Group> groups}) {
    final itemSchema = _getItemSchema(itemId);
    final requestedGroupIds = groups.map((e) => e.id);
    if (itemSchema != null) {
      final removedGroups = itemSchema.groups.where((it) => !requestedGroupIds.contains(it.id.hexString));
      final itemGroupIds = itemSchema.groups.map((e) => e.id.hexString);
      final toAddGroups = groups.where((toAddGroup) => !itemGroupIds.contains(toAddGroup.id));

      for (final groupSchema in removedGroups) {
        _removeItemFromGroup(itemSchema: itemSchema, groupSchema: groupSchema);
      }

      for (final group in toAddGroups) {
        _addItemToGroup(itemSchema: itemSchema, group: group);
      }
    }
  }

  void _removeItemFromGroup({required ItemSchema itemSchema, required GroupSchema groupSchema}) {
    realm.write(() {
      groupSchema.items.remove(itemSchema);
    });
  }

  void _addItemToGroup({required ItemSchema itemSchema, required Group group}) {
    final groupSchema = _getGroupSchema(group.id) ?? _addGroupSchema(group);
    realm.write(() {
      groupSchema.items.add(itemSchema);
    });
  }

  void _assignItemsToGroup({required GroupSchema groupSchema, required List<Item> items}) {
    final currentlyAssignedItemsSchema = groupSchema.items;
    final currentlyAssignedItemIds = currentlyAssignedItemsSchema.map((e) => e.id.hexString);
    final expectedItemIds = items.map((e) => e.id);

    final removedItems =
        currentlyAssignedItemsSchema.where((it) => !expectedItemIds.contains(it.id.hexString)).toList();
    final toAddItemIds =
        expectedItemIds.where((toAddItemId) => !currentlyAssignedItemIds.contains(toAddItemId)).toList();

    for (final itemSchema in removedItems) {
      _removeItemFromGroup(itemSchema: itemSchema, groupSchema: groupSchema);
    }

    for (final itemId in toAddItemIds) {
      _addItemToGroupSchema(itemId: itemId, groupSchema: groupSchema);
    }
  }

  void _addItemToGroupSchema({required String itemId, required GroupSchema groupSchema}) {
    final itemSchema = _getItemSchema(itemId);
    if (itemSchema != null) {
      realm.write(() {
        groupSchema.items.add(itemSchema);
      });
    }
  }

  ItemSchema? _getItemSchema(String id) {
    return realm.all<ItemSchema>().where((it) => it.id.hexString == id).firstOrNull;
  }
}
