/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/category.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/routes.dart';
import 'package:shelf_master/src/screens/category_list/bloc/category_list_cubit.dart';
import 'package:shelf_master/src/screens/category_list/bloc/category_list_state.dart';
import 'package:shelf_master/src/screens/widget/category/category_list_tile.dart';
import 'package:shelf_master/src/screens/widget/nav_bar/dashboard_navigation_bar.dart';
import 'package:shelf_master/src/screens/widget/remove_category_dialog.dart';
import 'package:shelf_master/src/screens/widget/search_bar.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late final CategoryListCubit _cubit = context.read<CategoryListCubit>();

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
        selectedRouteName: CategoryListRoute.name,
      ),
      body: BlocBuilder<CategoryListCubit, CategoryListState>(
        builder: (context, state) {
          return state.when(
            init: _init,
            loaded: _loaded,
            error: _error,
          );
        },
      ),
    );
  }

  Widget _init() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _loaded(List<Category> categories, SearchParams searchParams) {
    return Column(
      children: [
        SearchBar(
          onSearchParamsChanged: _onSearchParamsChanged,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return CategoryListTile(
                category: categories[index],
                onClick: () async {
                  await CategoryDetailRoute(categoryId: categories[index].id).push<void>(context);
                  _cubit.refresh();
                },
                onRemoveRequest: () {
                  return RemoveCategoryDialog.showRemoveCategoryDialog(context);
                },
                onRemoved: () {
                  context.read<CategoryListCubit>().removeCategory(categories[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _error() {
    return Center(
      child: Text(context.l10n.errorInfo),
    );
  }

  void _onSearchParamsChanged(SearchParams searchParams) {
    context.read<CategoryListCubit>().onSearchParamsChanged(searchParams);
  }
}
