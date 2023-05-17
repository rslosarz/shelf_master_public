# shelf_master_public

## Prerequisites

### macOS

1. Install openjdk (11.0.14-ms via sdkman - https://sdkman.io/install)
1. Install rbenv - https://github.com/rbenv/rbenv#using-package-managers
1. Install fvm - https://fvm.app/docs/getting_started/installation
1. Make sure ruby gems are run via rbenv
    ```shell
    $ which gem
    /Users/<USER>/.rbenv/shims/gem
    ```
1. Install bundler `gem install bundler`
1. Make sure `fvm flutter doctor -v` does not complain about missing requirements

## Build

```shell
fvm flutter pub get && fvm flutter pub run build_runner build --delete-conflicting-outputs
```

You can also use the ci command:

```shell
bundle exec fastlane ci
```

## Getting Started

App supports 2 flavors:

- prod
- dev

To run you can either run the following commands in terminal:

```sh
$ flutter run --flavor prod --target lib/main_prod.dart

$ flutter run --flavor dev --target lib/main_dev.dart
```

or use run configs added for both Android Studio (/.run) or VSCode (/.vscode)

## Golden tests

In order to regenerate golden files please run:

```shell
fvm flutter test --update-goldens
```

It is also possible to use [VS Code context menu] to regenerate individual tests from the IDE.

[VS Code context menu]:https://pub.dev/packages/golden_toolkit#configure-vs-code

## Assets

The `assets` directory houses images, fonts, and any other files you want to include with your
application.

The `assets/images` directory
contains [resolution-aware images](https://flutter.dev/docs/development/ui/assets-and-images#resolution-aware)
.

## Localization

This project generates localized messages based on arb files found in the `lib/src/l10n` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter apps](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
