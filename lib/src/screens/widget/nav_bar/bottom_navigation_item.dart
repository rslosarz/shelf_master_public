/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bottom_navigation_item.freezed.dart';

@freezed
class BottomNavigationItem with _$BottomNavigationItem {
  const factory BottomNavigationItem({
    required String name,
    required List<String> selectedForRouteNames,
    required IconData icon,
    required String Function(BuildContext context) onGenerateLabel,
    required void Function(BuildContext context) onTap,
  }) = _BottomNavigationItem;

  const BottomNavigationItem._();
}
