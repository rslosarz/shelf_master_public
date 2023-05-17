/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shelf_master/src/l10n/l10n.dart';

enum BeforeCloseDialogStatus {
  closingConfirmed,
  closingRejected,
}

class BeforeCloseDialog extends StatelessWidget {
  const BeforeCloseDialog({
    Key? key,
  }) : super(key: key);

  static Future<bool> showBeforeCloseDialog(BuildContext context) async {
    final result = await showDialog<BeforeCloseDialogStatus>(
      context: context,
      builder: (context) => const BeforeCloseDialog(),
    );

    if (result == BeforeCloseDialogStatus.closingConfirmed) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.beforeClosingDialogMessage),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.pop(BeforeCloseDialogStatus.closingConfirmed);
                },
                child: Text(context.l10n.yes),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop(BeforeCloseDialogStatus.closingRejected);
                },
                child: Text(context.l10n.no),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
