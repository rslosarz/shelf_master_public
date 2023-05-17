/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/group_repository.dart';
import 'package:shelf_master/src/repo/item_repository.dart';
import 'package:shelf_master/src/screens/print_label/bloc/print_label_state.dart';

class PrintLabelCubit extends Cubit<PrintLabelState> {
  final List<String>? selectedGroupIds;
  final List<String>? selectedItemsIds;
  final GroupRepository groupRepository;
  final ItemRepository itemRepository;
  final AnalyticsRepository analyticsRepository;

  PrintLabelCubit({
    required this.groupRepository,
    required this.itemRepository,
    required this.analyticsRepository,
    this.selectedGroupIds,
    this.selectedItemsIds,
    PrintLabelState? initialState,
  }) : super(initialState ?? const PrintLabelState.init()) {
    if (initialState == null) {
      load();
    }
  }

  void load() async {
    emit(const PrintLabelState.init());
    final groups = selectedGroupIds != null ? groupRepository.getGroupsById(selectedGroupIds!) : null;
    final items = selectedItemsIds != null ? itemRepository.getItemsById(selectedItemsIds!) : null;

    if (groups != null) {
      analyticsRepository.onQrCodeGroupLabel(groups.length);
    }
    if (items != null) {
      analyticsRepository.onQrCodeItemLabel(items.length);
    }
    emit(PrintLabelState.loaded(groups: groups, items: items));
  }

  void refresh() {
    load();
  }
}
