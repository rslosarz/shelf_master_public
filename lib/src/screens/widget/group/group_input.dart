/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/screens/widget/group/group_chip_widget.dart';

class GroupsInput extends StatefulWidget {
  final void Function(Set<Group>) onGroupsChanged;
  final Set<Group> availableGroups;
  final Set<Group> assignedGroups;

  const GroupsInput({
    Key? key,
    required this.onGroupsChanged,
    required this.availableGroups,
    required this.assignedGroups,
  }) : super(key: key);

  @override
  State<GroupsInput> createState() => _GroupsInputState();
}

class _GroupsInputState extends State<GroupsInput> {
  late Set<Group> selectedGroups = Set.from(widget.assignedGroups);
  TextEditingController? textEditingController;

  void _removeGroup(Group group) {
    setState(() {
      selectedGroups.remove(group);
    });
    widget.onGroupsChanged(selectedGroups);
  }

  void _addGroup(Group selectedGroup) {
    setState(() {
      selectedGroups.add(selectedGroup);
    });
    widget.onGroupsChanged(selectedGroups);
    textEditingController?.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(context.l10n.assignedGroupsLabel),
          Autocomplete<Group>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<Group>.empty();
              }
              return widget.availableGroups.where(
                (group) => group.name.isNotEmpty && group.name.contains(textEditingValue.text.toLowerCase()),
              );
            },
            optionsViewBuilder: _optionsViewBuilder,
            displayStringForOption: (group) => group.name,
            onSelected: _addGroup,
            fieldViewBuilder: _widgetLayout,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: selectedGroups
                  .map(
                    (group) => GroupChipWidget.chip(
                      group: group,
                      onRemove: () => _removeGroup(group),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetLayout(BuildContext context, TextEditingController ttec, FocusNode tfn, VoidCallback onFieldSubmitted) {
    textEditingController = ttec;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _inputField(ttec, tfn, onFieldSubmitted),
      ],
    );
  }

  Widget _inputField(TextEditingController ttec, FocusNode tfn, VoidCallback onFieldSubmitted) {
    return TextField(
      controller: ttec,
      focusNode: tfn,
      decoration: InputDecoration(
        helperText: context.l10n.enterGroupHint,
        hintText: selectedGroups.isNotEmpty ? '' : context.l10n.enterGroupHint,
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          final group =
              widget.availableGroups.where((e) => e.name == value).firstOrNull ?? Group.newEntity(name: value);
          onFieldSubmitted();
          _addGroup(group);
        }
      },
    );
  }

  Widget _optionsViewBuilder(BuildContext context, AutocompleteOnSelected<Group> onSelected, Iterable<Group> options) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.0)),
        ),
        child: SizedBox(
          height: 82.0 * options.length,
          width: size.width * 0.4,
          child: Card(
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                shrinkWrap: false,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GroupChipWidget.hint(group: option),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
