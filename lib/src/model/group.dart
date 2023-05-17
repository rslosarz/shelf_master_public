/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:realm/realm.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/schema.dart';

part 'group.freezed.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    String? locationDsc,
    @Default([]) List<Item> items,
  }) = _Group;

  const Group._();

  Set<Category> get categories => items.map((item) => item.categories).flattened.toSet();

  factory Group.newEntity({required String name}) {
    return Group(
      id: ObjectId().hexString,
      name: name,
    );
  }

  factory Group.fromSchema(GroupSchema schema) {
    return Group(
      id: schema.id.hexString,
      name: schema.name,
      locationDsc: schema.locationDsc,
      items: schema.items.map(Item.fromSchema).toList(),
    );
  }

  GroupSchema toSchema() {
    return GroupSchema(
      ObjectId.fromHexString(id),
      name,
      locationDsc: locationDsc,
      items: items.map((item) => item.toSchema()),
    );
  }

  String groupUrl() {
    return 'https://shelfmaster.xyz/group/id=$id';
  }

  String groupKey() {
    return 'key_group_$id';
  }
}
