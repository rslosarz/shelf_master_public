import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // ignore: unused_element
  void _ignoreCheckUnusedL10nFalsePositives() {
    AppLocalizations.of(this)?.localeName.toString();
    AppLocalizations.delegate.toString();
    AppLocalizations.supportedLocales.toString();
  }
}
