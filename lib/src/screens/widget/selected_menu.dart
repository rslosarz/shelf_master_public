/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:shelf_master/src/l10n/l10n.dart';

class SelectedMenu extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCloseSelection;
  final VoidCallback onClearAllClick;
  final VoidCallback onSelectAllClick;
  final VoidCallback onQRCodeClick;
  final VoidCallback onDeleteAllClick;

  const SelectedMenu({
    Key? key,
    required this.selectedCount,
    required this.onCloseSelection,
    required this.onClearAllClick,
    required this.onSelectAllClick,
    required this.onQRCodeClick,
    required this.onDeleteAllClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onCloseSelection,
          icon: const Icon(Icons.clear),
        ),
        Text(
          context.l10n.selectedLabel(selectedCount),
        ),
        const Spacer(),
        IconButton(
          onPressed: onClearAllClick,
          icon: const Icon(Icons.deselect_outlined),
        ),
        IconButton(
          onPressed: onSelectAllClick,
          icon: const Icon(Icons.select_all),
        ),
        TextButton(
          onPressed: onQRCodeClick,
          child: Text(context.l10n.qrLabelCta),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onDeleteAllClick,
          child: Text(context.l10n.deleteCta),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
