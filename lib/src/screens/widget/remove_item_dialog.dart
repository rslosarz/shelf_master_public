/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';

enum RemoveItemDialogStatus {
  removeConfirmed,
  removeDeclined,
}

class RemoveItemDialog extends StatelessWidget {
  const RemoveItemDialog({
    Key? key,
  }) : super(key: key);

  static Future<bool> showRemoveItemDialog(BuildContext context) async {
    context.read<AnalyticsRepository>().deleteItemRequest();
    final result = await showDialog<RemoveItemDialogStatus>(
      context: context,
      builder: (context) => const RemoveItemDialog(),
    );

    if (result == RemoveItemDialogStatus.removeConfirmed) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      insetPadding: const EdgeInsets.all(32),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.alertTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(context.l10n.removeItemDialogMessage),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.pop(RemoveItemDialogStatus.removeConfirmed);
                },
                child: Text(context.l10n.yes),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop(RemoveItemDialogStatus.removeDeclined);
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
