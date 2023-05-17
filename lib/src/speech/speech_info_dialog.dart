/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/speech/speech_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

enum SpeechLocale {
  defaultLocale,
  polish,
}

class SpeechInfoDialog extends StatefulWidget {
  final SpeechLocale locale;

  const SpeechInfoDialog({
    Key? key,
    required this.locale,
  }) : super(key: key);

  static Future<String?> showSpeechInfoDialog(BuildContext context,
      {SpeechLocale locale = SpeechLocale.defaultLocale}) async {
    context.read<AnalyticsRepository>().speechRecognitionTurnedOn();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SpeechInfoDialog(locale: locale),
    );

    return result;
  }

  @override
  State<StatefulWidget> createState() {
    return SpeechInfoDialogState();
  }
}

class SpeechInfoDialogState extends State<SpeechInfoDialog> {
  String recognizedWords = '';

  @override
  void initState() {
    super.initState();
    if (widget.locale == SpeechLocale.polish) {
      context.read<SpeechService>().startListeningPL(_handleSpeechResult);
    } else {
      context.read<SpeechService>().startListening(_handleSpeechResult);
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    print('QWE finalResult:${result.finalResult} recognizedWords:${result.recognizedWords}');
    if (result.finalResult) {
      context.pop(result.recognizedWords);
    }

    setState(() {
      recognizedWords = result.recognizedWords;
    });
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
          Text(context.l10n.speechInfoTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(context.l10n.speechInfoMessage),
          const SizedBox(height: 22),
          Text(recognizedWords),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.read<SpeechService>().stopListening();
            },
            child: Text(context.l10n.dismiss),
          ),
        ],
      ),
    );
  }
}
