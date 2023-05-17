/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/routes.dart';
import 'package:shelf_master/src/screens/group_detail/bloc/group_detail_cubit.dart';
import 'package:shelf_master/src/screens/group_detail/bloc/group_detail_state.dart';
import 'package:shelf_master/src/screens/keys.dart';
import 'package:shelf_master/src/screens/widget/before_close_dialog.dart';
import 'package:shelf_master/src/screens/widget/item/item_list_tile.dart';
import 'package:shelf_master/src/screens/widget/nav_bar/dashboard_navigation_bar.dart';
import 'package:shelf_master/src/screens/widget/remove_item_dialog.dart';
import 'package:shelf_master/src/screens/widget/search_bar.dart';
import 'package:shelf_master/src/theme/debouncer.dart';

class GroupDetailScreen extends StatefulWidget {
  final String? groupId;

  const GroupDetailScreen({Key? key, this.groupId}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late final GroupDetailCubit _cubit = context.read<GroupDetailCubit>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
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
    locationController.addListener(() {
      _debouncer.run(() {
        _onLocationChanged(locationController.text);
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
          selectedRouteName: GroupDetailRoute.name,
          navigatorInterceptor: () async {
            if (hasUnsavedChanges) {
              return BeforeCloseDialog.showBeforeCloseDialog(context);
            } else {
              return true;
            }
          },
        ),
        body: BlocConsumer<GroupDetailCubit, GroupDetailState>(
          listener: (context, state) {
            state.whenOrNull(
              loaded: (originalGroup, currentGroup, _, __, ___) {
                setState(() {
                  hasUnsavedChanges = originalGroup != currentGroup;
                });
              },
              addSuccess: () {
                context.pop(true);
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
            if (widget.groupId != null) {
              final isAdded = await AddItemToGroupRoute(groupId: widget.groupId!).push<bool>(context);
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
    Group originalGroup,
    Group currentGroup,
    List<Item> queriedItems,
    SearchParams searchParams,
    Set<Category> categories,
  ) {
    if (nameController.text != currentGroup.name) {
      nameController.text = currentGroup.name;
    }
    if (locationController.text != currentGroup.locationDsc) {
      locationController.text = currentGroup.locationDsc ?? '';
    }
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          leading: Container(),
          expandedHeight: 120.0,
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
                            hintText: context.l10n.groupNameHint,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: Keys.locationInputKey,
                          onSubmitted: _onLocationChanged,
                          controller: locationController,
                          decoration: InputDecoration(
                            hintText: context.l10n.groupLocationHint,
                          ),
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            PrintGroupLabelRoute([currentGroup.id]).push<void>(context);
                          },
                          child: Text(context.l10n.qrLabelCta),
                        ),
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
              availableCategories: categories,
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
                  context.read<GroupDetailCubit>().removeItem(queriedItems[index]);
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
    context.read<GroupDetailCubit>().onSaveChanges();
  }

  void _onNameChanged(String name) {
    context.read<GroupDetailCubit>().onNameChanged(name);
  }

  void _onLocationChanged(String location) {
    context.read<GroupDetailCubit>().onLocationChanged(location);
  }

  void _onSearchParamsChanged(SearchParams searchParams) {
    context.read<GroupDetailCubit>().load(searchParams: searchParams);
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
