/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:collection/collection.dart';
import 'package:realm/realm.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/schema.dart';

class CategoryRepository {
  final Realm realm;

  CategoryRepository({required this.realm});

  Set<Category> getAllCategories() {
    return realm.all<CategorySchema>().map(Category.fromSchema).toSet();
  }

  Category? getCategory(String id) {
    return realm.all<CategorySchema>().where((it) => it.id.hexString == id).map(Category.fromSchema).firstOrNull;
  }

  Category? getCategoryByName(String name) {
    return realm.all<CategorySchema>().where((it) => it.name == name).map(Category.fromSchema).firstOrNull;
  }

  Category addCategory(Category category) {
    final categorySchema = CategorySchema(
      ObjectId.fromHexString(category.id),
      category.name,
      category.colorHex,
    );
    realm.write(() => realm.add(categorySchema));
    return Category.fromSchema(categorySchema);
  }

  Category editCategory(Category category) {
    final categorySchema = _getCategorySchema(category.id)!;

    realm.write(() {
      categorySchema.name = category.name;
    });
    return Category.fromSchema(categorySchema);
  }

  CategorySchema? _getCategorySchema(String id) {
    return realm.all<CategorySchema>().where((it) => it.id.hexString == id).firstOrNull;
  }

  void removeCategory(Category category) {
    final categorySchema = _getCategorySchema(category.id)!;

    realm.write(() {
      realm.delete(categorySchema);
    });
  }
}
