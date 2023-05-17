/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/category_repository.dart';
import 'package:shelf_master/src/repo/group_repository.dart';
import 'package:shelf_master/src/repo/internal_storage_repository.dart';
import 'package:shelf_master/src/repo/item_repository.dart';
import 'package:shelf_master/src/screens/camera/camera_screen.dart';
import 'package:shelf_master/src/screens/category_detail/bloc/category_detail_cubit.dart';
import 'package:shelf_master/src/screens/category_detail/category_detail_screen.dart';
import 'package:shelf_master/src/screens/category_list/bloc/category_list_cubit.dart';
import 'package:shelf_master/src/screens/category_list/category_list_screen.dart';
import 'package:shelf_master/src/screens/group_detail/bloc/group_detail_cubit.dart';
import 'package:shelf_master/src/screens/group_detail/group_detail_screen.dart';
import 'package:shelf_master/src/screens/group_list/bloc/group_list_cubit.dart';
import 'package:shelf_master/src/screens/group_list/group_list_screen.dart';
import 'package:shelf_master/src/screens/item_detail/bloc/item_detail_cubit.dart';
import 'package:shelf_master/src/screens/item_detail/item_detail_screen.dart';
import 'package:shelf_master/src/screens/item_list/bloc/item_list_cubit.dart';
import 'package:shelf_master/src/screens/item_list/item_list_screen.dart';
import 'package:shelf_master/src/screens/print_label/bloc/print_label_cubit.dart';
import 'package:shelf_master/src/screens/print_label/print_label_screen.dart';
import 'package:shelf_master/src/screens/scan_code/scan_code_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<ItemListRoute>(
  path: '/',
)
class ItemListRoute extends GoRouteData {
  static String name = 'ItemListRoute';

  const ItemListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<ItemListCubit>(
      create: (context) => ItemListCubit(
        itemRepository: context.read<ItemRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const ItemListScreen(),
    );
  }
}

@TypedGoRoute<GroupListRoute>(
  path: '/group',
)
class GroupListRoute extends GoRouteData {
  static String name = 'GroupListRoute';

  const GroupListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<GroupListCubit>(
      create: (context) => GroupListCubit(
        groupRepository: context.read<GroupRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const GroupListScreen(),
    );
  }
}

@TypedGoRoute<CategoryListRoute>(
  path: '/category',
)
class CategoryListRoute extends GoRouteData {
  static String name = 'CategoryListRoute';

  const CategoryListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<CategoryListCubit>(
      create: (context) => CategoryListCubit(
        categoryRepository: context.read<CategoryRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const CategoryListScreen(),
    );
  }
}

@TypedGoRoute<CategoryDetailRoute>(
  path: '/category/id=:categoryId',
)
class CategoryDetailRoute extends GoRouteData {
  static String name = 'CategoryDetailRoute';
  final String categoryId;

