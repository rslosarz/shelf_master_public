/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/routes.dart';
import 'package:shelf_master/src/screens/group_list/bloc/group_list_cubit.dart';
import 'package:shelf_master/src/screens/group_list/bloc/group_list_state.dart';
import 'package:shelf_master/src/screens/widget/group/group_list_tile.dart';
import 'package:shelf_master/src/screens/widget/nav_bar/dashboard_navigation_bar.dart';
import 'package:shelf_master/src/screens/widget/remove_group_dialog.dart';
import 'package:shelf_master/src/screens/widget/search_bar.dart';
import 'package:shelf_master/src/screens/widget/selected_menu.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  late final GroupListCubit _cubit = context.read<GroupListCubit>();
  bool isSelectionMode = false;
  Set<Group> selectedGroups = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () {
              const ScanCodeRoute().push<void>(context);
            },
            icon: const Icon(Icons.qr_code),
          ),
        ],
      ),
      bottomNavigationBar: DashboardNavigationBar.asHero(
        selectedRouteName: GroupListRoute.name,
      ),
      body: BlocConsumer<GroupListCubit, GroupListState>(
        listener: (context, state) {
          if (state is GroupListLoadedState) {
            setState(() {
              isSelectionMode = false;
              selectedGroups.clear();
            });
          }
        },
        builder: (context, state) {
          return state.when(
            init: _init,
            loaded: _loaded,
            error: _error,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final isAdded = await const AddGroupRoute().push<bool>(context);
          if (isAdded == true) {
            _cubit.refresh();
          }
        },
      ),
    );
  }

  Widget _init() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _loaded(List<Group> groups, SearchParams searchParams, Set<Category> existingCategories) {
    return Column(
      children: [
        SearchBar(
          availableCategories: existingCategories,
          onSearchParamsChanged: _onSearchParamsChanged,
        ),
        if (isSelectionMode)
          SelectedMenu(
            selectedCount: selectedGroups.length,
            onCloseSelection: () {
              setState(() {
                isSelectionMode = false;
              });
            },
            onClearAllClick: () {
              setState(() {
                selectedGroups.clear();
              });
            },
            onSelectAllClick: () {
              setState(() {
                selectedGroups.addAll(groups);
              });
            },
            onQRCodeClick: () {
              PrintGroupLabelRoute(selectedGroups.map((it) => it.id).toList()).push<void>(context);
            },
            onDeleteAllClick: () async {
              final shouldRemove = await RemoveGroupDialog.showRemoveGroupDialog(context);
              if (shouldRemove) {
                _cubit.removeGroups(selectedGroups);
              }
            },
          ),
        Expanded(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final currentGroup = groups[index];
              return _buildGroupListTile(currentGroup);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupListTile(Group currentGroup) {
    return GroupListTile(
      group: currentGroup,
      isSelectionMode: isSelectionMode,
      isSelected: selectedGroups.contains(currentGroup),
      onClick: () async {
        await GroupDetailRoute(groupId: currentGroup.id).push<void>(context);
        _cubit.refresh();
      },
      onLongClick: () {
        setState(() {
          if (isSelectionMode) {
            if (selectedGroups.contains(currentGroup)) {
              selectedGroups.remove(currentGroup);
            } else {
              selectedGroups.add(currentGroup);
            }
          } else {
            isSelectionMode = !isSelectionMode;
            context.read<AnalyticsRepository>().selectGroupsModeOn();
          }
        });
      },
      onSelection: (selected) {
        setState(() {
          if (selected == true) {
            selectedGroups.add(currentGroup);
          } else {
            selectedGroups.remove(currentGroup);
          }
        });
      },
      onRemoveRequest: () {
        return RemoveGroupDialog.showRemoveGroupDialog(context);
      },
      onRemoved: () {
        _cubit.removeGroup(currentGroup);
      },
    );
  }

  Widget _error() {
    return Center(
      child: Text(context.l10n.errorInfo),
    );
  }

  void _onSearchParamsChanged(SearchParams searchParams) {
    _cubit.onSearchParamsChanged(searchParams);
  }
}
