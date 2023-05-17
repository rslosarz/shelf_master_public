/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:realm/realm.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/schema.dart';

part 'item.freezed.dart';

@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    String? name,
    int? quantity,
    String? image,
    @Default({}) Set<Category> categories,
  }) = _Item;

  const Item._();

  factory Item.newEntity({
    String? name,
  }) {
    return Item(
      id: ObjectId().hexString,
      name: name,
    );
  }

  factory Item.fromSchema(ItemSchema itemSchema) {
    return Item(
      id: itemSchema.id.hexString,
      name: itemSchema.name,
      quantity: itemSchema.quantity,
      image: itemSchema.image,
      categories: itemSchema.categories.map(Category.fromSchema).toSet(),
    );
  }

  ItemSchema toSchema() {
    return ItemSchema(
      ObjectId.fromHexString(id),
      name: name,
      quantity: quantity,
      image: image,
      categories: categories.map((category) => category.toSchema()),
    );
  }

  String imageHeroCategory() {
    return 'Hero_$id';
  }

  String imageKey() {
    return 'Key_$id';
  }

  String itemUrl() {
    return 'https://shelfmaster.xyz/item/id=$id';
  }
}
