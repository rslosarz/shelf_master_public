/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';

part 'print_label_state.freezed.dart';

@freezed
class PrintLabelState with _$PrintLabelState {
  const factory PrintLabelState.init() = PrintLabelInitState;

  const factory PrintLabelState.loaded({
    List<Group>? groups,
    List<Item>? items,
  }) = PrintLabelLoadedState;

  const factory PrintLabelState.error() = PrintLabelErrorState;
}
