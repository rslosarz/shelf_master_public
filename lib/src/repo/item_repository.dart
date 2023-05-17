/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:collection/collection.dart';
import 'package:realm/realm.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/schema.dart';
import 'package:shelf_master/src/theme/color_util.dart';

class ItemRepository {
  final Realm realm;

  ItemRepository({required this.realm});

  List<Item> getAllItems() {
    return realm.all<ItemSchema>().map(Item.fromSchema).toList();
  }

  List<Item> getAllItemsWithCategory(String categoryId) {
    final categorySchema = _getCategorySchema(categoryId);
    return realm
        .all<ItemSchema>()
        .where(
          (it) => it.categories.contains(categorySchema),
        )
        .map(Item.fromSchema)
        .toList();
  }

  Item? getItem(String id) {
    return realm.all<ItemSchema>().where((it) => it.id.hexString == id).map(Item.fromSchema).firstOrNull;
  }

  List<Item> getItemsById(List<String> ids) {
    return realm.all<ItemSchema>().where((it) => ids.contains(it.id.hexString)).map(Item.fromSchema).toList();
  }

  ItemSchema? _getItemSchema(String id) {
    return realm.all<ItemSchema>().where((it) => it.id.hexString == id).firstOrNull;
  }

  Item saveItem(Item item) {
    final itemSchema = _getItemSchema(item.id);
    if (itemSchema != null) {
      return editItem(item);
    } else {
      return addItem(item);
    }
  }

  Item addItem(Item item) {
    final itemCategorySchemas = item.categories.map(_createCategorySchema).toList();

    final itemSchema = ItemSchema(
      ObjectId.fromHexString(item.id),
      name: item.name,
      image: item.image,
      quantity: item.quantity,
      categories: itemCategorySchemas,
    );
    realm.write(() => realm.add(itemSchema));
    return Item.fromSchema(itemSchema);
  }

  Item editItem(Item item) {
    final itemSchema = _getItemSchema(item.id)!;
    final itemCategorySchemas = item.categories.map(_createCategorySchema).toList();

    realm.write(() {
      itemSchema.name = item.name;
      itemSchema.image = item.image;
      itemSchema.quantity = item.quantity;
      itemSchema.categories.clear();
      itemSchema.categories.addAll(itemCategorySchemas);
    });
    return Item.fromSchema(itemSchema);
  }

  void removeItem(Item item) {
    final itemSchema = _getItemSchema(item.id)!;

    realm.write(() {
      realm.delete(itemSchema);
    });
  }

  CategorySchema _createCategorySchema(Category category) {
    final categorySchema = _getCategorySchema(category.id);
    return categorySchema ??
        CategorySchema(
          ObjectId.fromHexString(category.id),
          category.name,
          ColorUtil.getRandomHexColor(),
        );
  }

  CategorySchema? _getCategorySchema(String id) {
    return realm.all<CategorySchema>().where((it) => it.id.hexString == id).firstOrNull;
  }
}
