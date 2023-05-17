/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/routes.dart';
import 'package:shelf_master/src/screens/item_list/bloc/item_list_cubit.dart';
import 'package:shelf_master/src/screens/item_list/bloc/item_list_state.dart';
import 'package:shelf_master/src/screens/widget/item/item_list_tile.dart';
import 'package:shelf_master/src/screens/widget/nav_bar/dashboard_navigation_bar.dart';
import 'package:shelf_master/src/screens/widget/remove_item_dialog.dart';
import 'package:shelf_master/src/screens/widget/search_bar.dart';
import 'package:shelf_master/src/screens/widget/selected_menu.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({Key? key}) : super(key: key);

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late final ItemListCubit _cubit = context.read<ItemListCubit>();
  bool isSelectionMode = false;
  Set<Item> selectedItems = {};

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
        selectedRouteName: ItemListRoute.name,
      ),
      body: BlocBuilder<ItemListCubit, ItemListState>(
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
          final isAdded = await const AddItemRoute().push<bool>(context);
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

  Widget _loaded(List<Item> items, SearchParams searchParams, Set<Category> categories) {
    return Column(
      children: [
        SearchBar(
          availableCategories: categories,
          onSearchParamsChanged: _onSearchParamsChanged,
        ),
        if (isSelectionMode)
          SelectedMenu(
            selectedCount: selectedItems.length,
            onCloseSelection: () {
              setState(() {
                isSelectionMode = false;
              });
            },
            onClearAllClick: () {
              setState(() {
                selectedItems.clear();
              });
            },
            onSelectAllClick: () {
              setState(() {
                selectedItems.addAll(items);
              });
            },
            onQRCodeClick: () {
              PrintItemLabelRoute(selectedItems.map((it) => it.id).toList()).push<void>(context);
            },
            onDeleteAllClick: () async {
              final shouldRemove = await RemoveItemDialog.showRemoveItemDialog(context);
              if (shouldRemove) {
                _cubit.removeItems(selectedItems);
              }
            },
          ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final currentItem = items[index];
              return _buildItemListTile(currentItem);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemListTile(Item item) {
    return ItemListTile(
      item: item,
      isSelectionMode: isSelectionMode,
      isSelected: selectedItems.contains(item),
      onClick: () async {
        await ItemDetailRoute(itemId: item.id).push<void>(context);
        _cubit.refresh();
      },
      onLongClick: () {
        setState(() {
          if (isSelectionMode) {
            if (selectedItems.contains(item)) {
              selectedItems.remove(item);
            } else {
              selectedItems.add(item);
            }
          } else {
            isSelectionMode = !isSelectionMode;
            context.read<AnalyticsRepository>().selectItemsModeOn();
          }
        });
      },
      onSelection: (selected) {
        setState(() {
          if (selected == true) {
            selectedItems.add(item);
          } else {
            selectedItems.remove(item);
          }
        });
      },
      onRemoveRequest: () {
        return RemoveItemDialog.showRemoveItemDialog(context);
      },
      onRemoved: () {
        _cubit.removeItem(item);
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
