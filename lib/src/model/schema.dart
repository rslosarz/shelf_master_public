/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:realm/realm.dart';

part 'schema.g.dart';

@RealmModel()
class _GroupSchema {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String? locationDsc;
  late List<_ItemSchema> items;
}

@RealmModel()
class _ItemSchema {
  @PrimaryKey()
  late ObjectId id;
  late String? name;
  late int? quantity;
  late String? image;
  late List<_CategorySchema> categories;
  @Backlink(#items)
  late Iterable<_GroupSchema> groups;
}

@RealmModel()
class _CategorySchema {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String colorHex;
}

@RealmModel()
class _ParameterSchema {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String value;
  late String colorHex;
}
