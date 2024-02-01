A simple command-line application that creates Fastlane directories and files from the given translation files.

Script accepts arguments:

- `--stringsDir "path_to_the_folder_with_translation_files"`
- `--updatedDir "path_to_the_folder_with_faslane_dirs"`

Command to run the script

iOS

`dart bin/dart_update_locales_fastlane.dart --stringsDir "/Users/mavbook/projects/flashcards/assets/i18n" --updatedDir "/Users/mavbook/projects/flashcards/fastlane/metadata" --os "ios"`

Android

`dart bin/dart_update_locales_fastlane.dart --stringsDir "/Users/mavbook/projects/flashcards/assets/i18n" --updatedDir "UPDATE_DIR_PATH" --os "android"`
