/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:realm/realm.dart';
import 'package:shelf_master/src/model/schema.dart';
import 'package:shelf_master/src/theme/color_util.dart';

part 'category.freezed.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String colorHex,
  }) = _Category;

  const Category._();

  factory Category.newEntity({
    required String name,
  }) {
    return _Category(
      id: ObjectId().hexString,
      name: name,
      colorHex: ColorUtil.getRandomHexColor(),
    );
  }

  factory Category.fromSchema(CategorySchema schema) {
    return _Category(
      id: schema.id.hexString,
      name: schema.name,
      colorHex: schema.colorHex,
    );
  }

  CategorySchema toSchema() {
    return CategorySchema(
      ObjectId.fromHexString(id),
      name,
      colorHex,
    );
  }

  String categoryKey() {
    return 'key_category_$id';
  }
}