  const CategoryDetailRoute({required this.categoryId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<CategoryDetailCubit>(
      create: (context) => CategoryDetailCubit(
        categoryId: categoryId,
        itemRepository: context.read<ItemRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: CategoryDetailScreen(categoryId: categoryId),
    );
  }
}

@TypedGoRoute<AddItemToCategoryRoute>(
  path: '/category/id=:categoryId/item/add',
)
class AddItemToCategoryRoute extends GoRouteData {
  static String name = 'AddItemToCategoryRoute';
  final String categoryId;

  const AddItemToCategoryRoute({required this.categoryId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<ItemDetailCubit>(
      create: (context) => ItemDetailCubit(
        requestedCategoryId: categoryId,
        itemRepository: context.read<ItemRepository>(),
        groupRepository: context.read<GroupRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        internalStorageRepository: context.read<InternalStorageRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const ItemDetailScreen(),
    );
  }
}

@TypedGoRoute<ItemDetailRoute>(
  path: '/item/id=:itemId',
)
class ItemDetailRoute extends GoRouteData {
  static String name = 'ItemDetailRoute';
  final String itemId;

  const ItemDetailRoute({required this.itemId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<ItemDetailCubit>(
      create: (context) => ItemDetailCubit(
        itemId: itemId,
        itemRepository: context.read<ItemRepository>(),
        groupRepository: context.read<GroupRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        internalStorageRepository: context.read<InternalStorageRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const ItemDetailScreen(),
    );
  }
}

@TypedGoRoute<AddItemRoute>(
  path: '/item/add',
)
class AddItemRoute extends GoRouteData {
  static String name = 'AddItemRoute';

  const AddItemRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<ItemDetailCubit>(
      create: (context) => ItemDetailCubit(
        itemRepository: context.read<ItemRepository>(),
        groupRepository: context.read<GroupRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        internalStorageRepository: context.read<InternalStorageRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const ItemDetailScreen(),
    );
  }
}

@TypedGoRoute<GroupDetailRoute>(
  path: '/group/id=:groupId',
)
class GroupDetailRoute extends GoRouteData {
  static String name = 'GroupDetailRoute';
  final String groupId;

  const GroupDetailRoute({required this.groupId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<GroupDetailCubit>(
      create: (context) => GroupDetailCubit(
        groupId: groupId,
        itemRepository: context.read<ItemRepository>(),
        groupRepository: context.read<GroupRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: GroupDetailScreen(groupId: groupId),
    );
  }
}

@TypedGoRoute<AddItemToGroupRoute>(
  path: '/group/id=:groupId/item/add',
)
class AddItemToGroupRoute extends GoRouteData {
  static String name = 'AddItemToGroupRoute';
  final String groupId;

  const AddItemToGroupRoute({required this.groupId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<ItemDetailCubit>(
      create: (context) => ItemDetailCubit(
        requestedGroupId: groupId,
        itemRepository: context.read<ItemRepository>(),
        groupRepository: context.read<GroupRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        internalStorageRepository: context.read<InternalStorageRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const ItemDetailScreen(),
    );
  }
}

@TypedGoRoute<AddGroupRoute>(
  path: '/group/add',
)
class AddGroupRoute extends GoRouteData {
  static String name = 'AddGroupRoute';

  const AddGroupRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<GroupDetailCubit>(
      create: (context) => GroupDetailCubit(
        itemRepository: context.read<ItemRepository>(),
        groupRepository: context.read<GroupRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const GroupDetailScreen(),
    );
  }
}

@TypedGoRoute<ScanCodeRoute>(
  path: '/scan',
)
class ScanCodeRoute extends GoRouteData {
  static String name = 'ScanCodeRoute';

  const ScanCodeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ScanCodeScreen();
  }
}

@TypedGoRoute<PrintGroupLabelRoute>(
  path: '/group/label',
)
class PrintGroupLabelRoute extends GoRouteData {
  static const String name = 'PrintGroupLabelRoute';
  final List<String> $extra;

  const PrintGroupLabelRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<PrintLabelCubit>(
      create: (context) => PrintLabelCubit(
        selectedGroupIds: $extra,
        groupRepository: context.read<GroupRepository>(),
        itemRepository: context.read<ItemRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const PrintLabelScreen(routeName: name),
    );
  }
}

@TypedGoRoute<PrintItemLabelRoute>(
  path: '/item/label',
)
class PrintItemLabelRoute extends GoRouteData {
  static const String name = 'PrintItemLabelRoute';
  final List<String> $extra;

  const PrintItemLabelRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider<PrintLabelCubit>(
      create: (context) => PrintLabelCubit(
        selectedItemsIds: $extra,
        groupRepository: context.read<GroupRepository>(),
        itemRepository: context.read<ItemRepository>(),
        analyticsRepository: context.read<AnalyticsRepository>(),
      ),
      child: const PrintLabelScreen(routeName: name),
    );
  }
}

@TypedGoRoute<CameraRoute>(
  path: '/camera',
)
class CameraRoute extends GoRouteData {
  static String name = 'CameraRoute';

  const CameraRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CameraScreen();
  }

  Future<File?> pushForResult(BuildContext context) async {
    final result = await const CameraRoute().push<Object?>(context);

    if (result is File) {
      return result;
    } else {
      return null;
    }
  }
}
