/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/routes.dart';
import 'package:shelf_master/src/screens/widget/nav_bar/bottom_navigation_item.dart';
import 'package:shelf_master/src/theme/app_theme.dart';

class DashboardNavigationBar extends StatefulWidget {
  final List<BottomNavigationItem> _navigationItems = [
    BottomNavigationItem(
      name: GroupListRoute.name,
      selectedForRouteNames: [
        GroupListRoute.name,
        GroupDetailRoute.name,
        AddGroupRoute.name,
        AddItemToGroupRoute.name,
      ],
      icon: Icons.inventory,
      onGenerateLabel: (context) => context.l10n.groupNavLabel,
      onTap: (context) => const GroupListRoute().push<void>(context),
    ),
    BottomNavigationItem(
      name: ItemListRoute.name,
      selectedForRouteNames: [
        ItemListRoute.name,
        ItemDetailRoute.name,
        AddItemRoute.name,
      ],
      icon: Icons.list,
      onGenerateLabel: (context) => context.l10n.itemNavLabel,
      onTap: (context) => const ItemListRoute().push<void>(context),
    ),
    BottomNavigationItem(
      name: ScanCodeRoute.name,
      selectedForRouteNames: [
        CategoryListRoute.name,
        CategoryDetailRoute.name,
      ],
      icon: Icons.category,
      onGenerateLabel: (context) => context.l10n.categoryNavLabel,
      onTap: (context) => const CategoryListRoute().push<void>(context),
    ),
  ];

  final String selectedRouteName;
  final Future<bool> Function()? navigatorInterceptor;

  DashboardNavigationBar({
    Key? key,
    required this.selectedRouteName,
    this.navigatorInterceptor,
  }) : super(key: key);

  static Widget asHero({
    Key? key,
    required String selectedRouteName,
    Future<bool> Function()? navigatorInterceptor,
  }) {
    return Hero(
      key: key,
      tag: 'dashboard-navigation-bar',
      transitionOnUserGestures: true,
      child: DashboardNavigationBar(
        selectedRouteName: selectedRouteName,
        navigatorInterceptor: navigatorInterceptor,
      ),
    );
  }

  @override
  State<DashboardNavigationBar> createState() => _DashboardNavigationBarState();
}

class _DashboardNavigationBarState extends State<DashboardNavigationBar> {
  late String selectedRouteName;

  @override
  void initState() {
    super.initState();
    selectedRouteName = widget.selectedRouteName;
  }

  @override
  void didUpdateWidget(covariant DashboardNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedRouteName = widget.selectedRouteName;
  }

  @override
  Widget build(BuildContext context) {
    final index = widget._navigationItems.indexWhere((it) => it.selectedForRouteNames.contains(selectedRouteName));
    return BottomNavigationBar(
      currentIndex: max(0, index),
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.fontColor,
      // selectedIconTheme:
      // this.unselectedIconTheme,
      onTap: _onTap,
      items: widget._navigationItems.map((it) {
        return BottomNavigationBarItem(
          activeIcon: Icon(it.icon, color: AppTheme.primary),
          icon: Icon(it.icon, color: AppTheme.fontColor),
          label: it.onGenerateLabel(context),
        );
      }).toList(),
    );
  }

  void _onTap(int index) async {
    final shouldContinue = await widget.navigatorInterceptor?.call() ?? true;

    if (shouldContinue) {
      final item = widget._navigationItems[index];
      selectedRouteName = item.name;
      // ignore: use_build_context_synchronously
      item.onTap(context);
    }
  }
}
