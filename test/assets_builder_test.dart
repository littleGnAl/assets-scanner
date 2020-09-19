// Copyright (C) 2020 littlegnal
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:io' as io;

import 'package:assets_scanner/assets_scanner_builder.dart';
import 'package:assets_scanner/src/assets_builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _pkgName = 'pkg';

const _assets = {
  '$_pkgName|assets/alarm_white.png': '123',
  '$_pkgName|assets/arrows.png': '456',
  '$_pkgName|lib/main.dart': '',
};

const _pubspecFile = {
  '$_pkgName|pubspec.yaml': '''
  flutter:
    assets:
      - assets/
  ''',
};

void main() {
  Builder builder;
  setUp(() {
    builder = assetScannerBuilder(BuilderOptions.empty);
  });

  group('AssetsBuilder default', () {
    test('generate nothing if no assets values in pubspec.yaml', () async {
      await testBuilder(builder, <String, dynamic>{
        '$_pkgName|pubspec.yaml': '',
        ..._assets,
      }, outputs: <String, dynamic>{});
    });

    test('generate r.dart', () async {
      final dir = io.Directory.current.path;
      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        ..._pubspecFile
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'),
      });
    });

    test('generate r.dart with duplicate assets value', () async {
      final dir = io.Directory.current.path;
      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        '$_pkgName|pubspec.yaml': '''
        flutter:
          assets:
            - assets/
            - assets/
            - assets/alarm_white.png
            - assets/alarm_white.png
            - assets/alarm_white.png
            - assets/alarm_white.png
        ''',
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'),
      });
    });

    test('generate r.dart with sub assets but not define in the pubspec.yaml',
        () async {
      final dir = io.Directory.current.path;
      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        '$_pkgName|assets/sub/alarm_white.png': '123',
        ..._pubspecFile
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'),
      });
    });

    test('generate r.dart with sub assets', () async {
      final dir = io.Directory.current.path;
      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      final subPathAlarm = p.join(dir, 'assets/sub/alarm_white.png');
      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        '$_pkgName|assets/sub/alarm_white.png': '123',
        '$_pkgName|pubspec.yaml': '''
        flutter:
          assets:
            - assets/
            - assets/sub/
        ''',
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '  /// ![]($subPathAlarm)\n'
            '  static const sub_alarm_white = \'assets/sub/alarm_white.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'),
      });
    });

    test('generate r.dart with invalid package assets', () async {
      final dir = io.Directory.current.path;
      final shrineCardDark = p.join(dir,
          'packages/flutter_gallery_assets/assets/studies/shrine_card_dark.png');
      final starterCard = p.join(dir,
          'packages/flutter_gallery_assets/assets/studies/starter_card.png');

      await testBuilder(builder, <String, dynamic>{
        '$_pkgName|packages/flutter_gallery_assets/assets/studies/shrine_card_dark.png':
            '123',
        '$_pkgName|packages/flutter_gallery_assets/assets/studies/starter_card.png':
            '456',
        '$_pkgName|lib/main.dart': '',
        '$_pkgName|pubspec.yaml': '''
        flutter:
          assets:
            - packages/flutter_gallery_assets/assets/studies/shrine_card_dark.png
            - packages/flutter_gallery_assets/assets/studies/starter_card.png
        ''',
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($shrineCardDark)\n'
            '  static const flutter_gallery_assets_assets_studies_shrine_card_dark = \'packages/flutter_gallery_assets/assets/studies/shrine_card_dark.png\';\n'
            '\n'
            '  /// ![]($starterCard)\n'
            '  static const flutter_gallery_assets_assets_studies_starter_card = \'packages/flutter_gallery_assets/assets/studies/starter_card.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'),
      });
    });

    test('generate r.dart with package assets only', () async {
      await testBuilder(builder, <String, dynamic>{
        '$_pkgName|lib/main.dart': '',
        '$_pkgName|pubspec.yaml': '''
        dependencies:
          flutter_gallery_assets: ^0.2.2
        flutter:
          assets:
            - packages/flutter_gallery_assets/assets/studies/shrine_card_dark.png
            - packages/flutter_gallery_assets/assets/studies/starter_card.png
        ''',
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class FlutterGalleryAssets {\n'
            '  static const package = \'flutter_gallery_assets\';\n'
            '\n'
            '  static const assets_studies_shrine_card_dark = \'assets/studies/shrine_card_dark.png\';\n'
            '\n'
            '  static const assets_studies_starter_card = \'assets/studies/starter_card.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'),
      });
    });

    test('generate r.dart with invalid assets', () async {
      final dir = io.Directory.current.path;
      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        '$_pkgName|assets/.DS_Store': '456',
        ..._pubspecFile
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'),
      });
    });
  });

  group('generate with assets_scanner_options.yaml', () {
    test('generate nothing path not sub-path of lib/', () async {
      final optionsFile = io.File('assets_scanner_options.yaml')
        ..createSync()
        ..writeAsStringSync('path: src/lib');

      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, onLog: (l) {
        expect(l.message,
            'The custom path in assets_scanner_options.yaml should be sub-path of lib/.');
      });

      optionsFile.deleteSync();
    });

    test('generate with path: \'lib/src\'', () async {
      final dir = io.Directory.current.path;
      final optionsFile = io.File('assets_scanner_options.yaml')
        ..createSync()
        ..writeAsStringSync('path: lib/src');

      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/src/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'
            ''),
      });

      optionsFile.deleteSync();
    });

    test('generate with path: \'lib/src/sub\'', () async {
      final dir = io.Directory.current.path;
      final optionsFile = io.File('assets_scanner_options.yaml')
        ..createSync()
        ..writeAsStringSync('path: lib/src/sub');

      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/src/sub/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'
            ''),
      });

      optionsFile.deleteSync();
    });

    test('generate with className: \'CustomR\'', () async {
      final dir = io.Directory.current.path;
      final optionsFile = io.File('assets_scanner_options.yaml')
        ..createSync()
        ..writeAsStringSync('className: \'CustomR\'');

      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class CustomR {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'
            ''),
      });

      optionsFile.deleteSync();
    });

    test('generate with ignoreComment: true', () async {
      final optionsFile = io.File('assets_scanner_options.yaml')
        ..createSync()
        ..writeAsStringSync('ignoreComment: true');

      await testBuilder(builder, <String, dynamic>{
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, outputs: <String, dynamic>{
        '$_pkgName|lib/r.dart': decodedMatches('$rFileHeader\n'
            'class R {\n'
            '  static const package = \'pkg\';\n'
            '\n'
            '  static const alarm_white = \'assets/alarm_white.png\';\n'
            '\n'
            '  static const arrows = \'assets/arrows.png\';\n'
            '\n'
            '$ignoreForFile\n'
            '}\n'
            ''),
      });

      optionsFile.deleteSync();
    });
  });
}
