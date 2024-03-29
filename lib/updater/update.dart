import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

///
/// Directory with translations made by slang-gpt
/// https://pub.dev/packages/slang_gpt
///
const kTranslationsDir = 'stringsDir';

///
/// Directory with fastlane files
///
const kFastlaneDir = 'updatedDir';

///
/// OS type - ios or android
///
const kOS = 'os';

void update(ArgResults argResults) async {
  List<String> args = argResults.rest;
  final os = args[2];

  stderr.writeln('working directory - ${argResults.arguments}');
  if (args.isEmpty) {
    _printErrors(ErrorType.noParameters);
  } else {
    final List<FileSystemEntity> translationsFiles = await _dirContents(Directory(args[0]));
    final List<FileSystemEntity> fastlaneFiles = await _dirContents(Directory(args[1]));
    final List<Directory> fastlaneDirs = fastlaneFiles.whereType<Directory>().toList();
    final List<String> fastlaneDirsPaths = fastlaneDirs.map((e) => e.path).toList();

    late final Map<String, String> dirFilenames;

    if (os == 'ios') {
      dirFilenames = _dirNameFileNameIos;
    } else {
      dirFilenames = _dirNameFileNameAndroid;
    }

    for (final dirName in dirFilenames.keys) {
      final pathToTranslationFile =
          translationsFiles.firstWhere((e) => e.path.split('/').last == dirFilenames[dirName]).path;

      final Map<String, dynamic> translationsMap = await _readFileAsMap(pathToTranslationFile);

      final dirPath = '${Directory(args[1]).path}/$dirName';
      final Map<String, String> fileNameTranslatedString;

      if (os == 'ios') {
        fileNameTranslatedString = _fileNameTranslatedStringIos;
      } else {
        fileNameTranslatedString = {};
        // fileNameTranslatedString = _fileNameTranslatedStringAndroid;
      }

      for (final filename in fileNameTranslatedString.keys) {
        try {
          // suggest that translation has structrued like this:
          // {
          // "appstore": {
          //   "name": "Learn English With SpeakFly AI",
          //   "subtitle": "Tutor - lessons and flashcards",
          //   "keywords": "flashcards, language, ai, learn language, english tutor, ai tutor, learn english",
          //   "description": "Master English, German, Spanish, French and 9 more languages effortlessly with SpeakFly! Choose from exciting topics like art, design, philosophy, and cooking for engaging lessons. Get instant feedback on grammar and pronunciation, and complete advanced homework assignments. Let SpeakFly make you a fluent language superstar! \n1. English AI tutor with voice recognition. \n2. Accelerated language learning through example phrases. \n3. The app generates phrases for your words. \n4. Check pronunciation using the built-in reader. \nLicensed Application End User License Agreement \nhttps://ludreamity.com/agreement/ \nTerms of Use \nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
          // },
          String translatedStr =
              translationsMap[os == 'ios' ? 'appstore' : 'playstore'][fileNameTranslatedString[filename]];
          await _writeToFile(content: translatedStr, path: '$dirPath/$filename');
        } catch (e) {
          print(
              '[+++error - translation string missing] - ${fileNameTranslatedString[filename]} in the file $pathToTranslationFile');
        }
      }
    }
  }
}

Future<List<FileSystemEntity>> _dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file), onDone: () => completer.complete(files));
  return completer.future;
}

enum ErrorType { noParameters, noFiles }

Future<String> _readFileAsString(String filePath) async {
  final content = await File(filePath).readAsString();
  return content;
}

Future<Map<String, dynamic>> _readFileAsMap(String filePath) async {
  final input = await File(filePath).readAsString();
  final map = jsonDecode(input);
  return map;
}

Future _writeToFile({
  required String content,
  required String path,
}) async {
  final f = await File(path).create(recursive: true);
  await f.writeAsString(content);
}

void _printErrors(ErrorType type) {
  switch (type) {
    case ErrorType.noParameters:
      stderr.writeln('''
    Error - no or wrong parameters. 
    Please input parameters:
      --jsonToArb or --arbToJson
      --path "path_to_the_directory_with_files"
    ''');
      break;

    case ErrorType.noFiles:
      stderr.writeln('''
    Error - no files in the given directory. 
    Please input parameters:
      --jsonToArb or --arbToJson
      --path "path_to_the_directory_with_files"
    ''');
      break;
  }
}

// available codes  https://docs.fastlane.tools/actions/deliver/
final Map<String, String> _dirNameFileNameIos = {
  'default': 'translations.i18n.json',
  'ar-SA': 'translations_ar.i18n.json',
  // 'cs': 'app_cs.arb',
  'de-DE': 'translations_de.i18n.json',
  'en-US': 'translations.i18n.json',
  'es-ES': 'translations_es.i18n.json',
  'fr-FR': 'translations_fr.i18n.json',
  // 'hu': 'app_hu.arb',
  // 'it': 'translations_it.i18n.json',
  'ja': 'translations_jp.i18n.json',
  // 'ko': 'app_ko.arb',
  // 'nl-NL': 'app_nl.arb',
  // 'pl': 'app_pl.arb',
  'pt-PT': 'translations_pt.i18n.json',
  // 'ro': 'app_ro.arb',
  'ru': 'translations_ru.i18n.json',
  // 'sk': 'app_sk.arb',
  // 'sv': 'app_sv.arb',
  'tr': 'translations_tr.i18n.json',
  'zh-Hans': 'translations_cn.i18n.json',
  // 'zh-Hant': 'app_zh-tw.arb',
};

// can't find available codes, issue https://github.com/fastlane/fastlane/issues/21011
final Map<String, String> _dirNameFileNameAndroid = {
  'ar': 'app_ar.arb',
  'cs-CZ': 'app_cs.arb',
  'de-DE': 'app_de.arb',
  'en-US': 'app_en.arb',
  'es-ES': 'app_es.arb',
  'fr-FR': 'app_fr.arb',
  'hu-HU': 'app_hu.arb',
  'it-IT': 'app_it.arb',
  'ja-JP': 'app_ja.arb',
  'ko-KR': 'app_ko.arb',
  'nl-NL': 'app_nl.arb',
  'pl-PL': 'app_pl.arb',
  'pt-BR': 'app_pt-br.arb',
  'ro': 'app_ro.arb',
  'ru-RU': 'app_ru.arb',
  'sk': 'app_sk.arb',
  // 'sv': 'app_sv.arb',
  'tr-TR': 'app_tr.arb',
  // 'zh_Hans': 'app_zh-cn.arb',
  'zh-TW': 'app_zh-tw.arb',
};

final Map<String, String> _fileNameTranslatedStringIos = {
  'description.txt': "description",
  'name.txt': "name",
  'subtitle.txt': "subtitle",
  'keywords.txt': "keywords",
};
