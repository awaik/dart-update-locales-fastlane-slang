import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

///

const kTranslationsDir = 'stringsDir';
const kFastlaneDir = 'updatedDir';
const kFlavor = 'flavor';
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
        fileNameTranslatedString = _fileNameTranslatedStringAndroid;
      }

      for (final filename in fileNameTranslatedString.keys) {
        try {
          String translatedStr = translationsMap[fileNameTranslatedString[filename]];
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
  'default': 'app_en.arb',
  'ar-SA': 'app_ar.arb',
  'cs': 'app_cs.arb',
  'de-DE': 'app_de.arb',
  'en-US': 'app_en.arb',
  'es-ES': 'app_es.arb',
  'fr-FR': 'app_fr.arb',
  'hu': 'app_hu.arb',
  'it': 'app_it.arb',
  'ja': 'app_ja.arb',
  'ko': 'app_ko.arb',
  'nl-NL': 'app_nl.arb',
  'pl': 'app_pl.arb',
  'pt-BR': 'app_pt-br.arb',
  'ro': 'app_ro.arb',
  'ru': 'app_ru.arb',
  'sk': 'app_sk.arb',
  'sv': 'app_sv.arb',
  'tr': 'app_tr.arb',
  'zh-Hans': 'app_zh-cn.arb',
  'zh-Hant': 'app_zh-tw.arb',
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
