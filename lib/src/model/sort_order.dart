/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/cupertino.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';

enum SortOrder {
  nameAsc,
  nameDesc;
}

extension SortOrderL10n on SortOrder {
  String getSortOrderLabel(BuildContext context) {
    switch (this) {
      case SortOrder.nameAsc:
        return context.l10n.sortOrderNameAsc;
      case SortOrder.nameDesc:
        return context.l10n.sortOrderNameDesc;
    }
  }
}

extension SortOrderFunctions on SortOrder {
  int Function(Item a, Item b) sortItem() {
    switch (this) {
      case SortOrder.nameAsc:
        return (a, b) => a.name?.compareTo(b.name ?? '') ?? 0;
      case SortOrder.nameDesc:
        return (a, b) => b.name?.compareTo(a.name ?? '') ?? 0;
    }
  }

  int Function(Group a, Group b) sortGroup() {
    switch (this) {
      case SortOrder.nameAsc:
        return (a, b) => a.name.compareTo(b.name);
      case SortOrder.nameDesc:
        return (a, b) => b.name.compareTo(a.name);
    }
  }

  int Function(Category a, Category b) sortCategory() {
    switch (this) {
      case SortOrder.nameAsc:
        return (a, b) => a.name.compareTo(b.name);
      case SortOrder.nameDesc:
        return (a, b) => b.name.compareTo(a.name);
    }
  }
}
