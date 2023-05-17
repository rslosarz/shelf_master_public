/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();

  Future<void> initSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> startListening(void Function(SpeechRecognitionResult) onSpeechResult) async {
    await _speechToText.listen(onResult: onSpeechResult);
  }

  Future<void> startListeningPL(void Function(SpeechRecognitionResult) onSpeechResult) async {
    await _speechToText.listen(onResult: onSpeechResult, localeId: 'pl_PL');
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
