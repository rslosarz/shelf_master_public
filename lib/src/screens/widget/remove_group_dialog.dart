/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';

enum RemoveGroupDialogStatus {
  removeConfirmed,
  removeDeclined,
}

class RemoveGroupDialog extends StatelessWidget {
  const RemoveGroupDialog({
    Key? key,
  }) : super(key: key);

  static Future<bool> showRemoveGroupDialog(BuildContext context) async {
    context.read<AnalyticsRepository>().deleteGroupRequest();
    final result = await showDialog<RemoveGroupDialogStatus>(
      context: context,
      builder: (context) => const RemoveGroupDialog(),
    );

    if (result == RemoveGroupDialogStatus.removeConfirmed) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.alertTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(context.l10n.removeGroupDialogMessage),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.pop(RemoveGroupDialogStatus.removeConfirmed);
                },
                child: Text(context.l10n.yes),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop(RemoveGroupDialogStatus.removeDeclined);
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
