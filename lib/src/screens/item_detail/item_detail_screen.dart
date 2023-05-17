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
import 'package:shelf_master/src/routes.dart';
import 'package:shelf_master/src/screens/item_detail/bloc/item_detail_cubit.dart';
import 'package:shelf_master/src/screens/item_detail/bloc/item_detail_state.dart';
import 'package:shelf_master/src/screens/keys.dart';
import 'package:shelf_master/src/screens/widget/before_close_dialog.dart';
import 'package:shelf_master/src/screens/widget/category/categories_input.dart';
import 'package:shelf_master/src/screens/widget/group/group_input.dart';
import 'package:shelf_master/src/screens/widget/item/item_image_widget.dart';
import 'package:shelf_master/src/screens/widget/nav_bar/dashboard_navigation_bar.dart';
import 'package:shelf_master/src/speech/speech_info_dialog.dart';
import 'package:shelf_master/src/theme/app_theme.dart';
import 'package:shelf_master/src/theme/debouncer.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final nameController = TextEditingController();
  bool hasUnsavedChanges = false;
  final _debouncer = Debouncer(milliseconds: 500);
  final DraggableScrollableController draggableScrollableController = DraggableScrollableController();
  late final _cubit = context.read<ItemDetailCubit>();

  double fraction = 0.5;
  double pixels = 400;
  final minHeight = 100;

  @override
  void initState() {
    super.initState();
    draggableScrollableController.addListener(() {
      setState(() {
        fraction = draggableScrollableController.size;
        pixels = draggableScrollableController.pixels;
      });
    });
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
              onPressed: () async {
                final result = await SpeechInfoDialog.showSpeechInfoDialog(context);
                if (result != null) {
                  _cubit.onSpeechRecognitionResult(result);
                }
              },
              icon: const Icon(Icons.mic),
            ),
            IconButton(
              onPressed: () async {
                final result = await SpeechInfoDialog.showSpeechInfoDialog(context, locale: SpeechLocale.polish);
                if (result != null) {
                  _cubit.onSpeechRecognitionResult(result);
                }
              },
              icon: SizedBox(
                height: 30,
                width: 30,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 15,
                      child: Container(color: Colors.white),
                    ),
                    Positioned(
                      top: 15,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(color: Colors.red),
                    ),
                    const Positioned.fill(child: Icon(Icons.mic)),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                const ScanCodeRoute().push<void>(context);
              },
              icon: const Icon(Icons.qr_code),
            ),
          ],
        ),
        bottomNavigationBar: DashboardNavigationBar.asHero(
          selectedRouteName: ItemDetailRoute.name,
          navigatorInterceptor: () async {
            if (hasUnsavedChanges) {
              return BeforeCloseDialog.showBeforeCloseDialog(context);
            } else {
              return true;
            }
          },
        ),
        body: BlocConsumer<ItemDetailCubit, ItemDetailState>(
          listener: (context, state) {
            state.whenOrNull(
              loaded: (originalItem, currentItem, originalGroups, selectedGroups, _, __) {
                setState(() {
                  hasUnsavedChanges = originalItem != currentItem || originalGroups != selectedGroups;
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
                noItem: _error,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _init() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _loaded(
    Item originalItem,
    Item currentItem,
    List<Group> originalGroups,
    List<Group> selectedGroups,
    List<Group> availableGroups,
    Set<Category> availableCategories,
  ) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    if (nameController.text != currentItem.name) {
      nameController.text = currentItem.name ?? '';
    }

    return Stack(
      children: [
        Hero(
          tag: currentItem.imageHeroCategory(),
          child: ItemImageWidget(
            width: double.infinity,
            height: size.height - size.height * fraction,
            imageUrl: currentItem.image,
            onEditClick: () async {
              final image = await const CameraRoute().pushForResult(context);
              _cubit.onImageChanged(image);
            },
          ),
        ),
        DraggableScrollableSheet(
          controller: draggableScrollableController,
          initialChildSize: 0.5,
          minChildSize: minHeight / size.height,
          maxChildSize: 1,
          snapSizes: const [0.6, 1.0],
          snap: true,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: AppTheme.boxShadow,
              ),
              child: _bottomSheetContent(controller, currentItem, availableGroups, selectedGroups, availableCategories),
            );
          },
        ),
      ],
    );
  }

  Padding _bottomSheetContent(
    ScrollController controller,
    Item currentItem,
    List<Group> availableGroups,
    List<Group> selectedGroups,
    Set<Category> availableCategories,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        controller: controller,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 8,
                width: 150,
                decoration: BoxDecoration(
                  color: AppTheme.inactive,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasUnsavedChanges)
                ElevatedButton(
                  onPressed: _onSaveChanges,
                  child: Text(context.l10n.saveChangesCta),
                ),
              ElevatedButton(
                onPressed: () {
                  PrintItemLabelRoute([currentItem.id]).push<void>(context);
                },
                child: Text(context.l10n.qrLabelCta),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              key: Keys.nameInputKey,
              onSubmitted: _onNameChanged,
              controller: nameController,
              decoration: InputDecoration(
                hintText: context.l10n.itemNameHint,
              ),
              enableSuggestions: false,
              autocorrect: false,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: pixels > 200 ? pixels - 150 : 50,
            child: Row(
              children: [
                Expanded(
                  child: GroupsInput(
                    onGroupsChanged: _onGroupsChanged,
                    availableGroups: availableGroups.toSet(),
                    assignedGroups: selectedGroups.toSet(),
                  ),
                ),
                Container(width: 1, height: double.infinity, color: AppTheme.fontColor),
                Expanded(
                  child: CategoriesInput(
                    onCategoriesChanged: _onCategoriesChanged,
                    availableCategories: availableCategories,
                    assignedCategories: currentItem.categories,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _error() {
    return Center(
      child: Text(context.l10n.errorInfo),
    );
  }

  void _onSaveChanges() {
    _cubit.onSaveChanges();
  }

  void _onNameChanged(String name) {
    _cubit.onNameChanged(name);
  }

  void _onGroupsChanged(Set<Group> groups) {
    _cubit.onGroupsChanged(groups.toList());
  }

  void _onCategoriesChanged(Set<Category> categories) {
    _cubit.onCategoriesChanged(categories);
  }
}
