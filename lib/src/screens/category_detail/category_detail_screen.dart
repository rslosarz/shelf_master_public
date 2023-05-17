/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/routes.dart';
import 'package:shelf_master/src/screens/category_detail/bloc/category_detail_cubit.dart';
import 'package:shelf_master/src/screens/category_detail/bloc/category_detail_state.dart';
import 'package:shelf_master/src/screens/keys.dart';
import 'package:shelf_master/src/screens/widget/before_close_dialog.dart';
import 'package:shelf_master/src/screens/widget/item/item_list_tile.dart';
import 'package:shelf_master/src/screens/widget/nav_bar/dashboard_navigation_bar.dart';
import 'package:shelf_master/src/screens/widget/remove_item_dialog.dart';
import 'package:shelf_master/src/screens/widget/search_bar.dart';
import 'package:shelf_master/src/theme/debouncer.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String? categoryId;

  const CategoryDetailScreen({Key? key, this.categoryId}) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late final CategoryDetailCubit _cubit = context.read<CategoryDetailCubit>();
  final nameController = TextEditingController();
  bool hasUnsavedChanges = false;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      _debouncer.run(() {
        _onNameChanged(nameController.text);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (hasUnsavedChanges) {
          return BeforeCloseDialog.showBeforeCloseDialog(context);
        } else {
          return true;
        }
      },
      child: Scaffold(
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
          selectedRouteName: CategoryDetailRoute.name,
          navigatorInterceptor: () async {
            if (hasUnsavedChanges) {
              return BeforeCloseDialog.showBeforeCloseDialog(context);
            } else {
              return true;
            }
          },
        ),
        body: BlocConsumer<CategoryDetailCubit, CategoryDetailState>(
          listener: (context, state) {
            state.whenOrNull(
              loaded: (category, originalName, _, __) {
                if (nameController.text != category.name) {
                  nameController.text = category.name;
                }
                setState(() {
                  hasUnsavedChanges = category.name != originalName;
                });
              },
              addSuccess: () {
                context.pop();
              },
            );
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: state.when(
                init: _init,
                loaded: _loaded,
                addSuccess: _init,
                notFound: _error,
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            if (widget.categoryId != null) {
              final isAdded = await AddItemToCategoryRoute(categoryId: widget.categoryId!).push<bool>(context);
              if (isAdded == true) {
                _cubit.refresh();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _init() {
    return Center(
      key: ValueKey('$runtimeType init'),
      child: const CircularProgressIndicator(),
    );
  }

  Widget _loaded(
    Category category,
    String originalName,
    List<Item> queriedItems,
    SearchParams searchParams,
  ) {
    if (nameController.text != category.name) {
      nameController.text = category.name;
    }
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          leading: Container(),
          expandedHeight: 90,
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: Keys.nameInputKey,
                          onSubmitted: _onNameChanged,
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: context.l10n.categoryNameHint,
                          ),
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: hasUnsavedChanges
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: _onSaveChanges,
                                  child: Text(context.l10n.saveChangesCta),
                                ),
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          delegate: SectionHeaderDelegate(
            height: 80,
            child: SearchBar(
              onSearchParamsChanged: _onSearchParamsChanged,
            ),
          ),
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              return ItemListTile(
                item: queriedItems[index],
                onClick: () {
                  ItemDetailRoute(itemId: queriedItems[index].id).push<void>(context);
                },
                onRemoveRequest: () {
                  return RemoveItemDialog.showRemoveItemDialog(context);
                },
                onRemoved: () {
                  context.read<CategoryDetailCubit>().removeItem(queriedItems[index]);
                },
              );
            },
            childCount: queriedItems.length,
          ),
        ),
      ],
    );
  }

  Widget _error() {
    return Center(
      key: ValueKey('$runtimeType error'),
      child: Text(context.l10n.errorInfo),
    );
  }

  void _onSaveChanges() {
    context.read<CategoryDetailCubit>().onSaveChanges();
  }

  void _onNameChanged(String name) {
    context.read<CategoryDetailCubit>().onNameChanged(name);
  }

  void _onSearchParamsChanged(SearchParams searchParams) {
    context.read<CategoryDetailCubit>().load(searchParams: searchParams);
  }
}

class SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SectionHeaderDelegate({
    required this.child,
    this.height = 50,
  });

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
